//
//  SpotifyAPIController.h
//  NOTHSTest
//
//  Created by Belén Molina del Campo on 14/05/2016.
//  Copyright © 2016 Belén Molina del Campo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Album.h"

@interface SpotifyAPIController : NSObject

-(instancetype)init;

- (void)fetchAlbumsWithCompletionHandler:(void (^)(NSArray *albums, NSError *error))completionHandler;

- (void)downloadImage:(Album *)album forIndexPath:(NSIndexPath *)indexPath completionHandler:(void (^)(UIImage *image, NSError *error))completionHandler;

@end
