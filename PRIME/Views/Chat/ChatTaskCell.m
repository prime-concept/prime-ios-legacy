//
//  ChatTaskCell.m
//  PRIME
//
//  Created by Taron on 3/15/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "TaskIcons.h"
#import <ChatTaskCell.h>
#import <ChatUtility.h>
#import <PureLayout.h>

@interface ChatTaskCell () {
    BOOL _didSetupConstraints;
}

@property (strong, nonatomic) UIImageView* accessoryImageView;
@property (strong, nonatomic) UIImageView* balloonImageView;
@property (strong, nonatomic) TaskView* taskView;
@property (strong, nonatomic) UIView* taskMessageView;
@property (strong, nonatomic) UILabel* taskLastMessageLabel;
@property (strong, nonatomic) UILabel* dateLabel;
@property (strong, nonatomic) UILabel* guidLabel;
@property (strong, nonatomic) UIView* dateLabelWrapperView;
@property (strong, nonatomic) NSLayoutConstraint* balloonTopConstraint;
@property (strong, nonatomic) NSLayoutConstraint* descriptionLabelHeightConstraint;
@property (strong, nonatomic) UIImageView* statusImageView;
@property (strong, nonatomic) UILabel* timeLabel;
@property (assign, nonatomic) BOOL activateDescriptionLabelHeightConstraint;
@property (strong, nonatomic) NSLayoutConstraint* timeLabelRightConstraintFromSuperView;
@property (strong, nonatomic) NSLayoutConstraint* timeLabelRightConstraintFromStatusImageView;
@property (strong, nonatomic) NSLayoutConstraint* timeLabelBottomConstraint;
@property (strong, nonatomic) NSLayoutConstraint* timeLabelAlignHorizontalConstraint;

@end

CGFloat const kBalloonImageViewRightInset = 20;
CGFloat const kBalloonImageViewLeftInset = 5;
CGFloat const kBalloonTopInset = 5;
CGFloat const kIconLeftInset = 20;
CGFloat const kIconSize = 37;
CGFloat const kTopInset = 10;
CGFloat const kLeftConstraintFromIcon = 10;
CGFloat const kTaskLastMessageTop = 5;
CGFloat const kTaskLastMessageBottom = 15;
CGFloat const kCellHeaderTopMargin = 4;
CGFloat const kAllVerticalConstraintsConsts = 45;
CGFloat const kCellMinHeight = 62;
CGFloat const kTaskLastMessageLabelMaxHeight = 48;
CGFloat const kGuidLabelFontSize = 10.0f;
CGFloat const kTimeLabelRightConstraintFromSuperView = 10.0f;
CGFloat const kTimeLabelRightConstraintFromStatusImageView = 24.0f;
CGFloat const kTimeLabelBottomConstraint = 4.0f;
CGFloat const kTimeLabelHeight = 10.0f;
CGFloat const kTimeLabelWidth = 28.0f;
static NSString* const kVoiceMessagTitle = @"Voice message";

@implementation ChatTaskCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _balloonImageView = [UIImageView newAutoLayoutView];
        _balloonImageView.image = [UIImage imageNamed:@"ModernBubbleIncomingFull"];
        [_balloonImageView setTintColor:kChatLeftBalloonImageViewColor];
        [self.contentView addSubview:_balloonImageView];
        _imageViewIcon = [UIImageView newAutoLayoutView];
        _accessoryImageView = [UIImageView newAutoLayoutView];
        _nameLabel = [UILabel newAutoLayoutView];
        _descriptionLabel = [UILabel newAutoLayoutView];
        _taskView = [TaskView newAutoLayoutView];
        _guidLabel = [UILabel newAutoLayoutView];

        _taskMessageView = [UIView newAutoLayoutView];
        [_balloonImageView addSubview:_taskMessageView];
        [_balloonImageView addSubview:_taskView];
        [_balloonImageView addSubview:_guidLabel];
        [_taskView addSubview:_imageViewIcon];
        [_taskView addSubview:_nameLabel];
        [_taskView addSubview:_descriptionLabel];
        [_taskView addSubview:_accessoryImageView];

        _dateLabel = [UILabel newAutoLayoutView];
        _dateLabel.numberOfLines = 1;
        [_dateLabel setBackgroundColor:[UIColor clearColor]];
        _dateLabelWrapperView = [UIView newAutoLayoutView];
        [self.contentView addSubview:_dateLabelWrapperView];
        [_dateLabelWrapperView addSubview:_dateLabel];
        [_dateLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 5, 0, 5)];

        _statusImageView = [UIImageView newAutoLayoutView];
        [self.balloonImageView addSubview:_statusImageView];

        _timeLabel = [UILabel newAutoLayoutView];
        [_taskMessageView addSubview:_timeLabel];

        [self setNeedsUpdateConstraints];
        [self setValues];
    }

    return self;
}

