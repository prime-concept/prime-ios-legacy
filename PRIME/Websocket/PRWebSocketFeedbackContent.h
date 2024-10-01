//
//  PRWebSocketFeedbackContent.h
//  PRIME
//
//  Created by Admin on 17/08/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PRWebSocketFeedbackContent : PRModel

@property (nonatomic, retain) NSString* chatId;
@property (nonatomic, retain) NSString* clientId;
@property (nonatomic, retain) NSString* messageId;
@property (nonatomic, retain) NSNumber* status;
@property (nonatomic, retain) NSNumber* timestamp;

@end
