//
//  PRVoiceMessageModel.m
//  PRIME
//
//  Created by Aram on 12/26/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRVoiceMessageModel.h"

@implementation PRVoiceMessageModel

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
