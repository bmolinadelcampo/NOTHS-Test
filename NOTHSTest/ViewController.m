//
//  ViewController.m
//  NOTHSTest
//
//  Created by Belén Molina del Campo on 14/05/2016.
//  Copyright © 2016 Belén Molina del Campo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITableViewDataSource, UITabBarDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *albums;
@property (strong, nonatomic) SpotifyAPIController *APIController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.APIController = [SpotifyAPIController new];

    [self.APIController fetchAlbumsWithCompletionHandler:^(NSArray *albums, NSError *error) {
        
        if (!error) {
            
            self.albums = albums;
            
            NSLog(@"Running completionHandler");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
        } else {
            
            NSLog(@"%@", error);
        }
        
    }];
}

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
                    
                    cell.imageView.image = image;
                });
            }];
        }
        
        cell.imageView.image = [UIImage imageNamed:@"default-placeholder"];
        
    } else {
        
        cell.imageView.image = currentAlbum.image;
    }
    
    return cell;
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
                        
                        [self.tableView cellForRowAtIndexPath:indexPath].imageView.image = image;
                    });
                }];

            }
        }
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

@end
