//
//  EditContactCell.m
//  PRIME
//
//  Created by Taron on 3/30/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "EditContactCell.h"


@implementation EditContactCell


- (void)awakeFromNib
{
    [super awakeFromNib];

    [[UITextField appearance] setFont:[UIFont systemFontOfSize:16]];
    _labelInfoName.font = [UIFont systemFontOfSize:13];
    _labelInfoName.textColor = kProfileInfoNameColor;
    _textFieldForPicker = [UIPickerTextField new];
    [self.contentView insertSubview:_textFieldForPicker atIndex:0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state.
}

- (void)drawRect:(CGRect)rect
{
    if (!_needToShowSeperator) {
        return;
    }
    static const CGFloat marginFromArrow = 5;
    static const CGFloat marginFromCellSeperators = 4;

    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetAllowsAntialiasing(context, NO);
    CGContextSetStrokeColorWithColor(context, kAppLabelColor.CGColor);

    CGFloat xPosition = CGRectGetMaxX(_imageViewArrow.frame) + marginFromArrow;
    CGContextSetLineWidth(context, 1.0 / [UIScreen mainScreen].scale);
    CGContextMoveToPoint(context, xPosition, marginFromCellSeperators);
    CGContextAddLineToPoint(context, xPosition, CGRectGetMaxY(rect) - marginFromCellSeperators);

    CGContextStrokePath(context);
}

-(UITextField*)getTextField{
    return nil;
}


@end
