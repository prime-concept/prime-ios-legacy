//
//  PRChatSendMessageViewCell.m
//  PRIME
//
//  Created by Mariam on 3/10/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRChatSendMessageViewCell.h"
#import <ChatUtility.h>
#import <NSDate+MTDates.h>

@interface PRChatSendMessageViewCell ()

@end

@implementation PRChatSendMessageViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setUpBalloonImageView];

    self.messageLabel.textColor = kChatRightMessageTextColor;

    self.timeLabel.textAlignment = NSTextAlignmentRight;
    self.timeLabel.textColor = kChatRightTimeLabelTextColor;
}

- (void)setUpBalloonImageView
{
    [self.balloonImageView setImage:[UIImage imageNamed:@"ModernBubbleOutgoingFull"]];
    [self.balloonImageView setTintColor:kChatBalloonImageViewColor];
}

@end
