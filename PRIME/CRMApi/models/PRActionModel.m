//
//  PRActionModel.m
//  PRIME
//
//  Created by Simon on 3/13/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRActionModel.h"

@implementation PRActionModel

#ifdef USE_COREDATA
@dynamic actionId, actionName, date, code, actionDescription, user;
#endif

+ (RKObjectMapping*) mapping
{
    static RKObjectMapping *mapping = nil;
    
    pr_dispatch_once({
        
        mapping = [super mapping];
        
        [mapping addAttributeMappingsFromDictionary:
         @{
           @"id" : @"actionId",
           @"name" : @"actionName",
           @"description" : @"actionDescription"}];
        
        [mapping addAttributeMappingsFromArray:
         @[
           @"date",
           @"code"
           ]];
        
        [mapping addRelationshipMappingWithSourceKeyPath: @"user"
                                                 mapping: [PRUserModel mapping]];
        
        [PRActionModel setIdentificationAttributes: @[@"actionId"]
                                           mapping: mapping];
    });
    
    return mapping;
}

@end