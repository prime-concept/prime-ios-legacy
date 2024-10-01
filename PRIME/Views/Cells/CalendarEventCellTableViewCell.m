//
//  CalendarEventCellTableViewCell.m
//  PRIME
//
//  Created by Artak on 1/29/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "CalendarEventCellTableViewCell.h"

@interface CalendarEventCellTableViewCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint* uberLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView* lineView;
@property (weak, nonatomic) IBOutlet UIView* uberView;
@property (weak, nonatomic) IBOutlet UIImageView* uberImageView;
@property (strong, nonatomic) UILabel* uberNameLabel;
@property (strong, nonatomic) UILabel* uberTimeLabel;

@end

@implementation CalendarEventCellTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    UIFont* const kLabelsFont = [UIFont systemFontOfSize:13.0f];
    UIFont* const kDateLabelsFont = [UIFont systemFontOfSize:12.0f];

    _labelStartDate.font = kDateLabelsFont;
    _labelEndDate.font = kDateLabelsFont;
    _labelEndDate.textColor = kAppLabelColor;
    _labelName.font = [UIFont systemFontOfSize:15.0f];
    _labelName.textColor = [UIColor blackColor];
    _labelNote.font = kLabelsFont;
    _labelNote.textColor = kAppLabelColor;

    _uberNameLabel = [UILabel newAutoLayoutView];
    _uberTimeLabel = [UILabel newAutoLayoutView];
    [_uberView addSubview:_uberNameLabel];
    [_uberView addSubview:_uberTimeLabel];

    _uberNameLabel.text = [self uberText];

    CGRect labelTextSize = [_uberNameLabel.text boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.frame), FLT_MAX)
                                                             options:NSStringDrawingUsesLineFragmentOrigin
                                                          attributes:@{ NSFontAttributeName : kLabelsFont }
                                                             context:nil];

    [[_uberNameLabel autoSetDimension:ALDimensionWidth toSize:CGRectGetWidth(labelTextSize)] setPriority:UILayoutPriorityDefaultHigh];
    [_uberNameLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeRight];

    [_uberTimeLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeLeft];
    [_uberTimeLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:_uberNameLabel withOffset:6.f];

    _uberNameLabel.font = kLabelsFont;
    _uberNameLabel.textColor = [UIColor colorWithRed:190. / 255 green:161. / 255 blue:118. / 255 alpha:1];
    _uberTimeLabel.font = kLabelsFont;
    _uberTimeLabel.textColor = [UIColor colorWithRed:211. / 255 green:188. / 255 blue:164. / 255 alpha:1];

    _uberImageView.image = [UIImage imageNamed:@"uberIcon"];
    _uberImageView.hidden = YES;
    _uberView.hidden = YES;
    _lineView.backgroundColor = kCalendarEventLineColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected) {
        _lineView.backgroundColor = kCalendarEventLineColor;
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        _lineView.backgroundColor = kCalendarEventLineColor;
    }
}

static CGFloat const kUberLabelBottomConstraint = 23.0f;
static CGFloat const kHiddenUberLabelBottomConstraint = 3.0f;

#pragma mark - Setup UBER View

- (void)hideUber:(BOOL)hidden
{
    _uberView.hidden = hidden;
    _uberImageView.hidden = hidden;

    _uberLabelBottomConstraint.constant = hidden ? kHiddenUberLabelBottomConstraint : kUberLabelBottomConstraint;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setUberWithTime:(NSString*)uberTime
{
    _uberTimeLabel.text = !uberTime ? @"" : uberTime;
    _uberNameLabel.text = !uberTime ? NSLocalizedString(@"Waiting for UBER", nil) : [self uberText];
    [self hideUber:NO];
}

- (NSString*)uberText
{
    return (IS_IPHONE_4 || IS_IPHONE_5) ? @"UBER" : NSLocalizedString(@"Ride there with UBER", nil);
}

@end
