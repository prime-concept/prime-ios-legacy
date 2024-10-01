//
//  XNTKeychainStore.m
//  XNTrends
//
//  Created by Simon Simonyan on 2/8/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "XNTKeychainStore.h"
#import "XNTKeychainQuery.h"
#import "AFOAuth2Client.h"
#import "NSObject+Keychain.h"
#import "Constants.h"

static XNTKeychainStore* _store = nil;
static NSString* _defaultIdentifier = nil;
static NSString* _defaultService = nil;
static NSString* _defaultAccessGroup = nil;
static NSString* _defaultKeyPrefix = nil;

#if __IPHONE_4_0 && TARGET_OS_IPHONE
static CFTypeRef XNKeychainAccessibilityType = NULL;
#endif

@interface XNTKeychainStore () {

    NSObject* syncObj;
}

@end

@implementation XNTKeychainStore

+ (XNTKeychainStore*)sharedStore
{
    if (!_store) {
        _store = [[self alloc] init];
    }

    return _store;
}

+ (void)setSharedStore:(XNTKeychainStore*)store
{
    @synchronized([self class])
    {
        _store = store;
    }
}

+ (XNTKeychainStore*)storeWithIdentifier:(NSString*)identifier
{
    return [[self alloc] initWithIdentifier:identifier];
}

+ (XNTKeychainStore*)storeWithIdentifier:identifier
                                 service:service
{
    return [[self alloc] initWithIdentifier:identifier
                                    service:service];
}

+ (XNTKeychainStore*)storeWithIdentifier:(NSString*)identifier
                                 service:(NSString*)service
                             accessGroup:(NSString*)accessGroup
{
    return [[self alloc] initWithIdentifier:identifier
                                    service:service
                                accessGroup:accessGroup];
}

+ (NSString*)defaultIdentifier
{
    return _defaultIdentifier;
}

+ (NSString*)defaultService
{
    if (!_defaultService) {
        _defaultService = [[NSBundle mainBundle] bundleIdentifier];
    }

    return _defaultService;
}

+ (NSString*)defaultAccessGroup
{
    return _defaultAccessGroup;
}

+ (NSString*)accessToken
{
    AFOAuthCredential* credential = [AFOAuthCredential objectFromKeychainWithKey:kCredentialKeyPath];

    return credential ? credential.accessToken : @"";
}

+ (NSString*)defaultKeyPrefix
{
    return _defaultKeyPrefix;
}

+ (void)setDefaultIdentifier:(NSString*)defaultIdentifier
{
    NSString* oldIdentifier = [self defaultIdentifier];

    if (_defaultIdentifier) {
        @synchronized(_defaultIdentifier)
        {
            if (defaultIdentifier) {
                _defaultIdentifier = [[NSString alloc] initWithString:defaultIdentifier];
            } else {
                _defaultIdentifier = nil;
            }
        }
    } else {
        if (defaultIdentifier) {
            _defaultIdentifier = [[NSString alloc] initWithString:defaultIdentifier];
        } else {
            _defaultIdentifier = nil;
        }
    }

    if (![oldIdentifier isEqualToString:_defaultIdentifier]) {

        XNTKeychainStore* store = [self sharedStore];

        [self setSharedStore:
                  [[self alloc] initWithIdentifier:[self defaultIdentifier]
                                           service:[store service]
                                       accessGroup:[store accessGroup]]];
    }
}

+ (void)setDefaultService:(NSString*)defaultService
{
    NSString* oldService = [self defaultService];

    if (_defaultService) {
        @synchronized(_defaultService)
        {
            if (defaultService) {
                _defaultService = [[NSString alloc] initWithString:defaultService];
            } else {
                _defaultService = nil;
            }
        }
    } else {
        if (defaultService) {
            _defaultService = [[NSString alloc] initWithString:defaultService];
        } else {
            _defaultService = nil;
        }
    }

    if (![oldService isEqualToString:_defaultService]) {

        XNTKeychainStore* store = [self sharedStore];

        [self setSharedStore:
                  [[self alloc] initWithIdentifier:[store identifier]
                                           service:[self defaultService]
                                       accessGroup:[store accessGroup]]];
    }
}

