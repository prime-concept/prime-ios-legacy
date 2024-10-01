//
//  PRStatusModel.m
//  PRIME
//
//  Created by Admin on 2/1/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRStatusModel.h"

@implementation PRStatusModel

+ (RKObjectMapping*) mapping
{
    static RKObjectMapping *mapping = nil;
    
    pr_dispatch_once({
        
        mapping = [RKObjectMapping mappingForClass: [self class]];
        [mapping addAttributeMappingsFromArray:@[
                                                 @"error",
                                                 @"errorDescription"]];
    });
    
    return mapping;
}

@end
