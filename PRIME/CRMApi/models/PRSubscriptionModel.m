//
//  PCSubscriptionModel.m
//  PRIME
//
//  Created by Sargis Terteryan on 5/18/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import "PRSubscriptionModel.h"

@implementation PRSubscriptionModel

#ifdef USE_COREDATA
@dynamic channelId;
@dynamic unseenMessagesCount;
#endif

+ (RKObjectMapping*)mapping
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({

        mapping = [super mapping];

        [mapping addAttributeMappingsFromDictionary:
         @{
           @"channelId" : @"channelId",
           @"unread" : @"unseenMessagesCount"}];

        mapping.assignsNilForMissingRelationships = YES;

        [PRSubscriptionModel setIdentificationAttributes:@[ @"channelId" ]
                                                 mapping:mapping];

    });

    return mapping;
}

@end
