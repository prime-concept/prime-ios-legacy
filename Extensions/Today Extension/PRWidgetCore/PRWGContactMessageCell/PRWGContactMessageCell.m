//
//  PRWGContactMessageCell.m
//  PRIME
//
//  Created by Armen on 5/24/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import "PRWGContactMessageCell.h"
#import "Constants.h"
#import "PRWGCacheManager.h"
@import Contacts;

static NSInteger const kDateLabelBottomConstraintForHideMode = 0;
static NSInteger const kDateLabelBottomConstraintForShowMode = 6;

@interface PRWGContactMessageCell()

@property (weak, nonatomic) IBOutlet UIImageView *balloonImageView;
@property (weak, nonatomic) IBOutlet UIImageView *contactImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *surnameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *clockLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateLabelBottomConstraint;

@end

@implementation PRWGContactMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)updateCellWithData:(NSDictionary *)data {
    BOOL isCellLeft = ((NSNumber *)([data valueForKey:kWidgetMessageIsLeft])).boolValue;
    if (isCellLeft) {
        _balloonImageView.image = [_balloonImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _balloonImageView.tintColor = kChatLeftBalloonImageViewColor;
        [_nameLabel setTextColor:kLeftContactMessageButtonColor];
        [_surnameLabel setTextColor:kLeftContactMessageButtonColor];
    } else {
        _balloonImageView.image = [_balloonImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _balloonImageView.tintColor = kChatBalloonImageViewColor;
        _clockLabel.textColor = kChatRightTimeLabelTextColor;
        [_nameLabel setTextColor:kRightContactMessageButtonColor];
        [_surnameLabel setTextColor:kRightContactMessageButtonColor];
    }
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
    NSString *fileName = [[data valueForKey:@"text"] stringByReplacingOccurrencesOfString:@"/chat.private/" withString:@""];
    NSData *contactData = [PRWGCacheManager getFileDataFromCache:fileName];
    CNContact *contact = [NSKeyedUnarchiver unarchiveObjectWithData:contactData];
    [_nameLabel setText:[contact givenName]];
    [_surnameLabel setText:[contact familyName]];
    UIImage *avatarImage = ([UIImage imageWithData:[contact thumbnailImageData]]) ?[UIImage imageWithData:[contact thumbnailImageData]] :[UIImage imageWithData:[contact imageData]];
    if(avatarImage)
    {
        [_contactImageView setImage:avatarImage];
    }
    else
    {
        avatarImage = [UIImage imageNamed:@"avatar"];
        avatarImage = [avatarImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_contactImageView setImage:avatarImage];
        ((NSNumber *)([data valueForKey:kWidgetMessageIsLeft])).boolValue ? [_contactImageView setTintColor:kLeftContactMessageSeperatorColor] : [_contactImageView setTintColor:kRightContactMessageButtonColor];
    }
}

- (void)setTime:(double)timestamp {

    NSDate* date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm"];

    _clockLabel.text = [dateFormat stringFromDate:date];
}

@end
