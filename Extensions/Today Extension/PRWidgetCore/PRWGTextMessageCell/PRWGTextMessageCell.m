//
//  PRWGChatTableViewCell.m
//  PRIME
//
//  Created by Armen on 4/9/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import "PRWGTextMessageCell.h"
#import "Constants.h"

static NSInteger const kDateLabelBottomConstraintForHideMode = 0;
static NSInteger const kDateLabelBottomConstraintForShowMode = 6;

@interface PRWGTextMessageCell()

@property (weak, nonatomic) IBOutlet UIImageView *messageBoobleImageView;
@property (weak, nonatomic) IBOutlet UILabel *messageTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *clockLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateLabelBottomConstraint;

@end

@implementation PRWGTextMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)updateCellWithData:(NSDictionary *)data {
    BOOL isCellLeft = ((NSNumber *)([data valueForKey:kWidgetMessageIsLeft])).boolValue;
    if (isCellLeft) {
        _messageBoobleImageView.image = [_messageBoobleImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _messageBoobleImageView.tintColor = kChatLeftBalloonImageViewColor;
        _messageTextLabel.textColor = kChatLeftMessageTextColor;
    } else {
        _messageBoobleImageView.image = [_messageBoobleImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _messageBoobleImageView.tintColor = kChatBalloonImageViewColor;
        _messageTextLabel.textColor = kChatRightMessageTextColor;
        _clockLabel.textColor = kChatRightTimeLabelTextColor;
    }
    _messageTextLabel.text = [data objectForKey:kWidgetMessageText];
    double timestamp =((NSNumber *)([data valueForKey:kWidgetMessageTimestamp])).doubleValue;
    [self setTime:timestamp];
    NSString *formattedDate = [data valueForKey:kWidgetMessageFormatedDate];
    if (formattedDate) {
        [_dateLabel setText:formattedDate];
        _dateLabelBottomConstraint.constant = kDateLabelBottomConstraintForShowMode;
    } else {
        _dateLabel.text = @"";
        _dateLabelBottomConstraint.constant = kDateLabelBottomConstraintForHideMode;
    }
}

- (void)setTime:(double)timestamp {

    NSDate* date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm"];

    _clockLabel.text = [dateFormat stringFromDate:date];
}


@end
