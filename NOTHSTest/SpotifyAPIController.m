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
static NSString *const kReleaseDatePrecisionString = @"release_date_precision";
static NSString *const kYearString = @"year";
static NSString *const kMonthString = @"month";
static NSString *const kDayString = @"day";

@interface SpotifyAPIController ()

@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSMutableArray *albums;
@property (strong, nonatomic) NSMutableArray *namesArray;
@property (strong, nonatomic) NSMutableArray *imagesUrlsArray;
@property (strong, nonatomic) NSMutableArray *albumUrlsArray;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end


@implementation SpotifyAPIController

-(instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        self.dateFormatter = [NSDateFormatter new];
    }
    
    return self;
}

#pragma mark - Fetch basic info 

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
                
                [self fetchReleaseDatefromUrl:album.infoUrl completionHandler:^(NSDate *releaseDate) {
                    
                    album.releaseDate = releaseDate;
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

#pragma mark - Fetch Date 

-(void)fetchReleaseDatefromUrl:(NSURL *)url completionHandler:(void (^)(NSDate *releaseDate))completionHandler
{
    
    NSURLSessionDataTask *fetchAlbumJson = [self.session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!error) {
            
            NSDictionary *albumJsonFeed = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            
            NSString *releaseDatePrecisionString = albumJsonFeed[@"release_date_precision"];
            
            NSString *releaseDateString = albumJsonFeed[kReleaseDateString];
            
            [self configureDateFormatter:self.dateFormatter forDatePrecision:releaseDatePrecisionString];
            
            NSDate *releaseDate = [self.dateFormatter dateFromString:releaseDateString];
            
            completionHandler(releaseDate);
            
            
        } else {
            
            NSLog(@"%@", error);
        }
        
    }];
    
    [fetchAlbumJson resume];
}

-(void)configureDateFormatter:(NSDateFormatter *)dateFormatter forDatePrecision:(NSString *)datePrecision
{
    
    if ([datePrecision isEqualToString:kYearString]) {
        
        dateFormatter.dateFormat = @"YYYY";
        
    } else if ([datePrecision isEqualToString:kMonthString]) {
        
        dateFormatter.dateFormat = @"YYYY-MM";
        
    } else if ([datePrecision isEqualToString:kDayString]) {
        
        dateFormatter.dateFormat = @"YYYY-MM-DD";
    }

}
#pragma mark - Fetch Images

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
