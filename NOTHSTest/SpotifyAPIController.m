//
//  SpotifyAPIController.m
//  NOTHSTest
//
//  Created by Belén Molina del Campo on 14/05/2016.
//  Copyright © 2016 Belén Molina del Campo. All rights reserved.
//

#import "SpotifyAPIController.h"

@interface SpotifyAPIController ()

@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSMutableArray *albums;
@property (strong, nonatomic) NSMutableArray *namesArray;
@property (strong, nonatomic) NSMutableArray *imagesUrlsArray;
@property (strong, nonatomic) NSMutableArray *albumUrlsArray;

@end


@implementation SpotifyAPIController


- (NSArray *)fetchAlbums {
    
    self.albums = [NSMutableArray new];
    
    self.session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:@"https://api.spotify.com/v1/artists/36QJpDe2go2KgaRleHCDTp/albums?limit=50"];
    
    NSURLSessionDataTask *fetchJson = [self.session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!error) {
            
            NSDictionary *jsonFeed = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            NSArray *jsonItemsArray = jsonFeed[@"items"];
            
            for (NSDictionary *item in jsonItemsArray) {
                NSString *name = item[@"name"];
                
                NSArray *imagesArray = item[@"images"];
                NSDictionary *smallImage = imagesArray[2];
                NSURL *imageUrl = [NSURL URLWithString:smallImage[@"url"]];
                
                NSURL *albumUrl = [NSURL URLWithString:item[@"href"]];
                
                Album *newAlbum = [Album new];
                newAlbum.name = name;
                newAlbum.imageUrl = imageUrl;
                newAlbum.infoUrl = albumUrl;
                
                [self.albums addObject:newAlbum];
            }
            
            for (Album *album in self.albums) {
                
                [self fetchReleaseYearfromUrl:album.infoUrl completionHandler:^(NSString *releaseYear) {
                    
                    album.releaseYear = releaseYear;
                    NSLog(@"Name: %@, Year: %@", album.name, album.releaseYear);
                }
                 ];
            }

        } else {
            NSLog(@"%@", error);
        }
        
    }];
    
    [fetchJson resume];
    
    return self.albums;
}


-(void)fetchReleaseYearfromUrl:(NSURL *)url completionHandler:(void (^)(NSString *releaseYear))completionHandler{
    
    NSURLSessionDataTask *fetchAlbumJson = [self.session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!error) {
            
            NSDictionary *albumJsonFeed = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            NSString *releaseDate = albumJsonFeed[@"release_date"];
            NSString *releaseYear = [releaseDate substringToIndex:4];
            
            completionHandler(releaseYear);
            
        } else {
            
            NSLog(@"%@", error);
        }
        
    }];
    
    [fetchAlbumJson resume];
}

@end
