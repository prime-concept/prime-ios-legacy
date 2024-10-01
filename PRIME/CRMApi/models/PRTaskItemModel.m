//
//  PRTaskItemModel.m
//  PRIME
//
//  Created by Simon on 15/01/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRTaskItemModel.h"

@implementation PRTaskItemModel

#ifdef USE_COREDATA
@dynamic itemName, itemType, itemValue, itemIcon, shareable, latitude, longitude;
#endif

+ (RKObjectMapping*)mapping
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({

        mapping = [super mapping];
        [mapping addAttributeMappingsFromDictionary:
                     @{
                         @"name" : @"itemName",
                         @"type" : @"itemType",
                         @"value" : @"itemValue",
                         @"shareable" : @"shareable",
                         @"icon" : @"itemIcon"
                     }];

        [mapping addAttributeMappingsFromArray:@[ @"longitude",
            @"latitude" ]];
    });

    return mapping;
}

@end
