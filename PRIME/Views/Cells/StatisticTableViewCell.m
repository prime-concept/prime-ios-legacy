//
//  StatisticTableViewCell.m
//  PRIME
//
//  Created by Artak on 3/17/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "StatisticTableViewCell.h"

@implementation StatisticTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    _progressBarHeigth = 18;
    _progressSize = 0.7;
    _leftMargin = 15;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)drawRect:(CGRect)rect
{
    if (_needToDrawProgerss) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        [self drawBackground:context withFrame:rect];
        [self drawProgressBackground:context withFrame:rect];
        [self drawProgress:context withFrame:rect];
    }
}

- (void)drawProgressBackground:(CGContextRef)context withFrame:(CGRect)frame
{

    CGRect progressRect = CGRectMake(_leftMargin, 0, frame.size.width - _leftMargin, _progressBarHeigth);
    UIBezierPath* roundedRect = [UIBezierPath bezierPathWithRect:progressRect];
    CGContextSetFillColorWithColor(context, kTableViewHeaderColor.CGColor);
    [roundedRect fill];
}

- (void)drawBackground:(CGContextRef)context withFrame:(CGRect)frame
{

    CGRect progressRect = CGRectMake(_leftMargin, 0, (frame.size.width - _leftMargin) * _progressSize, frame.size.height);
    UIBezierPath* roundedRect = [UIBezierPath bezierPathWithRect:progressRect];
    CGContextSetFillColorWithColor(context, kExpenseBackgroundColor.CGColor);
    [roundedRect fill];
}

- (void)drawProgress:(CGContextRef)context withFrame:(CGRect)frame
{

    CGRect progressRect = CGRectMake(_leftMargin, 0, (frame.size.width - _leftMargin) * _progressSize, _progressBarHeigth);
    UIBezierPath* roundedRect = [UIBezierPath bezierPathWithRect:progressRect];
    CGContextSetFillColorWithColor(context, _progressBarColor.CGColor);
    [roundedRect fill];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
}
@end
