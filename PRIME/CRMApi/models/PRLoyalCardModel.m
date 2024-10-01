//
//  PRLoyalCardModel.m
//  PRIME
//
//  Created by Artak on 7/16/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRLoyalCardModel.h"

@implementation PRLoyalCardModel

#ifdef USE_COREDATA
@dynamic cardId, type, cardNumber, issueDate, expiryDate, cardDescription, syncStatus, password;
#endif

+ (RKObjectMapping*)mapping
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({

        mapping = [super mapping];

        [mapping addAttributeMappingsFromDictionary:
                     @{
                         @"id" : @"cardId",
                         @"description" : @"cardDescription"
                     }];

        [mapping addAttributeMappingsFromArray:
                     @[
                        @"cardNumber",
                        @"issueDate",
                        @"expiryDate",
                        @"password"
                     ]];

        [mapping addRelationshipMappingWithSourceKeyPath:@"type"
                                                 mapping:[PRCardTypeModel mapping]];

        [super setIdentificationAttributes:@[ @"cardId" ]
                                   mapping:mapping];
    });

    return mapping;
}

@end
