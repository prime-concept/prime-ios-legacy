//
//  PRWGRequestTableViewCell.m
//  PRWidgetPrime
//
//  Created by Armen on 4/4/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import "PRWGRequestTableViewCell.h"
#import "Constants.h"

static NSInteger const kSeparatorViewBottomModeConstraint = 18.5;
static NSInteger const kSeparatorViewTopModeConstraint = 0;
static NSInteger const kPayLabelWidthInHideMode = 0;
static NSInteger const kPayLabelWidthInShowMode = 72;
static NSInteger const kTitleLabelCenterModeConstant = 0;
static NSInteger const kPayLabelCornerRadius = 5;

@interface PRWGRequestTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *typeImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *payLabel;
@property (weak, nonatomic) IBOutlet UILabel *payDateLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *payLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelCentrConstraint;

@end

@implementation PRWGRequestTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    _typeImageView.layer.masksToBounds = NO;
    _typeImageView.layer.cornerRadius = _typeImageView.frame.size.height/2;
    _dateLabel.text = @"";
    _dateLabel.hidden = YES;
    _separatorViewTopConstraint.constant = kSeparatorViewTopModeConstraint;
    _payLabel.hidden = YES;
    _payDateLabel.hidden = YES;
    _payDateLabel.textColor = kIconsColor;
    _payLabel.backgroundColor = kIconsColor;
    _payLabelWidthConstraint.constant = kPayLabelWidthInHideMode;
    _payLabel.layer.cornerRadius = kPayLabelCornerRadius;
    _payLabel.layer.masksToBounds = YES;
    _titleLabelCentrConstraint.constant = kTitleLabelCenterModeConstant;
}

- (void)updateCellWithData:(NSDictionary*)data {

    [_titleLabel setText:[data valueForKey:kWidgetMessageTaskName]];
    [_descriptionLabel setText:[data valueForKey:kWidgetMessageTaskDescription]];
    if (!_descriptionLabel || [_descriptionLabel.text isEqualToString:@""]) {
        _titleLabelCentrConstraint.constant = _titleLabel.bounds.size.height/2;
    } else {
        _titleLabelCentrConstraint.constant = kTitleLabelCenterModeConstant;
    }
    NSString *imageName = [data valueForKey:kWidgetMessageImageName];
    [_typeImageView setImage:[UIImage imageNamed:imageName]];
}

- (void)setDate:(NSDictionary*)date {

    NSDate *requestDate = [date valueForKey:kWidgetRequestDate];
    if (requestDate) {
        [_dateLabel setText:[self stringFromDate:requestDate]];
        _dateLabel.hidden = NO;
        _separatorViewTopConstraint.constant = kSeparatorViewBottomModeConstraint;
    }
}

- (void)setRequestStatus:(NSDictionary *)data
{
    NSString *progressStatus = [data valueForKey:kWidgetEventType];

    if (progressStatus) {
        NSString *headerText;

        if ([progressStatus isEqual:kWidgetEventTypeInProgress]) {
            headerText = NSLocalizedString(@"In progress", );
        } else {
            headerText = NSLocalizedString(@"To pay", );
        }

        [_dateLabel setText:headerText];
        _dateLabel.hidden = NO;
        _separatorViewTopConstraint.constant = kSeparatorViewBottomModeConstraint;
    }

    [self setPayButtonWithData:data];
}

- (void)setPayButtonWithData:(NSDictionary *)data
{
    NSString *payText = [data valueForKey:kWidgetRequestPayText];
    if (payText) {
        _payLabel.hidden = NO;
        _payDateLabel.hidden = NO;
        [_payLabel setText:payText];
        NSString *payDate = [data valueForKey:kWidgetRequestPayDate];
        [_payDateLabel setText: payDate ? payDate : @"" ];
        _payLabelWidthConstraint.constant = kPayLabelWidthInShowMode;
    } else {
        _payLabel.hidden = YES;
        _payDateLabel.hidden = YES;
        _payLabelWidthConstraint.constant = kPayLabelWidthInHideMode;
    }
}

#pragma mark - Private Functions

- (NSString *)stringFromDate:(NSDate*)date
{
    NSCalendar* calendar = [NSCalendar currentCalendar];

    if ([calendar isDateInToday:date]) {
        return NSLocalizedString(@"Today", );
    } else if ([calendar isDateInYesterday:date]) {
        return NSLocalizedString(@"Tomorrow", );
    }
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:DEFAULT_TIME_FORMAT];

    return [formatter stringFromDate:date];
}

@end
