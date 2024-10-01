//
//  ConfirmPasswordViewController.m
//  PRIME
//
//  Created by Artak Tsatinyan on 1/29/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "AppDelegate.h"
#import "ConfirmPasswordViewController.h"
#import "CreatePasswordViewController.h"
#import "PRUITabBarController.h"
#import "TouchIdAuth.h"
#import "AESCrypt.h"

@import AudioToolbox;

@implementation ConfirmPasswordViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _labelInfo.text = NSLocalizedString(@"Repeat password", );
    _labelInfo.textColor = kPhoneLabelTextColor;
    _labelNote.textColor = kAppLabelColor;
    _labelInfo.backgroundColor = kPhoneLabelBackgroundColor;
    [_textFieldPassword addTarget:self
                           action:@selector(passwordEditingChanged)
                 forControlEvents:UIControlEventEditingChanged];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_textFieldPassword becomeFirstResponder];
}

#pragma mark - Actions

- (void)passwordEditingChanged
{
    if ([_textFieldPassword.passcode length] != 4) {
        return;
    }

    if (_isPasswordChangeRequested) {
        [self changePasswordRequest];
        return;
    }
    [self createPasswordRequest];
}

- (void)didMoveToParentViewController:(UIViewController*)parent
{
    if (!parent) {
        // Back button is pressed.
        [_delegate resetPassword];
    }
}

#pragma mark - Password Requests

- (void)createPasswordRequest
{
    if ([_firstEnteredPassword isEqualToString:_textFieldPassword.passcode]) {

        [[self view] endEditing:YES];
        [self.navigationItem setHidesBackButton:YES animated:YES];

        _phoneNumber = _phoneNumber ?: [[NSUserDefaults standardUserDefaults] objectForKey:kUserPhoneNumber];
        __weak id weakSelf = self;
        [PRRequestManager setPassword:_firstEnteredPassword
            phone:_phoneNumber
            view:self.view
            mode:PRRequestMode_ShowErrorMessagesAndProgress
            success:^{

                ConfirmPasswordViewController* strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }

                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsAfterRegistration];
                [strongSelf authorizeUserWithCoreDataSetup:YES];
            }
            failure:^{

                ConfirmPasswordViewController* strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }

                [strongSelf passwordRequestFailed];
            }];
        return;
    }

    [self passwordsDoesNotMatch];
}

- (void)changePasswordRequest
{
    if ([_firstEnteredPassword isEqualToString:_textFieldPassword.passcode]) {

        [[self view] endEditing:YES];
        [self.navigationItem setHidesBackButton:YES animated:YES];

        __weak id weakSelf = self;
        [PRRequestManager changePassword:_firstEnteredPassword
            phone:_phoneNumber
            view:self.view
            mode:PRRequestMode_ShowErrorMessagesAndProgress
            success:^{

                ConfirmPasswordViewController* strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }

                [strongSelf authorizeUserWithCoreDataSetup:NO];
            }
            failure:^{

                ConfirmPasswordViewController* strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }

                [strongSelf passwordRequestFailed];
            }];
        return;
    }

    [self passwordsDoesNotMatch];
}

#pragma mark - Password Failures

- (void)passwordsDoesNotMatch
{
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    [PRMessageAlert showToastWithMessage:Message_PasswordDoesnotMatch];
    [_textFieldPassword setPasscode:@""];
    [_textFieldPassword becomeFirstResponder];
}

- (void)passwordRequestFailed
{
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    [_textFieldPassword setPasscode:@""];
    [_textFieldPassword becomeFirstResponder];
    [self.navigationItem setHidesBackButton:NO animated:YES];
}

#pragma mark - User Authorization

- (void)authorizeUserWithCoreDataSetup:(BOOL)shouldSetupCoreData
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:kUserPhoneNumber]) {
        [defaults setObject:_phoneNumber forKey:kUserPhoneNumber];
        [defaults synchronize];
    }

    NSUserDefaults* sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSiriUserDefaultsSuiteName];
    if (![sharedDefaults objectForKey:kUserPhoneNumber]) {
        [sharedDefaults setObject:_phoneNumber forKey:kUserPhoneNumber];
        [sharedDefaults synchronize];
    }

    NSString* customerId = [defaults objectForKey:kCustomerId];

    __weak id weakSelf = self;
    [PRRequestManager authorizeWithUsername:customerId ? customerId : _phoneNumber
        password:_firstEnteredPassword
        setupCoreData:shouldSetupCoreData
        view:self.view
        mode:PRRequestMode_ShowErrorMessagesAndProgress
        success:^{
            ConfirmPasswordViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            [defaults setBool:YES forKey:kUserRegistered];
            [defaults synchronize];

            [TouchIDAuth activateWithPasscode:[AESCrypt encrypt:strongSelf.firstEnteredPassword password:kClientSecret]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf done];
            });
        }
        failure:^{
            AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            dispatch_async(dispatch_get_main_queue(), ^{
                [appDelegate setInitalViewController];
            });
        }
        offline:^{

        }
        incorrectPasswordBlock:^{
        }];
}

#pragma mark - Transition

- (void)done
{
    if (_isPasswordChangeRequested) {
        [PRGoogleAnalyticsManager sendEventWithName:kChangePasswordNewPasswordRepeated parameters:nil];
        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
    }

    if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsAfterRegistration]) {
        [PRGoogleAnalyticsManager sendEventWithName:kPasswordReapeted parameters:nil];
        PRUITabBarController* tabBarController = [PRUITabBarController instantiateFromStoryboard];
        tabBarController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:tabBarController animated:YES completion:nil];
        [tabBarController getHelpScreenFeatureAndPresentOnTabBar:nil];
    }

}

@end
