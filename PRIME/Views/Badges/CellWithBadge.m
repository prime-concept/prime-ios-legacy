//
//  CellWithBadge.m
//  PRIME
//
//  Created by Artak on 11/23/15.
//  Copyright © 2015 XNTrends. All rights reserved.
//

#import "CellWithBadge.h"

@implementation CellWithBadge

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void) createBadgeWithValue:(NSInteger) count{
    CGFloat kBadgeSize = 20;
    CGFloat kBadgeOfset = -5;

    if (count == 0) {
        _badge.hidden = YES;
        return;
    }
    if (_badge == nil) {
        _badge = [UILabel newAutoLayoutView];
        _badge.backgroundColor = kBadgeBackgroundColor;
        _badge.clipsToBounds = YES;
        _badge.textAlignment = NSTextAlignmentCenter;
        _badge.textColor = kBadgeTextColor;
        _badge.font = [UIFont systemFontOfSize:kBadgeFontSize];
        _badge.layer.cornerRadius = kBadgeSize / 2;
        [self.imageView addSubview:_badge];
        [_badge autoSetDimensionsToSize:CGSizeMake(kBadgeSize, kBadgeSize)];
        [_badge autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kBadgeOfset];
        [_badge autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kBadgeOfset];
    }
    _badge.hidden = NO;
    if (count > 9) {
        _badge.text = @"9+";
    } else {
        _badge.text = [NSString stringWithFormat:@"%lu", count];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if (selected) {
        _badge.backgroundColor = kBadgeBackgroundColor;
    }
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        _badge.backgroundColor = kBadgeBackgroundColor;
    }
}

@end
