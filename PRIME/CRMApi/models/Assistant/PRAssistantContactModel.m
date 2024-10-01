//
//  PRAssistantContactModel.m
//  PRIME
//
//  Created by Artak on 2/26/16.
//  Copyright (c) 2016 XNTrends. All rights reserved.
//

#import "PRAssistantContactModel.h"
#import "PRAssistantEmailModel.h"
#import "PRAssistantPhoneModel.h"
#import "PRAssistantTypeModel.h"

@implementation PRAssistantContactModel

@dynamic contactId;
@dynamic firstName;
@dynamic lastName;
@dynamic middleName;
@dynamic state;
@dynamic contactType;
@dynamic emails;
@dynamic phones;

+ (RKObjectMapping*)mapping
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({

        mapping = [super mapping];

        [mapping addAttributeMappingsFromDictionary:
                     @{
                         @"id" : @"contactId"
                     }];

        [mapping addAttributeMappingsFromArray:
                     @[
                        @"firstName",
                        @"middleName",
                        @"lastName"
                     ]];

        mapping.assignsDefaultValueForMissingAttributes = YES;

        [mapping addRelationshipMappingWithSourceKeyPath:@"contactType"
                                                 mapping:[PRAssistantTypeModel mapping]];
        [mapping addRelationshipMappingWithSourceKeyPath:@"phones"
                                                 mapping:[PRAssistantPhoneModel mapping]];
        [mapping addRelationshipMappingWithSourceKeyPath:@"emails"
                                                 mapping:[PRAssistantEmailModel mapping]];

        [self setIdentificationAttributes:@[ @"contactId" ]
                                  mapping:mapping];
    });

    return mapping;
}
@end
