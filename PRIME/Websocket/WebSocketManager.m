//
//  WebSocketManager.m
//  PRIME
//
//  Created by Artak on 8/17/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "ChatUtility.h"
#import "CommandBuilder.h"
#import "CommandParser.h"
#import "PRDatabase.h"
#import "PRMessageProcessingManager.h"
#import "PRWebSocketFeedbackContent.h"
#import "PRWebSocketFeedbackModel.h"
#import "PRWebSocketMessageContent.h"
#import "PRWebSocketRegistrationContent.h"
#import "Reachability.h"
#import "WebSocketManager.h"
#import "XNTKeychainStore.h"
#import "Config.h"

@interface WebSocketManager () {
    BOOL _isReachable;
    BOOL _isConnecting;
    volatile BOOL _isRegistrationCompleted;
    volatile BOOL _isSocketOpened;
}

@property (nonatomic, strong) SRWebSocket* socket;
@property (nonatomic, strong) NSOperationQueue* socketOperationQueue;
@property (nonatomic, strong) NSTimer* timer;

@end

@implementation WebSocketManager

+ (WebSocketManager*)sharedInstance
{
    static WebSocketManager* manager = nil;

    pr_dispatch_once({
        manager = [[self alloc] init];
        [manager initWebSocket];

        manager.socketOperationQueue = [[NSOperationQueue alloc] init];
        manager.socketOperationQueue.name = @"Socket operation Queue";
        manager.socketOperationQueue.maxConcurrentOperationCount = 1;
        manager.socketOperationQueue.suspended = YES;

        [[NSNotificationCenter defaultCenter] addObserver:manager
                                                 selector:@selector(reachabilityChanged:)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];

        manager.timer = [NSTimer scheduledTimerWithTimeInterval:kResendMessagesTimerInterval
                                                         target:manager
                                                       selector:@selector(resendMessages)
                                                       userInfo:nil
                                                        repeats:YES];

    });

    return manager;
}

- (void)initWebSocket
{
    if (_isConnecting) {
        return;
    }

    NSString* accessToken = [XNTKeychainStore accessToken];

    DLog(@"Websocket --------- Createing new socket");
    _isConnecting = YES;
    _isReachable = ![PRRequestManager connectionRequired];

	NSString *kWebsocketRegistrationUrl = [NSString stringWithFormat:@"%@/chat-server/v3_1/messages?access_token=%@&X-Client-Id=%@&X-Device-Id=%@", Config.chatEndpoint, accessToken, kClientID, [CRMRestClient getUniqueDeviceIdentifierAsString]];
	kWebsocketRegistrationUrl = [kWebsocketRegistrationUrl stringByReplacingOccurrencesOfString:@"https://" withString:@"wss://"];

	NSString* path = kWebsocketRegistrationUrl;

#ifdef USE_XNCICHAT_SERVER
    path = kWebsocketRegistrationUrl;
#endif
    NSURL* url = [NSURL URLWithString:path];
    _socket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:url]];
    _socket.delegate = self;

    [_socket open];
}

- (void)reachabilityChanged:(NSNotification*)notification
{
    DLog(@"Websocket --------- Reachabiliy changed");
    Reachability* noteObject = notification.object;
    if (noteObject.currentReachabilityStatus == NotReachable) {
        _isReachable = NO;
        _isRegistrationCompleted = NO;

        return;
    }
    _isReachable = YES;

    if (self.socket.readyState == SR_CLOSED || self.socket.readyState == SR_CLOSING) {
        [self initWebSocket];
    }
}

- (BOOL)isSocketOpened
{
    return _isSocketOpened;
}