+ (void)setDefaultAccessGroup:(NSString*)defaultAccessGroup
{
    NSString* oldAccessGroup = [self defaultAccessGroup];

    if (_defaultAccessGroup) {
        @synchronized(_defaultAccessGroup)
        {
            if (defaultAccessGroup) {
                _defaultAccessGroup = [[NSString alloc] initWithString:defaultAccessGroup];
            } else {
                _defaultAccessGroup = nil;
            }
        }
    } else {
        if (defaultAccessGroup) {
            _defaultAccessGroup = [[NSString alloc] initWithString:defaultAccessGroup];
        } else {
            _defaultAccessGroup = nil;
        }
    }

    if (![oldAccessGroup isEqualToString:_defaultAccessGroup]) {

        XNTKeychainStore* store = [self sharedStore];

        [self setSharedStore:
                  [[self alloc] initWithIdentifier:[store identifier]
                                           service:[store service]
                                       accessGroup:[self defaultAccessGroup]]];
    }
}

+ (void)setDefaultKeyPrefix:(NSString*)defaultKeyPrefix
{
    if (_defaultKeyPrefix) {
        @synchronized(_defaultKeyPrefix)
        {
            if (defaultKeyPrefix) {
                _defaultKeyPrefix = [[NSString alloc] initWithString:defaultKeyPrefix];
            } else {
                _defaultKeyPrefix = nil;
            }
        }
    } else {
        if (defaultKeyPrefix) {
            _defaultKeyPrefix = [[NSString alloc] initWithString:defaultKeyPrefix];
        } else {
            _defaultKeyPrefix = nil;
        }
    }
}

+ (NSString*)keyIncludingPrefix:(NSString*)key
{
    NSString* prefix = [self.class defaultKeyPrefix];
    if (prefix != nil  && ![key containsString:prefix]) {
        return [[NSString alloc] initWithFormat:@"%@%@", prefix, key];
    }
    return key;
}

- (XNTKeychainStore*)init
{
    return [self initWithIdentifier:nil];
}

- (XNTKeychainStore*)initWithIdentifier:(NSString*)identifier
{
    return [self initWithIdentifier:identifier
                            service:nil];
}

- (XNTKeychainStore*)initWithIdentifier:(NSString*)identifier
                                service:(NSString*)service
{
    return [self initWithIdentifier:identifier
                            service:service
                        accessGroup:nil];
}

- (XNTKeychainStore*)initWithIdentifier:(NSString*)identifier
                                service:(NSString*)service
                            accessGroup:(NSString*)accessGroup
{
    self = [super init];
    if (self) {

        if (!identifier) {
            _identifier = [self.class defaultIdentifier];
        } else {
            _identifier = [[NSString alloc] initWithString:identifier];
        }

        if (!service) {
            _service = [self.class defaultService];
        } else {
            _service = [[NSString alloc] initWithString:service];
        }

        if (!accessGroup) {
            _accessGroup = [self.class defaultAccessGroup];
        } else {
            _accessGroup = [[NSString alloc] initWithString:accessGroup];
        }
    }

    return self;
}

#pragma mark -

+ (NSData*)dataForKey:(NSString*)key
{
    XNTKeychainStore* store = [self.class sharedStore];

    return [store dataForKey:key];
}

+ (NSData*)dataForKey:(NSString*)key
           identifier:(NSString*)identifier
{
    XNTKeychainStore* store = [self.class storeWithIdentifier:identifier];

    return [store dataForKey:key];
}

+ (NSData*)dataForKey:(NSString*)key
           identifier:(NSString*)identifier
              service:(NSString*)service
{
    XNTKeychainStore* store = [self.class storeWithIdentifier:identifier
                                                      service:service];

    return [store dataForKey:key];
}

