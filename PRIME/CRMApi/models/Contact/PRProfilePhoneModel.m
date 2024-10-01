//
//  PRProfilePhoneModel.m
//  PRIME
//
//  Created by Nerses Hakobyan on 12/28/15.
//  Copyright © 2015 XNTrends. All rights reserved.
//

#import "PRProfilePhoneModel.h"

@implementation PRProfilePhoneModel

@dynamic phoneId;
@dynamic phone;
@dynamic primaryNumber;
@dynamic phoneType;
@dynamic state;
@dynamic comment;

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
