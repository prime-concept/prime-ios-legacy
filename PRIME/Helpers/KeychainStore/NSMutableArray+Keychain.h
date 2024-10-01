//
//  NSMutableArray+Keychain.h
//  XNTrends
//
//  Created by Simon Simonyan on 2/10/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Keychain)

+(NSMutableArray*) objectFromKeychainWithKey:(NSString *)key forClass: (Class) class;

@end
