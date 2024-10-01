//
//  PRAssistantPhoneModel.m
//  PRIME
//
//  Created by Artak on 2/26/16.
//  Copyright (c) 2016 XNTrends. All rights reserved.
//

#import "PRAssistantPhoneModel.h"
#import "PRAssistantPhoneTypeModel.h"

@implementation PRAssistantPhoneModel

@dynamic phone;
@dynamic phoneId;
@dynamic primaryNumber;
@dynamic state;
@dynamic phoneType;

+ (RKObjectMapping*)mapping
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({

        mapping = [super mapping];

        [mapping addAttributeMappingsFromDictionary:
                     @{
                         @"id" : @"phoneId",
                         @"primary" : @"primaryNumber",
                     }];

        [mapping addAttributeMappingsFromArray:
                     @[
                        @"phone"
                     ]];

        [mapping addRelationshipMappingWithSourceKeyPath:@"phoneType"
                                                 mapping:[PRAssistantPhoneTypeModel mapping]];

        [self setIdentificationAttributes:@[ @"phoneId" ]
                                  mapping:mapping];
    });

    return mapping;
}

@end
