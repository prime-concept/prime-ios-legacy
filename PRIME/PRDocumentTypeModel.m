//
//  PRDocumentTypeModel.m
//  PRIME
//
//  Created by Hamlet on 2/20/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import "PRDocumentTypeModel.h"

@implementation PRDocumentTypeModel

#ifdef USE_COREDATA
@dynamic typeId, name;
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
           @"name"
           ]];

        [PRDocumentTypeModel setIdentificationAttributes:@[ @"typeId" ]
                                               mapping:mapping];
    });

    return mapping;
}

@end
