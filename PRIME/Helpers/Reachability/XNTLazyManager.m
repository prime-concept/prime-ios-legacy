//
//  XNTLazyManager.m
//  XNTrends
//
//  Created by Simon Simonyan on 2/18/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "XNTLazyManager.h"
#import "Reachability.h"

@interface XNTLazyManager () {
    NSMutableSet* loadedDataSet;
}

//@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability* internetReachability;
@property (nonatomic) Reachability* wifiReachability;

@property (atomic) NetworkStatus netStatus;
@property (atomic) BOOL connectionRequired;

@property (nonatomic, assign) dispatch_once_t onceTokenForFirstTime;
@property (nonatomic, assign) dispatch_once_t onceTokenForReachability;

@end

@implementation XNTLazyManager

- (instancetype)initWithObserver:(id)observer
                        selector:(SEL)selector
{
    self = [super init];
    if (self) {
        loadedDataSet = [[NSMutableSet alloc] init];

        // Observe the kNetworkReachabilityChangedNotification. When that notification is
        // posted, the method reachabilityChanged will be called.
        [[NSNotificationCenter defaultCenter] addObserver:observer
                                                 selector:selector
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
    }
    return self;
}

- (void)shouldBeRefreshedWithDate:(NSDate*)date
                   relativeToDate:(NSDate*)currentDate
                             then:(void (^)(PRRequestMode mode))then
                        otherwise:(void (^)())otherwise
{
    [loadedDataSet removeAllObjects]; //TODO: !!!

    [self shouldBeUpdatedWithDate:date
                   relativeToDate:currentDate
                             then:^{
                                 then(PRRequestMode_ShowOnlyErrorMessages); // Because progress is shown by PullToRefresh itself
                             }
                        otherwise:otherwise];
}

- (void)shouldBeUpdatedIfReachabilityChangedWithNotification:(NSNotification*)notification
                                                        date:(NSDate*)date
                                              relativeToDate:(NSDate*)currentDate
                                                        then:(void (^)(PRRequestMode mode))then
{
    Reachability* curReach = [notification object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);

    [self ifNetworkReachableThenUpdateStatusWithReachability:curReach
                                                        then:
                                                            ^{

                                                                [self ifFirstTime:^{
                                                                    [PRMessageAlert showToastWithMessage:Message_ConnectedToInternet];

                                                                    [self shouldBeUpdatedWithDate:date
                                                                                   relativeToDate:currentDate
                                                                                             then:^{
                                                                                                 then(PRRequestMode_ShowOnlyProgress); // It will be worong to show error messages suddenly
                                                                                             }
                                                                                        otherwise:nil];
                                                                }
                                                                    otherwise:^{
                                                                        [self shouldBeUpdatedWithDate:date
                                                                                       relativeToDate:currentDate
                                                                                                 then:^{
                                                                                                     then(PRRequestMode_ShowOnlyProgress); // It will be worong to show error messages suddenly
                                                                                                 }
                                                                                            otherwise:nil];
                                                                    }];
                                                            }];
}

- (void)shouldBeUpdatedIfViewDidAppearWithDate:(NSDate*)date
                                relativeToDate:(NSDate*)currentDate
                                          then:(void (^)(PRRequestMode mode))then
                          otherwiseIfFirstTime:(void (^)())otherwiseIfFirstTime
                                     otherwise:(void (^)())otherwise
{
    dispatch_once(&_onceTokenForReachability, ^{
        /*self.hostReachability = [Reachability reachabilityWithHostName:kServerBaseUrl];
         [self.hostReachability startNotifier];
         [self updateInterfaceWithReachability:self.hostReachability];*/

        self.internetReachability = [Reachability reachabilityForInternetConnection];
        [self.internetReachability startNotifier];

        // DO NOT REMOVE!!! It should update Reachability Status
        [self ifNetworkReachableThenUpdateStatusWithReachability:self.internetReachability
                                                            then:^{
                                                                //Do nothing
                                                            }];

        self.wifiReachability = [Reachability reachabilityForLocalWiFi];
        [self.wifiReachability startNotifier];

        // DO NOT REMOVE!!! It should update Reachability Status
        [self ifNetworkReachableThenUpdateStatusWithReachability:self.internetReachability
                                                            then:^{
                                                                //Do nothing
                                                            }];
    });

    [self ifNetworkReachable:^{
        [self ifFirstTime:^{

            // Call trought shouldBeUpdatedWithDate to refresh cached dates !!!
            [self shouldBeUpdatedWithDate:date
                relativeToDate:currentDate
                then:^{
                    then(PRRequestMode_ShowErrorMessagesAndProgress);
                }
                otherwise:^{
                    NSAssert(0, @"Otherwise should not be called!");
                }];

        }
            otherwise:^{
                [self shouldBeUpdatedWithDate:date
                    relativeToDate:currentDate
                    then:^{
                        then(PRRequestMode_ShowOnlyProgress);
                    }
                    otherwise:^{
                        otherwise();
                    }];
            }];

    }
        otherwise:^{
            [self ifFirstTime:^{
                otherwiseIfFirstTime();
            }
                otherwise:^{
                    otherwise();
                }];
        }];
}

- (void)shouldBeUpdatedWithDate:(NSDate*)date
                 relativeToDate:(NSDate*)currentDate
                           then:(void (^)())then
                      otherwise:(void (^)())otherwise
{
    NSString* key = [self.class keyForDate:date];

    BOOL exist = [loadedDataSet containsObject:key];

    if (!exist) {
        [self ifNetworkReachable:^{

            NSString* keyGroup = [self.class keyForGroupWithDate:date];

            do {
                if (currentDate) {
                    NSString* currentKeyGroup = [self.class keyForGroupWithDate:currentDate];

                    if ([keyGroup isEqualToString:currentKeyGroup]) {
                        NSDate* dateThreeMonthsBefore = [date mt_dateMonthsBefore:3];

                        for (int i = 0; i != 7; ++i) {
                            NSDate* date = [dateThreeMonthsBefore mt_dateMonthsAfter:i];

                            keyGroup = [self.class keyForGroupWithDate:date];

                            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"SELF beginswith '%@'", keyGroup];
                            NSSet* filteredSet = [loadedDataSet filteredSetUsingPredicate:predicate];

                            for (NSString* _key in filteredSet) {
                                [loadedDataSet removeObject:_key];
                            }

                            NSString* key = [self.class keyForDate:date];

                            [loadedDataSet addObject:key];
                        }

                        break;
                    }
                }

                NSPredicate* predicate = [NSPredicate predicateWithFormat:@"SELF beginswith '%@'", keyGroup];
                NSSet* filteredSet = [loadedDataSet filteredSetUsingPredicate:predicate];

                for (NSString* _key in filteredSet) {
                    [loadedDataSet removeObject:_key];
                }

                [loadedDataSet addObject:key];

            } while (NO);

            then();
        }
                       otherwise:otherwise];

    } else if (otherwise) {
        otherwise();
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

#pragma mark Private functions
#pragma mark -

- (void)ifNetworkReachableThenUpdateStatusWithReachability:(Reachability*)reachability
                                                      then:(void (^)())then
{
    self.netStatus = [reachability currentReachabilityStatus];
    self.connectionRequired = [reachability connectionRequired];

    switch (_netStatus) {
    case NotReachable: {
        // Minor interface detail- connectionRequired may return YES even
        // when the host is unreachable. We cover that up here...
        _connectionRequired = NO;
        break;
    }

    case ReachableViaWWAN:
    case ReachableViaWiFi:

        then();

        break;
    }
}

- (void)ifFirstTime:(void (^)())firstTime
          otherwise:(void (^)())otherwise
{
    pr_dispatch_once_with_else_ex(_onceTokenForFirstTime,
        {
            firstTime();

        },
        ^{

            if (otherwise) {
                otherwise();
            }
        });
}

- (void)ifNetworkReachable:(void (^)())networkReachable
                 otherwise:(void (^)())otherwise
{
    if ((_netStatus != NotReachable) && (_connectionRequired == NO)) {
        networkReachable();

    } else if (otherwise) {
        otherwise();
    }
}

+ (NSString*)keyForDate:(NSDate*)date
{
    return [date mt_stringFromDateWithFormat:@"YYYYMMDDHH" localized:NO];
}

+ (NSString*)keyForGroupWithDate:(NSDate*)date
{
    return [date mt_stringFromDateWithFormat:@"YYYYMM" localized:NO];
}

@end
