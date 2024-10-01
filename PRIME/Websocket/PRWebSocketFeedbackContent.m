//
//  PRWebSocketFeedbackContent.m
//  PRIME
//
//  Created by Admin on 17/08/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRWebSocketFeedbackContent.h"

@implementation PRWebSocketFeedbackContent

@dynamic chatId;
@dynamic clientId;
@dynamic messageId;
@dynamic status;
@dynamic timestamp;

+ (RKObjectMapping*)mapping
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({

        mapping = [super mapping];

        [mapping addAttributeMappingsFromArray:
                     @[
                        @"chatId",
                        @"clientId",
                        @"messageId",
                        @"status",
                        @"timestamp"
                     ]];
    });

    return mapping;
}

@end
