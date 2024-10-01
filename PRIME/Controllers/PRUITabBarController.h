//
//  PRUITabBarController.h
//  PRIME
//
//  Created by Artak Tsatinyan on 2/20/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MainScreenTabs) {
    MainScreenTabs_Calendar = 0,
    MainScreenTabs_Requests,
    MainScreenTabs_Chat,
    MainScreenTabs_Top10,
    MainScreenTabs_Profile
};

@protocol TabBarItemChanged <NSObject>

@required
/** Called when tab bar item is changed. */
- (void)updateViewController;

@optional
- (void)handleLongPressOnTabBar:(UILongPressGestureRecognizer*)gesture;

@end

@class RequestsDetailViewController;
@interface PRUITabBarController : UITabBarController <UITabBarControllerDelegate>

/** Indicates badges in the application icon, in the requests and in the chat rooms. */
- (void)showBadge;

/** Instantiates PRUITabBarController from storyboard. */
+ (PRUITabBarController*)instantiateFromStoryboard;

/** Open task page for TaskId then called openTaskWithTaskId to open according chat page */
- (void)openChatWithTaskId:(NSNumber*)taskId;

/** Open task page for TaskId*/
- (RequestsDetailViewController*)openTaskWithTaskId:(NSNumber*)taskId;

/** Gets the help screen feature JSON data after registration.*/
- (void)getHelpScreenFeatureAndPresentOnTabBar:(UIViewController*)rootViewController;


@end
