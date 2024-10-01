//
//  WebSocketConstants.h
//  PRIME
//
//  Created by Artak on 8/21/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WebSoketCommandType) {
    WebSoketCommandType_Request = 1,
    WebSoketCommandType_Response
};

typedef NS_ENUM(NSInteger, WebSoketCommandId) {
    WebSoketCommandId_Register = 1,
    WebSoketCommandId_Message,
    WebSoketCommandId_Feedback
};

typedef NS_ENUM(NSInteger, WebSoketMessageStatus) {
    WebSoketMessageStatus_Sent = 1,
    WebSoketMessageStatus_Delivered,
    WebSoketMessageStatus_Seen,
    WebSoketMessageStatus_Deleted
};

//Prefix.
extern NSString const* const kClientPrefix;
extern NSString* const kChatPrefix;
extern NSString* const kMainChatPrefix;

//Base.
extern NSString* const kTypeKey;
extern NSString* const kRequestIdKey;
extern NSString* const kGuidKey;

//Body.
extern NSString* const kBody;
extern NSString* const kChatId;
extern NSString* const kClientId;
extern NSString* const kMessageId;
extern NSString* const kStatus;
extern NSString* const kTimestamp;
extern NSString* const kMessageType;
extern NSString* const kContent;
extern NSString* const kTimeToLive;
extern NSString* const kSenderName;
extern NSString* const kSource;
extern NSString* const kUpdatedAt;
extern NSString* const kChannelId;

//Task
extern NSString* const kTask;
extern NSString* const kTaskId;
extern NSString* const kTaskLinkMessage;

//Notifications.
extern NSString* const kMessageSent;
extern NSString* const kMessageReceived;
extern NSString* const kVoiceMessageReceived;
extern NSString* const kAudioFileReceived;
extern NSString* const kMessageStatusUpdated;
extern NSString* const kFeedbackReceived;
extern NSString* const kMessageDeletedFeedbackReceived;
extern NSString* const kUnseenMessageUpdate;
extern NSString* const kMessageInSending;
extern NSString* const kWebSocketDidOpen;
