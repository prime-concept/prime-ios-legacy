//
//  PRProfileContactEmailModel.m
//  PRIME
//
//  Created by Nerses Hakobyan on 12/29/15.
//  Copyright © 2015 XNTrends. All rights reserved.
//

#import "PRProfileContactEmailModel.h"

@implementation PRProfileContactEmailModel

@dynamic emailId;
@dynamic email;
@dynamic primaryNumber;
@dynamic emailType;
@dynamic state;
@dynamic comment;
@dynamic profileContact;

+ (RKObjectMapping*)mapping
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({

        mapping = [super mapping];

        mapping.assignsDefaultValueForMissingAttributes = YES;

        [mapping addAttributeMappingsFromDictionary:
                     @{
                         @"id" : @"emailId",
                         @"primary" : @"primaryNumber",
                     }];

        [mapping addAttributeMappingsFromArray:
                     @[
                        @"email",
                        @"comment"
                     ]];

        [mapping addRelationshipMappingWithSourceKeyPath:@"emailType"
                                                 mapping:[PREmailTypeModel mapping]];

        [self setIdentificationAttributes:@[ @"emailId" ]
                                  mapping:mapping];
    });

    return mapping;
}

@end
