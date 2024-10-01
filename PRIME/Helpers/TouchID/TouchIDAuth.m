//
//  TouchIdAuth.m
//  PRIME
//
//  Created by Artak on 6/8/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "TouchIDAuth.h"
#import "TouchIDManager.h"
#import "XNTKeychainStore.h"
#import "AESCrypt.h"

@implementation TouchIDAuth

+ (BOOL)canAuthenticate
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* phone = [defaults objectForKey:kUserPhoneNumber];
    NSString* customerId = [defaults objectForKey:kCustomerId];

    NSString* keychainPrefix = customerId ? customerId : phone;
    return [TouchIDManager isAuthenticationWithBiomerticsSupported] && ![[TouchIDAuth storedPassForPhone:keychainPrefix] isEqualToString:@""]; //TODO no functionality to set key prefix!!!
}

+ (NSString*)storedPassForPhone:(NSString*)phone
{
    return [XNTKeychainStore stringForKey:[phone stringByAppendingString:kPasscodeKey] identifier:kOwnerIdentifier];
}

+ (void)authorizeWithStoredPassWithView:(UIView*)view
                          setupCoreData:(BOOL)setupCoreData
                                success:(void (^)())success
                                offline:(void (^)(NSString* phone, NSString* passCode))offline
                               fallback:(void (^)())fallback
{

    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* phone = [defaults objectForKey:kUserPhoneNumber];
    NSString* customerId = [defaults objectForKey:kCustomerId];

    NSString* username = customerId ? customerId : phone;

    NSString* storedPassCode = [TouchIDAuth storedPassForPhone:username];
    NSString* passCode = storedPassCode.length == 4 ? storedPassCode : [AESCrypt decrypt:storedPassCode password:kClientSecret];
    [PRRequestManager authorizeWithUsername:username
        password:passCode
        setupCoreData:setupCoreData
        view:view
        mode:view != nil ? PRRequestMode_ShowOnlyProgress : PRRequestMode_ShowNothing
        success:success
        failure:^{
            fallback();
        }
        offline:^{
            offline(phone, passCode);
        }
        incorrectPasswordBlock:^{

        }];
}

+ (void)authenticateWithView:(UIView*)view
               setupCoreData:(BOOL)setupCoreData
                     success:(void (^)())success
                     offline:(void (^)(NSString* phone, NSString* passCode))offline
                    fallback:(void (^)())fallback
{

    [TouchIDManager verifyUserIdentityWithReason:NSLocalizedString(@"Authentication is needed to access your account.", nil)
        success:^{
            dispatch_async(dispatch_get_main_queue(), ^{

                [self authorizeWithStoredPassWithView:view setupCoreData:setupCoreData success:success offline:offline fallback:fallback];
            });
        }
        tryagain:^{

        }
        failure:^{

        }];
}

+ (void)activateWithPasscode:(NSString*)passcode
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* phone = [defaults objectForKey:kUserPhoneNumber];
    NSString* customerId = [defaults objectForKey:kCustomerId];
    NSString* keychainPrefix = customerId ? customerId : phone;

    [XNTKeychainStore setString:passcode forKey:[keychainPrefix stringByAppendingString:kPasscodeKey] identifier:kOwnerIdentifier];
    [XNTKeychainStore setString:passcode forKey:[keychainPrefix stringByAppendingString:kPasscodeKey] identifier:kOwnerIdentifier service:kServiceNameForExtensions accessGroup:kSiriUserDefaultsSuiteName];
    [XNTKeychainStore setString:passcode forKey:[keychainPrefix stringByAppendingString:kPasscodeKey] identifier:kOwnerIdentifier service:kServiceNameForExtensions accessGroup:kUserDefaultsSuiteName];
}

@end
