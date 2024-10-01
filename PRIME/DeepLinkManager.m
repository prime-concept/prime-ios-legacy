//
//  DeepLinkManager.m
//  PRIME
//
//  Created by Aram on 3/23/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import "DeepLinkManager.h"
#import "ChatViewController.h"
#import "AppDelegate.h"

@implementation DeepLinkManager

+ (void)handleDeepLinkForServices:(NSDictionary*)serviceInfo tabBarController:(UITabBarController*)tabBarController
{
    NSString* serviceID = [serviceInfo objectForKey:kServiceIDKey];
    if (!serviceID) {
        return;
    }

    BOOL alreadySelectedChat = tabBarController.selectedIndex == MainScreenTabs_Chat;
    if (tabBarController.selectedIndex == MainScreenTabs_Profile) {
        if (tabBarController.presentedViewController) {
            [tabBarController.presentedViewController dismissViewControllerAnimated:NO completion:nil];
        }
    }

    if (!alreadySelectedChat) {
        [tabBarController setSelectedIndex:MainScreenTabs_Chat];
    }
    if (tabBarController.tabBar.hidden) {
        tabBarController.tabBar.hidden = NO;
    }
    if (tabBarController.presentedViewController) {
        [tabBarController.presentedViewController dismissViewControllerAnimated:NO completion:nil];
    }

    ChatViewController* chatVC = [((UINavigationController*)tabBarController.selectedViewController).viewControllers firstObject];
    [chatVC.navigationController popToRootViewControllerAnimated:NO];
    NSAssert([chatVC isKindOfClass:[ChatViewController class]], @"ChatVC is not kind of class ChatViewController");

    [chatVC openServiceWithID:serviceID];
}

@end
