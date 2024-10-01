//
//  PRTasklinkMessageBody.m
//  PRIME
//
//  Created by Aram on 11/6/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRTasklinkMessageBody.h"

@implementation PRTasklinkMessageBody

#ifdef USE_COREDATA
@dynamic clientId, chatId, messageType, messageId, ttl, content, timestamp, status;
#endif

+ (RKObjectMapping*)mapping
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({

        mapping = [super mapping];

        [mapping addAttributeMappingsFromArray:@[
            @"clientId",
            @"chatId",
            @"messageType",
            @"messageId",
            @"ttl",
            @"content",
            @"timestamp",
            @"status"
        ]];

        [super setIdentificationAttributes:@[ @"messageId" ] mapping:mapping];
    });

    return mapping;
}

@end
