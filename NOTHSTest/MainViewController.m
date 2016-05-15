//
//  ViewController.m
//  NOTHSTest
//
//  Created by Belén Molina del Campo on 14/05/2016.
//  Copyright © 2016 Belén Molina del Campo. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController () <UITableViewDataSource, UITabBarDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *albums;
@property (strong, nonatomic) SpotifyAPIController *APIController;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

- (IBAction)showInfo:(UIBarButtonItem *)sender;

@end

@implementation MainViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self configureRefreshControl];
    
    [self styleNavigationBar];
    
    self.APIController = [SpotifyAPIController new];

    [self startDownload:self.APIController];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.albums count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"albumCell"];
    
    Album *currentAlbum = self.albums[indexPath.row];
    
    cell.nameLabel.text = currentAlbum.name;
    
    if (currentAlbum.releaseYear) {
        
        cell.releaseYearLabel.text = [NSString stringWithFormat:@"%ld", (long)currentAlbum.releaseYear];
    }
    
    if (!currentAlbum.image)
    {
        if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
        {
            [self.APIController downloadImage:currentAlbum forIndexPath:indexPath completionHandler:^(UIImage *image, NSError *error) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    cell.thumbnailImageView.image = image;
                });
            }];
        }
        
        cell.thumbnailImageView.image = [UIImage imageNamed:@"default-placeholder"];
        
    } else {
        
        cell.thumbnailImageView.image = currentAlbum.image;
    }
    
    return cell;
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

#pragma mark - Private methods

- (void)startDownload:(SpotifyAPIController *)apiController {
    
    
    [apiController fetchAlbumsWithCompletionHandler:^(NSArray *albums, NSError *error) {
        
        if (!error) {
            
            self.albums = albums;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
        } else {
            
            NSLog(@"%@", error);
            [self showErrorAlert];
        }
        
        if (!self.refreshControl.enabled) {
            
            self.refreshControl.enabled = YES;
        }
    
    }];
}

- (void)loadImagesForOnscreenRows
{
    
    NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
    
    for (NSIndexPath *indexPath in visiblePaths)
    {
        Album *album = (self.albums)[indexPath.row];
        
        if (!album.image)
        {
            [self.APIController downloadImage:album forIndexPath:indexPath completionHandler:^(UIImage *image, NSError *error) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    ((AlbumTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath]).thumbnailImageView.image = image;
                });
            }];
            
        }
    }
}

- (void)showErrorAlert
{
    
    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"It looks like there was a problem." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *tryAgainAction = [UIAlertAction actionWithTitle:@"Try again" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self startDownload:self.APIController];
    }];
    
    [errorAlert addAction:tryAgainAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [errorAlert addAction:cancelAction];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:errorAlert animated: YES completion:nil];
    });
}

- (void)configureRefreshControl
{
    self.refreshControl = [UIRefreshControl new];
    
    self.refreshControl.enabled = NO;
    [self.refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    
    [self.tableView addSubview:self.refreshControl];
}

- (void)handleRefresh:(UIRefreshControl *)refreshControl
{
    [self startDownload:self.APIController];
    [refreshControl endRefreshing];
}

- (void)styleNavigationBar
{
    UIColor *titleColor = [UIColor colorWithRed:1.00 green:0.80 blue:0.19 alpha:1.00];
    UIFont *titleFont = [UIFont fontWithName:@"CarouselambraW00-Regular" size:(28)];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowOffset = CGSizeMake(0.0f, 1.0f);
    shadow.shadowBlurRadius = 2.0f;
    shadow.shadowColor = [UIColor blackColor];
    
    NSDictionary *titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                         titleColor, NSForegroundColorAttributeName,
                                         shadow, NSShadowAttributeName,
                                         titleFont, NSFontAttributeName,
                                         nil];
    
    [self.navigationController.navigationBar setTitleTextAttributes:titleTextAttributes];
    
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];

    
    UIColor *navigationBarBackgroundColor = [UIColor colorWithRed:0.80 green:0.19 blue:0.18 alpha:1.00];
    [self.navigationController.navigationBar setBarTintColor:navigationBarBackgroundColor];
}

- (IBAction)showInfo:(UIBarButtonItem *)sender {
    
    NSString *message = @"Belén Molina del Campo \nMay 2016 \n\nThanks!";
    
    UIAlertController *infoAlertController = [UIAlertController alertControllerWithTitle:@"NOTHS Coding Test" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil];
    
    [infoAlertController addAction:dismissAction];
    
    [self presentViewController:infoAlertController animated:YES completion:nil];
}

@end
