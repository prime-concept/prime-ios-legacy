//
//  PCSubscriptionModel.h
//  PRIME
//
//  Created by Sargis Terteryan on 5/18/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import "PRModel.h"

@interface PRSubscriptionModel : PRModel

@property (nonatomic, strong) NSString* channelId;
@property (nonatomic, strong) NSNumber* unseenMessagesCount;

+ (RKObjectMapping*)mapping;

@end
