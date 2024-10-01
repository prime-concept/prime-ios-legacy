//
//  PRProfileEmailModel.m
//  PRIME
//
//  Created by Nerses Hakobyan on 12/28/15.
//  Copyright © 2015 XNTrends. All rights reserved.
//

#import "PRProfileEmailModel.h"

@implementation PRProfileEmailModel

@dynamic email;
@dynamic emailId;
@dynamic primaryNumber;
@dynamic emailType;
@dynamic state;
@dynamic comment;

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
