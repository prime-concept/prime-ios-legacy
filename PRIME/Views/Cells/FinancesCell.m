//
//  FinancesCell.m
//  PRIME
//
//  Created by Admin on 3/15/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "FinancesCell.h"

@implementation FinancesCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    _labelName.font = [UIFont boldSystemFontOfSize:17];
    _labelValue.font = [UIFont boldSystemFontOfSize:16];
    _labelAccount.font = [UIFont systemFontOfSize:15];

    _labelAccount.textColor = kAppLabelColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
