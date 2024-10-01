//
//  PRProfileContactPhoneModel.m
//  PRIME
//
//  Created by Nerses Hakobyan on 12/29/15.
//  Copyright © 2015 XNTrends. All rights reserved.
//

#import "PRProfileContactPhoneModel.h"

@implementation PRProfileContactPhoneModel

@dynamic phoneId;
@dynamic phone;
@dynamic primaryNumber;
@dynamic phoneType;
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
                         @"id" : @"phoneId",
                         @"primary" : @"primaryNumber",
                     }];

        [mapping addAttributeMappingsFromArray:
                     @[
                        @"phone",
                        @"comment"
                     ]];

        [mapping addRelationshipMappingWithSourceKeyPath:@"phoneType"
                                                 mapping:[PRPhoneTypeModel mapping]];

        [self setIdentificationAttributes:@[ @"phoneId" ]
                                  mapping:mapping];
    });

    return mapping;
}

@end
