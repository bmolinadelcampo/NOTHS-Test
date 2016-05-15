//
//  SpotifyAPIController.m
//  NOTHSTest
//
//  Created by Belén Molina del Campo on 14/05/2016.
//  Copyright © 2016 Belén Molina del Campo. All rights reserved.
//

#import "SpotifyAPIController.h"

static NSString *const kAlbumFeedUrl = @"https://api.spotify.com/v1/artists/36QJpDe2go2KgaRleHCDTp/albums?limit=50";

static NSString *const kItemsString = @"items";
static NSString *const kNameString = @"name";
static NSString *const kImagesString = @"images";
static NSString *const kUrlString = @"url";
static NSString *const kHrefString = @"href";
static NSString *const kReleaseDateString = @"release_date";

@interface SpotifyAPIController ()

@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSMutableArray *albums;
@property (strong, nonatomic) NSMutableArray *namesArray;
@property (strong, nonatomic) NSMutableArray *imagesUrlsArray;
@property (strong, nonatomic) NSMutableArray *albumUrlsArray;

@end


@implementation SpotifyAPIController


- (void)fetchAlbumsWithCompletionHandler: (void (^)(NSArray *albums, NSError *error))completionHandler
{

    self.albums = [NSMutableArray new];
    
    self.session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:kAlbumFeedUrl];
    
    NSURLSessionDataTask *fetchJson = [self.session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!error) {
            
            NSDictionary *jsonFeed = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            NSArray *jsonItemsArray = jsonFeed[kItemsString];
            
            for (NSDictionary *item in jsonItemsArray) {
                
                NSString *name = item[kNameString];
                
                NSArray *imagesArray = item[kImagesString];
                NSDictionary *smallImage = imagesArray[2];
                NSURL *imageUrl = [NSURL URLWithString:smallImage[kUrlString]];
                
                NSURL *albumUrl = [NSURL URLWithString:item[kHrefString]];
                
                NSDictionary *albumInfo = [NSDictionary dictionaryWithObjectsAndKeys:name, @"name", imageUrl, @"imageUrl", albumUrl, @"infoUrl", nil];
                
                Album *newAlbum = [[Album alloc] initWithContentsOfDictionary:albumInfo];
                
                [self.albums addObject:newAlbum];
            }
            
            __block int count = 0;
            
            for (Album *album in self.albums) {
                
                [self fetchReleaseYearfromUrl:album.infoUrl completionHandler:^(NSString *releaseYear) {
                    
                    album.releaseYear = releaseYear;
                    NSLog(@"Name: %@, Year: %@", album.name, album.releaseYear);
                    count++;
                    if (count == [self.albums count]) {
                        completionHandler(self.albums, nil);
                    }
                }
                 ];
            }

        } else {
            
            NSLog(@"%@", error);
            completionHandler(nil, error);
        }
        
    }];
    
    [fetchJson resume];
    
    return;
}


-(void)fetchReleaseYearfromUrl:(NSURL *)url completionHandler:(void (^)(NSString *releaseYear))completionHandler
{
    
    NSURLSessionDataTask *fetchAlbumJson = [self.session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!error) {
            
            NSDictionary *albumJsonFeed = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            NSString *releaseDate = albumJsonFeed[kReleaseDateString];
            NSString *releaseYear = [releaseDate substringToIndex:4];
            
            completionHandler(releaseYear);
            
        } else {
            
            NSLog(@"%@", error);
        }
        
    }];
    
    [fetchAlbumJson resume];
}

- (void)downloadImage:(Album *)album forIndexPath:(NSIndexPath *)indexPath completionHandler:(void (^)(UIImage *image, NSError *error))completionHandler
{
    
    NSURLSessionDataTask *loadimages = [[NSURLSession sharedSession] dataTaskWithURL:album.imageUrl completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!error) {
            
            UIImage *albumImage = [UIImage imageWithData:data];
            album.image = albumImage;

            completionHandler(albumImage, nil);
            
        } else {
            
            completionHandler(nil, error);
        }
    }];
    
    [loadimages resume];
}

@end
