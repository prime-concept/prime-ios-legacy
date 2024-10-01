//
//  PRTasksTypesModel.m
//  PRIME
//
//  Created by Admin on 2/17/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRTasksTypesModel.h"

@implementation PRTasksTypesModel

#ifdef USE_COREDATA
@dynamic typeId, typeName, count;
#endif

+ (RKObjectMapping*)mapping
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({

        mapping = [super mapping];

        [mapping addAttributeMappingsFromDictionary:
                     @{
                         @"id" : @"typeId",
                         @"name" : @"typeName",
                         @"count" : @"count"
                     }];

        [PRTasksTypesModel setIdentificationAttributes:@[ @"typeId" ]
                                               mapping:mapping];
    });

    return mapping;
}

@end
