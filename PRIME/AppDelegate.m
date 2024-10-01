//
//  AppDelegate.m
//  PRIME
//
//  Created by Artak on 11/01/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "AppDelegate.h"
#import "ConfirmPasswordViewController.h"
#import "LoginViewController.h"
#import "NotificationManager.h"
#import "PRCardData.h"
#import "PROverviewSliderViewController.h"
#import "PRUINavigationController.h"
#import "PRUITabBarController.h"
#import "RegistrationStepOneViewController.h"
#import "WelcomeViewController.h"
#import "XNTKeychainStore.h"
#import <FirebaseCrashlytics/FirebaseCrashlytics.h>
#import "CreatePasswordViewController.h"
#import "PRUrlHandler.h"
#import "PRRegistrationWithCardViewController.h"
#import "PRAppVersionManager.h"
#import "Branch/Branch.h"
#import "DeepLinkManager.h"
#import "PRRequestManager.h"
#import "PRMessageProcessingManager.h"
#import "ChatUtility.h"
#import "PRUserDefaultsManager.h"
#import <Intents/Intents.h>
#import "UIAlertController+PRNewWindow.h"
#import "PRRRClubRegistrationWithCardViewController.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/AdSupport.h>
#import "AppWindow.h"
#import "NSBundle+Convenience.h"
#import "Config.h"
#import "DebugMenuViewController.h"


@import Firebase;

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@import UserNotifications;
#endif

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@interface AppDelegate () <UNUserNotificationCenterDelegate, FIRMessagingDelegate>
#else
@interface AppDelegate ()
#endif
@property (strong, nonatomic) NSDate* timeout;
@property (assign, nonatomic) BOOL shouldPresentLoginViewController;
@property (strong, nonatomic) PRAppVersionManager* versionManager;
@property (assign, nonatomic) BOOL isDeepLinkPressed;
@end

// Copied from Apple's header in case it is missing in some cases (e.g. pre-Xcode 8 builds).
#ifndef NSFoundationVersionNumber_iOS_9_x_Max
#define NSFoundationVersionNumber_iOS_9_x_Max 1299
#endif

static NSString* const kChatUpdate = @"chatUpdate";
static NSString* const kRequestsUpdate = @"requestsUpdate";
static NSString* const kCalendarUpdate = @"calendarUpdate";
static NSString* const kProfileUpdate = @"profileUpdate";
static NSString* const kContentUpdate = @"contentUpdate";
static NSString* const userNotificationActionResponseTypedTextKey = @"UIUserNotificationActionResponseTypedTextKey";

@implementation AppDelegate

UIBackgroundTaskIdentifier backgroundTask;

#pragma mark - Application Launching

- (NSString*)flushGCov:(NSString*)ignored
{
#if defined(COVERAGE_ENABLED)
    extern void __gcov_flush(void);
    __gcov_flush();

    return @"GCov Flushed";
#endif
    return @"GCov not Flushed";
}

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    [PRRequestManager initReachability];

    _launchOptions = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];

#if !defined(Calabash) && defined(Prime)
    [INPreferences requestSiriAuthorization:^(INSiriAuthorizationStatus status) {}];
#endif

    [self customizeTabBarItems];

    [self setInitalViewController];
    [self checkAppVersionAndShowAlertIfNeeded];
    [self initBranchSession:launchOptions];

#ifdef NOTIFICATION_FUNC
    [self setupRemoteNotifications];
#endif

    NSString* customerId = [[NSUserDefaults standardUserDefaults] objectForKey:kCustomerId];
    NSUserDefaults* defaults = [[NSUserDefaults alloc] initWithSuiteName:kSiriUserDefaultsSuiteName];
    NSUserDefaults* extensionsDefaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    [defaults setValue:customerId forKey:kCustomerId];
    [extensionsDefaults setValue:customerId forKey:kCustomerId];
    if (customerId != nil && ![customerId isEqualToString:@""]) {
        [[FIRCrashlytics crashlytics] setUserID:customerId];
    }

    return YES;
}

#pragma mark - Helpers

