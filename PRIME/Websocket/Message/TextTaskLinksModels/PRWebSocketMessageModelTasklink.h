//
//  PRWebSocketMessageModelTasklink.h
//  PRIME
//
//  Created by Artak on 3/28/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "PRWebSocketMessageBaseModel.h"
#import "PRWebSocketMessageContentTasklink.h"

@interface PRWebSocketMessageModelTasklink : PRWebSocketMessageBaseModel

@property (nonatomic, retain) PRWebSocketMessageContentTasklink *body;

@end
