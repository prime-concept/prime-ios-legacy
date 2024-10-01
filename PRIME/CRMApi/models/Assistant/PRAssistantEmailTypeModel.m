//
//  PRAssistantEmailTypeModel.m
//  PRIME
//
//  Created by Artak on 2/26/16.
//  Copyright (c) 2016 XNTrends. All rights reserved.
//

#import "PRAssistantEmailTypeModel.h"

@implementation PRAssistantEmailTypeModel

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
