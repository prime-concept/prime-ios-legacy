//
//  PRPhoneTypeModel.m
//
//
//  Created by Artak on 2/26/16.
//
//

#import "PRAssistantPhoneTypeModel.h"

@implementation PRAssistantPhoneTypeModel

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
