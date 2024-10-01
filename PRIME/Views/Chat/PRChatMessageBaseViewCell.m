//
//  PRChatMessageBaseViewCell.m
//  PRIME
//
//  Created by Mariam on 3/10/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRChatMessageBaseViewCell.h"
#import <ChatUtility.h>
#import <NSDate+MTDates.h>

@interface PRChatMessageBaseViewCell ()

@property (weak, nonatomic) IBOutlet UILabel* guidLabel;
@property (weak, nonatomic) IBOutlet UIButton* resendMessageButton;
@property (weak, nonatomic) IBOutlet UIImageView* statusImageView;
@property (nonatomic, weak) IBOutlet UILabel* dateLabel;
@property (nonatomic, weak) IBOutlet UIView* dateLabelWrapperView;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint* messageViewResizableConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* headerViewHeightConstraint;

@end

static const CGFloat _balloonMarginLarge = 40;
static const CGFloat _balloonMarginSmall = 5;
static const CGFloat _balloonMarginWithCellHeader = 1;
static const CGFloat _dateLabelHeigth = 10;
static const CGFloat _messageViewMarginBottom = 10;
static const CGFloat _messageViewMarginTop = 10;
static const CGFloat _messageViewMarginSideLarge = 71;
static const CGFloat _messageViewMarginSideSmall = 10;
static const CGFloat _headerLabelHeigth = 16;
static const CGFloat kGuidLabelFontSize = 10.0f;
static const CGFloat kLeftCellMessageLabelBottomConstraint = 13.0f;
static const CGFloat kRightCellMessageLabelBottomConstraint = 10.0f;

static NSString* const kLeftCellIdentifier = @"PRChatReceiveMessageViewCell";

#define kNotSentMessageTimeLabelTextColor [UIColor colorWithRed:220. / 255 green:69. / 255 blue:70. / 255 alpha:1]

@implementation PRChatMessageBaseViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self localInit];
}

#pragma mark - Configuration

- (void)localInit
{
    [self setUpHeaderDateView];
    [self setUpMessageLabel];
    [self setUpStatusImageView];
    _timeLabel.font = [UIFont systemFontOfSize:9];
}

- (void)setUpHeaderDateView
{
    _dateLabelWrapperView.backgroundColor = kDateLabelWrapperViewBackgroundColor;
    _dateLabelWrapperView.layer.cornerRadius = _headerLabelHeigth / 2;
    _dateLabelWrapperView.clipsToBounds = YES;

#ifdef PrimeRRClub
    _dateLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1];
#elif PrimeClubConcierge
    _dateLabel.textColor = [UIColor colorWithRed:199. / 255 green:201. / 255 blue:204. / 255 alpha:1.0];
#else
    _dateLabel.textColor = [UIColor whiteColor];
#endif
    _dateLabel.font = [UIFont systemFontOfSize:12];
}

- (void)setUpMessageLabel
{
    _messageLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink | NSTextCheckingTypePhoneNumber;
    _messageLabel.numberOfLines = 0;
    _messageLabel.userInteractionEnabled = YES;
    _messageLabel.extendsLinkTouchArea = YES;
    _messageLabel.delegate = self;
    _messageLabel.textColor = kChatRightMessageTextColor;
    _messageLabel.font = [UIFont systemFontOfSize:15];
    _guidLabel.font = [UIFont systemFontOfSize:kGuidLabelFontSize];
    _guidLabel.numberOfLines = 0;
}

#pragma mark - Public Methods

- (void)setDate:(double)timestamp
{
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:timestamp];

    _timeLabel.text = [ChatUtility formatedTime:date];
    _dateLabel.text = [ChatUtility formatedDate:date];
}