- (void)requestIDFA
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (@available(iOS 14.0, *)) {
            [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
                // Tracking authorization completed. Start loading ads here.
                // [self loadAd];
            }];
        }
    });
}

- (void)checkAppVersionAndShowAlertIfNeeded
{
    _versionManager = [PRAppVersionManager new];
    [_versionManager checkAppVersionAndShowAlertIfNeeded];
}

- (UITabBarController*)getTabBarController
{
    UIViewController* viewController = [[self.window.rootViewController childViewControllers] lastObject];
    UITabBarController* tabBarController = nil;

    if (![viewController isKindOfClass:[LoginViewController class]]
        && ![viewController isKindOfClass:[ConfirmPasswordViewController class]]) {

        UIViewController* confirmPasswordVC = [((UINavigationController*)[viewController presentedViewController]).viewControllers lastObject];
        if (![confirmPasswordVC isKindOfClass:[ConfirmPasswordViewController class]]) {
            return nil;
        }
        tabBarController = (UITabBarController*)[confirmPasswordVC presentedViewController];
    } else {
        tabBarController = (UITabBarController*)[viewController presentedViewController];
    }

    if (!tabBarController || ![tabBarController isKindOfClass:[UITabBarController class]] || _shouldPresentLoginViewController) {
        _shouldPresentLoginViewController = NO;
        return nil;
    }

    return tabBarController;
}

#pragma mark - Setup Remote Notifications

- (void)setupRemoteNotifications
{
#ifdef USE_XNTEST_SERVER
    __weak id weakSelf = self;
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC));
    dispatch_after(delay, dispatch_get_main_queue(), ^{
        [weakSelf registerToRemoteNotification];
    });
#else
    [self registerToRemoteNotification];
#endif
}

- (void)registerToRemoteNotification
{
    // Use Firebase library to configure APIs.
    [FIRApp configure];

    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
        UIUserNotificationType allNotificationTypes = (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings* settings = [UIUserNotificationSettings settingsForTypes:allNotificationTypes
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    } else {
// iOS 10 or later.
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
        UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];

        // For iOS 10 display notification (sent via APNS)
        center.delegate = self;

        // For iOS 10 data message (sent via FCM)
        [FIRMessaging messaging].delegate = self;

        UNNotificationAction* openAction = [UNNotificationAction
            actionWithIdentifier:@"OPEN_ACTION"
                           title:@"Open"
                         options:UNNotificationActionOptionForeground];

        UNTextInputNotificationAction* replyAction = [UNTextInputNotificationAction
            actionWithIdentifier:@"REPLY_ACTION"
                           title:@"Reply"
                         options:UNNotificationActionOptionAuthenticationRequired];

        UNNotificationCategory* generalCategory = [UNNotificationCategory
            categoryWithIdentifier:@"REPLY_MESSAGE_CATEGORY"
                           actions:@[ replyAction, openAction ]
                 intentIdentifiers:@[]
                           options:UNNotificationCategoryOptionNone];

        UNAuthorizationOptions options = (UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert);
        [center setNotificationCategories:[NSSet setWithObjects:generalCategory, nil]];
        [center requestAuthorizationWithOptions:options
                              completionHandler:^(BOOL granted, NSError* _Nullable error){
                                  if (!granted) {
                                      [PRGoogleAnalyticsManager sendEventWithName:kNotificationPermissionDoNotAllowButtonClicked parameters:nil];
                                      return;
                                  }
                                  [PRGoogleAnalyticsManager sendEventWithName:kNotificationPermissionAllowButtonClicked parameters:nil];
                              }];

#endif
    }

    [[UIApplication sharedApplication] registerForRemoteNotifications];

    // Add observer for InstanceID token refresh callback.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tokenRefreshNotification:)
                                                 name:kFIRInstanceIDTokenRefreshNotification
                                               object:nil];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSLog(@"APNs token retrieved: %@", deviceToken);
    [[FIRMessaging messaging] setAPNSToken:deviceToken
                                      type:FIRMessagingAPNSTokenTypeUnknown];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Unable to register for remote notifications: %@", [error localizedDescription]);
}

