//
//  PRWebSocketFeedback.m
//  PRIME
//
//  Created by Admin on 17/08/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRWebSocketFeedbackModel.h"
#import "PRWebSocketFeedbackContent.h"

@implementation PRWebSocketFeedbackModel

@dynamic body;
@dynamic isSent;

+ (RKObjectMapping*)mapping
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({

        mapping = [super mapping];

        [mapping addRelationshipMappingWithSourceKeyPath:@"body"
                                                 mapping:[PRWebSocketFeedbackContent mapping]];
    });

    return mapping;
}

@end
