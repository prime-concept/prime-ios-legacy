//
//  TouchIDManager.h
//  PRIME
//
//  Created by Admin on 6/3/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TouchIDManager : NSObject

+ (BOOL) isAuthenticationWithBiomerticsSupported;

+ (void) verifyUserIdentityWithReason: (NSString*) reason
                             success: (void (^)()) success
                            tryagain: (void (^)()) tryagain
                             failure: (void (^)()) failure;

@end
