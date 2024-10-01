//
//  PRWGPhotoMessageCell.m
//  PRIME
//
//  Created by Armen on 5/22/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import "PRWGPhotoMessageCell.h"
#import "PRWGCacheManager.h"
#import "Constants.h"

@interface PRWGPhotoMessageCell()

@property (weak, nonatomic) IBOutlet UIImageView *balloonImageView;
@property (weak, nonatomic) IBOutlet UIImageView *messageImageView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *clockLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *defaultVideoImageView;

@end

static NSInteger const kDateLabelBottomConstraintForHideMode = 0;
static NSInteger const kDateLabelBottomConstraintForShowMode = 6;

@implementation PRWGPhotoMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

-(void)updateCellWithData:(NSDictionary*)data
{
    double timestamp =((NSNumber *)([data valueForKey:kWidgetMessageTimestamp])).doubleValue;
    [self setTimeAndDate:timestamp];
    BOOL isCellLeft = ((NSNumber *)([data valueForKey:kWidgetMessageIsLeft])).boolValue;
    if (isCellLeft) {
        _balloonImageView.image = [_balloonImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _balloonImageView.tintColor = kChatLeftBalloonImageViewColor;;
        _dateLabelBottomConstraint.constant = kDateLabelBottomConstraintForHideMode;
        if(_defaultVideoImageView)
        {
            [_defaultVideoImageView setTintColor:kChatLeftTimeLabelTextColor];
        }
        _clockLabel.textColor = kChatLeftTimeLabelTextColor;
    } else {
        _balloonImageView.image = [_balloonImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _balloonImageView.tintColor = kChatBalloonImageViewColor;
        if(_defaultVideoImageView)
        {
            [_defaultVideoImageView setTintColor:kChatRightTimeLabelTextColor];
        }
        _clockLabel.textColor = kChatRightTimeLabelTextColor;
    }
    if ([data valueForKey:kWidgetMessageFormatedDate]) {
        [_dateLabel setText:[data valueForKey:kWidgetMessageFormatedDate]];
        _dateLabelBottomConstraint.constant = kDateLabelBottomConstraintForShowMode;
    } else {
        _dateLabelBottomConstraint.constant = kDateLabelBottomConstraintForHideMode;
        _dateLabel.text = @"";
    }
    NSString *fileName = [[data valueForKey:@"text"] stringByReplacingOccurrencesOfString:@"/chat.private/" withString:@""];
    [_messageImageView setImage:[UIImage imageWithData:[PRWGCacheManager getFileDataFromCache:fileName]]];
}

- (void)setTimeAndDate:(double)timestamp {
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm"];

    _clockLabel.text = [dateFormat stringFromDate:date];
}

@end
