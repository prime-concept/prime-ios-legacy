//
//  PRWebSocketResponseContent.m
//  PRIME
//
//  Created by Admin on 8/19/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRWebSocketResponseContent.h"

@implementation PRWebSocketResponseContent

@dynamic status;
@dynamic messageType;

+ (RKObjectMapping*)mapping
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({

        mapping = [super mapping];

        [mapping addAttributeMappingsFromArray:
                     @[
                        @"status",
                        @"messageType"
                     ]];
    });

    return mapping;
}

@end
