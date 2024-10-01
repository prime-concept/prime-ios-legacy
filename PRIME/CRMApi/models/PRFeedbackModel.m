//
//  PRFeedbackModel.m
//  PRIME
//
//  Created by Admin on 9/29/15.
//  Copyright © 2015 XNTrends. All rights reserved.
//

#import "PRFeedbackModel.h"


@implementation PRFeedbackModel

@dynamic comment;
@dynamic stars;
@dynamic objectId;
@dynamic objectType;

+ (RKObjectMapping*) mapping
{
    static RKObjectMapping *mapping = nil;
    
    pr_dispatch_once({
        
        mapping = [super mapping];
        
        [mapping addAttributeMappingsFromArray:
         @[
           @"comment",
           @"stars",
           @"objectId",
           @"objectType"
           ]];
    });
    
    
    [self setIdentificationAttributes: @[@"objectId"]
                              mapping: mapping];
    return mapping;
}

@end
