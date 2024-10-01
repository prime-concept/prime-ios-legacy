//
//  XNTLazyManager.h
//  XNTrends
//
//  Created by Simon Simonyan on 2/18/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRRequestManager.h"

@interface XNTLazyManager : NSObject

- (id) initWithObserver:(id)observer
               selector:(SEL)selector;

- (void) shouldBeRefreshedWithDate: (NSDate*) date
                    relativeToDate: (NSDate*) currentDate
                              then: (void (^)(PRRequestMode mode)) then
                         otherwise: (void (^)()) otherwise;

- (void) shouldBeUpdatedIfReachabilityChangedWithNotification: (NSNotification *) notification
                                                         date: (NSDate*) date
                                               relativeToDate: (NSDate*) currentDate
                                                         then: (void (^)(PRRequestMode mode)) then;

- (void) shouldBeUpdatedIfViewDidAppearWithDate: (NSDate *) date
                                 relativeToDate: (NSDate*) currentDate
                                           then: (void (^)(PRRequestMode mode)) then
                           otherwiseIfFirstTime: (void (^)()) otherwiseIfFirstTime
                                      otherwise: (void (^)()) otherwise;

- (void) shouldBeUpdatedWithDate: (NSDate*) date
                  relativeToDate: (NSDate*) currentDate
                            then: (void (^)()) then
                       otherwise: (void (^)()) otherwise;
@end
