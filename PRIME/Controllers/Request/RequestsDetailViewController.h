//
//  RequestsDetailViewController.h
//  PRIME
//
//  Created by Artak Tsatinyan on 2/10/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "BaseViewController.h"
#import "PRTaskDetailModel.h"
#import "TTTAttributedLabel.h"

#import <SSPullToRefresh/SSPullToRefreshView.h>
#import <UIKit/UIKit.h>

@interface RequestsDetailViewController : BaseViewController <SSPullToRefreshViewDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, TTTAttributedLabelDelegate, UIActionSheetDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) NSNumber* taskId;
@property (strong, nonatomic) NSDate* requestDate;

@property (strong, nonatomic) SSPullToRefreshView* pullToRefreshView;

- (void)openChat;

@end
