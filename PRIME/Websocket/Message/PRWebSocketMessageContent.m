//
//  PRWebSocketMessageContent.m
//  PRIME
//
//  Created by Artak on 17/08/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRWebSocketMessageContent.h"

@implementation PRWebSocketMessageContent

@dynamic messageId;
@dynamic clientId;
@dynamic chatId;
@dynamic timestamp;
@dynamic messageType;
@dynamic status;
@dynamic ttl;

+ (NSString*)messageTypeString:(ChatMessageType)messageType
{
    NSString* result = nil;

    switch (messageType) {

    case ChatMessageType_Text:
        result = @"text";
        break;
    case ChatMessageType_Image:
        result = @"image";
        break;
    case ChatMessageType_Voice:
        result = @"voicemessage";
        break;
    case ChatMessageType_Video:
        result = @"video";
        break;
    case ChatMessageType_Contact:
        result = @"contact";
        break;
    case ChatMessageType_Location:
        result = @"location";
        break;
    case ChatMessageType_Tasklink:
        result = @"tasklink";
        break;
    default:
        [NSException raise:NSGenericException format:@"Unexpected message type."];
    }

    return result;
}
@end
