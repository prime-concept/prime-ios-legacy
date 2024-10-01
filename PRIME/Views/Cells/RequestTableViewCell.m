//
//  RequestTableViewCell.m
//  PRIME
//
//  Created by Admin on 1/30/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "RequestTableViewCell.h"

@implementation RequestTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    [_labelName setTextColor:kTaskTitleColor];
    [_labelDescription setTextColor:kTaskDescriptionColor];
    [_buttonPay setTitleColor:kPayButtonTextColor forState:UIControlStateNormal];
    [_buttonPay setBackgroundColor:kPayButtonBackgroundColor];
    [_labelDueDate setTextColor:[UIColor redColor]];
    [_separatorView setBackgroundColor:kCalendarLineColor];

    [_buttonPay.layer setCornerRadius:6];

    [_labelName setFont:[UIFont systemFontOfSize:20.0f]];
    [_labelDescription setFont:[UIFont systemFontOfSize:15.0f]];

    [_labelDueDate setFont:[UIFont systemFontOfSize:7.0f]];
    [_buttonPay.titleLabel setFont:[UIFont systemFontOfSize:11.0f]];

    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    //[self setStyle];
    //[self initTapRecognizer];
}

- (IBAction)buttonPayPressed:(id)sender
{
    [PRGoogleAnalyticsManager sendEventWithName:kTaskPayButtonClicked parameters:nil];
    [_delegate pay:[self paymentLink] withSender:sender];
}

-(void)setSeparatorLineHidden:(BOOL)hidden
{
    [_separatorView setHidden:hidden];
}

@end
