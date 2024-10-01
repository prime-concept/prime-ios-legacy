//
//  Config.h
//  PRIME
//
//  Created by Андрей Соловьев on 01.03.2023.
//  Copyright © 2023 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *isProdEnabledKey;

@interface Config : NSObject

@property(class, nonatomic, setter=setProdEnabled:) BOOL isProdEnabled;
@property(class, nonatomic, setter=setDebugEnabled:) BOOL isDebugEnabled;

+ (NSString *)crmEndpoint;
+ (NSString *)chatEndpoint;

@end

extern NSString *resolve(NSString * prod, NSString *dev);

NS_ASSUME_NONNULL_END