#pragma mark - Notification Handler

- (void)tokenRefreshNotification:(NSNotification*)notification
{
    // Note that this callback will be fired everytime a new token is generated, including the first
    // time. So if you need to retrieve the token as soon as it is available this is where that
    // should be done.
    
    [[FIRInstanceID instanceID] instanceIDWithHandler:^(FIRInstanceIDResult * _Nullable result, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error fetching remote instance ID: %@", error);
        } else {
            NSLog(@"Remote instance ID token: %@", result.token);
            [[NSNotificationCenter defaultCenter] postNotificationName:kFCMRefreshedToken
                                                                object:result.token];
        }
    }];
}

- (void)connectToFcm
{
    [[FIRInstanceID instanceID] instanceIDWithHandler:^(FIRInstanceIDResult * _Nullable result, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error fetching remote instance ID: %@", error);
        } else {
            NSLog(@"Remote instance ID token: %@", result.token);
        }
    }];
}

#pragma mark - Remote Notifications

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

// Receive data message on iOS 10 devices while app is in the foreground.
- (void)applicationReceivedRemoteMessage:(FIRMessagingRemoteMessage*)remoteMessage
{
    NSLog(@"%@", remoteMessage.appData);
    _launchOptions = remoteMessage.appData;
    [self processRemoteNotification];
}

// Receive displayed notifications for iOS 10 devices.
// Handle incoming notification messages while app is in the foreground.
- (void)userNotificationCenter:(UNUserNotificationCenter*)center
       willPresentNotification:(UNNotification*)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    _launchOptions = notification.request.content.userInfo;
    [self processRemoteNotification];
    completionHandler(UNNotificationPresentationOptionNone);
}

#endif

- (void)application:(UIApplication*)application
    didReceiveRemoteNotification:(NSDictionary*)userInfo
          fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    [PRGoogleAnalyticsManager sendEventWithName:kRemoteNotificationOpenedButtonClicked parameters:nil];
    NSString* userName = [[NSUserDefaults standardUserDefaults] valueForKey:kUserNameKey];
    if (userName == nil) {
        return;
    }

    if (![RKManagedObjectStore defaultStore]) {
        [CRMRestClient setupCoreData:userName];
    }
    
    // MARK: - Not ready. Need more fixes
    if ([userInfo valueForKey:@"$custom_url"]) {
        _launchOptions = userInfo;
        [self processRemoteNotification];
        return;
    }

    BOOL chatUpdate = [[userInfo objectForKey:kChatUpdate] boolValue];
    BOOL requestsUpdate = [[userInfo objectForKey:kRequestsUpdate] boolValue];
    BOOL calendarUpdate = [[userInfo objectForKey:kCalendarUpdate] boolValue];
    BOOL profileUpdate = [[userInfo objectForKey:kProfileUpdate] boolValue];
    BOOL contentUpdate = [[userInfo objectForKey:kContentUpdate] boolValue];

    NSString* accessToken = [XNTKeychainStore accessToken];
    [[PRUserDefaultsManager sharedInstance] saveToken:accessToken];

    if (requestsUpdate || calendarUpdate) {
        [self getTasksInBackgroundAndUpdateRequests:requestsUpdate andCalendar:calendarUpdate];
    }

    if (chatUpdate) {
        [self getMessagesInBackground];
    }

    if (profileUpdate) {
        [self getProfileInBackground];
    }

    if (contentUpdate) {
        [self getCityGuideInBackground];
    }
}

- (void)application:(UIApplication*)application handleActionWithIdentifier:(nullable NSString*)identifier forRemoteNotification:(NSDictionary*)userInfo withResponseInfo:(NSDictionary*)responseInfo completionHandler:(void (^)())completionHandler
{
    NSString* typedText = responseInfo[userNotificationActionResponseTypedTextKey];
    NSString* trimmedMessageText = [typedText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if (![[NSUserDefaults standardUserDefaults] boolForKey:kCoreDataDidSetup]) {
        NSString* userName = [[NSUserDefaults standardUserDefaults] valueForKey:kUserNameKey];
        [CRMRestClient setupCoreData:userName];
    }
    __block UIApplication* app = UIApplication.sharedApplication;
    backgroundTask = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (backgroundTask != UIBackgroundTaskInvalid) {
                [app endBackgroundTask:backgroundTask];
                backgroundTask = UIBackgroundTaskInvalid;
            }
        });

    }];

    [PRMessageProcessingManager sendMessage:trimmedMessageText toChannelWithID:[ChatUtility mainChatIdWithPrefix] withBackgroundTask:backgroundTask];
}

