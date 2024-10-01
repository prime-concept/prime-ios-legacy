//
//  CreatePasswordViewController.m
//  PRIME
//
//  Created by Artak on 1/29/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "ConfirmPasswordViewController.h"
#import "Constants.h"
#import "CreatePasswordViewController.h"

@implementation CreatePasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (!_isPasswordChangeRequested) {
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]]];
    }

    _labelNote.textColor = kAppLabelColor;

    [_labelNote setText:[NSString stringWithFormat:NSLocalizedString(@"Write a password which you will use to enter application %@", nil),
                                  NSLocalizedString([[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey], nil)]];

    _labelInfo.backgroundColor = kPhoneLabelBackgroundColor;
    _labelInfo.textColor = kPhoneLabelTextColor;

    [_textFieldPassword addTarget:self
                           action:@selector(passwordEditingChanged)
                 forControlEvents:UIControlEventEditingChanged];
}

- (void)viewDidAppear:(BOOL)animated
{
    [_textFieldPassword becomeFirstResponder];
}

- (void)resetPassword
{
    [_textFieldPassword setPasscode:@""];
}

- (void)passwordEditingChanged
{
    if ([_textFieldPassword.passcode length] == 4) {
        [self nextStep];
    }
}

- (void)nextStep
{
    [PRGoogleAnalyticsManager sendEventWithName: _isPasswordChangeRequested ? kChangePasswordNewPasswordEntered : kPasswordCreated parameters:nil];
    ConfirmPasswordViewController* confirmPasswordVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ConfirmPasswordViewController"];
    confirmPasswordVC.firstEnteredPassword = _textFieldPassword.passcode;
    confirmPasswordVC.phoneNumber = _phoneNumber;
    confirmPasswordVC.isPasswordChangeRequested = _isPasswordChangeRequested;
    confirmPasswordVC.delegate = self;
    [self.navigationController pushViewController:confirmPasswordVC animated:YES];
}

@end
