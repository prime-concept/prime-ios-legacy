//
//  PRWebSocketTasklinkContent.h
//  PRIME
//
//  Created by Artak on 3/24/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "PRModel.h"
#import "PRTaskDetailModel.h"
#import "PRWebSocketMessageContentText.h"

@interface PRWebSocketTasklinkContent : PRModel

@property (nonatomic, retain) PRTaskDetailModel* task;
@property (nonatomic, retain) PRWebSocketMessageModel* message;

@end
