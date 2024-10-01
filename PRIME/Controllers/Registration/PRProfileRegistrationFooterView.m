//
//  PRProfileRegistrationFooterView.m
//  PRIME
//
//  Created by Aram on 8/22/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRProfileRegistrationFooterView.h"

#if defined(PrimeClubConcierge)
    static NSString* const kSelectedCheckboxImageName = @"selectedCheckbox";
    static NSString* const kNoneSelectedCheckboxImageName = @"unselectedCheckbox";
#else
    static NSString* const kSelectedCheckboxImageName = @"circleCheckbox_selected";
    static NSString* const kNoneSelectedCheckboxImageName = @"circleCheckbox_noneSelected";
#endif

@interface PRProfileRegistrationFooterView ()
@property (weak, nonatomic) IBOutlet UILabel* titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView* checkboxImageView;

@property (weak, nonatomic) id<PRCheckboxDelegate> delegate;
@property (assign, nonatomic) BOOL isCheckboxSelected;

@end

@implementation PRProfileRegistrationFooterView

- (void)awakeFromNib
{
    [super awakeFromNib];

    [_checkboxImageView setImage:[[UIImage imageNamed:kNoneSelectedCheckboxImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [_checkboxImageView setTintColor:kSegmentedControlTaskStatusColor];
    [_checkboxImageView setUserInteractionEnabled:YES];

    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkboxSelected)];
    [_checkboxImageView addGestureRecognizer:tapGesture];
}

- (void)configureViewWithTitle:(NSString*)title titleFont:(UIFont*)titleFont delegate:(id<PRCheckboxDelegate>)delegate checkboxSize:(CGSize)checkboxSize
{
    [_checkboxImageView setFrame:CGRectMake(0, 0, checkboxSize.width, checkboxSize.height)];
    [_titleLabel setFont:titleFont];
    [_titleLabel setText:title];
    _delegate = delegate;
}

- (void)checkboxSelected
{
    NSString* imageName = _isCheckboxSelected ? kNoneSelectedCheckboxImageName : kSelectedCheckboxImageName;
    [_checkboxImageView setImage:[[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];

    _isCheckboxSelected = !_isCheckboxSelected;

    if (_delegate && [_delegate respondsToSelector:@selector(didSelectCheckbox:)]) {
        [_delegate didSelectCheckbox:_isCheckboxSelected];
    }
}

@end