- (void)processRemoteNotification
{
    [PRUrlHandler loginIfNeededWithRequestURL:(NSString*)[_launchOptions objectForKey:@"url"]
        registerUser:^{
            [self setCreatePasswordViewController];
        }
        continueSteps:^{
            UITabBarController* tabBarController = [self getTabBarController];

            if (tabBarController) {
                [NotificationManager proccessNotificationWithTabBarController:tabBarController];
            }
        }];
}

#pragma mark - FIRMessagingDelegate

/**
 *  This method is protocol required method which needs to be implemented.
 *  As there is already such functionality (with notification) which provides
 *  the refreshed token, that’s why the implementation of this method is left empty.
 */
- (void)messaging:(FIRMessaging*)messaging didRefreshRegistrationToken:(NSString*)fcmToken {}

#pragma mark - URL Schemes

- (BOOL)application:(UIApplication*)application openURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication annotation:(id)annotation
{
    if ([PRUrlHandler isLoginUrl:url.absoluteString] && [[NSUserDefaults standardUserDefaults] boolForKey:kUserRegistered]) {
        [self createNavVCWithWelcomeVC];
    }
    [self handleOpenURL:url withParams:nil];
    return YES;
}

- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)url
{
    [self handleOpenURL:url withParams:nil];
    return YES;
}

- (void)handleOpenURL:(NSURL*)url withParams:(NSDictionary*)params
{
	if ([url.host isEqualToString:@"debug-6347325-ncpwb"]) {
		Config.isDebugEnabled = YES;
		return;
	}

    NSMutableDictionary* userInfoDictionary = [[NSMutableDictionary alloc] init];
    NSString* urlString = url.absoluteString;
    NSString* prefixWithChat = [kURLSchemesPrefix stringByAppendingString: @"chat"];
    NSString* prefixWithCityGuide = [kURLSchemesPrefix stringByAppendingString:@"cityguide"];
    
    if ([urlString containsString:prefixWithChat]) {
        NSString* urlStringWithoutPath = [urlString substringWithRange:[urlString rangeOfString:prefixWithChat]];
        urlString = [urlStringWithoutPath stringByAppendingString:url.path];
    }
    
    if ([urlString containsString:prefixWithCityGuide]) {
        NSString* urlStringWithoutPath = [urlString substringWithRange:[urlString rangeOfString:prefixWithCityGuide]];
        urlString = [urlStringWithoutPath stringByAppendingString:url.path];
        
        NSString* customURL = [params objectForKey:kDeepLinkCustomURL];
        if (customURL) {
            [userInfoDictionary setValue:customURL forKey:kDeepLinkCustomURL];
        } else if ([params objectForKey:kDeepLinkCanonicalURL]) {
            [userInfoDictionary setValue:[params objectForKey:kDeepLinkCanonicalURL] forKey:kDeepLinkCustomURL];
        }
    }
    
    [userInfoDictionary setValue:urlString forKey:kDeepLinkURLKey];
    _launchOptions = userInfoDictionary;
    [self processRemoteNotification];
}

#pragma mark - Customize Tab Bar

