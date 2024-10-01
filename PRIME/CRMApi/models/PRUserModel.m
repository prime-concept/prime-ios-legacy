//
//  PRUserModel.m
//  PRIME
//
//  Created by Simon on 3/13/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRUserModel.h"

@implementation PRUserModel

#ifdef USE_COREDATA
@dynamic userId, userName;
#endif

+ (RKObjectMapping*) mapping
{
    static RKObjectMapping *mapping = nil;
    
    pr_dispatch_once({
        
        mapping = [super mapping];
        
        [mapping addAttributeMappingsFromDictionary:
         @{
           @"id" : @"userId",
           @"name" : @"userName"}];
        
        [PRUserModel setIdentificationAttributes: @[@"userId"]
                                         mapping: mapping];
    });
    
    return mapping;
}

@end