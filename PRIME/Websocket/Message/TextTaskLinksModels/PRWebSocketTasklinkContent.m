//
//  PRWebSocketTasklinkContent.m
//  PRIME
//
//  Created by Artak on 3/24/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "PRWebSocketTasklinkContent.h"

@implementation PRWebSocketTasklinkContent

@dynamic task;
@dynamic message;

static RKObjectMapping* mapping = nil;

+ (RKObjectMapping*)mapping
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({
        mapping = [super mapping];
        [mapping addRelationshipMappingWithSourceKeyPath:@"task"
                                                 mapping:[PRTaskDetailModel mappingForChat]];
        [mapping addRelationshipMappingWithSourceKeyPath:@"message"
                                                 mapping:[PRWebSocketMessageModel mapping]];

    });

    return mapping;
}

@end