#pragma mark helpers
- (void)registerForChat:(NSString*)chatId
{
    NSNumber* timestamp = nil;
    if (chatId == nil) {
        // First time registration called without timestamp to get all missed messages.
        timestamp = @((long)[[NSDate new] timeIntervalSince1970]);
    } else {
        PRWebSocketMessageContent* message = [PRDatabase webSocketLastSynchMessageContentForChatId:chatId
                                                                                       andClientId:[ChatUtility clientIdWithPrefix]]
                                                 .body;
        if (message && message.timestamp) {
            timestamp = message.timestamp;
        } else {
            timestamp = @0;
        }
    }
    NSString* registrationCommand = [CommandBuilder buildRegistrationCommandForChatId:chatId andTimesTamp:timestamp];
    [_socketOperationQueue addOperationWithBlock:^{

        if (_isSocketOpened) {
            DLog(@"Websocket --------- sendRegistrationCommandForTask jsonString = %@", registrationCommand);
            [WebSocketManager.sharedInstance.socket send:registrationCommand];
        }
    }];
}

- (void)sendMainChatIdToServer
{
    [_socketOperationQueue addOperationWithBlock:^{
        if (_isSocketOpened) {
            [WebSocketManager.sharedInstance.socket send:[ChatUtility mainChatIdWithPrefix]];
        }
    }];
}

- (void)sendData:(id)data
{
    if (!_isRegistrationCompleted) {
        return;
    }

    [WebSocketManager.sharedInstance.socket send:data];
}

- (PRWebSocketBaseModel*)sendMessage:(NSString*)text
                             forChat:(NSString*)chatId
{
    PRWebSocketBaseModel* message = [self.class messageForText:text andChatId:chatId];

    NSString* messageCommand = [CommandBuilder buildMessageCommandForMessage:message.guid];

    if (_isReachable) {
        [_socketOperationQueue addOperationWithBlock:^{

            DLog(@"Websocket --------- sendMessageCommandForTask jsonString = %@", messageCommand);
            [self sendData:messageCommand];
        }];
    }

    return message;
}

+ (PRWebSocketBaseModel*)messageForText:(NSString*)text andChatId:(NSString*)chatId;
{
    __block NSString* guid = nil;

    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext* localContext) {

        PRWebSocketMessageModel* message = [PRWebSocketMessageModel MR_createEntityInContext:localContext];

        guid = [[NSUUID UUID] UUIDString];

        PRWebSocketMessageContentText* body = [PRWebSocketMessageContentText MR_createEntityInContext:localContext];
        body.messageId = [[NSUUID UUID] UUIDString];
        body.clientId = [ChatUtility clientIdWithPrefix];
        body.chatId = chatId;
        body.timestamp = @((long)[[NSDate new] timeIntervalSince1970]);
        body.messageType = [PRWebSocketMessageContent messageTypeString:ChatMessageType_Text];
        body.content = text;

        message.type = @(WebSoketCommandType_Request);
        message.requestId = @(WebSoketCommandId_Message);
        message.guid = guid;
        message.isSent = NO;
        message.creationDate = [NSDate new];
        message.body = body;
    }];

    return [PRDatabase messageById:guid];
}

- (void)sendFeedbackForMessage:(NSString*)messageId withStatus:(NSNumber*)status
{
    [_socketOperationQueue addOperationWithBlock:^{

        PRWebSocketMessageContent* message = [PRDatabase webSocketMessageContentForGuid:messageId];

        NSString* feedbackCommand = [CommandBuilder buildFeedbackCommandForMessage:messageId andStatus:status andChatId:message.chatId];
        [self sendData:feedbackCommand];
    }];
}

- (NSComparisonResult)statusOfMessage:(NSString*)messageId comparedWithStatus:(NSNumber*)status
{
    PRWebSocketMessageContent* messageModel = [PRDatabase webSocketMessageContentForGuid:messageId];
    return [messageModel.status compare:status];
}

#pragma mark websocket delegate
- (void)webSocketDidOpen:(SRWebSocket*)webSocket
{
    DLog(@"Websocket --------- webSocketDidOpen");
    _isConnecting = NO;
    _isSocketOpened = YES;
    _socketOperationQueue.suspended = NO;
    [self sendMainChatIdToServer];
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:kWebSocketDidOpen object:nil];
}

