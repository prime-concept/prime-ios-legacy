//
//  PRWebSocketMessageContent.h
//  PRIME
//
//  Created by Artak on 17/08/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PRWebSocketMessageContent : PRModel

@property (nonatomic, retain) NSString* messageId;
@property (nonatomic, retain) NSString* clientId;
@property (nonatomic, retain) NSString* chatId;
@property (nonatomic, retain) NSNumber* timestamp;
@property (nonatomic, retain) NSNumber* ttl;
@property (nonatomic, retain) NSString* messageType;
@property (nonatomic, retain) NSNumber* status;

+ (NSString*)messageTypeString:(ChatMessageType)messageType;
@end
