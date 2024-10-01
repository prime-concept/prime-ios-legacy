//
//  PRWebSocketMessageModel.h
//  PRIME
//
//  Created by Artak on 17/08/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRWebSocketBaseModel.h"

@class PRWebSocketMessageContent;

@interface PRWebSocketMessageBaseModel : PRWebSocketBaseModel

@property (nonatomic) BOOL isSent;
@property (nonatomic, retain) PRWebSocketMessageContent* body;
@property (nonatomic) MessageState state;

@end
