//
//  PRServicesModel.m
//  PRIME
//
//  Created by Gayane on 5/13/16.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRServicesModel.h"

@implementation PRServicesModel

@dynamic serviceId;
@dynamic name;
@dynamic serviceDescription;
@dynamic icon;
@dynamic url;
@dynamic nativeUrl;
@dynamic image;

+ (RKObjectMapping*)mapping
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({

        mapping = [super mapping];

        [mapping addAttributeMappingsFromDictionary:
                     @{
                         @"id" : @"serviceId",
                         @"description" : @"serviceDescription"
                     }];

        [mapping addAttributeMappingsFromArray:
                     @[
                        @"name",
                        @"icon",
                        @"url",
                        @"nativeUrl"
                     ]];

        [super setIdentificationAttributes:@[ @"serviceId" ]
                                   mapping:mapping];
    });

    return mapping;
}

@end
