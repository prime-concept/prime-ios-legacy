//
//  PRTasklinkTask.m
//  PRIME
//
//  Created by Aram on 11/15/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRTasklinkTask.h"

@implementation PRTasklinkTask

#ifdef USE_COREDATA
@dynamic taskLinkId, taskName, taskId, taskType, taskDescription, requestDate, reserved, completed, customerId;
#endif

+ (RKObjectMapping*)mapping
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({

        mapping = [super mapping];

        [mapping addAttributeMappingsFromDictionary:
                     @{
                         @"id" : @"taskId",
                         @"name" : @"taskName",
                         @"description" : @"taskDescription",
                         @"taskId" : @"taskLinkId"
                     }];

        [mapping addAttributeMappingsFromArray:
                     @[
                        @"requestDate",
                        @"customerId",
                        @"reserved",
                        @"completed"
                     ]];

        [mapping addRelationshipMappingWithSourceKeyPath:@"taskType"
                                                 mapping:[PRTaskTypeModel mapping]];

    });

    return mapping;
}

@end
