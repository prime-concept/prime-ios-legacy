//
//  PRWebSocketBaseModel.m
//  PRIME
//
//  Created by Admin on 17/08/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRWebSocketBaseModel.h"

@implementation PRWebSocketBaseModel

@dynamic type;
@dynamic requestId;
@dynamic guid;
@dynamic body;

+ (RKObjectMapping*)mapping
{

    RKObjectMapping* mapping = [super mapping];

    [mapping addAttributeMappingsFromArray:
                 @[
                    @"type",
                    @"requestId",
                    @"guid"
                 ]];

    return mapping;
}

@end
