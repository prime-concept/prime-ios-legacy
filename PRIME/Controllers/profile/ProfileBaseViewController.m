//
//  ProfileBaseViewController.m
//  PRIME
//
//  Created by Artak on 7/3/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "ProfileBaseViewController.h"

@interface ProfileBaseViewController ()

@end

@implementation ProfileBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _lazyManager = [[XNTLazyManager alloc] initWithObserver:self
                                                   selector:@selector(reachabilityChanged:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    UINavigationBar* navigationBar = self.navigationController.navigationBar;
    [navigationBar showBottomHairline];
    [navigationBar setTintColor:kNavigationBarTintColor];
}

- (void)initPullToRefreshForScrollView:(UIScrollView*)scrollView
{
    NSAssert(_pullToRefreshView == nil, @"PullToRefresh already initialized");
    _pullToRefreshView = [[SSPullToRefreshView alloc] initWithScrollView:scrollView
                                                                delegate:self];
}

- (void)reachabilityChanged:(NSNotification*)note
{
    //Implementation.
}
@end