- (void)customizeTabBarItems
{
    [[UILabel appearanceWhenContainedIn:[UITableView class], nil] setFont:[UIFont systemFontOfSize:16]];
    [[UITabBar appearance] setTintColor:kTabBarSelectedIconColor];
	[[UITabBar appearance] setBackgroundColor:kTabBarBackgroundColor];
    [[UITabBar appearance] setBarTintColor:kTabBarBackgroundColor];

	[[UITabBar appearance] setUnselectedItemTintColor:kTabBarUnselectedTextColor];

    // Set color of selected text.
    [[UITabBarItem appearance] setTitleTextAttributes:
                                   @{ NSForegroundColorAttributeName : kTabBarSelectedTextColor }
                                             forState:UIControlStateSelected];

    // Set color of unselected text.
    [[UITabBarItem appearance] setTitleTextAttributes:
                                   @{ NSForegroundColorAttributeName : kTabBarUnselectedTextColor }
                                             forState:UIControlStateNormal];
}

#pragma mark - Branch.io

- (BOOL)application:(UIApplication*)application continueUserActivity:(NSUserActivity*)userActivity restorationHandler:(void (^)(NSArray* restorableObjects))restorationHandler
{
    _isDeepLinkPressed = YES;
    BOOL handledByBranch = [[Branch getInstance] continueUserActivity:userActivity];

    return handledByBranch;
}

- (void)initBranchSession:(NSDictionary*)launchOptions
{
    __weak AppDelegate* weakSelf = self;
    [[Branch getInstance] initSessionWithLaunchOptions:launchOptions
                            andRegisterDeepLinkHandler:^(NSDictionary* params, NSError* error) {
                                AppDelegate* strongSelf = weakSelf;
                                if (!strongSelf) {
                                    return;
                                }
                                [strongSelf handleDeepLink:params];
                            }];
}

// Handler for deep link.
- (void)handleDeepLink:(NSDictionary*)params
{
    if (_isDeepLinkPressed) {
        NSString* serviceID = [params objectForKey:kServiceIDKey];
        if (serviceID && ![serviceID isEqualToString:@""]) {

            UITabBarController* tabBarController = [self getTabBarController];
            if (tabBarController) {
                [DeepLinkManager handleDeepLinkForServices:params tabBarController:tabBarController];
            } else {
                _launchOptions = @{ kDeepLinkKey : params };
            }
        } else {
            NSString* deepLinkPath = [params objectForKey:kDeepLinkPath];
            if (deepLinkPath && ![deepLinkPath isEqualToString:@""]) {
                NSString* deepLinkUrl = [[NSString stringWithFormat:@"%@%@", kURLSchemesPrefix, deepLinkPath] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSURL* url = [NSURL URLWithString:deepLinkUrl];
                [self handleOpenURL:url withParams:params];
            }
        }
    }

    _isDeepLinkPressed = NO;
}

#pragma mark - Setup View Controllers

- (void)setInitalViewController
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    BOOL isRegistered = [defaults boolForKey:kUserRegistered];

    if (!isRegistered) {
#ifdef Prime
        [self setOverviewViewController];
#else
        [self setPageViewControllerWithButtons:YES];
#endif
        return;
    }
    [self setLoginViewController];
}

- (void)setOverviewViewController
{
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle:nil];

    PROverviewSliderViewController* overviewSliderViewController = (PROverviewSliderViewController*)[mainStoryboard
        instantiateViewControllerWithIdentifier:@"PROverviewSliderViewController"];

    [self setRootViewControllerForWindow:overviewSliderViewController];
}

- (void)setPageViewControllerWithButtons:(BOOL)showButtons
{
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle:nil];

    UIPageViewController* pageViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    pageViewController.dataSource = self;

    WelcomeViewController* welcomeViewController = (WelcomeViewController*)[mainStoryboard
        instantiateViewControllerWithIdentifier:@"WelcomeViewController"];

    NSArray<__kindof UIViewController*>* viewControllers = @[ welcomeViewController ];
    [pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

    if (!showButtons) {
        [welcomeViewController hideButtons];
    }

    [self setRootViewControllerForWindow:pageViewController];
}

- (UINavigationController*)createNavVCWithLoginVC
{
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle:nil];

    UIViewController* viewController = (LoginViewController*)[mainStoryboard
        instantiateViewControllerWithIdentifier:@"LoginViewController"];

    UINavigationController* navigationController = [[PRUINavigationController alloc] initWithRootViewController:viewController];
    return navigationController;
}

