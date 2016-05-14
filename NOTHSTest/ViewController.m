//
//  ViewController.m
//  NOTHSTest
//
//  Created by Belén Molina del Campo on 14/05/2016.
//  Copyright © 2016 Belén Molina del Campo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) NSArray *albums;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SpotifyAPIController *APIController = [SpotifyAPIController new];
    self.albums = [APIController fetchAlbums];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
