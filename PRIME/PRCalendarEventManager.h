//
//  PRCalendarEventManager.h
//  PRIME
//
//  Created by Aram on 3/8/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PRCalendarEventManager : NSObject

+ (PRCalendarEventManager*)sharedInstance;

- (void)syncEventsWithNativeCalendar:(NSArray<PRTaskDetailModel*>*)evens;

@end