- (void)createNavVCWithWelcomeVC
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setLoginViewController)
                                                 name:kOpenLoginViewController
                                               object:nil];

    [XNTKeychainStore setDefaultIdentifier:nil];
    [XNTKeychainStore setDefaultKeyPrefix:nil];
    [self setPageViewControllerWithButtons:NO];
}

- (void)setLoginViewController
{
    UINavigationController* navigationController = [self createNavVCWithLoginVC];
    [self setRootViewControllerForWindow:navigationController];
}

- (void)setCreatePasswordViewController
{
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle:nil];

    UIViewController* viewController = (CreatePasswordViewController*)[mainStoryboard
        instantiateViewControllerWithIdentifier:@"CreatePasswordViewController"];

    UINavigationController* navigationController = [[PRUINavigationController alloc] initWithRootViewController:viewController];
    [self setRootViewControllerForWindow:navigationController];
}

- (void)presentLoginViewController
{
    UINavigationController* navigationController = [self createNavVCWithLoginVC];
    ((LoginViewController*)navigationController.viewControllers.lastObject).isFromBackground = YES;
    UIViewController* tabbar = self.window.rootViewController.childViewControllers.lastObject.presentedViewController;
    if (![tabbar isKindOfClass:[PRUITabBarController class]]) {
        tabbar = tabbar.presentedViewController;
    }

    if (!tabbar) {
        return;
    }

    [tabbar.presentedViewController dismissViewControllerAnimated:NO completion:nil];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [tabbar presentViewController:navigationController animated:YES completion:nil];
}

- (void)setRootViewControllerForWindow:(__kindof UIViewController*)rootViewController
{
    _window = [[AppWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [_window setRootViewController:rootViewController];
    [_window setBackgroundColor:[UIColor whiteColor]];
    [_window makeKeyAndVisible];
}

- (UIViewController*)pageViewController:(UIPageViewController*)pageViewController viewControllerBeforeViewController:(UIViewController*)viewController
{
    return nil;
}

- (UIViewController*)pageViewController:(UIPageViewController*)pageViewController viewControllerAfterViewController:(UIViewController*)viewController
{
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        return nil;
    }

    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* rootViewController;

#if defined(Otkritie) || defined(PrivateBankingPRIMEClub) || defined(PrimeClubConcierge)
    PRRegistrationWithCardViewController* registrationWithCardVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"PRRegistrationWithCardViewController"];
    registrationWithCardVC.parentController = pageViewController;
    rootViewController = registrationWithCardVC;
#elif defined(PrimeRRClub)
    PRRRClubRegistrationWithCardViewController* registrationWithCardVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"PRRRClubRegistrationWithCardViewController"];
    registrationWithCardVC.parentController = pageViewController;
    rootViewController = registrationWithCardVC;
#else
    RegistrationStepOneViewController* registrationStepOneVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"RegistrationStepOneViewController"];
    registrationStepOneVC.parentController = pageViewController;
    rootViewController = registrationStepOneVC;
#endif

    UINavigationController* navigationController = [[PRUINavigationController alloc] initWithRootViewController:rootViewController];

    return navigationController;
}

#pragma mark - Setup Timeout

- (BOOL)isTimeoutExpired
{
    return [_timeout compare:[NSDate date]] == NSOrderedAscending;
}

- (void)refreshTimeout
{
    _timeout = [[NSDate date] mt_dateSecondsAfter:60 * 5];
}

#pragma mark - Application State

- (void)applicationDidEnterBackground:(UIApplication*)application
{
    [self refreshTimeout];
}

- (void)applicationWillEnterForeground:(UIApplication*)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

    _shouldPresentLoginViewController = NO;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    BOOL isRegistered = [defaults boolForKey:kUserRegistered];

    if ([self isTimeoutExpired] && isRegistered) {
        NSLog(@"Session is expired !!!");
        [XNTKeychainStore setDefaultIdentifier:nil];
        [XNTKeychainStore setDefaultKeyPrefix:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kAppWillEnterForegroundAfterTimeout object:nil];
        [self presentLoginViewController];
        _shouldPresentLoginViewController = YES;
    }
}