- (void)setLayouts
{
    [_dateLabelWrapperView autoAlignAxisToSuperviewAxis:ALAxisVertical];

    [_dateLabelWrapperView autoPinEdgeToSuperviewEdge:ALEdgeTop
                                            withInset:kCellHeaderTopMargin];

    [_taskView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero
                                        excludingEdge:ALEdgeBottom];

    [_taskMessageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero
                                               excludingEdge:ALEdgeTop];

    [_taskView autoPinEdgeToSuperviewEdge:ALEdgeBottom
                                withInset:0
                                 relation:NSLayoutRelationGreaterThanOrEqual];

    [_balloonImageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(kBalloonTopInset, kBalloonImageViewLeftInset, 0, kBalloonImageViewRightInset)
                                                excludingEdge:ALEdgeTop];

    _balloonTopConstraint = [_balloonImageView autoPinEdge:ALEdgeTop
                                                    toEdge:ALEdgeBottom
                                                    ofView:_dateLabelWrapperView
                                                withOffset:1];

    [_imageViewIcon autoPinEdgeToSuperviewEdge:ALEdgeTop
                                     withInset:kTopInset];

    [_imageViewIcon autoPinEdgeToSuperviewEdge:ALEdgeLeft
                                     withInset:kIconLeftInset];

    [_imageViewIcon autoSetDimensionsToSize:CGSizeMake(kIconSize, kIconSize)];

    [_imageViewIcon autoPinEdgeToSuperviewEdge:ALEdgeBottom
                                     withInset:10
                                      relation:NSLayoutRelationGreaterThanOrEqual];

    [_nameLabel autoPinEdgeToSuperviewEdge:ALEdgeTop
                                 withInset:kTopInset];

    [_nameLabel autoPinEdge:ALEdgeLeft
                     toEdge:ALEdgeRight
                     ofView:_imageViewIcon
                 withOffset:kLeftConstraintFromIcon];

    [_descriptionLabel autoPinEdge:ALEdgeLeft
                            toEdge:ALEdgeRight
                            ofView:_imageViewIcon
                        withOffset:kLeftConstraintFromIcon];

    [_descriptionLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom
                                        withInset:kTopInset];

    _descriptionLabelHeightConstraint = [_descriptionLabel autoSetDimension:ALDimensionHeight
                                                                     toSize:0];
    [_descriptionLabelHeightConstraint setActive:_activateDescriptionLabelHeightConstraint];

    [_descriptionLabel autoPinEdge:ALEdgeTop
                            toEdge:ALEdgeBottom
                            ofView:_nameLabel];

    [_accessoryImageView autoPinEdgeToSuperviewEdge:ALEdgeRight
                                          withInset:15];

    [_accessoryImageView autoPinEdge:ALEdgeLeft
                              toEdge:ALEdgeRight
                              ofView:_nameLabel
                          withOffset:5.f];

    [_accessoryImageView autoPinEdge:ALEdgeLeft
                              toEdge:ALEdgeRight
                              ofView:_descriptionLabel
                          withOffset:5.f];

    [_accessoryImageView autoSetDimensionsToSize:CGSizeMake(8, 18)];

    [_accessoryImageView autoAlignAxis:ALAxisHorizontal
                      toSameAxisOfView:_taskView];

    [_statusImageView autoSetDimensionsToSize:CGSizeMake(14, 14)];

    [_statusImageView autoPinEdgeToSuperviewEdge:ALEdgeRight
                                       withInset:10];

    [_statusImageView autoPinEdgeToSuperviewEdge:ALEdgeBottom
                                       withInset:3];

    [_timeLabel autoSetDimensionsToSize:CGSizeMake(kTimeLabelWidth, kTimeLabelHeight)];
    _timeLabelBottomConstraint = [_timeLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom
                                                              withInset:kTimeLabelBottomConstraint];
    _timeLabelAlignHorizontalConstraint = [_timeLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:_statusImageView];

    _timeLabelRightConstraintFromSuperView = [_timeLabel autoPinEdgeToSuperviewEdge:ALEdgeRight
                                                                          withInset:kTimeLabelRightConstraintFromSuperView];
    _timeLabelRightConstraintFromStatusImageView = [_timeLabel autoPinEdgeToSuperviewEdge:ALEdgeRight
                                                                                withInset:kTimeLabelRightConstraintFromStatusImageView];

    [_timeLabelBottomConstraint setActive:NO];
    [_timeLabelAlignHorizontalConstraint setActive:NO];
    [_timeLabelRightConstraintFromSuperView setActive:NO];
    [_timeLabelRightConstraintFromStatusImageView setActive:NO];

    if ([PRDatabase isUserProfileFeatureEnabled:ProfileFeature_Chat_Debug]) {
        _guidLabel.hidden = NO;

        [_guidLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_taskView];
        [_guidLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kIconLeftInset];

        [_taskMessageView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_guidLabel];
    } else {
        [_taskMessageView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_taskView];
    }

    _didSetupConstraints = YES;
}

