//
//  PRVerifyResponseModel.m
//  PRIME
//
//  Created by Artak on 30/05/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "PRVerifyResponseModel.h"

@implementation PRVerifyResponseModel

+ (RKObjectMapping*)mapping
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({

        mapping = [RKObjectMapping mappingForClass:[self class]];

        [mapping addAttributeMappingsFromDictionary:
                     @{ @"username" : @"username" }];
    });

    return mapping;
}
@end
