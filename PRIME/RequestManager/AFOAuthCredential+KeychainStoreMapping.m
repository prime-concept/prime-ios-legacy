//
//  AFOAuthCredential+KeychainStoreMapping.m
//  PRIME
//
//  Created by Admin on 2/17/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "AFOAuthCredential+KeychainStoreMapping.h"

@interface AFOAuthCredential ()

- (NSDate *) expiration;

@end

@implementation AFOAuthCredential (KeychainStoreMapping)

+ (NSDictionary*)mts_mapping
{
    return @{
             @"at": mts_key(accessToken),
             @"tt": mts_key(tokenType),
             @"rt": mts_key(refreshToken),
             @"e": mts_key(expiration)
             };
}

+ (BOOL)mts_shouldSetUndefinedKeys
{
    return NO;
}

@end
