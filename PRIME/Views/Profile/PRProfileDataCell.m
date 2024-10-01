//
//  ProfileTableViewCell.m
//  PRIME
//
//  Created by Aram on 1/20/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRProfileDataCell.h"

@implementation PRProfileDataCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    _cellTitle.font = [UIFont systemFontOfSize:16 weight:UIFontWeightUltraLight];
    [_cellImage setTintColor:kSegmentedControlTaskStatusColor];
}

- (void)configureCellByText:(NSString*)text andImage:(UIImage*)image
{
    _cellTitle.text = text;
    _cellImage.image = image;
}

@end
