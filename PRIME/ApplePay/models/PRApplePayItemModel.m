//
//  PRApplePayItemModel.m
//  PRIME
//
//  Created by Davit on 1/10/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRApplePayItemModel.h"

@implementation PRApplePayItemModel

+ (RKObjectMapping*)mapping
{
    static RKObjectMapping* mapping = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        mapping = [RKObjectMapping mappingForClass:[PRApplePayItemModel class]];
        [mapping addAttributeMappingsFromArray:
                     @[
                        @"name",
                        @"amount"
                     ]];
    });

    return mapping;
}

@end
