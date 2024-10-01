//
//  PRTasklinkMessage.m
//  PRIME
//
//  Created by Aram on 11/6/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRTasklinkMessage.h"

@implementation PRTasklinkMessage

#ifdef USE_COREDATA
@dynamic requestId, guid, source, body, type;
#endif

+ (RKObjectMapping*)mapping
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({

        mapping = [super mapping];

        [mapping addAttributeMappingsFromArray:@[
            @"requestId",
            @"guid",
            @"source",
            @"type"
        ]];

        [super setIdentificationAttributes:@[ @"guid" ] mapping:mapping];

        mapping.assignsNilForMissingRelationships = YES;

        [mapping addRelationshipMappingWithSourceKeyPath:@"body"
                                                 mapping:[PRTasklinkMessageBody mapping]];
    });

    return mapping;
}

@end
