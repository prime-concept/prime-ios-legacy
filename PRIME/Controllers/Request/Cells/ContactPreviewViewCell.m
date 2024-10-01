//
//  ContactPreviewViewCell.m
//  PRIME
//
//  Created by Armen on 5/17/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import "ContactPreviewViewCell.h"

@interface ContactPreviewViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *checkImageView;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UITextView *mainContentTextView;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

@implementation ContactPreviewViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _checked = YES;
    [_categoryLabel setFont: [_categoryLabel.font fontWithSize: 11]];
    [_categoryLabel setTextColor:[UIColor colorWithRed:0 /255 green:131. /255 blue:248. /255 alpha:1.0]];
    [_checkImageView setImage:[UIImage imageNamed:@"confirmationChecked"]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setCategoryLabelText:(NSString*)text
{
    [_categoryLabel setText:text];
}

- (void)setMainContentText:(NSString*)text
{
    [_mainContentTextView setText:text];
}

- (void)setContactName:(NSString*)text
{
    [_checkImageView setHidden:YES];
    [_mainContentTextView setFont:[UIFont boldSystemFontOfSize:16.0]];
    [_mainContentTextView setText:text];
}

- (void)changeCheckedStatus
{
    _checked = !_checked;
    _checked ? [_checkImageView setImage:[UIImage imageNamed:@"confirmationChecked"]]: [_checkImageView setImage:[UIImage imageNamed:@"confirmationUnchecked"]];
}

- (void)setSeparator
{
    [_separatorView setHidden:NO];
}

@end
