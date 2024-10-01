//
//  NotificationManager.m
//  PRIME
//
//  Created by Artak on 9/4/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "AppDelegate.h"
#import "ChatViewController.h"
#import "NotificationManager.h"
#import "PRUINavigationController.h"
#import "PRUITabBarController.h"
#import "ProfileViewController.h"
#import "RequestsDetailViewController.h"
#import "RequestsViewController.h"
#import "ReviewViewController.h"
#import "TopTenViewController.h"
#import "CalendarViewController.h"

NSString* const kKeyForLaunchURL = @"url";

// Calendar
NSString* const kParseCalendarTab = @"calendar";
NSString* const kParseCalendarToday = @"today";

// Requests
NSString* const kParseRequestTab = @"request";
NSString* const kParseRequestBooked = @"booked";
NSString* const kParseRequestToPay = @"to_pay";
NSString* const kParseRequestInProgress = @"in_progress";
NSString* const kParseRequestCompleted = @"completed";
NSString* const kParseTaskPage = @"task";
NSString* const kParseTaskInfoPage = @"taskinfo";

// Chat
NSString* const kParseChatTab = @"chat";
NSString* const kParseChatPage = @"chat";
NSString* const kTypeMessageClick = @"TypeMessageIsClicked";
NSString* const kMoreButtonClick = @"MoreButtonIsClicked";


// Services
NSString* const kOpenService = @"OpenServiceWithServiceID";
NSString* const kServiceNotExist = @"ServiceWithIDNotExist";

// CityGuide
NSString* const kParseCityguideTab = @"cityguide";
NSString* const kCityGuideURLKey = @"$custom_url";

// Profile
NSString* const kParseProfileTab = @"me";

// Reviews
NSString* const kParseReviewPage = @"review";

@implementation NotificationManager

#pragma mark - Notification Parser

+ (void)parse:(NSDictionary*)params andOpenInTabBarController:(UITabBarController*)tabBarController
{
    NSString* url = [params objectForKey:kKeyForLaunchURL];
    if (url == nil) {
        return;
    }
    
    if ([url rangeOfString:kURLSchemesPrefix].location != NSNotFound) {
        NSString* parametersString = [url substringFromIndex:[url rangeOfString:kURLSchemesPrefix].length];
        NSMutableArray<NSString*>* arrayWithTransitionParameters = [[NSMutableArray alloc] initWithArray:[parametersString componentsSeparatedByString:@"/"]];

        if ([arrayWithTransitionParameters count] > 0) {
            NSString* str = [[NSString alloc] initWithFormat:@"%@", [arrayWithTransitionParameters lastObject]];
            if ([str isEqualToString:@""] || [str isEqualToString:@" "]) {
                [arrayWithTransitionParameters removeLastObject];
            }
        }

        NSString* kFirstParam = ([arrayWithTransitionParameters count] > 0) ? [arrayWithTransitionParameters objectAtIndex:0] : @"";

        if ([kFirstParam isEqualToString:kParseRequestTab] || [kFirstParam isEqualToString:kParseTaskPage] || [kFirstParam isEqualToString:kParseTaskInfoPage]) {
            [NotificationManager handleNotificationForRequestsWithParameters:arrayWithTransitionParameters
                                                   andOpenInTabBarController:tabBarController];
            return;
        }
        if ([kFirstParam isEqualToString:kParseReviewPage]) {
            [NotificationManager handleNotificationForReviewsWithParameters:arrayWithTransitionParameters
                                                  andOpenInTabBarController:tabBarController];
            return;
        }
        if ([kFirstParam isEqualToString:kParseChatTab]) {
            [NotificationManager handleNotificationForChatWithParameters:arrayWithTransitionParameters
                                               andOpenInTabBarController:tabBarController];
            return;
        }
        if ([kFirstParam isEqualToString:kParseCityguideTab]) {
            NSString* customURL = [params objectForKey:kCityGuideURLKey];
            [NotificationManager handleNotificationForCityGuideWithParameters:parametersString
                                                                    customURL:customURL
                                                    andOpenInTabBarController:tabBarController];
            return;
        }
        if ([kFirstParam isEqualToString:kParseProfileTab]) {
            [NotificationManager handleNotificationForProfileWithParameters:arrayWithTransitionParameters
                                                  andOpenInTabBarController:tabBarController];
            return;
        }
        if ([kFirstParam isEqualToString:kParseCalendarTab] || [kFirstParam integerValue]) {
            [NotificationManager handleNotificationForCalendarWithParameters:arrayWithTransitionParameters
                                                   andOpenInTabBarController:tabBarController];
        }
    }
}

