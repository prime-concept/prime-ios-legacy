//
//  CommandBuilder.m
//  PRIME
//
//  Created by Artak on 8/19/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "ChatUtility.h"
#import "CommandBuilder.h"
#import "PRUserProfileModel.h"

@implementation CommandBuilder

+ (NSString*)base64EncodeString:(NSString*)plainString
{
#ifdef CHAT_BASE64_ENCODING_FUNC
    NSData* plainData = [plainString dataUsingEncoding:NSUTF8StringEncoding];
    NSString* base64String = [plainData base64EncodedStringWithOptions:0];

    return base64String;
#endif
    return plainString;
}

+ (NSNumber*)currentTimestamp
{
    return @((long)[[NSDate new] timeIntervalSince1970]);
}

+ (NSString*)buildMessageCommandForMessage:(NSString*)guid
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"guid==%@", guid];
    PRWebSocketBaseModel* message = [[PRWebSocketBaseModel MR_findAllWithPredicate:predicate] firstObject];

    return [self createJSONForModel:message];
}

+ (NSString*)buildRegistrationCommandForChatId:(NSString*)chatId
                                  andTimesTamp:(NSNumber*)timestamp
{
    // FIXME:(PRIM-51): Create non entity class for registration.
    PRWebSocketRegistrationModel* message = [PRWebSocketRegistrationModel MR_createEntity];
    message.type = @(WebSoketCommandType_Request);
    message.requestId = @(WebSoketCommandId_Register);
    message.guid = [[NSUUID UUID] UUIDString];
    message.version = @"1.3";

    PRWebSocketRegistrationContent* body = [PRWebSocketRegistrationContent MR_createEntity];
    body.clientId = [ChatUtility clientIdWithPrefix];
    body.chatId = chatId;
    body.timestamp = timestamp;
    body.deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];

    message.body = body;

    return [self buildMessageCommandForMessage:message.guid];
}

+ (NSString*)buildFeedbackCommandForMessage:(NSString*)messageId
                                  andStatus:(NSNumber*)status
                                  andChatId:(NSString*)chatId
{
    __block NSString* guid = nil;

    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext* localContext) {

        PRWebSocketFeedbackModel* message = [PRWebSocketFeedbackModel MR_createEntityInContext:localContext];

        guid = [[NSUUID UUID] UUIDString];

        PRWebSocketFeedbackContent* body = [PRWebSocketFeedbackContent MR_createEntityInContext:localContext];
        body.clientId = [ChatUtility clientIdWithPrefix];
        body.chatId = chatId;
        body.timestamp = [self.class currentTimestamp];
        body.messageId = messageId;
        body.status = status;

        message.type = @(WebSoketCommandType_Request);
        message.requestId = @(WebSoketCommandId_Feedback);
        message.guid = guid;
        message.body = body;

    }];

    PRWebSocketFeedbackModel* message = (PRWebSocketFeedbackModel*)[PRDatabase messageById:guid];

    return [self buildMessageCommandForMessage:message.guid];
}

+ (NSString*)buildResponseForRequest:(NSNumber*)requestId
                             andGuid:(NSString*)guid
                      andMessageType:(NSNumber*)messageType
                           andStatus:(NSNumber*)status
{
    PRWebSocketResponseModel* message = [PRWebSocketResponseModel MR_createEntity];
    message.guid = guid;
    message.type = @(WebSoketCommandType_Response);
    message.requestId = requestId;

    PRWebSocketResponseContent* body = [PRWebSocketResponseContent MR_createEntity];
    message.body = body;
    message.body.status = status;
    message.body.messageType = [PRWebSocketMessageContent messageTypeString:messageType.integerValue];

    return [self createJSONForModel:message];
}

+ (NSString*)createJSONForModel:(PRWebSocketBaseModel*)model
{
    RKObjectMapping* mapping = [model.class mapping];

    RKRequestDescriptor* requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:mapping.inverseMapping
                                                                                   objectClass:[model class]
                                                                                   rootKeyPath:nil
                                                                                        method:0];

    NSDictionary* dict = [RKObjectParameterization parametersWithObject:model
                                                      requestDescriptor:requestDescriptor
                                                                  error:nil];

    if ([model isKindOfClass:[PRWebSocketMessageModel class]]) {
        dict[kBody][kContent] = [self base64EncodeString:dict[kBody][kContent]];
    }

    NSData* jsonData = [RKMIMETypeSerialization dataFromObject:dict
                                                      MIMEType:RKMIMETypeJSON
                                                         error:nil];

    NSString* jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];

    return jsonString;
}

@end