- (void)webSocket:(SRWebSocket*)webSocket didFailWithError:(NSError*)error
{
    DLog(@"Websocket --------- didFailWithError");
    _isConnecting = NO;
    _isSocketOpened = NO;
    _isRegistrationCompleted = NO;
    _socketOperationQueue.suspended = YES;
}

- (void)webSocket:(SRWebSocket*)webSocket didCloseWithCode:(NSInteger)code reason:(NSString*)reason wasClean:(BOOL)wasClean
{
    DLog(@"Websocket --------- didCloseWithCode");
    _isConnecting = NO;
    _isSocketOpened = NO;
    _isRegistrationCompleted = NO;
    _socketOperationQueue.suspended = YES;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self initWebSocket];
    });
}

- (void)webSocket:(SRWebSocket*)webSocket didReceiveMessage:(id)message
{
    [PRMessageProcessingManager getMessagesForChannelId:message
                                                   guid:nil
                                                  limit:@kMessagesFetchLimit
                                                 toDate:nil
                                               fromDate:nil
                                                success:^(NSArray<PRMessageModel*>* messages) {}
                                                failure:^{}];

    // Functionality in case if messages will be sent with socket.

    /*
    CommandParser* commandParser = [CommandParser new];
    [commandParser parse:message];

    if (![PRDatabase isUserProfileFeatureEnabled:ProfileFeature_TaskLink]) {
        if ([commandParser.jsonDictionary[kBody][kMessageType] integerValue] == ChatMessageType_Tasklink) {
            return;
        }
    }

    NSNumber* type = [commandParser type];

    NSNumber* status = @(0);

    @try {
        DLog(@"Websocket --------- didReceiveMessage message = %@", message);

        DLog(@"Websocket --------- didReceiveMessage type = %@", type);

        switch ([type integerValue]) {
        case WebSoketCommandType_Response:

            [self handleResponse:commandParser];
            break;

        case WebSoketCommandType_Request:

            [self handleRequest:commandParser];
            break;

        default:
            break;
        }
    }
    @catch (NSException* exception) {
        status = @(1);
    }
    @finally {

        if ([type integerValue] != WebSoketCommandType_Request) {
            return;
        }
        __block NSString* json = [CommandBuilder buildResponseForRequest:[commandParser requestId]
                                                                 andGuid:[commandParser guid]
                                                          andMessageType:[commandParser messageType]
                                                               andStatus:status];

        NSOperation* operation = [NSBlockOperation blockOperationWithBlock:^{
            [self sendData:json];
        }];

        operation.queuePriority = NSOperationQueuePriorityHigh;
        [_socketOperationQueue addOperation:operation];
    }
    */
}

#pragma mark response hendlers

- (void)handleResponse:(CommandParser*)commandParser
{
    NSNumber* requestId = [commandParser requestId];

    if (requestId == nil) {
        return;
    }

    DLog(@"Websocket --------- handleResponse requestId = %@", requestId);

    NSInteger requestIntegerId = [requestId integerValue];

    switch (requestIntegerId) {
    case WebSoketCommandId_Feedback:

        [self handleFeedbackResponse:commandParser];
        break;

    case WebSoketCommandId_Message:

        [self handleMessageResponse:commandParser];
        break;

    case WebSoketCommandId_Register:

        [self handleRegistrationResponse:commandParser];
        break;
    }
}

- (void)handleFeedbackResponse:(CommandParser*)commandParser
{
    PRWebSocketFeedbackModel* feedback = [PRDatabase webSocketFeedbackModelForGuid:[commandParser guid]];
    feedback.isSent = YES;
    NSNumber* responseStatus = [commandParser status];
    if ([responseStatus integerValue] == 0) {

        [MagicalRecord saveWithBlock:^(NSManagedObjectContext* localContext) {
            PRWebSocketFeedbackModel* feedbackLocal = [feedback MR_inContext:localContext];
            feedbackLocal.isSent = YES;
        }];
    }
}

