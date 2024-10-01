//
//  PRWebSocketMessageModelTasklink.m
//  PRIME
//
//  Created by Artak on 3/28/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "PRWebSocketMessageModelTasklink.h"

@implementation PRWebSocketMessageModelTasklink
@dynamic body;

+ (RKObjectMapping*)mapping
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({
        mapping = [super mapping];
        [mapping addRelationshipMappingWithSourceKeyPath:@"body"
                                                 mapping:[PRWebSocketMessageContentTasklink mapping]];
    });

    return mapping;
}

@end
