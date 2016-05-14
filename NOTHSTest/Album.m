//
//  Album.m
//  NOTHSTest
//
//  Created by Belén Molina del Campo on 14/05/2016.
//  Copyright © 2016 Belén Molina del Campo. All rights reserved.
//

#import "Album.h"

@implementation Album

-(instancetype)initWithContentsOfDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    
    if (self) {
        self.name = dictionary[@"name"];
        self.imageUrl = dictionary[@"imageUrl"];
        self.infoUrl = dictionary[@"infoUrl"];
    }
    
    return self;
}

@end
