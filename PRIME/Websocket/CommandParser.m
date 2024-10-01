//
//  CommandParser.m
//  PRIME
//
//  Created by Artak on 8/19/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "ChatUtility.h"
#import "CommandBuilder.h"
#import "CommandParser.h"
#import "PRWebSocketBaseModel.h"
#import "PRWebSocketFeedbackContent.h"
#import "PRWebSocketFeedbackModel.h"
#import "PRWebSocketMessageContent.h"
#import "PRWebSocketMessageModel.h"
#import "PRWebSocketMessageModelTasklink.h"
#import "PRWebSocketTasklinkContent.h"

@implementation CommandParser

- (void)parse:(NSString*)response
{
    _jsonDictionary = [self.class jsonStringToDictionary:response];
}

+ (NSDictionary*)jsonStringToDictionary:(NSString*)jsonString
{
    NSError* error;
    NSData* data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary* jsonDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:kNilOptions
                                                                     error:&error];
    return jsonDictionary;
}

- (NSNumber*)type
{
    return _jsonDictionary[kTypeKey];
}

- (NSNumber*)requestId
{
    return _jsonDictionary[kRequestIdKey];
}

- (NSString*)guid
{
    return _jsonDictionary[kGuidKey];
}

- (NSNumber*)timestamp
{
    return _jsonDictionary[kBody][kTimestamp];
}

- (NSNumber*)status
{
    return _jsonDictionary[kBody][kStatus];
}

- (NSString*)clientId
{
    return _jsonDictionary[kBody][kClientId];
}

- (NSString*)chatId
{
    return _jsonDictionary[kBody][kChatId];
}

- (NSString*)contentGuid
{
    return _jsonDictionary[kBody][kMessageId];
}

- (NSNumber*)messageType
{
    return _jsonDictionary[kBody][kMessageType];
}

- (NSNumber*)ttl
{
    return _jsonDictionary[kBody][kTimeToLive];
}

- (NSString*)base64DecodeString:(NSString*)base64String
{
#ifdef CHAT_BASE64_ENCODING_FUNC
    NSData* decodedData = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    NSString* decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    if (!decodedString) {
        decodedString = [[NSString alloc] initWithData:decodedData encoding:NSWindowsCP1251StringEncoding];
    }
    return decodedString;
#endif
    return base64String;
}

- (BOOL)isOwnMessage
{
    NSString* clienId = _jsonDictionary[kBody][kClientId];
    return [clienId isEqualToString:[ChatUtility clientIdWithPrefix]];
}

- (BOOL)isDuplicateMessage
{
    NSString* messageId = _jsonDictionary[kBody][kMessageId];
    PRWebSocketMessageContent* messageModel = [PRDatabase webSocketMessageContentForGuid:messageId];
    return messageModel != nil;
}

