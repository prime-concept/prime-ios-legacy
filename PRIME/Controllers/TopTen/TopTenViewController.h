//
//  TopTenViewController.h
//  PRIME
//
//  Created by Artak on 1/31/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRUITabBarController.h"
#import "WebViewController.h"
#import <SSPullToRefresh/SSPullToRefreshView.h>
#import <UIKit/UIKit.h>

@interface TopTenViewController : WebViewController <TabBarItemChanged, CLLocationManagerDelegate>

- (void)setCityGuideWithDeepLink:(NSString*)url;
- (void)initLocationManager;
- (void)deleteCookiesWithCompletionBlock:(void (^)())completionBlock;

@end
