//
//  PRWebSocketFeedback.h
//  PRIME
//
//  Created by Admin on 17/08/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PRWebSocketBaseModel.h"

@class PRWebSocketFeedbackContent;

@interface PRWebSocketFeedbackModel : PRWebSocketBaseModel

@property (nonatomic) BOOL isSent;
@property (nonatomic, retain) PRWebSocketFeedbackContent* body;

@end
