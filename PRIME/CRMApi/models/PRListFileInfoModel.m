//
//  PRListFileInfoModel.m
//  PRIME
//
//  Created by Admin on 6/5/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRListFileInfoModel.h"

@implementation PRListFileInfoModel

+ (RKObjectMapping*) mapping
{
    static RKObjectMapping *mapping = nil;
    
    pr_dispatch_once({
        
        mapping = [RKObjectMapping mappingForClass: [self class]];
        
        [mapping addAttributeMappingsFromDictionary:
         @{
           @"description" : @"fileDescription"
           }];
        
        [mapping addAttributeMappingsFromArray:
         @[
           @"uid",
           @"fileName",
           @"size",
           @"createdAt",
           @"contentType",
           @"height",
           @"width"
           ]];
        
    });
    
    return mapping;
}

@end
