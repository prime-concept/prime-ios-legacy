//
//  PRWebSocketMessageModel.h
//  PRIME
//
//  Created by Artak on 3/28/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "PRWebSocketMessageBaseModel.h"
#import "PRWebSocketMessageContentText.h"

@interface PRWebSocketMessageModel : PRWebSocketMessageBaseModel

@property (nonatomic, retain) PRWebSocketMessageContentText *body;
@end
