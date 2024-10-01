//
//  PRProfileEmailTypeModel.m
//  PRIME
//
//  Created by Nerses Hakobyan on 12/28/15.
//  Copyright © 2015 XNTrends. All rights reserved.
//

#import "PREmailTypeModel.h"

@implementation PREmailTypeModel

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

    [self setIdentificationAttributes:@[ @"typeId" ]
                              mapping:mapping];

    return mapping;
}

@end
