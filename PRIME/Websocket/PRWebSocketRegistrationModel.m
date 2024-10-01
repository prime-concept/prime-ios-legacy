//
//  PRWebSocketRegistrationModel.m
//  PRIME
//
//  Created by Artak on 8/19/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRWebSocketRegistrationContent.h"
#import "PRWebSocketRegistrationModel.h"

@implementation PRWebSocketRegistrationModel

@dynamic body;
@dynamic version;

+ (RKObjectMapping*)mapping
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({

        mapping = [super mapping];

        [mapping addRelationshipMappingWithSourceKeyPath:@"body"
                                                 mapping:[PRWebSocketRegistrationContent mapping]];

        [mapping addAttributeMappingsFromArray:@[ @"version" ]];
    });

    return mapping;
}

@end
