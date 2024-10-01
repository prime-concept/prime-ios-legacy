//
//  PRWGChatTaskCell.m
//  PRIME
//
//  Created by Armen on 5/2/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import "PRWGChatTaskCell.h"
#import "Constants.h"

NSInteger const kTitleLabelTopModeConstraint = 0;
NSInteger const ktitleLabelBottomModeConstraint = -9;
NSInteger const kMessageViewHideModeHeight = 0;
NSInteger const kMessageViewShowModeHeight = 30;
NSInteger const kDateLabelTopModeConstraint = 13;
NSInteger const kDateLabelBottomModeConstraint = 0;

@interface PRWGChatTaskCell()
@property (weak, nonatomic) IBOutlet UIImageView *serviceImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *messageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *clockLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bubbleImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelCenterConstraint;

@end

@implementation PRWGChatTaskCell

- (void)awakeFromNib {
    [super awakeFromNib];

    _dateLabelBottomConstraint.constant = kTitleLabelTopModeConstraint;
    _bubbleImageView.tintColor = kChatLeftBalloonImageViewColor;
    _titleLabelCenterConstraint.constant = ktitleLabelBottomModeConstraint;
}

-(void)updateCellWithData:(NSDictionary*)data
{
    NSString *imageName = [[data valueForKey:kWidgetMessageTaskLink] valueForKey:kWidgetMessageImageName];
    [_serviceImageView setImage:[UIImage imageNamed:imageName]];
    [_titleLabel setText:[[data valueForKey:kWidgetMessageTaskLink] valueForKey:kWidgetMessageTaskName]];
    [_descriptionLabel setText:[[data valueForKey:kWidgetMessageTaskLink] valueForKey:kWidgetMessageTaskDescription]];
    if (!_descriptionLabel.text || [_descriptionLabel.text isEqualToString:@""]) {
        _titleLabelCenterConstraint.constant = kTitleLabelTopModeConstraint;
    } else {
        _titleLabelCenterConstraint.constant = ktitleLabelBottomModeConstraint;
    }
    NSString *message = [[data valueForKey:kWidgetMessageTaskLink] valueForKey:kWidgetMessage];
    if (message) {
        _messageView.hidden = NO;
        _messageViewHeightConstraint.constant = kMessageViewShowModeHeight;
        _messageLabel.text = message;
        double timeStamp = ((NSNumber *)([[data valueForKey:kWidgetMessageTaskLink] valueForKey:kWidgetMessageTimestamp])).doubleValue;
        [self setTimeAndDate:timeStamp];
    } else {
        _messageView.hidden = YES;
        _messageViewHeightConstraint.constant = kMessageViewHideModeHeight;
    }
    if ([data valueForKey:kWidgetMessageFormatedDate]) {
        [_dateLabel setText:[data valueForKey:kWidgetMessageFormatedDate]];
        _dateLabelBottomConstraint.constant = kDateLabelTopModeConstraint;
    } else {
        _dateLabelBottomConstraint.constant = kDateLabelBottomModeConstraint;
        _dateLabel.text = @"";
    }
}

- (void)setTimeAndDate:(double)timestamp
{
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm"];
    _clockLabel.text = [dateFormat stringFromDate:date];
}

-(void)updateForCompactMode
{
    _messageView.hidden = YES;
    _messageViewHeightConstraint.constant = kMessageViewHideModeHeight;
    _dateLabelBottomConstraint.constant = kDateLabelBottomModeConstraint;
    _dateLabel.text = @"";
}

@end