- (void)handleMessageResponse:(CommandParser*)commandParser
{
    NSNumber* responseStatus = [commandParser status];
    NSNumber* ttl = [commandParser ttl];
    PRWebSocketMessageBaseModel* message = [PRDatabase webSocketMessageModelForGuid:[commandParser guid]];

    DLog(@"Websocket --------- handleMessageResponse responseStatus = %@", responseStatus);

    if (message == nil) {
        return;
    }

    if ((message.isSent == YES) && ([self statusOfMessage:[commandParser contentGuid] comparedWithStatus:@(WebSoketMessageStatus_Sent)] != NSOrderedAscending)) {
        return;
    }

    message.isSent = YES;
    message.body.status = @(WebSoketMessageStatus_Sent);
    message.body.ttl = ttl;

    if ([responseStatus integerValue] != 0) {
        return;
    }
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext* localContext) {
        PRWebSocketMessageBaseModel* messageLocal = [message MR_inContext:localContext];
        messageLocal.isSent = YES;
        messageLocal.body.status = @(WebSoketMessageStatus_Sent);
        messageLocal.body.ttl = ttl;
    }];

    [[NSNotificationCenter defaultCenter] postNotificationName:kMessageSent object:message];
}

- (void)handleRegistrationResponse:(CommandParser*)commandParser
{
    NSNumber* responseStatus = [commandParser status];
    _socketOperationQueue.suspended = NO;

    DLog(@"Websocket --------- handleRegistrationResponse responseStatus = %@", responseStatus);

    if ([responseStatus integerValue] == 0) {

        _socketOperationQueue.suspended = NO;
        _isRegistrationCompleted = YES;
        [_timer fire];
        return;
    }
    if ([commandParser clientId] == nil) {
        _socketOperationQueue.suspended = YES;
    }
    //Todo notify to send message again.
    [_socketOperationQueue addOperationWithBlock:^{

        // [WebSocketManager.sharedClient.socket send: message]; TODO

    }];
}

#pragma mark reuqest hendlers
- (void)handleRequest:(CommandParser*)commandParser
{
    NSNumber* requestId = [commandParser requestId];

    DLog(@"Websocket --------- handleRequest requestId = %@", requestId);

    switch ([requestId integerValue]) {
    case WebSoketCommandId_Feedback: {
        [self handleFeedbackRequest:commandParser];
    } break;
    case WebSoketCommandId_Message: {
        [self handleMessageRequest:commandParser];
    } break;
    case WebSoketCommandId_Register:
        // Can't be this case.
        break;
    default:
        break;
    }
}

- (void)handleFeedbackRequest:(CommandParser*)commandParser
{
    NSString* messageId = [commandParser contentGuid];
    NSNumber* status = [commandParser status];
    NSNumber* ttl = [commandParser ttl];

    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];

    if ([status isEqualToNumber:@(WebSoketMessageStatus_Deleted)]) {
        NSString* deletedMessageId = [PRDatabase deleteWebSocketMessageModelWithMessageId:messageId];
        [center postNotificationName:kMessageDeletedFeedbackReceived object:deletedMessageId userInfo:nil];
        return;
    }

    if ([self statusOfMessage:messageId comparedWithStatus:status] != NSOrderedAscending) {
        return;
    }

    PRWebSocketMessageContent* message = [PRDatabase webSocketMessageContentForGuid:messageId];
    message.status = status;
    message.ttl = ttl;

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext* localContext) {
        PRWebSocketMessageContent* localContextMessage = [message MR_inContext:localContext];
        localContextMessage.status = message.status;
        localContextMessage.ttl = message.ttl;
    }];

    [center postNotificationName:kFeedbackReceived object:message userInfo:nil];
}

