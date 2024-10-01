//
//  PRTasklinkContent.m
//  PRIME
//
//  Created by Aram on 11/6/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRTasklinkContent.h"

@implementation PRTasklinkContent

#ifdef USE_COREDATA
@dynamic task, message;
#endif

+ (RKObjectMapping*)mapping
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({

        mapping = [super mapping];

        [mapping addRelationshipMappingWithSourceKeyPath:@"task"
                                                 mapping:[PRTasklinkTask mapping]];

        [mapping addRelationshipMappingWithSourceKeyPath:@"message"
                                                 mapping:[PRTasklinkMessage mapping]];

    });

    return mapping;
}

@end
