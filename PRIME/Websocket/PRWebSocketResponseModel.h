//
//  PRWebSocketResponseModel.h
//  PRIME
//
//  Created by Admin on 8/19/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PRWebSocketBaseModel.h"
#import "PRWebSocketResponseContent.h"

@class NSManagedObject;

@interface PRWebSocketResponseModel : PRWebSocketBaseModel

@property (nonatomic, retain) PRWebSocketResponseContent *body;

@end
