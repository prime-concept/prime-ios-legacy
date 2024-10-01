//
//  PRPaymentView.m
//  PRIME
//
//  Created by Davit on 1/11/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRPaymentView.h"
#import "TaskIcons.h"

static const CGFloat kTrailingLeadingSpace = 15;
static const CGFloat kWidthInSmallScreens = 300;

@interface PRPaymentView ()

@property (weak, nonatomic) IBOutlet UIView* contentView;
@property (weak, nonatomic) IBOutlet UIView* backgroundView;
@property (weak, nonatomic) IBOutlet UIView* containerView;
@property (weak, nonatomic) IBOutlet UIView* topSeparatorView;
@property (weak, nonatomic) IBOutlet UIView* bottomSeparatorView;

@property (weak, nonatomic) IBOutlet UIImageView* requestIconImageView;

@property (weak, nonatomic) IBOutlet UILabel* requestNameLabel;
@property (weak, nonatomic) IBOutlet UILabel* requestDetailsLabel;
@property (weak, nonatomic) IBOutlet UILabel* requestNumberTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel* requestNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel* totalTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel* totalLabel;
@property (weak, nonatomic) IBOutlet UILabel* serviceTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel* serviceLabel;
@property (weak, nonatomic) IBOutlet UILabel* statusTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel* statusLabel;

@property (weak, nonatomic) IBOutlet UIButton* closeButton;
@property (weak, nonatomic) IBOutlet UIButton* cardPayButton;
@property (weak, nonatomic) IBOutlet UIButton* applePayButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint* paymentViewWidthConstraint;

@end

@implementation PRPaymentView

#pragma mark - Setup View

- (void)setupViewWithTask:(PRTaskDetailModel*)task
              paymentInfo:(PRPaymentDataModel*)paymentData
{
    if (IS_IPHONE_4 || IS_IPHONE_5) {
        _paymentViewWidthConstraint.constant = kWidthInSmallScreens;
    }

    [_requestIconImageView setImage:[UIImage imageNamed:[TaskIcons imageNameFromTaskTypeId:task.taskType.typeId.integerValue]]];

    [_requestNameLabel setText:task.taskName];
    [_requestDetailsLabel setText:task.taskDescription];

    [_requestNumberTitleLabel setText:NSLocalizedString(@"Request number:", nil)];
    [_requestNumberLabel setText:[paymentData.data.orderId stringValue]];

    [_totalTitleLabel setText:NSLocalizedString(@"Total:", nil)];
    [_totalLabel setText:[NSString stringWithFormat:@"%@ %@", paymentData.data.amount, (paymentData.data.currencyCode) ?: @""]];

    [_serviceTitleLabel setText:NSLocalizedString(@"Service:", nil)];
    [_serviceLabel setText:[paymentData.data.paymentSummaryItems firstObject].name];

    [_statusTitleLabel setText:NSLocalizedString(@"Status:", nil)];
    [_statusLabel setText:(paymentData.data.status.integerValue == 0) ? NSLocalizedString(@"Created", nil) : NSLocalizedString(@"Registered", nil)];

    [_closeButton setImage:[[UIImage imageNamed:@"close_payment"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                  forState:UIControlStateNormal];
    [_closeButton setTintColor:kSegmentedControlTaskStatusColor];

    [_cardPayButton setBackgroundColor:kSegmentedControlTaskStatusColor];
    [_cardPayButton setTitle:NSLocalizedString(@"Pay with card", nil) forState:UIControlStateNormal];

    [self setupApplePayButton];
}

- (void)setupApplePayButton
{
    PKPaymentButton* applePayButton = [[PKPaymentButton alloc] initWithPaymentButtonType:PKPaymentButtonTypePlain
                                                                      paymentButtonStyle:PKPaymentButtonStyleBlack];
    [applePayButton addTarget:self
                       action:@selector(applePayButtonDidPress:)
             forControlEvents:UIControlEventTouchUpInside];

    [self.containerView addSubview:applePayButton];

    [applePayButton configureForAutoLayout];
    [applePayButton autoPinEdge:ALEdgeLeft
                         toEdge:ALEdgeRight
                         ofView:_cardPayButton
                     withOffset:kTrailingLeadingSpace];

    [applePayButton autoPinEdgeToSuperviewEdge:ALEdgeRight
                                     withInset:kTrailingLeadingSpace];

    [applePayButton autoAlignAxis:ALAxisHorizontal
                 toSameAxisOfView:_cardPayButton];

    [applePayButton autoSetDimension:ALDimensionHeight
                              toSize:CGRectGetHeight(_cardPayButton.frame)];
}

#pragma mark - Actions

- (IBAction)closeButtonPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(paymentViewCloseButtonDidPress:)]) {
        [self.delegate paymentViewCloseButtonDidPress:self];
    }
}

- (IBAction)cardPayButtonPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(paymentViewPayWithCardButtonDidPress:)]) {
        [self.delegate paymentViewPayWithCardButtonDidPress:self];
    }
}

- (void)applePayButtonDidPress:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(paymentViewPayWithApplePayButtonDidPress:)]) {
        [self.delegate paymentViewPayWithApplePayButtonDidPress:self];
    }
}

@end
