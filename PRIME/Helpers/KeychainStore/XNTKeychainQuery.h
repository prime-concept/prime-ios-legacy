//
//  XNTKeychainQuery.h
//  XNTrends
//
//  Created by Simon Simonyan on 2/8/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XNTKeychainQuery : NSObject

/** kSecAttrGeneric */
@property (nonatomic, copy) NSString *identifier;

/** kSecAttrService */
@property (nonatomic, copy) NSString *service;

/** kSecAttrAccount */
@property (nonatomic, copy) NSString *key;

/** kSecAttrData */
@property (nonatomic, copy) NSData *data;

/** kSecAttrAccessGroup */
@property (nonatomic, copy) NSString *accessGroup;

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL save;

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL fetch;

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL deleteItem;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *fetchAll;

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL deleteAll;

@end
