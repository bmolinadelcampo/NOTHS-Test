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
@property BOOL pullToRefreshEnabled;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pullToRefreshEnabled = NO;
    
    self.APIController = [SpotifyAPIController new];

    [self startDownload:self.APIController];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.albums count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"albumCell"];
    
    Album *currentAlbum = self.albums[indexPath.row];
    
    cell.nameLabel.text = currentAlbum.name;
    cell.releaseYearLabel.text = currentAlbum.releaseYear;
    
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
            
            NSLog(@"Running completionHandler");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
        } else {
            
            NSLog(@"%@", error);
            [self showErrorAlert];
        }
        
        self.pullToRefreshEnabled = YES;
        
        
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

- (void)showErrorAlert {
    
    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"It looks like there was a problem." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *tryAgainAction = [UIAlertAction actionWithTitle:@"Try again" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self startDownload:self.APIController];
    }];
    
    [errorAlert addAction:tryAgainAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Cancel");
    }];
    
    [errorAlert addAction:cancelAction];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:errorAlert animated: YES completion:nil];
    });
}

- (void)handleRefresh:(UIRefreshControl *)refreshControl {
    
    if (self.pullToRefreshEnabled) {
        [self startDownload:self.APIController];
    }
    
    [refreshControl endRefreshing];
}
@end
