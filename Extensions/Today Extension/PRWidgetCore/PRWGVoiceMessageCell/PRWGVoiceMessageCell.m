//
//  PRWGSentVoiceCell.m
//  PRIME
//
//  Created by Armen on 4/27/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import "PRWGVoiceMessageCell.h"
#import "Constants.h"

@interface PRWGVoiceMessageCell()
@property (weak, nonatomic) IBOutlet UIImageView *bubbleImageView;
@property (weak, nonatomic) IBOutlet UILabel *clockLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateLabelBottomConstraint;

@end

@implementation PRWGVoiceMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

-(void)updateCellWithData:(NSDictionary*)data {
    double timestamp =((NSNumber *)([data valueForKey:kWidgetMessageTimestamp])).doubleValue;
    [self setTimeAndDate:timestamp];
    BOOL isCellLeft = ((NSNumber *)([data valueForKey:kWidgetMessageIsLeft])).boolValue;
    if (isCellLeft) {
        _bubbleImageView.image = [_bubbleImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _bubbleImageView.tintColor = kChatLeftBalloonImageViewColor;
        _durationLabel.textColor = kChatLeftMessageTextColor;
        _dateLabelBottomConstraint.constant = 0;
    } else {
        _bubbleImageView.image = [_bubbleImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _bubbleImageView.tintColor = kChatBalloonImageViewColor;
        _durationLabel.textColor = kChatRightMessageTextColor;
        _clockLabel.textColor = kChatRightTimeLabelTextColor;
    }
    if ([data valueForKey:kWidgetMessageFormatedDate]) {
        [_dateLabel setText:[data valueForKey:kWidgetMessageFormatedDate]];
        _dateLabelBottomConstraint.constant = 13;
    } else {
        _dateLabelBottomConstraint.constant = 0;
        _dateLabel.text = @"";
    }
    _durationLabel.text = [data valueForKey:kWidgetMessageDuration] ? [data valueForKey:kWidgetMessageDuration] : @"";
}

- (void)setTimeAndDate:(double)timestamp {

    NSDate* date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm"];

    _clockLabel.text = [dateFormat stringFromDate:date];
}

@end
