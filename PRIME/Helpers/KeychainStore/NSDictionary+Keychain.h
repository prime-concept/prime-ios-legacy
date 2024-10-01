//
//  NSDictionary+Keychain.h
//  PRIME
//
//  Created by Admin on 2/9/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Keychain)

-(BOOL) storeToKeychainWithKey:(NSString *)key;

+(NSDictionary *) dictionaryFromKeychainWithKey:(NSString *)key;

@end
