//
//  CommandBuilder.h
//  PRIME
//
//  Created by Artak on 8/19/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRWebSocketFeedbackContent.h"
#import "PRWebSocketFeedbackModel.h"
#import "PRWebSocketMessageContent.h"
#import "PRWebSocketMessageModel.h"
#import "PRWebSocketRegistrationContent.h"
#import "PRWebSocketRegistrationModel.h"
#import "PRWebSocketResponseContent.h"
#import "PRWebSocketResponseModel.h"
#import <Foundation/Foundation.h>

@interface CommandBuilder : NSObject

/** Builds feedback command for message by messageId, status and chatId.*/
+ (NSString*)buildFeedbackCommandForMessage:(NSString*)messageId
                                  andStatus:(NSNumber*)status
                                  andChatId:(NSString*)chatId;

/** Builds registration command for chatId by times tamp.*/
+ (NSString*)buildRegistrationCommandForChatId:(NSString*)chatId
                                  andTimesTamp:(NSNumber*)timestamp;

/** Builds response for request by requestId, messageType, guid and status.*/
+ (NSString*)buildResponseForRequest:(NSNumber*)requestId
                             andGuid:(NSString*)guid
                      andMessageType:(NSNumber*)messageType
                           andStatus:(NSNumber*)status;

/** Build message command for message by guid.*/
+ (NSString*)buildMessageCommandForMessage:(NSString*)guid;

@end