+ (NSData*)dataForKey:(NSString*)key
           identifier:(NSString*)identifier
              service:(NSString*)service
          accessGroup:(NSString*)accessGroup
{
    XNTKeychainStore* store = [self.class storeWithIdentifier:identifier
                                                      service:service
                                                  accessGroup:accessGroup];

    return [store dataForKey:key];
}

+ (BOOL)setData:(NSData*)data
         forKey:(NSString*)key
{
    XNTKeychainStore* store = [self.class sharedStore];

    return [store setData:data
                   forKey:key];
}

+ (BOOL)setData:(NSData*)data
         forKey:(NSString*)key
     identifier:(NSString*)identifier
{
    XNTKeychainStore* store = [self.class storeWithIdentifier:identifier];

    return [store setData:data
                   forKey:key];
}

+ (BOOL)setData:(NSData*)data
         forKey:(NSString*)key
     identifier:(NSString*)identifier
        service:(NSString*)service
{
    XNTKeychainStore* store = [self.class storeWithIdentifier:identifier
                                                      service:service];

    return [store setData:data
                   forKey:key];
}

+ (BOOL)setData:(NSData*)data
         forKey:(NSString*)key
     identifier:(NSString*)identifier
        service:(NSString*)service
    accessGroup:(NSString*)accessGroup
{
    XNTKeychainStore* store = [self.class storeWithIdentifier:identifier
                                                      service:service
                                                  accessGroup:accessGroup];

    return [store setData:data
                   forKey:key];
}

- (BOOL)setData:(NSData*)data
         forKey:(NSString*)key
{
    XNTKeychainQuery* query = [[XNTKeychainQuery alloc] init];
    query.identifier = _identifier;
    query.service = _service;
    query.accessGroup = _accessGroup;
    query.key = [self.class keyIncludingPrefix:key];
    query.data = data;

    return [query save];
}

- (NSData*)dataForKey:(NSString*)key
{
    XNTKeychainQuery* query = [[XNTKeychainQuery alloc] init];
    query.identifier = _identifier;
    query.service = _service;
    query.accessGroup = _accessGroup;
    query.key = [self.class keyIncludingPrefix:key];

    [query fetch];

    return query.data;
}

+ (BOOL)deleteForKey:(NSString*)key
{
    XNTKeychainStore* store = [self.class sharedStore];

    return [store deleteForKey:key];
}

+ (BOOL)deleteForKey:(NSString*)key
          identifier:(NSString*)identifier
{
    XNTKeychainStore* store = [self.class storeWithIdentifier:identifier];

    return [store deleteForKey:key];
}

+ (BOOL)deleteForKey:(NSString*)key
          identifier:(NSString*)identifier
             service:(NSString*)service
{
    XNTKeychainStore* store = [self.class storeWithIdentifier:identifier
                                                      service:service];

    return [store deleteForKey:key];
}

+ (BOOL)deleteForKey:(NSString*)key
          identifier:(NSString*)identifier
             service:(NSString*)service
         accessGroup:(NSString*)accessGroup
{
    XNTKeychainStore* store = [self.class storeWithIdentifier:identifier
                                                      service:service
                                                  accessGroup:accessGroup];

    return [store deleteForKey:key];
}

- (BOOL)deleteForKey:(NSString*)key
{
    XNTKeychainQuery* query = [[XNTKeychainQuery alloc] init];
    query.identifier = _identifier;
    query.service = _service;
    query.accessGroup = _accessGroup;
    query.key = [self.class keyIncludingPrefix:key];

    return [query deleteItem];
}

+ (BOOL)deleteAll
{
    XNTKeychainStore* store = [self.class sharedStore];

    return [store deleteAll];
}

+ (BOOL)deleteAllForIdentifier:(NSString*)identifier
{
    XNTKeychainStore* store = [self.class storeWithIdentifier:identifier];

    return [store deleteAll];
}

