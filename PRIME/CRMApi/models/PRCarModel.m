//
//  PRCarModel.m
//  PRIME
//
//  Created by Mariam on 6/19/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRCarModel.h"

@implementation PRCarModelResponse

#ifdef USE_COREDATA

@dynamic data;

#endif

+ (RKObjectMapping*)mapping
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({

        mapping = [super mapping];

        RKRelationshipMapping* relationshipMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"data" toKeyPath:@"data" withMapping:[PRCarModel mapping]];

        [mapping addPropertyMapping:relationshipMapping];
    });

    return mapping;
}

@end

@implementation PRCarModel

#ifdef USE_COREDATA

@dynamic carId, vin, registrationPlate, brand, model, releaseDate, color, state;

#endif

+ (RKObjectMapping*)mapping
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({

        mapping = [super mapping];

        [mapping addAttributeMappingsFromDictionary:
                     @{
                         @"id" : @"carId",
                     }];

        [mapping addAttributeMappingsFromArray:
                     @[
                        @"vin",
                        @"registrationPlate",
                        @"brand",
                        @"model",
                        @"releaseDate",
                        @"color"
                     ]];

        [[self class] setIdentificationAttributes:@[ @"carId" ]
                                          mapping:mapping];
    });

    return mapping;
}

@end
