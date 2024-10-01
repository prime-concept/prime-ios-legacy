//
//  PRClubPrimeOverviewViewController.m
//  PRIME
//
//  Created by Davit on 8/19/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "PRClubPrimeOverviewViewController.h"

@interface PRClubPrimeOverviewViewController ()

@property (weak, nonatomic) IBOutlet UIButton* loginWithFacebookButton;
@property (weak, nonatomic) IBOutlet UIButton* sendButton;
@property (weak, nonatomic) IBOutlet UITextField* nameTextField;
@property (weak, nonatomic) IBOutlet UITextField* phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField* emailTextField;
@property (weak, nonatomic) IBOutlet UILabel* becomeUserLabel;
@property (weak, nonatomic) IBOutlet UILabel* fillRegistrationFormLabel;
@property (weak, nonatomic) IBOutlet UILabel* registrationAgreementLabel;

@end

@implementation PRClubPrimeOverviewViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    const UIColor* placeholderColor = [UIColor colorWithRed:101.0 / 255.0 green:78.0 / 255.0 blue:70.0 / 255.0 alpha:1.0];
    const UIColor* facebookButtonBorderColor = [UIColor colorWithRed:67.0 / 255.0 green:79.0 / 255.0 blue:105.0 / 255.0 alpha:1.0];
    const UIColor* sendButtonBorderColor = [UIColor colorWithRed:230.0 / 255.0 green:226.0 / 255.0 blue:217.0 / 255.0 alpha:1.0];
    const CGFloat buttonBorderWidth = 1.0f;
    const CGFloat buttonCornerRadius = 10.0f;

    [_loginWithFacebookButton.layer setBorderWidth:buttonBorderWidth];
    [_loginWithFacebookButton.layer setBorderColor:facebookButtonBorderColor.CGColor];
    [_loginWithFacebookButton.layer setCornerRadius:buttonCornerRadius];
    [_loginWithFacebookButton.layer setMasksToBounds:YES];

    [_sendButton.layer setBorderWidth:buttonBorderWidth];
    [_sendButton.layer setBorderColor:sendButtonBorderColor.CGColor];
    [_sendButton.layer setCornerRadius:buttonCornerRadius];
    [_sendButton.layer setMasksToBounds:YES];

    [_nameTextField setValue:placeholderColor
                  forKeyPath:@"_placeholderLabel.textColor"];
    [_phoneTextField setValue:placeholderColor
                   forKeyPath:@"_placeholderLabel.textColor"];
    [_emailTextField setValue:placeholderColor
                   forKeyPath:@"_placeholderLabel.textColor"];
}

#pragma mark - Fill Screen

- (void)fillScreenWithData:(NSDictionary*)dataDict
{
    [_loginWithFacebookButton setTitle:NSLocalizedString(dataDict[kOverviewFacebookButtonTitleKey], nil) forState:UIControlStateNormal];
    [_sendButton setTitle:NSLocalizedString(dataDict[kOverviewSendButtonTitleKey], nil) forState:UIControlStateNormal];

    [_nameTextField setValue:NSLocalizedString(dataDict[kOverviewNameKey], nil)
                  forKeyPath:@"_placeholderLabel.text"];
    [_phoneTextField setValue:NSLocalizedString(dataDict[kOverviewPhoneKey], nil)
                   forKeyPath:@"_placeholderLabel.text"];
    [_emailTextField setValue:NSLocalizedString(dataDict[kOverviewEmailKey], nil)
                   forKeyPath:@"_placeholderLabel.text"];

    [_becomeUserLabel setText:NSLocalizedString(dataDict[kOverviewTitleKey], nil)];
    [_fillRegistrationFormLabel setText:NSLocalizedString(dataDict[kOverviewRegistrationFormKey], nil)];
    [_registrationAgreementLabel setText:NSLocalizedString(dataDict[kOverviewAgreementKey], nil)];
}

#pragma mark - Actions

- (IBAction)loginWithFacebookButtonPressed:(id)sender
{
}

- (IBAction)sendButtonPressed:(id)sender
{
}

- (IBAction)instagramButtonPressed:(id)sender
{
}

- (IBAction)facebookButtonPressed:(id)sender
{
}

- (IBAction)telegramButtonPressed:(id)sender
{
}

@end
