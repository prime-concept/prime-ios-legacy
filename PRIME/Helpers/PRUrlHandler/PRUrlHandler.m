//
//  PRUrlHandler.m
//  PRIME
//
//  Created by Mariam on 6/2/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRUrlHandler.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "ConfirmPasswordViewController.h"

#define kLoginPath @"login/"

@interface PRUrlHandler ()
@end

@implementation PRUrlHandler

#pragma mark - Url Handler

+ (void)loginIfNeededWithRequestURL:(NSString*)url
                       registerUser:(void (^)())registerUser
                      continueSteps:(void (^)())continueSteps;
{
    if ([self isLoginUrl:url]) {

        NSString* requestString = [self paramsStringFromUrl:url];
        NSString* customerId = [self customerId];

        [PRRequestManager loginWithRequest:requestString
            view:nil
            mode:PRRequestMode_ShowNothing
            success:^() {
                [self openLoginViewControllerIdNeeded];
                [self saveProfilePhone:[[[self paramsStringFromUrl:url] componentsSeparatedByString:@","] firstObject]];

                if ([self canRegisterOrSwitchFromUser:customerId]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshTouchIDButton object:nil];
                    continueSteps();
                } else {
                    registerUser();
                }
            }
            failure:^{
                [self openLoginViewControllerIdNeeded];
                continueSteps();
            }
            unknownUser:^{
                [self openLoginViewControllerIdNeeded];
                continueSteps();
            }];
    } else {
        continueSteps();
    }
}

+ (BOOL)isLoginUrl:(NSString*)url
{
    return [url containsString:[self loginPath]];
}
#pragma mark - Private Methods

+ (BOOL)canRegisterOrSwitchFromUser:(NSString*)customerId
{

    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    if ([defaults boolForKey:kUserRegistered]) {

        NSString* newCustomerId = [self customerId];
        [TouchIDAuth activateWithPasscode:[TouchIDAuth storedPassForPhone:customerId]];

        if (![customerId isEqualToString:newCustomerId]) {

            NSString* phone = [defaults objectForKey:kUserPhoneNumber];
            [CRMRestClient cleanupCoreDataAndSetupForPhone:phone];

            [PRRequestManager setPassword:[self passwordForCustomer:customerId]
                                    phone:phone
                                     view:nil
                                     mode:PRRequestMode_ShowNothing
                                  success:^{
                                  }
                                  failure:^{

                                  }];
        }
        return YES;
    } else {
        return NO;
    }
}

+ (NSString*)customerId
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kCustomerId];
}

+ (NSString*)loginPath
{
    return [kURLSchemesPrefix stringByAppendingString:kLoginPath];
}

+ (NSString*)passwordForCustomer:(NSString*)customerId
{
    NSString* storedPassword = [TouchIDAuth storedPassForPhone:customerId];
    return storedPassword.length == 4 ? storedPassword : [AESCrypt decrypt:storedPassword password:kClientSecret];
}

+ (NSString*)paramsStringFromUrl:(NSString*)url
{
    return [url substringFromIndex:[url rangeOfString:[self loginPath]].length];
}

+ (UITabBarController*)tabBarControllerForVC:(UIViewController*)viewController
{
    UITabBarController* tabBarController;
    if (![viewController isKindOfClass:[LoginViewController class]]
        && ![viewController isKindOfClass:[ConfirmPasswordViewController class]]) {

    } else {
        tabBarController = (UITabBarController*)[viewController presentedViewController];
    }
    return tabBarController;
}

+ (void)saveProfilePhone:(NSString*)phone
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:kUserPhoneNumber] || ![[defaults objectForKey:kUserPhoneNumber] isEqualToString:phone]) {
        [defaults setObject:phone forKey:kUserPhoneNumber];
        [defaults synchronize];
    }

    NSUserDefaults* sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    if (![sharedDefaults objectForKey:kUserPhoneNumber] || ![[sharedDefaults objectForKey:kUserPhoneNumber] isEqualToString:phone]) {
        [sharedDefaults setObject:phone forKey:kUserPhoneNumber];
        [sharedDefaults synchronize];
    }
}

+ (void)openLoginViewControllerIdNeeded
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kUserRegistered]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kOpenLoginViewController object:nil];
    }
}

@end
