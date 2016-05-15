//
//  Album.h
//  NOTHSTest
//
//  Created by Belén Molina del Campo on 14/05/2016.
//  Copyright © 2016 Belén Molina del Campo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Album : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSURL *imageUrl;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSURL *infoUrl;
@property (strong, nonatomic) NSDate *releaseDate;
@property (readonly) NSInteger releaseYear;

-(instancetype)initWithContentsOfDictionary:(NSDictionary *)dictionary;

-(NSInteger)setReleaseYear;

-(void)setReleaseDate:(NSDate *)releaseDate;

@end
