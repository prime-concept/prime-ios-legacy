//
//  DocumentTableViewCell.m
//  PRIME
//
//  Created by Artak on 1/31/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "DocumentTableViewCell.h"

@interface DocumentTableViewCell ()
@property (strong, nonatomic) UILabel* labelName;

@property (strong, nonatomic) UILabel* labelItemsCount;
@end

@implementation DocumentTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    _labelName = [UILabel newAutoLayoutView];
    _labelItemsCount = [UILabel newAutoLayoutView];
    [self.contentView addSubview:_labelName];
    [self.contentView addSubview:_labelItemsCount];
}

- (void)setLabelsValuesForLabelName:(NSString*)name
                    labelItemsCount:(NSString*)count
                          textColor:(UIColor*)color
{
    _labelName.text = name;
    _labelName.textColor = color;
    [_labelName autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 16, 0, 0) excludingEdge:ALEdgeRight];
    [_labelItemsCount autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0) excludingEdge:ALEdgeLeft];
    [_labelName autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:_labelItemsCount];
    _labelItemsCount.textAlignment = NSTextAlignmentRight;
    _labelItemsCount.textColor = kAppLabelColor;
    if (!count) {
        _labelItemsCount.text = @"";
        return;
    }
    _labelItemsCount.text = count;
}

@end
