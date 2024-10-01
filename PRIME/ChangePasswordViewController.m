//
//  ChangePasswordViewController.m
//  PRIME
//
//  Created by Aram on 3/7/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "AESCrypt.h"
#import "TouchIdAuth.h"
#import "CreatePasswordViewController.h"

@interface ChangePasswordViewController ()

@property (weak, nonatomic) IBOutlet UILabel* labelInfo;
@property (weak, nonatomic) IBOutlet PRPasswordField* textFieldPassword;
@property (weak, nonatomic) IBOutlet UILabel* labelNote;

@end

static NSString* const kCreatePasswordViewControllerIdentifier = @"CreatePasswordViewController";
static NSString* const kLabelNoteText = @"Please, enter current password.";
static NSString* const kLabelInfoText = @"Current password";

@implementation ChangePasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _labelNote.textColor = kAppLabelColor;
    [_labelNote setText:NSLocalizedString(kLabelNoteText, nil)];

    _labelInfo.backgroundColor = kPhoneLabelBackgroundColor;
    _labelInfo.textColor = kPhoneLabelTextColor;
    [_labelInfo setText:NSLocalizedString(kLabelInfoText, nil)];

    [_textFieldPassword addTarget:self
                           action:@selector(passwordEditingChanged)
                 forControlEvents:UIControlEventEditingChanged];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_textFieldPassword becomeFirstResponder];
}

- (void)passwordEditingChanged
{
    if ([_textFieldPassword.passcode length] == 4) {
        [self validatePassword];
    }
}

- (void)validatePassword
{
    [[self view] endEditing:YES];

    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* customerId = [defaults objectForKey:kCustomerId];
    NSString* phone = [defaults objectForKey:kUserPhoneNumber];
    NSString* username = customerId ? customerId : phone;

    __weak id weakSelf = self;
    [PRRequestManager validatePassword:_textFieldPassword.passcode
        username:username
        view:self.view
        mode:PRRequestMode_ShowOnlyProgress
        success:^{
            ChangePasswordViewController* strongSelf = weakSelf;
            if (strongSelf) {
                [strongSelf nextStep];
            }
        }
        failure:^{

            ChangePasswordViewController* strongSelf = weakSelf;
            if (strongSelf) {
                [PRMessageAlert showToastWithMessage:Message_IncorrectPassword];
                [strongSelf dismissViewController];
            }

        }
        offline:^{

            ChangePasswordViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            [PRMessageAlert showToastWithMessage:Message_InternetConnectionOffline];
            [strongSelf dismissViewController];
        }];
}

- (void)nextStep
{
    [PRGoogleAnalyticsManager sendEventWithName:kChangePasswordCurrentPasswordEntered parameters:nil];
    NSString* phoneNumber = [[NSUserDefaults standardUserDefaults] objectForKey:kUserPhoneNumber];

    CreatePasswordViewController* createPasswordViewController = [[Utils mainStoryboard] instantiateViewControllerWithIdentifier:kCreatePasswordViewControllerIdentifier];
    createPasswordViewController.phoneNumber = phoneNumber;
    createPasswordViewController.isPasswordChangeRequested = YES;

    [self.navigationController pushViewController:createPasswordViewController animated:YES];
    [self removeFromParentViewController];
}

- (void)dismissViewController
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
