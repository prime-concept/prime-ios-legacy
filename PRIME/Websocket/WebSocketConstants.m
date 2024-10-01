//
//  WebSocketConstants.m
//  PRIME
//
//  Created by Artak on 8/21/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "WebSocketConstants.h"

NSString const* const kClientPrefix = @"C";
NSString* const kChatPrefix = @"T";
NSString* const kMainChatPrefix = @"N";
//Base.
NSString* const kTypeKey = @"type";
NSString* const kRequestIdKey = @"requestId";
NSString* const kGuidKey = @"guid";

//Body.
NSString* const kBody = @"body";
NSString* const kChatId = @"chatId";
NSString* const kClientId = @"clientId";
NSString* const kMessageId = @"messageId";
NSString* const kStatus = @"status";
NSString* const kTimestamp = @"timestamp";
NSString* const kMessageType = @"messageType";
NSString* const kContent = @"content";
NSString* const kTimeToLive = @"ttl";
NSString* const kSenderName = @"senderName";
NSString* const kSource = @"source";
NSString* const kUpdatedAt = @"updatedAt";
NSString* const kChannelId = @"channelId";

NSString* const kMessageSent = @"kMessageSent";
NSString* const kMessageReceived = @"kMessageReceived";
NSString* const kVoiceMessageReceived = @"kVoiceMessageReceived";
NSString* const kAudioFileReceived = @"kAudioFileReceived";
NSString* const kMessageStatusUpdated = @"kMessageStatusUpdated";
NSString* const kMessageDeletedFeedbackReceived = @"kMessageDeletedFeedbackReceived";
NSString* const kFeedbackReceived = @"kFeedbackReceived";
NSString* const kMessageInSending = @"kMessageInSending";
NSString* const kWebSocketDidOpen = @"kWebSocketDidOpen";

NSString* const kUnseenMessageUpdate = @"kUnseenMessageUpdate";

NSString* const kTask = @"task";
NSString* const kTaskId = @"taskId";
NSString* const kTaskLinkMessage = @"message";
