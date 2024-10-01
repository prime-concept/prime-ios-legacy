//
//  PRCardTypeModel.m
//  PRIME
//
//  Created by Admin on 7/16/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRCardTypeModel.h"

@implementation PRCardTypeModel

#ifdef USE_COREDATA
@dynamic typeId, name, position, color, logoUrl;
#endif

+ (RKObjectMapping*)mapping
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({

        mapping = [super mapping];

        [mapping addAttributeMappingsFromDictionary:
                     @{
                         @"id" : @"typeId"
                     }];

        [mapping addAttributeMappingsFromArray:
                     @[
                        @"name",
                        @"position",
                        @"color",
                        @"logoUrl"
                     ]];

        [PRCardTypeModel setIdentificationAttributes:@[ @"typeId" ]
                                               mapping:mapping];
    });

    return mapping;
}

@end
