//
//  PRPaymentDataModel.m
//  PRIME
//
//  Created by Davit on 1/16/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRPaymentDataModel.h"

@implementation PRPaymentDataModel

+ (RKObjectMapping*)mapping
{
    static RKObjectMapping* mapping = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        mapping = [RKObjectMapping mappingForClass:[PRPaymentDataModel class]];
        [mapping addAttributeMappingsFromArray:
                     @[
                        @"success",
                        @"status"
                     ]];

        RKObjectMapping* applePayInfoMapping = [PRApplePayInfoModel mapping];
        [mapping addRelationshipMappingWithSourceKeyPath:@"data" mapping:applePayInfoMapping];
    });

    return mapping;
}

@end
