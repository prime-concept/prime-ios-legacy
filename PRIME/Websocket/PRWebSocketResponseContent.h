//
//  PRWebSocketResponseContent.h
//  PRIME
//
//  Created by Admin on 8/19/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRModel.h"

@interface PRWebSocketResponseContent : PRModel

@property (nonatomic, retain) NSNumber* status;
@property (nonatomic, retain) NSString* messageType;

@end
