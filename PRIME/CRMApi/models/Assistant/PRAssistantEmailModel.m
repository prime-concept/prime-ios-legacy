//
//  PRAssistantEmailModel.m
//  PRIME
//
//  Created by Artak on 2/26/16.
//  Copyright (c) 2016 XNTrends. All rights reserved.
//

#import "PRAssistantEmailModel.h"
#import "PRAssistantEmailTypeModel.h"

@implementation PRAssistantEmailModel

@dynamic email;
@dynamic emailId;
@dynamic primaryNumber;
@dynamic state;
@dynamic emailType;

+ (RKObjectMapping*)mapping
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({

        mapping = [super mapping];

        [mapping addAttributeMappingsFromDictionary:
                     @{
                         @"id" : @"emailId",
                         @"primary" : @"primaryNumber",
                     }];

        [mapping addAttributeMappingsFromArray:
                     @[
                        @"email"
                     ]];

        [mapping addRelationshipMappingWithSourceKeyPath:@"emailType"
                                                 mapping:[PRAssistantEmailTypeModel mapping]];

        [self setIdentificationAttributes:@[ @"emailId" ]
                                  mapping:mapping];
    });

    return mapping;
}
@end