- (void)setValues
{
    _guidLabel.hidden = YES;
    _guidLabel.numberOfLines = 0;
    _guidLabel.font = [UIFont systemFontOfSize:kGuidLabelFontSize];
    _timeLabel.numberOfLines = 1;
    _timeLabel.font = [UIFont systemFontOfSize:9.0f];
    [_timeLabel setBackgroundColor:[UIColor clearColor]];
    [_timeLabel setTextColor:kChatLeftTimeLabelTextColor];
    _nameLabel.font = [UIFont systemFontOfSize:15 weight:0.2];
    _descriptionLabel.font = [UIFont systemFontOfSize:13];
    _nameLabel.textColor = [UIColor colorWithRed:45. / 255 green:46. / 255 blue:44. / 255 alpha:1];
    _descriptionLabel.textColor = [UIColor colorWithRed:77. / 255 green:77. / 255 blue:77. / 255 alpha:1];
    _accessoryImageView.image = [UIImage imageNamed:@"accessoryImage"];
    _taskView.backgroundColor = [UIColor clearColor];
    _descriptionLabel.numberOfLines = 0;
    _nameLabel.numberOfLines = 0;
    _dateLabelWrapperView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.4];
    _dateLabelWrapperView.layer.cornerRadius = 16 / 2;
    _dateLabelWrapperView.clipsToBounds = YES;
    _dateLabel.textColor = [UIColor whiteColor];
    _dateLabel.font = [UIFont systemFontOfSize:12];
    _dateLabel.text = @"";
    _dateLabel.textAlignment = NSTextAlignmentCenter;
    _statusImageView.contentMode = UIViewContentModeScaleAspectFit;
    [_statusImageView setBackgroundColor:[UIColor clearColor]];
    _statusImageView.contentMode = UIViewContentModeScaleAspectFit;
    [_statusImageView setImage:[UIImage imageNamed:kMessageStatusDeliveredIconName]];
    self.backgroundColor = [UIColor clearColor];
}

- (void)setActivateDescriptionLabelHeightConstraint:(BOOL)activateDescriptionLabelHeightConstraint
{
    if (_descriptionLabelHeightConstraint) {
        [_descriptionLabelHeightConstraint setActive:activateDescriptionLabelHeightConstraint];
    }

    _activateDescriptionLabelHeightConstraint = activateDescriptionLabelHeightConstraint;
}

- (void)updateConstraints
{
    _dateLabelWrapperView.hidden = !_needToShowHeaderView;
    _balloonTopConstraint.constant = _needToShowHeaderView ? 1 : kBalloonTopInset;

    if (_didSetupConstraints) {
        [super updateConstraints];
        return;
    }
    [self setLayouts];
    [super updateConstraints];
}

- (void)setDate:(double)timestamp
{
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    _dateLabel.text = [ChatUtility formatedDate:date];
}

- (void)setTaskInformation:(PRTasklinkTask*)task
{
    NSAssert(task, @"TaskDetailModel is nil");
    _imageViewIcon.image = [UIImage imageNamed:[TaskIcons imageNameFromTaskTypeId:task.taskType.typeId.integerValue]];
    _nameLabel.text = task.taskName;
    _descriptionLabel.text = task.taskDescription;

    self.activateDescriptionLabelHeightConstraint = [_descriptionLabel.text isEqualToString:@""];
}

- (void)setTaskLastMessageInfo:(PRMessageModel*)taskLastMessage
{
    if (!_taskLastMessageLabel) {
        _taskLastMessageLabel = [UILabel newAutoLayoutView];
        [_taskMessageView addSubview:_taskLastMessageLabel];
        [_taskLastMessageLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(kTaskLastMessageTop, kIconLeftInset, kTaskLastMessageBottom, kBalloonImageViewRightInset + 8)];
        _taskLastMessageLabel.font = [UIFont systemFontOfSize:10];
        _taskLastMessageLabel.textColor = kTaskLinkMessageTextColor;
        _taskLastMessageLabel.numberOfLines = 4;
    }

    [self setTimeLabelText:taskLastMessage];

    NSString* messageClientId = [taskLastMessage isTasklink] ? taskLastMessage.content.message.body.clientId : taskLastMessage.clientId;
    NSString* messageContent = @"";

    if ([taskLastMessage messageType] == ChatMessageType_Tasklink) {
        messageContent = taskLastMessage.content.message.body.content;
    } else if ([taskLastMessage messageType] == ChatMessageType_Voice) {
        messageContent = NSLocalizedString(kVoiceMessagTitle, nil);
    } else {
        messageContent = taskLastMessage.text;
    }

    if ([messageClientId isEqual:[ChatUtility clientIdWithPrefix]]) {
        [self setStatusImageViewHidden:NO];
        [self updateStatusImageViewForMessage:taskLastMessage];
    } else {
        [self setStatusImageViewHidden:YES];
    }
    _taskLastMessageLabel.text = messageContent;
    if ([_taskLastMessageLabel.text isEqualToString:@""] || !_taskLastMessageLabel.text) {
        [_taskLastMessageLabel removeFromSuperview];
        _taskLastMessageLabel = nil;
        _taskView.needSeparator = NO;
    } else {
        _taskView.needSeparator = YES;
    }

    [_taskView setNeedsDisplay];
}

