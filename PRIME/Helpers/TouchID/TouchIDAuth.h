//
//  TouchIdAuth.h
//  PRIME
//
//  Created by Artak on 6/8/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TouchIDAuth : NSObject

+ (BOOL)canAuthenticate;

+ (void)authenticateWithView:(UIView*)view
               setupCoreData:(BOOL)setupCoreData
                     success:(void (^)())success
                     offline:(void (^)(NSString* phone, NSString* passCode))offline
                    fallback:(void (^)())fallback;

+ (void)activateWithPasscode:(NSString*)passcode;

+ (NSString*)storedPassForPhone:(NSString*)phone;

+ (void)authorizeWithStoredPassWithView:(UIView*)view
                          setupCoreData:(BOOL)setupCoreData
                                success:(void (^)())success
                                offline:(void (^)(NSString* phone, NSString* passCode))offline
                               fallback:(void (^)())fallback;

@end
