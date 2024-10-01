//
//  PRWebSocketRegistrationModel.h
//  PRIME
//
//  Created by Artak on 8/19/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRWebSocketBaseModel.h"
#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@class PRWebSocketRegistrationContent;

@interface PRWebSocketRegistrationModel : PRWebSocketBaseModel

@property (nonatomic, retain) PRWebSocketRegistrationContent* body;
@property (nonatomic, retain) NSString* version;

@end
