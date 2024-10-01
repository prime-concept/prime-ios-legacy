//
//  AddRequestBaseViewController.m
//  PRIME
//
//  Created by Artak on 3/23/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "AddRequestBaseViewController.h"

@interface AddRequestBaseViewController ()

@end

@implementation AddRequestBaseViewController

- (CGRect)createAdditionalOptions:(NSArray<Option*>*)items startPosition:(CGRect)frame forView:(UIView*)superView
{
    CGFloat topMargin = 10;
    CGFloat sideMargin = 10;
    CGFloat leftOffset = 0;
    CGFloat imageSize = 0.3 * frame.size.width / 3;
    CGFloat labelSize = frame.size.width / 2 - imageSize;

    UIView* seperatorLine = [[UIView alloc] init];
    frame = CGRectMake(sideMargin, frame.size.height + topMargin, self.view.frame.size.width - 2 * sideMargin, 1);
    seperatorLine.frame = frame;
    seperatorLine.backgroundColor = kAppColor;

    [superView addSubview:seperatorLine];

    int i = 0;
    for (Option* option in items) {
        if (i % 2 != 0) {
            leftOffset = frame.size.width / 2;
        } else {
            leftOffset = 0;
        }
        UIImageView* imageView = [[UIImageView alloc] init];
        CGRect imageFrame = CGRectMake(sideMargin + leftOffset, CGRectGetMaxY(frame) + topMargin, imageSize, imageSize);
        imageView.frame = imageFrame;
        imageView.image = [UIImage imageNamed:option.imageName];
        imageView.userInteractionEnabled = YES;
        [superView addSubview:imageView];

        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] init];
        [imageView addGestureRecognizer:tap];

        switch (option.optionId) {
        case OPTION_Avia:
            [tap addTarget:self action:@selector(addAviaOption:)];
            break;
        case OPTION_VIPHall:
            [tap addTarget:self action:@selector(addViphallOption:)];
            break;
        case OPTION_Transfer:
            [tap addTarget:self action:@selector(addTransferOption:)];
            break;
        case OPTION_Hotel:
            [tap addTarget:self action:@selector(addHotelOption:)];
            break;
        case OPTION_Restoran:
            [tap addTarget:self action:@selector(addRestoranOption:)];
            break;
        case OPTION_Other:
            [tap addTarget:self action:@selector(addOtherOption:)];
            break;
        }

        UILabel* label = [[UILabel alloc] init];
        label.frame = CGRectMake(CGRectGetMaxX(imageFrame) + sideMargin, CGRectGetMinY(imageFrame) + imageSize / 4, labelSize, imageSize / 2);
        label.text = option.optionName;
        label.font = [UIFont systemFontOfSize:13];
        [superView addSubview:label];

        if (i % 2 != 0 || [items count] - 1 == i) {
            frame.origin.y = CGRectGetMaxY(imageView.frame);
        }

        ++i;
    }

    return frame;
}

#pragma mark - Options

- (void)addAviaOption:(UITapGestureRecognizer*)tap
{
}

- (void)addViphallOption:(UITapGestureRecognizer*)tap
{
}

- (void)addTransferOption:(UITapGestureRecognizer*)tap
{
}

- (void)addHotelOption:(UITapGestureRecognizer*)tap
{
}

- (void)addRestoranOption:(UITapGestureRecognizer*)tap
{
}

- (void)addOtherOption:(UITapGestureRecognizer*)tap
{
}
@end
