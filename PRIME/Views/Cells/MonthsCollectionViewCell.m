//
//  MonthsCollectionViewCell.m
//  PRIME
//
//  Created by Artak on 3/16/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "MonthsCollectionViewCell.h"

@implementation MonthsCollectionViewCell

- (UILabel*)labelMonth
{
    if (_labelMonth == nil) {
        _labelMonth = [UILabel newAutoLayoutView];
        [self.contentView addSubview:_labelMonth];

        [_labelMonth autoPinEdgesToSuperviewEdges];
        _labelMonth.textAlignment = NSTextAlignmentCenter;
        _labelMonth.font = [UIFont systemFontOfSize:18];
        _labelMonth.textColor = kMonthColor;
        self.backgroundColor = kTableViewHeaderColor;
    }

    return _labelMonth;
}

- (void)setDate:(NSDate*)date
{
    _date = date;
    NSDateFormatter* dateFormater = [NSDateFormatter new];
    dateFormater.dateFormat = @"MMMM yyyy";

    self.labelMonth.text = [self.date mt_stringFromDateWithFormat:@"MMMM yyyy" localized:YES];
}
@end
