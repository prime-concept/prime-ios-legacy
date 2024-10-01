//
//  PRWebSocketRegistrationContent.h
//  PRIME
//
//  Created by Admin on 8/19/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRModel.h"


@interface PRWebSocketRegistrationContent : PRModel

@property (nonatomic, retain) NSString * clientId;
@property (nonatomic, retain) NSString * chatId;
@property (nonatomic, retain) NSString * deviceId;
@property (nonatomic, retain) NSNumber * timestamp;

@end
