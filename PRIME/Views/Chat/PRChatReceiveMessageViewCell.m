//
//  PRChatReceiveMessageViewCell.m
//  PRIME
//
//  Created by Mariam on 3/10/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRChatReceiveMessageViewCell.h"

@implementation PRChatReceiveMessageViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setUpBalloonImageView];

    self.timeLabel.textAlignment = NSTextAlignmentRight;
    self.timeLabel.textColor = kChatLeftTimeLabelTextColor;
    self.messageLabel.textColor = kChatLeftMessageTextColor;
}

- (void)setUpBalloonImageView
{
    [self.balloonImageView setImage:[UIImage imageNamed:@"ModernBubbleIncomingFull"]];
    [self.balloonImageView setTintColor:kChatLeftBalloonImageViewColor];
}

@end