- (void)applicationDidBecomeActive:(UIApplication*)application
{
    [self requestIDFA];
    [self connectToFcm];
    application.applicationSupportsShakeToEdit = YES;
}

- (void)applicationWillTerminate:(UIApplication*)application
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kCoreDataDidSetup];
}

- (void)getMessagesInBackground
{
    if (![NSManagedObjectContext MR_rootSavingContext]) {
        return;
    }

    NSString* channelId = [ChatUtility mainChatIdWithPrefix];

    if(!channelId)
    {
        return;
    }

    NSNumber* timeStamp = @((long)[[NSDate new] timeIntervalSince1970]);

    __block UIBackgroundTaskIdentifier backgroundTask = [self startBackgroundTask];

    [PRMessageProcessingManager getMessagesForChannelId:channelId
                                                   guid:nil
                                                  limit:@kMessagesFetchLimit
                                                 toDate:timeStamp
                                               fromDate:nil
                                                success:^(NSArray<PRMessageModel*>* messages) {
                                                    [[PRUserDefaultsManager sharedInstance] updateWidgetMessages];

                                                    if (backgroundTask != UIBackgroundTaskInvalid) {
                                                        [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
                                                        backgroundTask = UIBackgroundTaskInvalid;
                                                    }
                                                }
                                                failure:^{
                                                    if (backgroundTask != UIBackgroundTaskInvalid) {
                                                        [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
                                                        backgroundTask = UIBackgroundTaskInvalid;
                                                    }
                                                }];
}

- (void)getTasksInBackgroundAndUpdateRequests:(BOOL)isRequestUpdate andCalendar:(BOOL)isCalendarUpdate
{
    __block UIBackgroundTaskIdentifier backgroundTask = [self startBackgroundTask];

    [PRRequestManager getTasksWithView:nil
                                  mode:PRRequestMode_ShowNothing
                               success:^{
                                   if (isRequestUpdate) {
                                       [[PRUserDefaultsManager sharedInstance] setWidgetRequests];
                                   }
                                   if (isCalendarUpdate) {
                                       [[PRUserDefaultsManager sharedInstance] setWidgetEvents];
                                   }

                                   if (backgroundTask != UIBackgroundTaskInvalid) {
                                       [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
                                       backgroundTask = UIBackgroundTaskInvalid;
                                   }

                               }
                               failure:^{
                                   if (backgroundTask != UIBackgroundTaskInvalid) {
                                       [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
                                       backgroundTask = UIBackgroundTaskInvalid;
                                   }
                               }];
}

- (void)getProfileInBackground
{
    __block UIBackgroundTaskIdentifier backgroundTask = [self startBackgroundTask];

    [PRRequestManager getProfileWithView:nil
                                    mode:PRRequestMode_ShowNothing
                                 success:^(PRUserProfileModel* userProfile) {
                                     if (backgroundTask != UIBackgroundTaskInvalid) {
                                         [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
                                         backgroundTask = UIBackgroundTaskInvalid;
                                     }

                                 }
                                 failure:^{
                                     if (backgroundTask != UIBackgroundTaskInvalid) {
                                         [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
                                         backgroundTask = UIBackgroundTaskInvalid;
                                     }
                                 }];
}

- (void)getCityGuideInBackground
{
    __block UIBackgroundTaskIdentifier backgroundTask = [self startBackgroundTask];

    [[PRUserDefaultsManager sharedInstance] getCityGuideDataWithLocation];

    if (backgroundTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
        backgroundTask = UIBackgroundTaskInvalid;
    }
}

- (UIBackgroundTaskIdentifier)startBackgroundTask
{
    __block UIBackgroundTaskIdentifier backgroundTask;
    __block UIApplication* app = UIApplication.sharedApplication;
    backgroundTask = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (backgroundTask != UIBackgroundTaskInvalid) {
                [app endBackgroundTask:backgroundTask];
                backgroundTask = UIBackgroundTaskInvalid;
            }
        });

    }];

    return backgroundTask;
}
@end
