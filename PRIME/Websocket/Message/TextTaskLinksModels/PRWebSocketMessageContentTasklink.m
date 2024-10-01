//
//  PRWebSocketMessageContentTasklink.m
//  PRIME
//
//  Created by Artak on 3/12/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "PRWebSocketTasklinkContent.h"
#import "PRWebSocketMessageContentTasklink.h"

@implementation PRWebSocketMessageContentTasklink

@dynamic content;

+ (RKObjectMapping*)mapping
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({

        mapping = [super mapping];

        [mapping addAttributeMappingsFromArray:
                     @[
                        @"messageId",
                        @"chatId",
                        @"clientId",
                        @"messageType",
                        @"status",
                        @"timestamp"
                     ]];

        [mapping addRelationshipMappingWithSourceKeyPath:@"content"
                                                 mapping:[PRWebSocketTasklinkContent mapping]];

        [super setIdentificationAttributes:@[ @"messageId" ] mapping:mapping];
    });

    return mapping;
}

@end
