//
//  PRWebSocketResponseModel.m
//  PRIME
//
//  Created by Admin on 8/19/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRWebSocketResponseModel.h"
#import "PRWebSocketResponseContent.h"


@implementation PRWebSocketResponseModel

@dynamic body;

+ (RKObjectMapping*)mapping
{
    static RKObjectMapping* mapping = nil;
    
    pr_dispatch_once({
        
        mapping = [super mapping];
        
        [mapping addRelationshipMappingWithSourceKeyPath:@"body"
                                                 mapping:[PRWebSocketResponseContent mapping]];
    });
    
    return mapping;
}
@end
