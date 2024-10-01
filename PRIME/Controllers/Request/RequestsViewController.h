//
//  RequestsViewController.h
//  PRIME
//
//  Created by Simon on 1/30/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "BaseViewController.h"
#import "PRUITabBarController.h"
#import "RequestDataSource.h"
#import <SSPullToRefresh/SSPullToRefreshView.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, RequestFilter) {
    RequestsFilter_Non,
    RequestsFilter_CategoryId,
#ifdef NEW_IMPLEMENTATION
    RequestsFilter_Open,
    RequestsFilter_Close
#endif //NEW_IMPLEMENTATION
};

@class RequestsDetailViewController;

@interface RequestsViewController : BaseViewController <SSPullToRefreshViewDelegate, UITableViewDelegate, PRPayButtonDelegate, TabBarItemChanged>

@property (strong, nonatomic) UISegmentedControl* reservesOrRequestsSegmentedControl;

@property (strong, nonatomic) RequestDataSource* requestDataSource;

@property (strong, nonatomic) SSPullToRefreshView* pullToRefreshView;

@property (strong, nonatomic) NSNumber* filterById;
@property (nonatomic, assign) RequestFilter filterForKey;
@property (strong, nonatomic) UILabel* labelNoData;

- (IBAction)filterRequest:(UISegmentedControl*)sender;
- (IBAction)filterTaskStatus:(UISegmentedControl*)sender;
- (RequestsDetailViewController*)openRequestDetails:(NSNumber*)taskId
                                     andRequestDate:(NSDate*)requestDate
                                      withAnimation:(BOOL)animation;

- (void)updateRequestsWithSegment:(NSInteger)segment;
@end
