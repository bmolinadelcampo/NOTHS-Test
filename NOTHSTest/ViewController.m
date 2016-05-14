//
//  ViewController.m
//  NOTHSTest
//
//  Created by Belén Molina del Campo on 14/05/2016.
//  Copyright © 2016 Belén Molina del Campo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *albums;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SpotifyAPIController *APIController = [SpotifyAPIController new];

    [APIController fetchAlbumsWithCompletionHandler:^(NSArray *albums, NSError *error) {
        
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
    
    return cell;
}

@end
