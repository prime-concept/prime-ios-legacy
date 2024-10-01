//
//  PRWebSocketMessageModel.m
//  PRIME
//
//  Created by Artak on 3/28/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "PRWebSocketMessageContentText.h"
#import "PRWebSocketMessageModel.h"

@implementation PRWebSocketMessageModel

@dynamic body;

+ (RKObjectMapping*)mapping
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({
        mapping = [super mapping];
        [mapping addRelationshipMappingWithSourceKeyPath:@"body"
                                                 mapping:[PRWebSocketMessageContentText mapping]];
        [super setIdentificationAttributes:@[ @"guid" ] mapping:mapping];
    });

    
    return mapping;
}

@end
