//
//  BaseViewController.m
//  PRIME
//
//  Created by Gayane on 5/29/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:[self shouldHideNavigationBar]];

#if defined(VTB24) 
    [self setNavigationBarAndStatusBarColors];
#endif
}

- (BOOL)shouldHideNavigationBar
{
    return NO;
}

- (void)setNavigationBarAndStatusBarColors
{
    [[UIApplication sharedApplication] setStatusBarStyle:[self getStatusBarColor]];
    self.navigationController.navigationBar.barTintColor = [self getNavigationBarColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{ NSForegroundColorAttributeName : [self getNavigationBarTitleColor] }];
}

- (UIStatusBarStyle)getStatusBarColor
{
    return UIStatusBarStyleLightContent;
}

- (UIColor*)getNavigationBarColor
{
    return kNavigationBarBarTintColor;
}

- (UIColor*)getNavigationBarTitleColor
{
    return kNavigationBarTitleColor;
}

@end
