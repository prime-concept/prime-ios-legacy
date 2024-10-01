//
//  PRInfoTableViewCell.m
//  PRIME
//
//  Created by Mariam on 1/19/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRInfoTableViewCell.h"

@interface PRInfoTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel* labelDetail;
@property (weak, nonatomic) IBOutlet UIImageView* flagImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* infolabelLeftConstraint;

@end

static const CGFloat kInfoLabelDefaultPosition = 45.0;
static const CGFloat kInfoLabelPositionWithoutFlag = 17.0;

@implementation PRInfoTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)configureCellWithInfo:(NSString*)info
{
    [self configureCellWithInfo:info andDetail:@""];
}

- (void)configureCellWithInfo:(NSString*)info andDetail:(NSString*)detail
{
    _labelInfo.text = info;
    _labelDetail.text = detail;

    _labelInfo.textColor = kRBlackColor;
#ifdef Platinum
    _labelDetail.textColor = kTypingContainerViewColor;
#else
    _labelDetail.textColor = kIconsColor;
#endif
}

- (void)configureCellWithInfo:(NSString*)info placeholder:(NSString*)placeholder andDetail:(NSString*)detail
{
    if (!info || info.length <= 0) {
        [self configureCellWithInfo:placeholder andDetail:detail];
        _labelInfo.textColor = kGreyColor;
        return;
    }
    if (detail && [detail isEqualToString:@""]) {
        [self configureCellWithInfo:info andDetail:placeholder];
        _labelInfo.textColor = kRBlackColor;
        _labelDetail.textColor = kGreyColor;
        return;
    }
    [self configureCellWithInfo:info andDetail:detail];
    _labelInfo.textColor = kRBlackColor;
}

- (void)configureCellWithInfo:(NSString*)info placeholder:(NSString*)placeholder detail:(NSString*)detail andImage:(UIImage*)image
{
    [self configureCellWithInfo:info placeholder:placeholder andDetail:detail];
    [self setFlag:image];
}

- (void)configureCellWithInfo:(NSString*)info detail:(NSString*)detail andImage:(UIImage*)image
{
    [self configureCellWithInfo:info andDetail:detail];
    [self setFlag:image];
}

- (void)setFlag:(UIImage*)image
{
    _flagImageView.image = image;
    _infolabelLeftConstraint.constant =  image ? kInfoLabelDefaultPosition : kInfoLabelPositionWithoutFlag;
}

@end
