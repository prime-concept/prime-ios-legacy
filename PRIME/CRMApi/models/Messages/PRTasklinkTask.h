//
//  PRTasklinkTask.h
//  PRIME
//
//  Created by Aram on 11/15/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRModel.h"

@interface PRTasklinkTask : PRModel
@property (nonatomic, strong) NSNumber* taskId;
@property (nonatomic, strong) NSString* taskName;
@property (nonatomic, strong) PRTaskTypeModel* taskType;
@property (nonatomic, strong) NSDate* requestDate;
@property (nonatomic, strong) NSString* taskDescription;
@property (nonatomic, strong) NSNumber* customerId;
@property (nonatomic, strong) NSNumber* reserved;
@property (nonatomic, strong) NSNumber* completed;
@property (nonatomic, strong) NSNumber* taskLinkId;

+ (RKObjectMapping*)mapping;

@end
