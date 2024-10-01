//
//  PRMediaMessageModel.m
//  PRIME
//
//  Created by armens on 4/10/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import "PRMediaMessageModel.h"

@implementation PRMediaMessageModel

#ifdef USE_COREDATA
@dynamic name, path, privacy, uuid, checksum;
#endif

+ (RKObjectMapping*)mapping
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({
        mapping = [super mapping];

        [mapping addAttributeMappingsFromArray:
         @[
           @"name",
           @"path",
           @"privacy",
           @"uuid",
           @"checksum"
           ]];

        [super setIdentificationAttributes:@[ @"uuid" ] mapping:mapping];
    });

    return mapping;
}

@end