- (void)setMessageText:(NSString*)text messageGuid:(NSString*)guid
{
    _messageLabel.text = text;
    _guidLabel.text = nil;

    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds) - _messageViewMarginSideSmall - _messageViewMarginSideLarge - _balloonMarginSmall;
    _estimatedCellSize = [_messageLabel sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];

    if (width - _estimatedCellSize.width > _balloonMarginLarge) {
        _messageViewResizableConstraint.constant = width - _estimatedCellSize.width;
    } else {
        _messageViewResizableConstraint.constant = _balloonMarginLarge;
    }
    _estimatedCellSize.height += 2 * _dateLabelHeigth + _messageViewMarginTop + _messageViewMarginBottom;
    _estimatedCellSize.height += _headerViewHeightConstraint.constant;
    _estimatedCellSize.height += _balloonMarginWithCellHeader;

    if (_needToShowHeaderView) {
        _estimatedCellSize.height += _headerLabelHeigth;
    }

    if ([PRDatabase isUserProfileFeatureEnabled:ProfileFeature_Chat_Debug]) {
        _guidLabel.text = guid;
        CGSize guidTextSize = [_guidLabel sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
        CGFloat leftSpace = width - guidTextSize.width;

        if ((leftSpace < _messageViewResizableConstraint.constant)) {
            if ((leftSpace >= _balloonMarginLarge)) {
                _messageViewResizableConstraint.constant = leftSpace;
            } else {
                _messageViewResizableConstraint.constant = _balloonMarginLarge;
            }
        }
    }
}

- (void)createResendButton
{
    [_resendMessageButton addTarget:self.viewDelegate
                             action:@selector(openResendMessageMenu:)
                   forControlEvents:UIControlEventTouchUpInside];

    _balloonRightConstraint.constant = 35;
    [_resendMessageButton setHidden:NO];

    UIImage* tmpImage = [[UIImage imageNamed:@"message_resend"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [_resendMessageButton setImage:tmpImage forState:UIControlStateNormal];
}

- (void)deleteResendButton
{
    if (_resendMessageButton && self.balloonRightConstraint) {
        _balloonRightConstraint.constant = 5;
        _resendMessageButton.hidden = YES;
    }
}

- (void)statusSendingGrayIndicator
{
    [_statusImageView setImage:[UIImage imageNamed:kMessageStatusInSendingIconName]];
    [_timeLabel setTextColor:kChatRightTimeLabelTextColor];
}

- (void)statusSendingRedIndicator
{
    [_statusImageView setImage:[[UIImage imageNamed:kMessageStatusInSendingIconName]
                                   imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [_statusImageView setTintColor:[UIColor redColor]];
    [_timeLabel setTextColor:kNotSentMessageTimeLabelTextColor];
}

- (void)statusSent
{
    [_statusImageView setImage:[UIImage imageNamed:kMessageStatusSentIconName]];
    [_timeLabel setTextColor:kChatRightTimeLabelTextColor];
}

- (void)statusReserved
{
    [_statusImageView setImage:[UIImage imageNamed:kMessageStatusDeliveredIconName]];
    [_timeLabel setTextColor:kChatRightTimeLabelTextColor];
}

- (void)statusRead
{
    [_statusImageView setImage:[UIImage imageNamed:kMessageStatusReadIconName]];
    [_statusImageView setTintColor:kChatStatusReadColor];
    [_timeLabel setTextColor:kChatRightTimeLabelTextColor];
}

#pragma mark - Private Methods

- (void)updateConstraints
{
    _dateLabelWrapperView.hidden = !_needToShowHeaderView;
    _headerViewHeightConstraint.constant = _needToShowHeaderView ? _headerLabelHeigth : 0;

    [super updateConstraints];
}

- (NSInteger)resendMessageButtonTag
{
    return _resendMessageButton.tag;
}

- (void)setResendMessageButtonTag:(NSInteger)resendMessageButtonTag
{
    _resendMessageButton.tag = resendMessageButtonTag;
}

- (void)setUpStatusImageView
{
    _statusImageView.contentMode = UIViewContentModeScaleAspectFit;
    [_statusImageView setImage:[UIImage imageNamed:kMessageStatusDeliveredIconName]];
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel*)label
    didSelectLinkWithURL:(NSURL*)url
{
    [[UIApplication sharedApplication] openURL:url];
}

- (void)attributedLabel:(TTTAttributedLabel*)label
    didSelectLinkWithPhoneNumber:(NSString*)phoneNumber
{
    NSString* phoneNumberToCall = [@"telprompt://" stringByAppendingString:phoneNumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumberToCall]];
}

@end
