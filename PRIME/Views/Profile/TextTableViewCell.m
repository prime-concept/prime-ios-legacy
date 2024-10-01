//
//  TextTableViewCell.m
//  PRIME
//
//  Created by Admin on 1/31/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "TextTableViewCell.h"

@implementation TextTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    _labelText.textColor = kIconsColor;
    [_plusImageView setTintColor:kIconsColor];
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (TextTableViewCell*)configureCellByText:(NSString*)text andImage:(UIImage*)image
{
    [_labelText setText:text];
    [_plusImageView setImage:image];

    return self;
}

@end
