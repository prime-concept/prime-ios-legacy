//
//  NSDictionary+Keychain.m
//  PRIME
//
//  Created by Admin on 2/9/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "NSDictionary+Keychain.h"
#import "XNTKeychainStore.h"

@implementation NSDictionary (Keychain)

-(BOOL) storeToKeychainWithKey:(NSString *)key
{
    NSError *error = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: self
                                                       options: 0
                                                         error: &error];
    
    if ( !error ) {
        return [XNTKeychainStore setData: jsonData
                                  forKey: key];
    }
    
    return NO;
}


+(NSDictionary *) dictionaryFromKeychainWithKey:(NSString *)key
{
    NSError *error = nil;
    
    NSData *jsonData = [XNTKeychainStore dataForKey: key];
    
    if ( !jsonData ) {
        return nil;
    }
    
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData: jsonData
                                                        options: NSJSONReadingMutableLeaves | NSJSONReadingMutableContainers
                                                          error: &error];
    
    if ( error ) {
        return nil;
    }
    
    return res;
}

@end