- (CGFloat)taskCellEstimatedHeightForTask:(PRTasklinkTask*)task andMessage:(PRMessageModel*)message
{
    [self setTaskInformation:task];
    [self setTaskLastMessageInfo:message];

    CGFloat taskViewLabelsWidth = CGRectGetWidth([UIScreen mainScreen].bounds) - 120;
    CGFloat taskMessageWidth = CGRectGetWidth([UIScreen mainScreen].bounds) - 73;
    CGFloat nameHeight = [_nameLabel sizeThatFits:CGSizeMake(taskViewLabelsWidth, CGFLOAT_MAX)].height;

    CGFloat descriptionHeight = [_descriptionLabel sizeThatFits:CGSizeMake(taskViewLabelsWidth, CGFLOAT_MAX)].height;

    CGFloat taskLastMessageHeight = 0;
    if (_taskLastMessageLabel) {
        taskLastMessageHeight = [_taskLastMessageLabel sizeThatFits:CGSizeMake(taskMessageWidth, CGFLOAT_MAX)].height;
    }

    CGFloat ConstraintsHeight = _taskLastMessageLabel.text.length ? kAllVerticalConstraintsConsts : kAllVerticalConstraintsConsts - 20;
    CGFloat height = nameHeight + descriptionHeight + taskLastMessageHeight + ConstraintsHeight;
    return height < kCellMinHeight ? kCellMinHeight : height;
}

- (void)updateStatusImageViewForMessage:(PRMessageModel*)messageModel
{
    NSInteger ststus = [messageModel isTasklink] ? [messageModel getTasklinkMessageStatus] : [messageModel getMessageStatus];

    switch (ststus) {
    case MessageStatus_Sent:
        [_statusImageView setImage:[UIImage imageNamed:kMessageStatusSentIconName]];
        break;
    case MessageStatus_Reserved:
        [_statusImageView setImage:[UIImage imageNamed:kMessageStatusDeliveredIconName]];
        break;
    case MessageStatus_Seen:
        [_statusImageView setImage:[UIImage imageNamed:kMessageStatusReadIconName]];
        break;
    default: {
        if (!messageModel.isSent) {
            if (messageModel.state != (MessageState_Sending)) {
                [_statusImageView setImage:[[UIImage imageNamed:kMessageStatusInSendingIconName]
                                               imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
                [_statusImageView setTintColor:[UIColor redColor]];
            } else {
                [_statusImageView setImage:[UIImage imageNamed:kMessageStatusInSendingIconName]];
            }
        }
    } break;
    }
}

- (void)setGuid:(NSString*)guid
{
    _guidLabel.text = guid;
}

#pragma mark - Helpers

- (void)setTimeLabelText:(PRMessageModel*)messageModel
{
    if (messageModel) {
        _timeLabel.hidden = NO;

        NSDate* date = [NSDate dateWithTimeIntervalSince1970:[messageModel.timestamp longLongValue]];
        [_timeLabel setText:[ChatUtility formatedTime:date]];
    } else {
        _timeLabel.hidden = YES;
    }
}

- (void)setStatusImageViewHidden:(BOOL)hidden
{
    _statusImageView.hidden = hidden;

    [_timeLabelBottomConstraint setActive:hidden];
    [_timeLabelAlignHorizontalConstraint setActive:!hidden];
    [_timeLabelRightConstraintFromSuperView setActive:hidden];
    [_timeLabelRightConstraintFromStatusImageView setActive:!hidden];
}

@end

@implementation TaskView

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!_needSeparator) {
        CGContextClearRect(context, self.bounds);
        return;
    }
    CGContextSetAllowsAntialiasing(context, NO);
    CGContextSetRGBFillColor(context, 158. / 255, 159. / 255, 158. / 255, 1);
    CGContextClearRect(context, rect);
    CGContextFillRect(context, CGRectMake(CGRectGetMinX(self.frame) + kIconLeftInset,
                                   CGRectGetMaxY(self.frame) - 2,
                                   CGRectGetWidth(self.frame) - (kIconLeftInset + 15),
                                   1.0 / [UIScreen mainScreen].scale));
    CGContextStrokePath(context);
}

@end
