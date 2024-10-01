//
//  PRTaskStatusModel.m
//  PRIME
//
//  Created by Simon on 15/01/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRTaskStatusModel.h"

@implementation PRTaskStatusModel

#ifdef USE_COREDATA
@dynamic statusId, statusName;
#endif

+ (RKObjectMapping*) mapping
{
    static RKObjectMapping *mapping = nil;
    
    pr_dispatch_once({
        
        mapping = [super mapping];
        
        [mapping addAttributeMappingsFromDictionary:
         @{
           @"id" : @"statusId",
           @"name" : @"statusName"}];
    });
    
    return mapping;
}

@end
