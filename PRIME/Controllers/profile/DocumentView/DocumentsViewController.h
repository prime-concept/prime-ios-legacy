//
//  DocumentsViewController.h
//  PRIME
//
//  Created by Artak on 7/2/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "ProfileBaseViewController.h"
#import <SSPullToRefresh/SSPullToRefreshView.h>
#import <UIKit/UIKit.h>

@interface DocumentsViewController : ProfileBaseViewController <UITableViewDataSource, UITableViewDelegate, ReloadTable>

@property (strong, nonatomic) PRUserProfileModel* userProfile;
@property (strong, nonatomic) id<ReloadTable> reloadDelegate;

@end
