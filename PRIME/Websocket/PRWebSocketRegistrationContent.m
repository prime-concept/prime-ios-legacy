//
//  PRWebSocketRegistrationContent.m
//  PRIME
//
//  Created by Admin on 8/19/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRWebSocketRegistrationContent.h"


@implementation PRWebSocketRegistrationContent

@dynamic clientId;
@dynamic chatId;
@dynamic deviceId;
@dynamic timestamp;

+ (RKObjectMapping*)mapping
{
    static RKObjectMapping* mapping = nil;
    
    pr_dispatch_once({
        
        mapping = [super mapping];
        
        [mapping addAttributeMappingsFromArray:
         @[
           @"clientId",
           @"chatId",
           @"deviceId",
           @"timestamp"
           ]];
    });
    
    return mapping;
}
@end
