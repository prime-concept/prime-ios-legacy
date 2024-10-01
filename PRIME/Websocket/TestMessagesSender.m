//
//  TestMessagesSender.m
//  PRIME
//
//  Created by Taron on 4/16/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "ChatUtility.h"
#import "CommandBuilder.h"
#import "PRDataBase.h"
#import "TestMessagesSender.h"
#import "WebSocketManager.h"

@interface TestMessagesSender () {
    NSInteger _timeInterval;
    BOOL _needText;
    WebSoketMessageStatus _messagestatusForFeedback;
    WebSocketManager* _webSocketManager;
    WebSoketCommandType _webSoketCommandType;
}

@property (strong, nonatomic) NSArray<NSNumber*>* taskIds;
@property (strong, nonatomic) NSArray<NSNumber*>* chatIds;
@property (strong, nonatomic) NSTimer* timerForTaskMessage;
@property (strong, nonatomic) NSTimer* timerForFeedback;

@end

@implementation TestMessagesSender

- (instancetype)initWithTaskIds:(NSArray<NSNumber*>*)taskIds
                      orChatIds:(NSArray<NSNumber*>*)chatIds
          andRepeatTimeInterval:(NSInteger)interval
                       needText:(BOOL)needText
{
    self = [super init];
    if (self) {
        _chatIds = chatIds;
        _taskIds = taskIds;
        _timeInterval = interval;
        _needText = needText;
    }
    return self;
}

- (void)startReceiveTestTaskMessages
{
    _timerForTaskMessage = [NSTimer scheduledTimerWithTimeInterval:_timeInterval
                                                            target:self
                                                          selector:@selector(sendTaskMessages)
                                                          userInfo:nil
                                                           repeats:YES];
}

- (void)endReceiveTestTaskMessages
{
    [_timerForTaskMessage invalidate];
}

- (void)startReceiveFeedback:(WebSoketMessageStatus)messageStatus webSoketCommandType:(WebSoketCommandType)webSoketCommandType
{
    _messagestatusForFeedback = messageStatus;
    _webSoketCommandType=webSoketCommandType;
    _timerForFeedback = [NSTimer scheduledTimerWithTimeInterval:_timeInterval / 3
                                                         target:self
                                                       selector:@selector(sendFeedbackForTakLastMessage)
                                                       userInfo:nil
                                                        repeats:YES];
}
- (void)endReceiveFeedback
{
    [_timerForFeedback invalidate];
}

- (void)sendTaskMessages
{
    static int i = 0;
    int index = i % 2;
    if (!_webSocketManager) {
        _webSocketManager = [WebSocketManager sharedInstance];
    }
    NSString* json = [self taskMessageWithIndex:index];
    i++;
    [_webSocketManager webSocket:nil didReceiveMessage:json];
}

- (NSString*)taskMessageWithIndex:(NSInteger)index
{

    NSString* text = nil;
    if (_needText) {
        text = [NSString stringWithFormat:@"%@", @(arc4random_uniform(5000))];
    }

    NSString* guid = [[NSUUID UUID] UUIDString];
    NSString* taskMessageId = [[NSUUID UUID] UUIDString];
    NSString* messageId = [[NSUUID UUID] UUIDString];
    NSString* message = [self base64EncodeString:text];
    NSNumber* timestamp = @((long)[[NSDate new] timeIntervalSince1970]);
    PRTaskDetailModel* task = [self getTasksWithIndex:index];
    NSString* description = [self base64EncodeString:task.taskDescription];
    NSString* messageJson = nil;

    if (text && text.length) {
        messageJson = [NSString stringWithFormat:@", \"message\":{\"body\":{\"chatId\":\"%@\",\"messageId\":\"%@\",\"timestamp\":%@,\"messageType\":0,\"content\":\"%@\",\"status\":1,\"clientId\":\"U268435970\"}, \"requestId\":2, \"guid\":\"null\", \"type\":1, \"source\":\"CRM\"}", [ChatUtility chatIdWithPrefix:task.chatId.stringValue], messageId, timestamp, message];
    }
    else {
        messageJson = @"";
    }
    return [NSString stringWithFormat:@"{\"body\":{\"chatId\":\"N268481713\",\"messageId\":\"%@\",\"timestamp\":%@,\"messageType\":4,\"content\":{\"task\":{\"id\":%@,\"name\":\"%@\",\"customerId\":%@,\"chatId\":%@,\"description\":\"%@\",\"requestDate\":\"%@\",\"startServiceDate\":\"2015-10-14T00:00:00MSK\",\"endServiceDate\":\"2015-10-14T00:00:00MSK\",\"reserved\":%@,\"completed\":%@}%@},\"status\":3,\"clientId\":\"U268436204\"}, \"requestId\":2, \"guid\":\"%@\", \"type\":1, \"source\":\"CRM\"}", taskMessageId, timestamp, task.taskId, task.taskName, task.customerId, task.chatId, description, task.requestDate, task.reserved, task.completed, messageJson, guid];
}

- (PRTaskDetailModel*)getTasksWithIndex:(NSInteger)index
{
    NSPredicate* predicate = nil;
    if (_taskIds.count) {
        predicate = [NSPredicate predicateWithFormat:@"taskId=%@", _taskIds[index]];
    }
    else {
        predicate = [NSPredicate predicateWithFormat:@"chatId=%@", _chatIds[index]];
    }

    return [[PRTaskDetailModel MR_findAllWithPredicate:predicate] firstObject];
}

- (void)sendFeedbackForTakLastMessage
{
    static int i = 0;
    int index = i % 2;
    PRTaskDetailModel* task = [self getTasksWithIndex:index];
    PRWebSocketMessageBaseModel* message = [[PRDatabase webSocketMessageModelForChatId:
                                                            [ChatUtility chatIdWithPrefix:task.chatId.stringValue]] lastObject];
    NSNumber* timestamp = @((long)[[NSDate new] timeIntervalSince1970]);
    NSString* feedback = [NSString stringWithFormat:@"{\"body\":{\"chatId\":\"%@\",\"messageId\":\"%@\",\"timestamp\":%@,\"messageType\":0,\"status\":%@,\"clientId\":\"C268481713\"}, \"requestId\":3, \"guid\":\"%@\", \"type\":%@}", [ChatUtility chatIdWithPrefix:task.chatId.stringValue], message.body.messageId, timestamp, @(_messagestatusForFeedback), message.guid, @(_webSoketCommandType)];
    if (!_webSocketManager) {
        _webSocketManager = [WebSocketManager sharedInstance];
    }
    [_webSocketManager webSocket:nil didReceiveMessage:feedback];
    i++;
}

- (NSString*)base64EncodeString:(NSString*)plainString
{
#ifdef CHAT_BASE64_ENCODING_FUNC
    NSData* plainData = [plainString dataUsingEncoding:NSUTF8StringEncoding];
    NSString* base64String = [plainData base64EncodedStringWithOptions:0];

    return base64String;
#endif
    return plainString;
}

- (void)dealloc
{
    [_timerForTaskMessage invalidate];
    [_timerForFeedback invalidate];
}

@end
