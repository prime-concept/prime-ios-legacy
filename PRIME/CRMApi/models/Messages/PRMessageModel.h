//
//  PRMessageModel.h
//  PRIME
//
//  Created by Aram on 11/6/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRModel.h"
#import "PRTasklinkContent.h"

@interface PRMessageModel : PRModel

@property (nonatomic, strong) NSString* clientId;
@property (nonatomic, strong) NSString* guid;
@property (nonatomic, strong) NSNumber* externalId;
@property (nonatomic, strong) NSString* source;
@property (nonatomic, strong) NSString* type;
@property (nonatomic, strong) NSNumber* ttl;
@property (nonatomic, strong) NSString* channelId;
@property (nonatomic, strong) NSNumber* timestamp;
@property (nonatomic, strong) NSString* status;
@property (nonatomic, strong) NSNumber* updatedAt;
@property (nonatomic, strong) NSString* senderName;

@property (nonatomic, strong) NSString* text; // Used in case of text message.
@property (nonatomic, strong) PRTasklinkContent* content; // Used in case of task link.
@property (nonatomic, strong) NSString* audioFileName; // Used in case of voice message.
@property (nonatomic, strong) NSData* audioData; // Used in case of voice message.
@property (nonatomic, strong) NSString* mediaFileName; // Used in case of media message.
@property (nonatomic, strong) NSData* mediaData; // Used in case of media message.
@property (nonatomic, strong) NSString* mimeType; // Used for resend media message.

@property (nonatomic, assign) BOOL isSent;
@property (nonatomic, assign) MessageState state;
@property (nonatomic, assign) BOOL isReceivedFromServer;

+ (RKDynamicMapping*)mapping;
+ (RKObjectMapping*)inverseMappingForTextMessage;

- (BOOL)isTasklink;
- (ChatMessageType)messageType;
- (NSInteger)getMessageStatus;
- (NSInteger)getTasklinkMessageStatus;
- (NSString*)getDuration;

@end