- (void)saveMessageModelWithCompletionHandler:(void (^)(BOOL succeed))completionHandler
{
    NSString* chatIdString = _jsonDictionary[kBody][kChatId];
    if (!chatIdString || [chatIdString isEqualToString:@""]) {
        completionHandler(NO);
        return;
    }

    NSInteger type = [_jsonDictionary[kBody][kMessageType] integerValue];
    NSDictionary* taskLinkJson = _jsonDictionary[kBody][kContent];

    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;

    NSString* chatIdPrefix = [chatIdString substringToIndex:1];
    NSString* chatIdWithoutPrefixString = [chatIdString substringFromIndex:1];
    NSNumber* chatIdWithoutPrefix = (type == ChatMessageType_Tasklink) ? taskLinkJson[kTask][kTaskId] : [numberFormatter numberFromString:chatIdWithoutPrefixString];

    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"chatId == %@", chatIdWithoutPrefix];
    NSArray<PRTaskDetailModel*>* task = [PRTaskDetailModel MR_findAllWithPredicate:predicate];
    NSArray<PRTaskDetailModel*>* tasks = [PRTaskDetailModel MR_findAll];

    // Do not save the received message:
    // 1) if the message is a tasklink (type == 4) and it has not associated task.
    // 2) if the message is a text (type == 0), it is not a main chat message (chatId starts with "T") and it has not associated task.
    if (tasks.count && !task.count && (type == ChatMessageType_Tasklink || ![chatIdPrefix isEqualToString:@"N"])) {
        completionHandler(NO);
        return;
    }

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext* localContext) {

        PRWebSocketMessageBaseModel* model = nil;

        if (type == ChatMessageType_Tasklink) {
            NSNumber* taskId = taskLinkJson[kTask][kTaskId];
            PRWebSocketMessageModelTasklink* oldModel = [PRDatabase webSocketTasklinkModelForTaskId:taskId inContext:localContext];

            if (!oldModel) {
                model = [PRWebSocketMessageModelTasklink MR_createEntityInContext:localContext];
            } else {
                model = [oldModel MR_inContext:localContext];
                if ([oldModel.body.timestamp longValue] > [_jsonDictionary[kBody][kTimestamp] longValue]) {
                    return;
                }
            }
        } else {
            model = [PRWebSocketMessageModel MR_createEntityInContext:localContext];
        }

        model.guid = _jsonDictionary[kGuidKey];
        model.requestId = _jsonDictionary[kRequestIdKey];
        model.type = _jsonDictionary[kTypeKey];
        model.creationDate = [NSDate new];

        PRWebSocketMessageContent* message = nil;
        NSInteger status = [_jsonDictionary[kBody][kStatus] integerValue];

        if (type == ChatMessageType_Tasklink) {
            NSMutableDictionary* contentDictionary = [[NSMutableDictionary alloc] initWithDictionary:_jsonDictionary[kBody][kContent]];
            NSMutableDictionary* tasklinkMessage = [[NSMutableDictionary alloc] initWithDictionary:contentDictionary[kTaskLinkMessage]];
            NSMutableDictionary* tasklinkMessageBody = [[NSMutableDictionary alloc] initWithDictionary:tasklinkMessage[kBody]];
            NSString* messageId = tasklinkMessageBody[kMessageId];

            // Get tasklink message body if exists.
            PRWebSocketMessageContent* taskLinkContentExistingMessage = [PRDatabase webSocketMessageContentForMessageId:messageId inContext:localContext];

            if (taskLinkContentExistingMessage) {
                [tasklinkMessageBody removeObjectForKey:kStatus];
                [tasklinkMessage setValue:tasklinkMessageBody forKey:kBody];
                [contentDictionary setValue:tasklinkMessage forKey:kTaskLinkMessage];
            }

            message = [PRWebSocketMessageContentTasklink MR_createEntityInContext:localContext];
            message.messageType = [PRWebSocketMessageContent messageTypeString:ChatMessageType_Tasklink];

            //--- Start preparing TaskLinkContent ---//
            PRWebSocketTasklinkContent* taskLinkContent = [PRWebSocketTasklinkContent MR_createEntityInContext:localContext];
            RKMappingOperation* mappingOperation = [[RKMappingOperation alloc] initWithSourceObject:contentDictionary
                                                                                  destinationObject:taskLinkContent
                                                                                            mapping:[PRWebSocketTasklinkContent mapping]];
            RKManagedObjectMappingOperationDataSource* mappingDS = [[RKManagedObjectMappingOperationDataSource alloc] initWithManagedObjectContext:localContext
                                                                                                                                             cache:[[[RKObjectManager sharedManager] managedObjectStore] managedObjectCache]];
            mappingOperation.dataSource = mappingDS;
            [mappingOperation performMapping:nil];

            NSString* innerMessageText = taskLinkContent.message.body.content;
            if (innerMessageText) {
                taskLinkContent.message.body.content = [self base64DecodeString:innerMessageText];
            }

            NSString* taskDescryption = taskLinkContent.task.taskDescription;
            if (taskDescryption) {
                taskLinkContent.task.taskDescription = [self base64DecodeString:taskDescryption];
            }

            ((PRWebSocketMessageContentTasklink*)message).content = taskLinkContent;
            //--- End preparing TaskLinkContent ---//
        } else {

            //--- Start preparing Message Content ---//
            message = [PRWebSocketMessageContentText MR_createEntityInContext:localContext];
            message.messageType = [PRWebSocketMessageContent messageTypeString:ChatMessageType_Text];
            ((PRWebSocketMessageContentText*)message).content = [self base64DecodeString:_jsonDictionary[kBody][kContent]];
            //--- End preparing Message Content ---//
        }

        if (status == WebSoketMessageStatus_Sent && ![self isOwnMessage]) {
            message.status = @(WebSoketMessageStatus_Delivered);
        } else {
            message.status = _jsonDictionary[kBody][kStatus];
            model.isSent = YES;
        }

        message.messageId = _jsonDictionary[kBody][kMessageId];
        message.clientId = _jsonDictionary[kBody][kClientId];
        message.chatId = _jsonDictionary[kBody][kChatId];
        message.timestamp = _jsonDictionary[kBody][kTimestamp];
        message.timestamp = @([message.timestamp doubleValue]);
        message.ttl = _jsonDictionary[kBody][kTimeToLive];
        message.ttl = @([message.ttl doubleValue]);

        model.body = message;
    }
        completion:^(BOOL contextDidSave, NSError* _Nullable error) {
            completionHandler(contextDidSave && !error);
        }];
}

- (PRWebSocketFeedbackContent*)feedbackContent
{
    PRWebSocketFeedbackContent* feedback = [PRWebSocketFeedbackContent MR_createEntity];

    feedback.messageId = _jsonDictionary[kMessageId];
    feedback.clientId = _jsonDictionary[kClientId];
    feedback.chatId = _jsonDictionary[kChatId];
    feedback.timestamp = _jsonDictionary[kTimestamp];
    feedback.status = _jsonDictionary[kStatus];

    return feedback;
}
@end
