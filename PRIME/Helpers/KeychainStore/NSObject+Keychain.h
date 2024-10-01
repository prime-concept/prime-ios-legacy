//
//  NSObject+Keychain.h
//  XNTrends
//
//  Created by Simon Simonyan on 2/9/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Keychain)

- (BOOL) storeToKeychainWithKey:(NSString *)key;

+ (instancetype) objectFromKeychainWithKey:(NSString *)key;

@end
