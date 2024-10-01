//
//  XNTKeychainQuery.m
//  XNTrends
//
//  Created by Simon Simonyan on 2/8/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "XNTKeychainQuery.h"
#import "XNTKeychainStore.h"

@implementation XNTKeychainQuery

- (BOOL)save
{
    if (!self.service || !self.key || !self.data) {
        return NO;
    }

    NSMutableDictionary *query = [self queryIncludingKey];

    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL);

    if (status == errSecSuccess) {
        if (self.data) {
            NSMutableDictionary *attributes = [self attributes];

            status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)attributes);
        } else {
            [self deleteItem];
        }
    } else if (status == errSecItemNotFound) {
        query = [self queryIncludingKeyAndData];

#if __IPHONE_4_0 && TARGET_OS_IPHONE
        CFTypeRef accessibilityType = [XNTKeychainStore accessibilityType];
        if (accessibilityType) {
            query[(__bridge id)kSecAttrAccessible] = (__bridge id)accessibilityType;
        }
#endif

        status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
    } else {
        return NO;
    }

    return (status == errSecSuccess) ? YES : NO;
}

- (BOOL)fetch
{
    if (!self.service || !self.key) {
        return NO;
    }

    NSMutableDictionary *query = [self queryIncludingKey];

    query[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;
    query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;

    CFTypeRef data = nil;

    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &data);

    if (status != errSecSuccess) {
        return NO;
    }

    self.data = (__bridge_transfer NSData *)data;

    return YES;
}

- (BOOL)deleteItem
{
    if (!self.service || !self.key) {
        return NO;
    }

    NSMutableDictionary *query = [self queryIncludingKey];

#if TARGET_OS_IPHONE
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
#else
    CFTypeRef result = NULL;
    [query setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnRef];
    status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status == errSecSuccess) {
        status = SecKeychainItemDelete((SecKeychainItemRef)result);
        CFRelease(result);
    }
#endif

    return (status == errSecSuccess || status == errSecItemNotFound) ? YES : NO;
}

- (NSArray *)fetchAll
{
    NSMutableDictionary *query = [self query];

    query[(__bridge id)kSecReturnAttributes] = (__bridge id)kCFBooleanTrue;
    query[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;
    query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitAll;

    CFTypeRef result = NULL;

    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);

    if (status != errSecSuccess) {
        return nil;
    }

    return (__bridge_transfer NSArray *)result;
}

- (BOOL)deleteAll
{
    //TODO: !!!
    return NO;
}

- (NSMutableDictionary *)query
{
    NSMutableDictionary *query = [[NSMutableDictionary alloc] init];

    query[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;

    if (self.service) {
        query[(__bridge id)kSecAttrService] = self.service;
    }

    if (self.identifier) {
        query[(__bridge id)kSecAttrGeneric] = self.identifier;
    }

//#if __IPHONE_3_0 && TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
    if (self.accessGroup) {
        [query setObject:self.accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
    }
//#endif

    return query;
}

- (NSMutableDictionary *)queryIncludingKey
{
    NSMutableDictionary *query = [self query];

    if (self.key) {
        query[(__bridge id)kSecAttrAccount] = self.key;
    }

    return query;
}

- (NSMutableDictionary *)queryIncludingKeyAndData
{
    NSMutableDictionary *query = [self queryIncludingKey];

    query[(__bridge id)kSecValueData] = self.data;

    return query;
}

- (NSMutableDictionary *) attributes {
     NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];

    attributes[(__bridge id)kSecValueData] = self.data;

    return attributes;
}

@end