- (void)handleMessageRequest:(CommandParser*)commandParser
{
    NSString* messageId = [commandParser contentGuid];

    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];

    if ([commandParser isDuplicateMessage]) {

        NSNumber* status = [commandParser status];
        NSNumber* ttl = [commandParser ttl];

        if ([self statusOfMessage:messageId comparedWithStatus:status] == NSOrderedAscending) {

            PRWebSocketMessageContent* message = [PRDatabase webSocketMessageContentForGuid:messageId];
            message.status = status;
            message.ttl = ttl;

            [MagicalRecord saveWithBlock:^(NSManagedObjectContext* localContext) {
                PRWebSocketMessageContent* localContextMessage = [message MR_inContext:localContext];
                localContextMessage.status = message.status;
                localContextMessage.ttl = message.ttl;
            }];

            [center postNotificationName:kMessageStatusUpdated object:message userInfo:nil];
        }
        return;
    }

    if (![commandParser isOwnMessage]) {
        [self sendFeedbackForMessage:messageId
                          withStatus:@(WebSoketMessageStatus_Delivered)];
    }

    [commandParser saveMessageModelWithCompletionHandler:^(BOOL succeed) {
        if (succeed) {
            [center postNotificationName:kMessageReceived
                                  object:nil
                                userInfo:@{ kGuidKey : [commandParser guid] }];
        }
    }];
}

#pragma mark resend

- (void)resendMessages
{
    if (self.socket.readyState == SR_CLOSED || self.socket.readyState == SR_CLOSING) {
        [self initWebSocket];
    }

    NSArray<PRWebSocketBaseModel*>* messagesToResend = [PRDatabase webSocketMessageModelToResend];
    DLog(@"self.socket.readyState = %ld", (long)self.socket.readyState);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
        for (PRWebSocketBaseModel* model in messagesToResend) {
            if ([model isKindOfClass:[PRWebSocketMessageModel class]]) {

                PRWebSocketMessageModel* messageModel = (PRWebSocketMessageModel*)model;

                if (_isRegistrationCompleted) {
                    [_socketOperationQueue addOperationWithBlock:^{
                        [self sendData:[CommandBuilder buildMessageCommandForMessage:messageModel.guid]];
                    }];
                }

                if (messageModel.state == MessageState_Sending) {

                    [MagicalRecord saveWithBlock:^(NSManagedObjectContext* localContext) {
                        PRWebSocketMessageModel* model = (PRWebSocketMessageModel*)[messageModel MR_inContext:localContext];
                        model.state = MessageState_Initial;
                    }];
                    continue;
                }

                if (messageModel.state == MessageState_Initial && (now > [messageModel.body.timestamp longValue] + kTimeoutToShowRedButton)) {

                    [MagicalRecord saveWithBlock:^(NSManagedObjectContext* localContext) {
                        PRWebSocketMessageModel* model = (PRWebSocketMessageModel*)[messageModel MR_inContext:localContext];
                        model.state = MessageState_Aborted;
                    }
                        completion:^(BOOL contextDidSave, NSError* error) {
                            NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
                            [center postNotificationName:kMessageInSending object:nil];

                        }];
                }

                continue;
            }

            if ([model isKindOfClass:[PRWebSocketFeedbackModel class]]) {
                PRWebSocketFeedbackModel* feedbackModel = (PRWebSocketFeedbackModel*)model;
                if (now <= [feedbackModel.body.timestamp longValue] + kResendMessagesTimerInterval) {
                    continue;
                }
                if (_isRegistrationCompleted) {
                    [_socketOperationQueue addOperationWithBlock:^{

                        [self sendData:[CommandBuilder buildMessageCommandForMessage:model.guid]];
                    }];
                }
            }
        }
    });
}

+ (void)resetMessageState:(PRWebSocketMessageModel*)modelToSend
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext* localContext) {
        PRWebSocketMessageModel* model = (PRWebSocketMessageModel*)[modelToSend MR_inContext:localContext];
        model.state = MessageState_Sending;
    }
        completion:^(BOOL contextDidSave, NSError* error) {
            NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
            [center postNotificationName:kMessageInSending object:nil];

        }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

@end
