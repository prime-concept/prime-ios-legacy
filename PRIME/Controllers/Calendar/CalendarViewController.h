//
//  CalendarViewController.h
//  PRIME
//
//  Created by Simon on 1/29/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "BaseViewController.h"
#import "JTCalendar.h"
#import "PRUITabBarController.h"
#import <SSPullToRefresh/SSPullToRefreshView.h>

@interface CalendarViewController : BaseViewController <JTCalendarDataSource, UITableViewDelegate, SSPullToRefreshViewDelegate, TabBarItemChanged>

@property (strong, nonatomic) JTCalendar* calendar;
@property (strong, nonatomic) UILabel* labelNoData;

- (void)setCalendarSelectedDateToDate:(NSDate*)date;
- (void)setCalendarSelectedIdToDate:(NSNumber*)taskId;

@end
