//
//  AppDelegate.h
//  PRIME
//
//  Created by Admin on 11/01/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIPageViewControllerDataSource>

@property (strong, nonatomic) NSDictionary* launchOptions;
@property (strong, nonatomic) UIWindow* window;

- (void)setLoginViewController;
- (void)setInitalViewController;

@end
