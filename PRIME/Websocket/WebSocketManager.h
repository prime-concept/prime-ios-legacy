//
//  WebSocketManager.h
//  PRIME
//
//  Created by Artak on 8/17/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SocketRocket/SRWebSocket.h>
#import "PRWebSocketMessageModel.h"

@interface WebSocketManager : NSObject <SRWebSocketDelegate>

/** Initializes web socket and creates operation queue for messages. */
+ (WebSocketManager*)sharedInstance;

/** Sends registration command for chat which returns all missed messages for first time. */
- (void)registerForChat:(NSString*)chatId;

/** Sends chat message. */
- (PRWebSocketMessageModel*)sendMessage:(NSString*)message forChat:(NSString*)chatId;

/** Sends feedback for chat message. */
- (void)sendFeedbackForMessage:(NSString*)messageId withStatus:(NSNumber*)status;

/** Resets state of message. */
+ (void)resetMessageState:(PRWebSocketMessageModel*)modelToSend;

-(BOOL)isSocketOpened;

@end
