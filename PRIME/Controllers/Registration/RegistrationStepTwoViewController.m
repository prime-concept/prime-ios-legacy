//
//  RegistrationStepTwoViewController.m
//  PRIME
//
//  Created by Simon on 1/28/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "ClubInformationViewController.h"
#import "CreatePasswordViewController.h"
#import "PRStatusModel.h"
#import "RegistrationStepTwoViewController.h"

@import AudioToolbox;

@interface RegistrationStepTwoViewController ()

@end

@implementation RegistrationStepTwoViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _textFieldCode.delegate = self;
#if defined(PrimeClubConcierge)
	_textFieldCode.tintColor = kAppPassCodeColor;
#endif

    _labelPhoneNumber.text = [@"+" stringByAppendingString:_phoneNumber];
    _labelPhoneNumber.textColor = kPhoneLabelTextColor;
    _labelNote.textColor = kAppLabelColor;

    _labelPhoneNumber.backgroundColor = kPhoneLabelBackgroundColor;

    [_textFieldCode addTarget:self
                       action:@selector(textFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];

#ifdef Raiffeisen
    [self.navigationController.navigationBar setTintColor:kNavigationBarTintColor];
#endif

}

- (void)textFieldDidChange:(UITextField*)theTextField
{
    if ([theTextField.text length] == kMaxSMSCodeLength) {
        [self sendVerifyCode:theTextField.text];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [_textFieldCode becomeFirstResponder];
}

#pragma mark - Verification

- (void)sendVerifyCode:(NSString*)code
{
    [[self view] endEditing:YES];

    [self.navigationItem setHidesBackButton:YES animated:YES];

    __weak id weakSelf = self;
    [PRRequestManager verifyWithPhone:_phoneNumber
        code:code
        view:self.view
        mode:PRRequestMode_ShowErrorMessagesAndProgress
        success:^{
            RegistrationStepTwoViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            [strongSelf nextStep];
        }
        failure:^() {
            RegistrationStepTwoViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            [strongSelf vibrateAndFail];
        }
        unknownUser:^{
            RegistrationStepTwoViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            [strongSelf vibrateAndFail];
            [strongSelf openClubInformationView];
        }];
}

- (void)vibrateAndFail
{
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    [_textFieldCode setText:@""];
    [_textFieldCode becomeFirstResponder];
    if (self.navigationItem.rightBarButtonItem) {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    }
    [self.navigationItem setHidesBackButton:NO animated:YES];
}

- (void)openClubInformationView
{
    ClubInformationViewController* clubInformationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ClubInformationViewController"];
    clubInformationViewController.phoneNumber = _phoneNumber;
    [self.navigationController pushViewController:clubInformationViewController animated:YES];
}

- (void)nextStep
{
    [PRGoogleAnalyticsManager sendEventWithName:kRegistrationCodeConfirmed parameters:nil];
    CreatePasswordViewController* createPasswordViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CreatePasswordViewController"];
    createPasswordViewController.phoneNumber = _phoneNumber;
    createPasswordViewController.isPasswordChangeRequested = NO;
    [self.navigationController pushViewController:createPasswordViewController animated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
    NSString* finalString = [textField.text stringByReplacingCharactersInRange:range withString:string];

    if (self.navigationItem.rightBarButtonItem) {
        [self.navigationItem.rightBarButtonItem setEnabled:([finalString length] >= kMinSMSCodeLength)];
    }

    return [finalString length] <= kMaxSMSCodeLength;
}

#pragma mark - Memory Warning

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