+ (BOOL)deleteAllForIdentifier:(NSString*)identifier
                       service:(NSString*)service
{
    XNTKeychainStore* store = [self.class storeWithIdentifier:identifier
                                                      service:service];

    return [store deleteAll];
}

+ (BOOL)deleteAllForIdentifier:(NSString*)identifier
                       service:(NSString*)service
                   accessGroup:(NSString*)accessGroup
{
    XNTKeychainStore* store = [self.class storeWithIdentifier:identifier
                                                      service:service
                                                  accessGroup:accessGroup];

    return [store deleteAll];
}

- (BOOL)deleteAll
{
    XNTKeychainQuery* query = [[XNTKeychainQuery alloc] init];
    query.identifier = _identifier;
    query.service = _service;
    query.accessGroup = _accessGroup;

    return [query deleteAll];
}

#pragma mark -

#if __IPHONE_4_0 && TARGET_OS_IPHONE
+ (CFTypeRef)accessibilityType
{
    return XNKeychainAccessibilityType;
}

+ (void)setAccessibilityType:(CFTypeRef)accessibilityType
{
    CFRetain(accessibilityType);
    if (XNKeychainAccessibilityType) {
        CFRelease(XNKeychainAccessibilityType);
    }
    XNKeychainAccessibilityType = accessibilityType;
}
#endif

@end

@implementation XNTKeychainStore (String)

+ (NSString*)stringForKey:(NSString*)key
{
    return [self stringForKey:key
                   identifier:nil];
}

+ (NSString*)stringForKey:(NSString*)key
               identifier:(NSString*)identifier
{
    return [self stringForKey:key
                   identifier:identifier
                      service:nil];
}

+ (NSString*)stringForKey:(NSString*)key
               identifier:(NSString*)identifier
                  service:(NSString*)service
{
    return [self stringForKey:key
                   identifier:identifier
                      service:service
                  accessGroup:nil];
}

+ (NSString*)stringForKey:(NSString*)key
               identifier:(NSString*)identifier
                  service:(NSString*)service
              accessGroup:(NSString*)accessGroup
{
    NSData* data = [self dataForKey:key
                         identifier:identifier
                            service:service
                        accessGroup:accessGroup];
    if (data) {
        NSString *password = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        data = [self dataForKey:kPasscodeKey
                     identifier:identifier
                        service:service
                    accessGroup:accessGroup];
        if (password.length == 0 && data) {
            password = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
        return password;
    } else {
        data = [self dataForKey:kPasscodeKey
                     identifier:identifier
                        service:service
                    accessGroup:accessGroup];
        if (data) {
            return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    }

    return nil;
}

- (NSString*)stringForKey:(NSString*)key
{
    NSData* data = [self dataForKey:key];
    if (data) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }

    return nil;
}

+ (BOOL)setString:(NSString*)value
           forKey:(NSString*)key
{
    return [self setString:value
                    forKey:key
                identifier:nil];
}

+ (BOOL)setString:(NSString*)value
           forKey:(NSString*)key
       identifier:(NSString*)identifier
{
    return [self setString:value
                    forKey:key
                identifier:identifier
                   service:nil];
}

+ (BOOL)setString:(NSString*)value
           forKey:(NSString*)key
       identifier:(NSString*)identifier
          service:(NSString*)service
{
    return [self setString:value
                    forKey:key
                identifier:identifier
                   service:service
               accessGroup:nil];
}

+ (BOOL)setString:(NSString*)value
           forKey:(NSString*)key
       identifier:(NSString*)identifier
          service:(NSString*)service
      accessGroup:(NSString*)accessGroup
{
    NSData* data = [value dataUsingEncoding:NSUTF8StringEncoding];
    return [self setData:data
                  forKey:key
              identifier:identifier
                 service:service
             accessGroup:accessGroup];
}

- (void)setString:(NSString*)string
           forKey:(NSString*)key
{
    [self setData:[string dataUsingEncoding:NSUTF8StringEncoding]
           forKey:key];
}

@end
