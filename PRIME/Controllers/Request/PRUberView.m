//
//  PRUberView.m
//  PRIME
//
//  Created by Nerses Hakobyan on 4/9/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "PRUberView.h"
#import "RequestsDetailViewController.h"

@interface PRUberView ()

@property (strong, nonatomic) UIImageView* uberIconImageView;

@end

@implementation PRUberView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubviews];
        [self setValues];
    }
    return self;
}

- (void)initSubviews
{
    _uberViewNameLabel = [UILabel newAutoLayoutView];
    _uberIconImageView = [UIImageView newAutoLayoutView];
    [self addSubview:_uberViewNameLabel];
    [self addSubview:_uberIconImageView];
}

- (void)setValues
{
    [_uberIconImageView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [_uberIconImageView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_uberIconImageView autoSetDimensionsToSize:CGSizeMake(22, 22)];

    [_uberViewNameLabel setTextColor:kUberLabelTextColor];
    [_uberViewNameLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [_uberViewNameLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:_uberIconImageView withOffset:8];
    [_uberViewNameLabel setFont:[UIFont systemFontOfSize:14]];
    [_uberViewNameLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self withOffset:-5];
    [_uberIconImageView setImage:[UIImage imageNamed:@"uberIcon"]];
    [_uberViewNameLabel setText:(IS_IPHONE_4 || IS_IPHONE_5) ? @"UBER" : NSLocalizedString(@"Ride there with UBER", nil)];
}

@end