#pragma mark - Calendar

+ (void)handleNotificationForCalendarWithParameters:(NSArray<NSString*>*)arrayWithTransitionParameters
                          andOpenInTabBarController:(UITabBarController*)tabBarController
{
    NSString* kFirstParam = ([arrayWithTransitionParameters count] > 0) ? [arrayWithTransitionParameters objectAtIndex:0] : @"";
    NSString* kSecondParam = ([arrayWithTransitionParameters count] > 1) ? [arrayWithTransitionParameters objectAtIndex:1] : @"";
    NSString* kThirdParam = ([arrayWithTransitionParameters count] > 2) ? [arrayWithTransitionParameters objectAtIndex:2] : @"";

    BOOL alreadySelectedCalendar = tabBarController.selectedIndex == 0;
    if (tabBarController.selectedIndex == 4) {
        if (tabBarController.presentedViewController) {
            [tabBarController.presentedViewController dismissViewControllerAnimated:NO completion:nil];
        }
    }

    if (!alreadySelectedCalendar) {
        [tabBarController setSelectedIndex:0];
    }
    if (tabBarController.tabBar.hidden) {
        tabBarController.tabBar.hidden = NO;
    }
    if (tabBarController.presentedViewController) {
        [tabBarController.presentedViewController dismissViewControllerAnimated:NO completion:nil];
    }

    CalendarViewController* calendarVC = [((UINavigationController*)tabBarController.selectedViewController).viewControllers firstObject];
    [calendarVC.navigationController popToRootViewControllerAnimated:NO];

    if([kFirstParam integerValue]) {
        NSNumberFormatter* taskIdFormat = [[NSNumberFormatter alloc] init];
        taskIdFormat.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber *taskId = [taskIdFormat numberFromString:kFirstParam];
        [calendarVC  setCalendarSelectedIdToDate:taskId];
        return;
    }
    if ([kSecondParam isEqualToString:kParseCalendarToday]) {
        [calendarVC setCalendarSelectedDateToDate:[NSDate new]];
        return;
    }

    if (kSecondParam.length && [kSecondParam rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location == NSNotFound) {
        NSString* kLastParam = ([arrayWithTransitionParameters count] > 3) ? [arrayWithTransitionParameters objectAtIndex:3] : @"";

        NSInteger year = [kSecondParam integerValue];
        NSInteger month = [kThirdParam integerValue];
        NSInteger day = [kLastParam integerValue];

        if (year && month && day) {
            NSDateComponents* comps = [[NSDateComponents alloc] init];
            [comps setYear:year];
            [comps setMonth:month];
            [comps setDay:day];

            NSDate* date = [[NSCalendar currentCalendar] dateFromComponents:comps];
            [calendarVC setCalendarSelectedDateToDate:date];
        }
    }
}

#pragma mark - Requests

+ (void)handleNotificationForRequestsWithParameters:(NSArray<NSString*>*)arrayWithTransitionParameters
                          andOpenInTabBarController:(UITabBarController*)tabBarController
{
    NSString* kFirstParam = ([arrayWithTransitionParameters count] > 0) ? [arrayWithTransitionParameters objectAtIndex:0] : @"";
    NSString* kSecondParam = ([arrayWithTransitionParameters count] > 1) ? [arrayWithTransitionParameters objectAtIndex:1] : @"";
    NSString* kThirdParam = ([arrayWithTransitionParameters count] > 2) ? [arrayWithTransitionParameters objectAtIndex:2] : @"";

    BOOL alreadySelectedRequests = tabBarController.selectedIndex == 1;
    if (tabBarController.selectedIndex == 4) {
        if (tabBarController.presentedViewController) {
            [tabBarController.presentedViewController dismissViewControllerAnimated:NO completion:nil];
        }
    }
    if (!alreadySelectedRequests) {
        [tabBarController setSelectedIndex:1];
    }
    if (tabBarController.tabBar.hidden) {
        tabBarController.tabBar.hidden = NO;
    }
    if (tabBarController.presentedViewController) {
        [tabBarController.presentedViewController dismissViewControllerAnimated:NO completion:nil];
    }

    PRUINavigationController* navigationVC = (PRUINavigationController*)[tabBarController viewControllers][1];
    RequestsViewController* rootVC = [navigationVC.viewControllers firstObject];
    [navigationVC popToRootViewControllerAnimated:NO];

    if (kSecondParam.length && [kSecondParam rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location == NSNotFound) {
        BOOL withAnimation = kThirdParam == nil || kThirdParam.length == 0;
        RequestsDetailViewController* requestDetailVC = nil;

        if ([kFirstParam isEqualToString:kParseTaskInfoPage]) {
            requestDetailVC = [rootVC openRequestDetails:@([kSecondParam integerValue]) andRequestDate:nil withAnimation:withAnimation];
        } else {
            NSNumber* taskId = [PRDatabase getTaskIdByTaskLinkId:kSecondParam];
            if (taskId != nil && [taskId integerValue] > 0) {
                requestDetailVC = [rootVC openRequestDetails:taskId andRequestDate:nil withAnimation:withAnimation];
            }
        }

        if ([kThirdParam isEqualToString:kParseChatPage]) {
            [requestDetailVC openChat];
        }

        return;
    }

    if ([kSecondParam isEqualToString:kParseRequestToPay] || [kSecondParam isEqualToString:kParseRequestInProgress]) {
        [rootVC updateRequestsWithSegment:PRRequestSegment_InProgress];
        return;
    } else if ([kSecondParam isEqualToString:kParseRequestCompleted]) {
        [rootVC updateRequestsWithSegment:PRRequestSegment_Completed];
    }
}

#pragma mark - Chat

+ (void)handleNotificationForChatWithParameters:(NSArray<NSString*>*)arrayWithTransitionParameters
                      andOpenInTabBarController:(UITabBarController*)tabBarController
{
    NSString* kSecondParam = ([arrayWithTransitionParameters count] > 1) ? [arrayWithTransitionParameters objectAtIndex:1] : @"";
    BOOL alreadySelectedChat = tabBarController.selectedIndex == 2;
    if (tabBarController.selectedIndex == 4) {
        if (tabBarController.presentedViewController) {
            [tabBarController.presentedViewController dismissViewControllerAnimated:NO completion:nil];
        }
    }
    if (!alreadySelectedChat) {
        [tabBarController setSelectedIndex:2];
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
    if (kSecondParam.length) {
        if (chatVC.navigationController.viewControllers.count > 1) {
            [chatVC.navigationController popToRootViewControllerAnimated:NO];
        }
        if (!alreadySelectedChat) {
            if ([kSecondParam isEqualToString:kTypeMessageClick]) {
                [chatVC changeTypingTextViewTextWith:@""];
            } else {
                chatVC.initialString = kSecondParam;
                [self logOpenChatWithText];
            }

            return;
        }

        NSString* serviceID = [self canOpenServiceFromWidget:kSecondParam];
        if ([serviceID isEqualToString:kServiceNotExist]) {
            if ([kSecondParam isEqualToString:kTypeMessageClick]) {
                [chatVC changeTypingTextViewTextWith:@""];
            } else if ([kSecondParam isEqualToString:kMoreButtonClick]) {
                [chatVC moreButtonClickFromWidget];
            } else {
                [chatVC changeTypingTextViewTextWith:kSecondParam];
                [self logOpenChatWithText];
            }
        } else {
            [chatVC openServiceWithID:serviceID];
        }
    }
}

+ (void)logOpenChatWithText
{
    NSString *customerId = [[NSUserDefaults standardUserDefaults] objectForKey:kCustomerId];
    [PRGoogleAnalyticsManager sendEventWithName:kChatDeeplinkTextOpened
                                     parameters:@{ @"crm_id" : customerId }];
}

#pragma mark - CityGuide

+ (void)handleNotificationForCityGuideWithParameters:(NSString*)parametersString
                                           customURL:(NSString*)customURL
                           andOpenInTabBarController:(UITabBarController*)tabBarController
{
    BOOL alreadySelectedCityGuide = tabBarController.selectedIndex == 3;
    if (tabBarController.selectedIndex == 4) {
        if (tabBarController.presentedViewController) {
            [tabBarController.presentedViewController dismissViewControllerAnimated:NO completion:nil];
        }
    }

    if (!alreadySelectedCityGuide) {
        [tabBarController setSelectedIndex:3];
    }
    if (tabBarController.tabBar.hidden) {
        tabBarController.tabBar.hidden = NO;
    }
    if (tabBarController.presentedViewController) {
        [tabBarController.presentedViewController dismissViewControllerAnimated:NO completion:nil];
    }
    TopTenViewController* topTenVC = [((UINavigationController*)tabBarController.selectedViewController).viewControllers firstObject];
    NSString* cityGuideUrl = [parametersString stringByReplacingOccurrencesOfString:@"cityguide/" withString:kCityGuideBaseUrl];
    [topTenVC setCityGuideWithDeepLink: customURL == nil ? cityGuideUrl : customURL];
    [topTenVC initLocationManager];
}

#pragma mark - Profile

+ (void)handleNotificationForProfileWithParameters:(NSArray<NSString*>*)arrayWithTransitionParameters
                         andOpenInTabBarController:(UITabBarController*)tabBarController
{
    BOOL alreadySelectedProfile = tabBarController.selectedIndex == 4;
    if (!alreadySelectedProfile) {
        [tabBarController setSelectedIndex:4];
    }
    if (tabBarController.tabBar.hidden) {
        tabBarController.tabBar.hidden = NO;
    }
    if (tabBarController.presentedViewController) {
        [tabBarController.presentedViewController dismissViewControllerAnimated:NO completion:nil];
    }
    ProfileViewController* profileVC = [((UINavigationController*)tabBarController.selectedViewController).viewControllers firstObject];
    [profileVC.navigationController popToRootViewControllerAnimated:NO];
}

#pragma mark - Reviews

+ (void)handleNotificationForReviewsWithParameters:(NSArray<NSString*>*)arrayWithTransitionParameters
                         andOpenInTabBarController:(UITabBarController*)tabBarController
{
    NSString* kSecondParam = ([arrayWithTransitionParameters count] > 1) ? [arrayWithTransitionParameters objectAtIndex:1] : @"";
    ReviewViewController* reviewVC = [tabBarController.storyboard instantiateViewControllerWithIdentifier:@"ReviewViewController"];
    reviewVC.taskId = @([kSecondParam integerValue]);
    reviewVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [tabBarController presentViewController:reviewVC
                                   animated:YES
                                 completion:^{

                                 }];
}

#pragma mark - Process Notification

+ (void)proccessNotificationWithTabBarController:(UITabBarController*)tabBarController
{
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSDictionary* remoteNotif = appDelegate.launchOptions;
    if (remoteNotif) {
        [NotificationManager parse:remoteNotif andOpenInTabBarController:tabBarController];
    }
    appDelegate.launchOptions = nil;
}

#pragma mark - Can Open Service With ID

+ (NSString *)canOpenServiceFromWidget:(NSString*)widgetMessage {
    if ([widgetMessage hasPrefix:kOpenService]) {
        NSRange range = [widgetMessage rangeOfString:kOpenService];
        NSString *serviceIdString = [widgetMessage substringFromIndex:range.length];
        NSNumber *serviceID = @(serviceIdString.integerValue);
        NSArray<PRServicesModel*>* services = [PRDatabase getServices];

        for (PRServicesModel *model in services) {
            if ([model.serviceId isEqualToNumber:serviceID]) {
                return serviceIdString;
            }
        }
    }
    return kServiceNotExist;
}
@end
