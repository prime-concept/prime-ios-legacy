//
//  PRTaskDetailModel.m
//  PRIME
//
//  Created by Simon on 15/01/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRActionModel.h"
#import "PROrderModel.h"
#import "PRTaskDetailModel.h"
#import "PRTaskItemModel.h"

@implementation PRTaskDetailModel

#ifdef USE_COREDATA
@dynamic taskId, taskName, taskType, requestDate, taskDescription, customerId, responsibleId, status, items, orders, actions, reserved, completed, day, chatId, taskLinkId;
#endif

+ (RKObjectMapping*)mapping
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({

        mapping = [super mapping];

        [self addMapingAttributes:mapping];
    });

    return mapping;
}

+ (RKObjectMapping*)mappingForChat
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({

        mapping = [RKEntityMapping mappingForEntityForName:@"PRTaskDetailModelChat"
                                      inManagedObjectStore:[RKManagedObjectStore defaultStore]];

        [self addMapingAttributes:mapping];
    });

    return mapping;
}

+ (void)addMapingAttributes:(RKObjectMapping*)mapping
{
    [mapping addAttributeMappingsFromDictionary:
                 @{
                     @"id" : @"taskId",
                     @"name" : @"taskName",
                     @"description" : @"taskDescription",
                     @"taskId" : @"taskLinkId"
                 }];

    [mapping addAttributeMappingsFromArray:
                 @[
                    @"requestDate",
                    @"customerId",
                    @"responsibleId",
                    @"reserved",
                    @"completed",
                    @"chatId",
                 ]];

    [mapping addRelationshipMappingWithSourceKeyPath:@"taskType"
                                             mapping:[PRTaskTypeModel mapping]];

    [mapping addRelationshipMappingWithSourceKeyPath:@"status"
                                             mapping:[PRTaskStatusModel mapping]];

    [mapping addRelationshipMappingWithSourceKeyPath:@"orders"
                                             mapping:[PROrderModel mapping]];

    RKRelationshipMapping* relationshipMapping =
        [RKRelationshipMapping relationshipMappingFromKeyPath:@"items"
                                                    toKeyPath:@"items"
                                                  withMapping:[PRTaskItemModel mapping]];

    // To replace optional fields.
    relationshipMapping.assignmentPolicy = RKAssignmentPolicyReplace;

    [mapping addPropertyMapping:relationshipMapping];

    [PRTaskDetailModel setIdentificationAttributes:@[ @"taskId" ]
                                           mapping:mapping];
}

+ (RKObjectMapping*)mappingForActions
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({

        mapping = [super mapping];

        RKRelationshipMapping* relationshipMapping =
            [RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                        toKeyPath:@"actions"
                                                      withMapping:[PRActionModel mapping]];
        [mapping addPropertyMapping:relationshipMapping];
    });

    return mapping;
}

- (NSDate*)beginningOfDay:(NSDate*)date
{
    NSCalendar* cal = [NSCalendar currentCalendar];
    NSDateComponents* components = [cal components:(NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:date];

    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];

    return [cal dateFromComponents:components];
}

- (NSDate*)day
{

    return [self.requestDate mt_startOfCurrentDay];
}

@end
