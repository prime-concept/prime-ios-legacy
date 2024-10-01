//
//  NSMutableArray+Keychain.m
//  XNTrends
//
//  Created by Simon Simonyan on 2/10/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "NSMutableArray+Keychain.h"
#import "NSObject+Keychain.h"

@interface NSObject ()

+(id) dictFromKeychainWithKey:(NSString *)key;

@end



@implementation NSMutableArray (Keychain)

+(id) objectFromKeychainWithKey:(NSString *)key
{
    NSAssert(NO, @"Use objectFromKeychainWithKey: forClass:");
    return nil;
}

+(NSMutableArray*) objectFromKeychainWithKey:(NSString *)key forClass: (Class) class
{
    id dict = [self.class dictFromKeychainWithKey: key];
    
    if ( !dict) {
        return [[NSMutableArray alloc] init];
    }
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    [dict enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id value = obj;
        
        if (!value) {
            value = [NSNull null];
        } else if ([[value class]isSubclassOfClass:[NSObject class]]) {
            id object = [[class alloc] init];
            [object mts_setValuesForKeysWithDictionary: value];
            value = object;
        }
        
        [array addObject: value];
    }];
    
    return array;
}

@end
