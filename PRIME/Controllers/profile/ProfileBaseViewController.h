//
//  ProfileBaseViewController.h
//  PRIME
//
//  Created by Artak Tsatinyan on 7/3/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "BaseViewController.h"
#import "XNTLazyManager.h"
#import "UINavigationBar+Addition.h"
#import <SSPullToRefresh/SSPullToRefreshView.h>
#import <UIKit/UIKit.h>

@protocol ReloadTable <NSObject>

@optional
- (void)reload;
- (void)deleteDocumentWithId:(NSNumber*)documentId;
@end

@interface ProfileBaseViewController : BaseViewController <SSPullToRefreshViewDelegate>

@property (strong, nonatomic) SSPullToRefreshView* pullToRefreshView;

@property (strong, nonatomic) XNTLazyManager* lazyManager;

- (void)initPullToRefreshForScrollView:(UIScrollView*)scrollView;

@end
