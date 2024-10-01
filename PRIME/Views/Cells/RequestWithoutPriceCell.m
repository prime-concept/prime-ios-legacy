//
//  RequestWithoutLriceCell.m
//  PRIME
//
//  Created by Admin on 2/9/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "RequestWithoutPriceCell.h"

@implementation RequestWithoutPriceCell

- (void)awakeFromNib {
    [super awakeFromNib];

    _labelName.textColor = kTaskTitleColor;
    _labelDescription.textColor = kTaskDescriptionColor;
    [_separatorView setBackgroundColor:kCalendarLineColor];

    [_labelName setFont: [UIFont systemFontOfSize: 20.0f]];
    [_labelDescription setFont: [UIFont systemFontOfSize: 15.0f]];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setSeparatorLineHidden:(BOOL)hidden
{
    [_separatorView setHidden:hidden];
}

@end
