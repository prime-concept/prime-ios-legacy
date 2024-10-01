//
//  PRApplePayResponseModel.m
//  PRIME
//
//  Created by Davit on 1/10/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRApplePayResponseModel.h"

@implementation PRApplePayResponseModel

+ (RKObjectMapping*)mapping
{
    static RKObjectMapping* mapping = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        mapping = [RKObjectMapping mappingForClass:[PRApplePayResponseModel class]];
        [mapping addAttributeMappingsFromArray:
                     @[
                        @"success",
                        @"paymentResult"
                     ]];

        RKObjectMapping* errorMapping = [PRApplePayErrorModel mapping];
        [mapping addRelationshipMappingWithSourceKeyPath:@"error" mapping:errorMapping];
    });

    return mapping;
}

@end
