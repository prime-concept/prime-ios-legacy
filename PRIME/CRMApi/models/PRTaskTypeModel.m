//
//  PRTaskTypeModel.m
//  PRIME
//
//  Created by Simon on 15/01/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRTaskTypeModel.h"

@implementation PRTaskTypeModel

#ifdef USE_COREDATA
@dynamic typeId, typeName;
#endif

+ (RKObjectMapping*)mapping
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({

        mapping = [super mapping];

        [mapping addAttributeMappingsFromDictionary:
                     @{
                         @"id" : @"typeId",
                         @"name" : @"typeName"
                     }];
    });

    return mapping;
}

@end
