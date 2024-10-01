//
//  PRMessageModel.m
//  PRIME
//
//  Created by Aram on 11/6/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRMessageModel.h"
#import "PRAudioPlayer.h"

@implementation PRMessageModel

#ifdef USE_COREDATA
@dynamic clientId, guid, externalId, source, type, ttl, channelId, content, timestamp, status, updatedAt, text, senderName, audioFileName, audioData, isReceivedFromServer, mediaFileName, mediaData, mimeType;
#endif

@dynamic isSent;
@dynamic state;

#pragma mark - Mapping

+ (RKDynamicMapping*)mapping
{
    static RKDynamicMapping* dynamicMapping = nil;

    pr_dispatch_once({

        dynamicMapping = [RKDynamicMapping new];

        [dynamicMapping setObjectMappingForRepresentationBlock:^RKObjectMapping*(id representation) {
            id content = [representation valueForKey:@"content"];

            if ([self.class isInvalidMessage:representation]) {
                return nil;
            } else if (!content) {
                return [self.class mappingForStatusChanging];
            } else if ([content isKindOfClass:[NSString class]]) {
                return [self.class mappingForTextMessage];
            }

            return [self.class mappingForTasklinkMessage];
        }];

    });

    return dynamicMapping;
}

+ (RKObjectMapping*)inverseMappingForTextMessage
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({
        mapping = [super mapping];

        [self addMapingAttributes:mapping];

        [mapping addAttributeMappingsFromDictionary:@{ @"content" : @"text" }];
    });

    return [mapping inverseMapping];
}

+ (void)addMapingAttributes:(RKObjectMapping*)mapping
{
    [mapping addAttributeMappingsFromArray:
                 @[
                    @"senderName",
                    @"clientId",
                    @"guid",
                    @"externalId",
                    @"source",
                    @"type",
                    @"ttl",
                    @"channelId",
                    @"timestamp",
                    @"status",
                    @"updatedAt"
                 ]];

    [super setIdentificationAttributes:@[ @"guid" ] mapping:mapping];
}

+ (RKObjectMapping*)mappingForStatusChanging
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({
        mapping = [super mapping];

        [self addMapingAttributes:mapping];
    });

    return mapping;
}

+ (RKObjectMapping*)mappingForTasklinkMessage
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({
        mapping = [super mapping];

        [self addMapingAttributes:mapping];

        [mapping addRelationshipMappingWithSourceKeyPath:@"content"
                                                 mapping:[PRTasklinkContent mapping]];
    });

    return mapping;
}

+ (RKObjectMapping*)mappingForTextMessage
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({
        mapping = [super mapping];

        [self addMapingAttributes:mapping];

        [mapping addAttributeMappingsFromDictionary:@{
            @"content" : @"text"
        }];
    });

    return mapping;
}

+ (BOOL)isInvalidMessage:(id)representation
{
    NSString* guid = [representation valueForKey:kGuidKey];
    PRMessageModel* oldModel = [PRDatabase messageByGuid:guid];

    if (!oldModel) {

        id content = [representation valueForKey:kContent];

        // In case the message is tasklink.
        if (![content isKindOfClass:[NSString class]]) {

            NSNumber* taskID = [[content valueForKey:kTask] valueForKey:kTaskId];
            NSArray<PRMessageModel*>* taskLinkMessages = [PRDatabase taskLinkMessagesByTaskId:taskID];

            if (![taskLinkMessages count]) {
                return NO;
            }

            PRMessageModel* lastMessage = [taskLinkMessages lastObject];
            NSNumber* newMessageTimestamp = [representation valueForKey:kTimestamp];

            // In case if there is already a more recent taskLink message for the task.
            if ([newMessageTimestamp integerValue] < [[lastMessage timestamp] integerValue]) {
                return YES;
            }
        }

        return NO;
    }

    NSArray* statusTypes = [self.class statusTypes];

    NSInteger newStatus = [statusTypes indexOfObject:[representation valueForKey:kStatus]];
    NSInteger oldStatus = [statusTypes indexOfObject:oldModel.status];

    // In case if received a status update that have status lower than existed.
    if (newStatus <= oldStatus) {
        return YES;
    }

    return NO;
}

+ (NSArray*)statusTypes
{
    return @[ @"", @"SENT", @"RESERVED", @"SEEN", @"DELETED" ];
}

#pragma mark - Public Functions

- (BOOL)isTasklink
{
    return self.content != nil;
}

- (NSInteger)getMessageStatus
{
    NSArray* statusTypes = [self.class statusTypes];
    NSString* status = [[self.status stringByReplacingOccurrencesOfString:@" " withString:@""] uppercaseString];

    return [statusTypes indexOfObject:status];
}

- (NSInteger)getTasklinkMessageStatus
{
    if (![self isTasklink] || !self.content.message) {
        return 0;
    }

    return [self.content.message.body.status integerValue];
}

- (ChatMessageType)messageType
{
    ChatMessageType result = ChatMessageType_Text;

    if ([self.type isEqualToString:kMessageType_Text] && self.text) {
        result = ChatMessageType_Text;
    } else if ([self.type isEqualToString:kMessageType_VoiceMessage] && (self.audioFileName || self.text)) {
        result = ChatMessageType_Voice;
    } else if ([self.type isEqualToString:kMessageType_Image] && (self.mediaFileName || self.text)) {
        result = ChatMessageType_Image;
    } else if ([self.type isEqualToString:kMessageType_Video] && (self.mediaFileName || self.text)) {
        result = ChatMessageType_Video;
    } else if ([self.type isEqualToString:kMessageType_Contact] && (self.mediaFileName || self.text)) {
            result = ChatMessageType_Contact;
    } else if ([self.type isEqualToString:kMessageType_Location] && (self.mediaFileName || self.text)) {
        result = ChatMessageType_Location;
    } else if ([self.type isEqualToString:kMessageType_TaskLink] && self.content) {
        result = ChatMessageType_Tasklink;
    } else if ([self.type isEqualToString:kMessageType_Document] && (self.mediaFileName || self.text)) {
        result = ChatMessageType_Document;
    }

    return result;
}

- (NSString*)getDuration
{
    PRAudioPlayer* player = [[PRAudioPlayer alloc] initWithAudioFileName:self.audioFileName];
    return [player duration];
}

@end
