//
//  PRApplePayErrorModel.m
//  PRIME
//
//  Created by Davit on 1/10/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRApplePayErrorModel.h"

@implementation PRApplePayErrorModel

+ (RKObjectMapping*)mapping
{
    static RKObjectMapping* mapping = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        mapping = [RKObjectMapping mappingForClass:[PRApplePayErrorModel class]];
        [mapping addAttributeMappingsFromDictionary:
                     @{
                         @"code" : @"errorCode",
                         @"description" : @"errorDescription"
                     }];
    });

    return mapping;
}

@end
