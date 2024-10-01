//
//  PRWebSocketBaseModel.h
//  PRIME
//
//  Created by Admin on 17/08/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PRWebSocketBaseModel : PRModel

@property (nonatomic, retain) NSNumber* type;
@property (nonatomic, retain) NSNumber* requestId;
@property (nonatomic, retain) NSString* guid;

@property (nonatomic, retain) id body;

@property (nonatomic, retain) NSDate* creationDate; //internal use
+ (RKObjectMapping*)mapping;
@end
