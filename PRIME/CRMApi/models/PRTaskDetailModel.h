//
//  PRTaskDetailModel.h
//  PRIME
//
//  Created by Simon on 15/01/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#ifndef PRIME_PRTasksDetailModel_h
#define PRIME_PRTasksDetailModel_h

#import "PRTaskItemModel.h"
#import "PRTaskStatusModel.h"
#import "PRTaskTypeModel.h"
#import "PROrderModel.h"
#import "PRActionModel.h"
#import "PRModel.h"

@interface PRTaskDetailModel : PRModel

@property (nonatomic, strong) NSNumber* taskId;
@property (nonatomic, strong) NSString* taskName;
@property (nonatomic, strong) PRTaskTypeModel* taskType;
@property (nonatomic, strong) NSDate* requestDate;
@property (nonatomic, strong) NSString* taskDescription;
@property (nonatomic, strong) NSNumber* customerId;
@property (nonatomic, strong) NSNumber* responsibleId;
@property (nonatomic, strong) PRTaskStatusModel* status;
@property (nonatomic, strong) NSOrderedSet<PRTaskItemModel*>* items;
@property (nonatomic, strong) NSOrderedSet<PROrderModel*>* orders;
@property (nonatomic, strong) NSOrderedSet<PRActionModel*>* actions;

@property (nonatomic, strong) NSDate* day; // Used for Grouping.
@property (nonatomic, strong) NSNumber* reserved;
@property (nonatomic, strong) NSNumber* completed;

@property (nonatomic, strong) NSNumber* chatId;
@property (nonatomic, strong) NSNumber* taskLinkId;

+ (RKObjectMapping*)mapping;
+ (RKObjectMapping*)mappingForActions;
+ (RKObjectMapping*)mappingForChat;
@end

#endif
