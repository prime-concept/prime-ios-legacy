//
//  TouchIDManager.m
//  PRIME
//
//  Created by Admin on 6/3/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "TouchIDManager.h"

#import <LocalAuthentication/LocalAuthentication.h>

@implementation TouchIDManager

+ (BOOL) isAuthenticationWithBiomerticsSupported
{
    LAContext *context = [[LAContext alloc] init];
    
    NSError *error = nil;
    
    if ([context canEvaluatePolicy: LAPolicyDeviceOwnerAuthenticationWithBiometrics
                             error: &error]) {
        return TRUE;
    }
    
    return FALSE;
}

+ (void) verifyUserIdentityWithReason: (NSString*) reason
                             success: (void (^)()) success
                            tryagain: (void (^)()) tryagain
                             failure: (void (^)()) failure
{
    LAContext *context = [[LAContext alloc] init];
    
    [context evaluatePolicy: LAPolicyDeviceOwnerAuthenticationWithBiometrics
            localizedReason: reason
                      reply: ^(BOOL _success, NSError *error) {
                          
                          if (error) {
                              tryagain();
                              return;
                          }
                          
                          if (_success) {
                              success();
                          } else {
                              failure();
                          }
                      }];
}

@end
