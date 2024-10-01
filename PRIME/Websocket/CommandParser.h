//
//  CommandParser.h
//  PRIME
//
//  Created by Artak on 8/19/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRWebSocketMessageContent.h"
#import "PRWebSocketMessageContentTasklink.h"
#import "PRWebSocketMessageContentText.h"
#import <Foundation/Foundation.h>

@interface CommandParser : NSObject

@property (nonatomic, strong) NSDictionary<NSString*, id>* jsonDictionary;

- (void)parse:(NSString*)response;

- (NSNumber*)type;
- (NSNumber*)requestId;
- (NSString*)guid;

- (NSNumber*)timestamp;
- (NSNumber*)status;
- (NSString*)clientId;
- (NSString*)chatId;
- (NSString*)contentGuid;
- (NSNumber*)messageType;
- (NSNumber*)ttl;

- (void)saveMessageModelWithCompletionHandler:(void (^)(BOOL succeed))completionHandler;
- (PRWebSocketFeedbackContent*)feedbackContent;
- (BOOL)isDuplicateMessage;
- (BOOL)isOwnMessage;
@end
