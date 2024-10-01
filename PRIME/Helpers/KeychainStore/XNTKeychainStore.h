//
//  XNTKeychainStore.h
//  XNTrends
//
//  Created by Simon Simonyan on 2/8/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XNTKeychainStore : NSObject

+ (XNTKeychainStore*)sharedStore;

+ (XNTKeychainStore*)storeWithIdentifier:(NSString*)identifier;

+ (XNTKeychainStore*)storeWithIdentifier:(NSString*)identifier
                                 service:(NSString*)service;

+ (XNTKeychainStore*)storeWithIdentifier:(NSString*)identifier
                                 service:(NSString*)service
                             accessGroup:(NSString*)accessGroup;

+ (void)setSharedStore:(XNTKeychainStore*)store;

- (XNTKeychainStore*)init;

- (XNTKeychainStore*)initWithIdentifier:(NSString*)identifier;

- (XNTKeychainStore*)initWithIdentifier:(NSString*)identifier
                                service:(NSString*)service;

- (XNTKeychainStore*)initWithIdentifier:(NSString*)identifier
                                service:(NSString*)service
                            accessGroup:(NSString*)accessGroup;

+ (NSString*)defaultIdentifier;

+ (void)setDefaultIdentifier:(NSString*)defaultIdentifier;

+ (NSString*)defaultService;

+ (void)setDefaultService:(NSString*)defaultService;

+ (NSString*)defaultAccessGroup;

+ (void)setDefaultAccessGroup:(NSString*)defaultAccessGroup;

+ (NSString*)defaultKeyPrefix;

+ (void)setDefaultKeyPrefix:(NSString*)defaultKeyPrefix;

#pragma mark -

+ (NSData*)dataForKey:(NSString*)key;

+ (NSData*)dataForKey:(NSString*)key
           identifier:(NSString*)identifier;

+ (NSData*)dataForKey:(NSString*)key
           identifier:(NSString*)identifier
              service:(NSString*)service;

+ (NSData*)dataForKey:(NSString*)key
           identifier:(NSString*)identifier
              service:(NSString*)service
          accessGroup:(NSString*)accessGroup;

+ (BOOL)setData:(NSData*)data
         forKey:(NSString*)key;

+ (BOOL)setData:(NSData*)data
         forKey:(NSString*)key
     identifier:(NSString*)identifier;

+ (BOOL)setData:(NSData*)data
         forKey:(NSString*)key
     identifier:(NSString*)identifier
        service:(NSString*)service;

+ (BOOL)setData:(NSData*)data
         forKey:(NSString*)key
     identifier:(NSString*)identifier
        service:(NSString*)service
    accessGroup:(NSString*)accessGroup;

- (BOOL)setData:(NSData*)data
         forKey:(NSString*)key;

- (NSData*)dataForKey:(NSString*)key;

+ (BOOL)deleteForKey:(NSString*)key;

+ (NSString*)accessToken;

+ (BOOL)deleteForKey:(NSString*)key
          identifier:(NSString*)identifier;

+ (BOOL)deleteForKey:(NSString*)key
          identifier:(NSString*)identifier
             service:(NSString*)service;

+ (BOOL)deleteForKey:(NSString*)key
          identifier:(NSString*)identifier
             service:(NSString*)service
         accessGroup:(NSString*)accessGroup;

- (BOOL)deleteForKey:(NSString*)key;

+ (BOOL)deleteAll;

+ (BOOL)deleteAllForIdentifier:(NSString*)identifier;

+ (BOOL)deleteAllForIdentifier:(NSString*)identifier
                       service:(NSString*)service;

+ (BOOL)deleteAllForIdentifier:(NSString*)identifier
                       service:(NSString*)service
                   accessGroup:(NSString*)accessGroup;

- (BOOL)deleteAll;

#if __IPHONE_4_0 && TARGET_OS_IPHONE
+ (CFTypeRef)accessibilityType;

+ (void)setAccessibilityType:(CFTypeRef)accessibilityType;
#endif

@property (nonatomic, readonly) NSString* identifier;
@property (nonatomic, readonly) NSString* service;
@property (nonatomic, readonly) NSString* accessGroup;

@end

@interface XNTKeychainStore (String)

+ (NSString*)stringForKey:(NSString*)key;

+ (NSString*)stringForKey:(NSString*)key
               identifier:(NSString*)identifier;

+ (NSString*)stringForKey:(NSString*)key
               identifier:(NSString*)identifier
                  service:(NSString*)service;

+ (NSString*)stringForKey:(NSString*)key
               identifier:(NSString*)identifier
                  service:(NSString*)service
              accessGroup:(NSString*)accessGroup;

+ (BOOL)setString:(NSString*)value
           forKey:(NSString*)key;

+ (BOOL)setString:(NSString*)value
           forKey:(NSString*)key
       identifier:(NSString*)identifier;

+ (BOOL)setString:(NSString*)value
           forKey:(NSString*)key
       identifier:(NSString*)identifier
          service:(NSString*)service;

+ (BOOL)setString:(NSString*)value
           forKey:(NSString*)key
       identifier:(NSString*)identifier
          service:(NSString*)service
      accessGroup:(NSString*)accessGroup;

- (void)setString:(NSString*)string
           forKey:(NSString*)key;

- (NSString*)stringForKey:(NSString*)key;

@end

@interface XNTKeychainStore (UnsignedLong)

@end

@interface XNTKeychainStore (Password)

@end

@interface XNTKeychainStore (PaymentCards)

@end
