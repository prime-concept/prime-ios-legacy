//
//  PRCalendarEventManager.m
//  PRIME
//
//  Created by Aram on 3/8/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import "PRCalendarEventManager.h"
#import "EventKit/EventKit.h"

@interface PRCalendarEventManager ()
@property (nonatomic, strong) EKEventStore* eventStore;
@property (nonatomic, strong) NSMutableArray<PRTaskDetailModel*>* eventsToSync;
@property (nonatomic, assign) BOOL isEventUpdateProcessInProgress;
@end

@implementation PRCalendarEventManager

+ (PRCalendarEventManager*)sharedInstance
{
    static PRCalendarEventManager* sharedInstance;

    pr_dispatch_once({
        sharedInstance = [PRCalendarEventManager new];
        sharedInstance.eventStore = [EKEventStore new];
    });

    return sharedInstance;
}

#pragma mark - Public Functions

- (void)syncEventsWithNativeCalendar:(NSArray<PRTaskDetailModel*>*)events
{
    _eventsToSync = [events mutableCopy];
    if (!_isEventUpdateProcessInProgress) {
        __weak PRCalendarEventManager* weakSelf = self;
        [_eventStore requestAccessToEntityType:EKEntityTypeEvent
                                    completion:^(BOOL granted, NSError* _Nullable error) {
                                        PRCalendarEventManager* strongSelf = weakSelf;
                                        if (!strongSelf) {
                                            return;
                                        }

                                        if (!granted) {
                                            [PRGoogleAnalyticsManager sendEventWithName:kCalendarPermissionDoNotAllowButtonClicked parameters:nil];
                                            return;
                                        }
                                        [PRGoogleAnalyticsManager sendEventWithName:kCalendarPermissionAllowButtonClicked parameters:nil];
                                        [self addEventsToNativeCalendarFromArray:_eventsToSync];
                                    }];
    }
}

#pragma mark - Functionality

- (void)addEventsToNativeCalendarFromArray:(NSArray<PRTaskDetailModel*>*)events
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* oneMonthAgoComponents = [[NSDateComponents alloc] init];
    oneMonthAgoComponents.month = -1;
    NSDate* oneMonthAgo = [calendar dateByAddingComponents:oneMonthAgoComponents
                                                    toDate:[NSDate date]
                                                   options:0];
    NSDate* endDate = [NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24 * 365];
    NSPredicate* predicate = [_eventStore predicateForEventsWithStartDate:oneMonthAgo endDate:endDate calendars:nil];

    NSMutableArray* eventsToAdd = [NSMutableArray new];
    NSMutableDictionary* eventsToUpdate = [NSMutableDictionary dictionary];
    NSArray<EKEvent*>* eventsOnDate = [_eventStore eventsMatchingPredicate:predicate];

    for (PRTaskDetailModel* task in events) {
        if ([task.requestDate mt_isAfter:oneMonthAgo]) {
            BOOL exists = NO;

            if (eventsOnDate) {
                for (EKEvent* event in eventsOnDate) {
                    NSString* eventNotes = event.notes;
                    NSRange range = [eventNotes rangeOfString:kURLSchemesPrefix];
                    if (range.location != NSNotFound) {
                        NSString* result = [eventNotes substringFromIndex:range.location];
                        result = [result stringByTrimmingCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];

                        if ([result isEqualToString:[task.taskId stringValue]]) {
                            exists = YES;
                            [eventsToUpdate setObject:task forKey:event.eventIdentifier];
                            break;
                        }
                    }
                }
            }

            if (!exists) {
                [eventsToAdd addObject:task];
            }
        }
    }

    if (eventsToAdd.count > 0) {
        [self addEvents:eventsToAdd];
    }
    if (eventsToUpdate.count > 0) {
        [self updateEventsToNativeCalendar:eventsToUpdate];
    }
}

- (NSString*)getNotesSufix:(PRTaskDetailModel*)task
{
    return [@" " stringByAppendingString:[kURLSchemesPrefix stringByAppendingString:[NSString stringWithFormat:@"taskinfo/%@", [task.taskId stringValue]]]];
}

- (void)addEventsToNativeCalendar:(NSArray<PRTaskDetailModel*>*)events
{
    for (PRTaskDetailModel* task in events) {
        if (!task.taskId) {
            continue;
        }

        NSString* notesSufix = [self getNotesSufix:task];
        EKEvent* event = [EKEvent eventWithEventStore:_eventStore];
        event.title = task.taskName;
        if (task.taskDescription) {
            event.notes = [task.taskDescription stringByAppendingString:notesSufix];
        } else {
            event.notes = notesSufix;
        }
        event.calendar = [_eventStore defaultCalendarForNewEvents];
        event.startDate = task.requestDate;
        event.endDate = task.requestDate;

        [_eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:nil];
    }
}

- (void)updateEventsToNativeCalendar:(NSMutableDictionary<NSString*, PRTaskDetailModel*>*)events
{
    if (!_isEventUpdateProcessInProgress) {
        for (NSString* eventIdentifier in events.allKeys) {
            PRTaskDetailModel* task = [events valueForKey:eventIdentifier];
            EKEvent* event = [_eventStore eventWithIdentifier:eventIdentifier];
            if (event) {
                NSString* notesSufix = [self getNotesSufix:task];
                event.title = task.taskName;
                event.notes = [task.taskDescription stringByAppendingString:notesSufix];
                event.calendar = [_eventStore defaultCalendarForNewEvents];
                event.startDate = task.requestDate;
                event.endDate = task.requestDate;

                [_eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:nil];
            }
        }
    }
}

- (void)addEvents:(NSArray<PRTaskDetailModel*>*)events
{
    if (!_isEventUpdateProcessInProgress) {
        _isEventUpdateProcessInProgress = YES;
        // It is a Apple issue that cannot get default calendar to get events, so as a temporary solution is to refresh the event store instance.
        _eventStore = [EKEventStore new];
        [self addEventsToNativeCalendar:events];
        _isEventUpdateProcessInProgress = NO;
    }
}

@end
