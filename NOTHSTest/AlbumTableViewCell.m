//
//  AlbumTableViewCell.m
//  NOTHSTest
//
//  Created by Belén Molina del Campo on 14/05/2016.
//  Copyright © 2016 Belén Molina del Campo. All rights reserved.
//

#import "AlbumTableViewCell.h"

@implementation AlbumTableViewCell

- (void)awakeFromNib {
    
    [self prepareCell];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)prepareForReuse {
    
    [self prepareCell];
}

- (void)prepareCell {
    
    self.separatorInset = UIEdgeInsetsZero;

    self.nameLabel.text = @"";
    self.releaseYearLabel.text = @"-";
    self.imageView.image = [UIImage imageNamed:@"default-placeholder"];
}

@end
