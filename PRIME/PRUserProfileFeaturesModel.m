//
//  PRUserProfileFeaturesModel.m
//  PRIME
//
//  Created by Davit on 7/29/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "PRUserProfileFeaturesModel.h"

@implementation PRUserProfileFeaturesModel

#ifdef USE_COREDATA

@dynamic feature;

#endif

+ (RKObjectMapping*)mapping
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({

        mapping = [super mapping];

        [mapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"feature"]];

        [self setIdentificationAttributes:@[ @"feature" ]
                                  mapping:mapping];

    });

    return mapping;
}

@end
