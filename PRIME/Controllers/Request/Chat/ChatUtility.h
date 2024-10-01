//
//  ChatUtility.h
//  PRIME
//
//  Created by Simon on 1/23/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatUtility : NSObject

+ (NSString*)clientIdWithPrefix;

+ (NSString*)mainChatIdWithPrefix;

+ (NSString*)chatIdWithPrefix:(NSString*)chatId;

+ (NSString*)formatedTime:(NSDate*)date;

+ (NSString*)formatedDate:(NSDate*)date;

+ (BOOL)isYesterday:(NSDate*)date;

@end
