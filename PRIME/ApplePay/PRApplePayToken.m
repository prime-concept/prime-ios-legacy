//
//  PRApplePayToken.m
//  PRIME
//
//  Created by Davit on 1/17/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRApplePayToken.h"

@implementation PRApplePayToken

+ (RKObjectMapping*)mapping
{
    static RKObjectMapping* mapping = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        mapping = [RKObjectMapping mappingForClass:[PRApplePayToken class]];
        [mapping addAttributeMappingsFromArray:
                     @[
                        @"paymentToken",
                        @"paymentUid"
                     ]];
    });

    return mapping;
}

@end
