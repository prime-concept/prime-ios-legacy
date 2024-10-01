//
//  PRUrlHandler.h
//  PRIME
//
//  Created by Mariam on 6/2/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TouchIDAuth.h"
#import "AESCrypt.h"

@interface PRUrlHandler : NSObject

+ (void)loginIfNeededWithRequestURL:(NSString*)url
                       registerUser:(void (^)())registerUser
                      continueSteps:(void (^)())continueSteps;

+ (BOOL)isLoginUrl:(NSString*)url;
@end
