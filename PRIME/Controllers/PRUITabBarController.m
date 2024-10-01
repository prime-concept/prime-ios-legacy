//
//  PRUITabBarController.m
//  PRIME
//
//  Created by Artak Tsatinyan on 2/20/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "AppDelegate.h"
#import "ChatUtility.h"
#import "ChatViewController.h"
#import "CommandBuilder.h"
#import "NotificationManager.h"
#import "PRUITabBarController.h"
#import "RequestsDetailViewController.h"
#import "RequestsViewController.h"
#import "PRMessageProcessingManager.h"
#import "UITabBarItem+CustomBadge.h"
#import "WebSocketManager.h"
#import "TopTenViewController.h"
#import "PRTaskDocumentManager.h"
#import "DeepLinkManager.h"
#import "PRUserDefaultsManager.h"
#import "PRFeatureInfoProcessingManager.h"
#import "PRFeaturesContainerViewController.h"
#import "PRInformationNavigationController.h"
#import "PRInformationViewController.h"

@import WebKit;
@import Firebase;

@interface PRUITabBarController ()

@property (assign, nonatomic) BOOL shouldUpdateViewController;
@property (strong, nonatomic) NSArray<NSString*>* ticketsArray;
@property (assign, nonatomic) NSInteger currentShakeIndex;
@property (strong, nonatomic) PRFeatureInfoProcessingManager* featureInfoProcessingManager;
+ (UIStoryboard*)mainStoryboard;

@end

static NSString* const kTab1IconName = @"tabIcon1";
static NSString* const kTab1SelectedIconName = @"tabIcon1_selected";
static NSString* const kFeaturesContainerViewController = @"PRFeaturesContainerViewController";
static NSString* const kInformationNavigationController = @"PRInformationNavigationController";

@implementation PRUITabBarController

+ (PRUITabBarController*)instantiateFromStoryboard
{
    UIStoryboard* storyboard = [self mainStoryboard];
    PRUITabBarController* tabBarController = [storyboard instantiateViewControllerWithIdentifier:@"TabBar"];
    if ([PRDatabase ordersCount] != 0) {
        tabBarController.selectedIndex = MainScreenTabs_Requests;
    } else {
        tabBarController.selectedIndex = MainScreenTabs_Chat;
    }
    PRUserDefaultsManager *manager = [PRUserDefaultsManager sharedInstance];
    [manager getCityGuideDataWithLocation];

    return tabBarController;
}

+ (NSNumber*)taskIdForChatIds:(NSMutableArray*)chatIds
{
    if (!chatIds) {
        return nil;
    }
    NSArray<PRTaskDetailModel*>* taskDetailModels = [PRDatabase taskIdsForChatIds:chatIds];
    if (!taskDetailModels) {
        return nil;
    }
    PRTaskDetailModel* taskDetailModel = [taskDetailModels firstObject];
    return taskDetailModel.taskId;
}

- (RequestsViewController*)requestViewController
{
    [self setSelectedIndex:MainScreenTabs_Requests];

    UINavigationController* navigationController = [self selectedViewController];

    NSAssert(navigationController, @"Tab bar selected view controller can't be nil.");

    NSAssert(navigationController.viewControllers, @"Navigation view controller must have one child view controller.");

    [navigationController popToRootViewControllerAnimated:NO];

    RequestsViewController* requestsViewController =
        [navigationController.viewControllers firstObject];

    NSAssert([requestsViewController
                 isKindOfClass:[RequestsViewController class]],
        @"Child view controller must be instance of RequestsViewController.");

    NSAssert(requestsViewController, @"Requests tab view controller can't be nil.");

    return requestsViewController;
}

- (void)openOrderPage
{
    RequestsViewController* requestsViewController = [self requestViewController];
    [requestsViewController.reservesOrRequestsSegmentedControl setSelectedSegmentIndex:PRRequestSegment_InProgress];
    [requestsViewController.reservesOrRequestsSegmentedControl sendActionsForControlEvents:UIControlEventValueChanged];
}

- (RequestsDetailViewController*)openTaskWithTaskId:(NSNumber*)taskId
{
    RequestsViewController* requestsViewController = [self requestViewController];

    RequestsDetailViewController* requestsDetailViewController =
        [requestsViewController openRequestDetails:taskId
                                    andRequestDate:nil
                                     withAnimation:NO];

    NSAssert(requestsDetailViewController, @"requestsDetailViewController can't be nil.");

    return requestsDetailViewController;
}

- (void)openChatWithTaskId:(NSNumber*)taskId
{
    NSAssert(taskId, @"taskId can't be nil.");

    RequestsDetailViewController* requestsDetailViewController = [self openTaskWithTaskId:taskId];
    [requestsDetailViewController openChat];
}

+ (UIStoryboard*)mainStoryboard
{
    return [UIStoryboard storyboardWithName:@"Main"
                                     bundle:[NSBundle mainBundle]];
}

- (void)showBadge
{
    static NSInteger notificationsCurrentCount = 0;
    static NSInteger unseenMainMessagesCurrentCount = 0;

    [PRDatabase removeExpiredMessages];
    [PRDatabase removeExpiredRequests];

    [PRMessageProcessingManager updateMessagesStatusForCompletedTasks];
    NSInteger ordersCount = [PRDatabase ordersCount];
    NSInteger unseenMessagesMainCount = [PRDatabase unseenMessagesMainCount];
    NSInteger notificationsCount = [PRDatabase requestsUnseenMessagesCountFromSubscriptions] + ordersCount;

    NSArray<UITabBarItem*>* tabBarItems = self.tabBar.items;
    UITabBarItem* requestsTabBarItem = tabBarItems[1];
    UITabBarItem* mainChatTabBarItem = tabBarItems[2];

    if (notificationsCount) {
        BOOL isInvalidMessagesDeletionCompleted = [[NSUserDefaults standardUserDefaults] boolForKey:kInvalidMessagesDeletionDidComplete];
        if ([PRDatabase taskDetailsCount] && isInvalidMessagesDeletionCompleted && notificationsCount != notificationsCurrentCount) {
            notificationsCurrentCount = notificationsCount;

            [requestsTabBarItem setCustomBadgeValue:[@(notificationsCount) stringValue]
                                           withFont:[UIFont systemFontOfSize:kBadgeFontSize]
                                       andFontColor:kBadgeTextColor
                                 andBackgroundColor:kBadgeBackgroundColor];
        }
    } else {
        [requestsTabBarItem setBadgeValue:nil];
    }

    if (unseenMessagesMainCount != 0) {
        if (unseenMessagesMainCount != unseenMainMessagesCurrentCount) {
            unseenMainMessagesCurrentCount = unseenMessagesMainCount;

            [mainChatTabBarItem setCustomBadgeValue:[@(unseenMessagesMainCount) stringValue]
                                           withFont:[UIFont systemFontOfSize:kBadgeFontSize]
                                       andFontColor:kBadgeTextColor
                                 andBackgroundColor:kBadgeBackgroundColor];
        }
    } else {
        unseenMainMessagesCurrentCount = 0;
        [mainChatTabBarItem setBadgeValue:nil];
    }

    if (notificationsCount + unseenMessagesMainCount > 0) {

        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:notificationsCount + unseenMessagesMainCount];
    } else {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setFirstTabBarItemImage];
    NSArray<UITabBarItem*>* tabBarItems = self.tabBar.items;

    [tabBarItems[1] setImage:kTabItem5Image];
    [tabBarItems[2] setImage:kTabItem2Image];
    [tabBarItems[3] setImage:kTabItem3Image];
    [tabBarItems[4] setImage:kTabItem4Image];

    [tabBarItems[0] setTitle:NSLocalizedString(kTabItem1Title, nil)];
    [tabBarItems[1] setTitle:NSLocalizedString(kTabItem2Title, nil)];
    [tabBarItems[2] setTitle:NSLocalizedString(kTabItem3Title, nil)];
    [tabBarItems[3] setTitle:NSLocalizedString(kTabItem4Title, nil)];
    [tabBarItems[4] setTitle:NSLocalizedString(kTabItem5Title, nil)];

#ifdef PondMobile
    [tabBarItems[2] setTitleTextAttributes:@{
        UITextAttributeTextColor : [UIColor colorWithRed:136. / 255 green:107. / 255 blue:99. / 255 alpha:1],
        NSFontAttributeName : [UIFont fontWithName:@"Arial-BoldMT" size:12.0f]
    }
                                  forState:UIControlStateNormal];
    [tabBarItems[2] setTitlePositionAdjustment:UIOffsetMake(0, -2)];
    [tabBarItems[2] setImageInsets:UIEdgeInsetsMake(1, 0, -1, 0)];
    tabBarItems[2].selectedImage = [[UIImage imageNamed:@"tabIcon2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
#endif

    [self startWebSocketManager];

    __weak PRUITabBarController* weakSelf = self;
    [PRRequestManager getTasksWithView:self.view
                                  mode:PRRequestMode_ShowNothing
                               success:^() {
                                   PRUITabBarController* strongSelf = weakSelf;
                                   if (!strongSelf) {
                                       return;
                                   }

                                   [PRDatabase removeExpiredRequests];
                                   [PRMessageProcessingManager updateMessagesStatusForCompletedTasks];
                                   [strongSelf setWidgetData];
                                   [strongSelf getSubscriptions];
                                   [strongSelf saveTaskDocuments];
                               }
                               failure:nil];

    UILongPressGestureRecognizer* longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self.tabBar addGestureRecognizer:longPressGesture];

    UINavigationController* chatNavigationController = [self.viewControllers objectAtIndex:MainScreenTabs_Chat];
    ChatViewController* chatViewController = [chatNavigationController.viewControllers objectAtIndex:0];
    [chatViewController initLocationManager];

    self.tabBarController.delegate = self;
    self.delegate = self;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(messageReceived:)
                                                 name:kMessageReceived
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setFirstTabBarItemImage)
                                                 name:UIApplicationSignificantTimeChangeNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshedFCMTokenReceived:)
                                                 name:kFCMRefreshedToken
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(restoreCurrentShakeIndex)
                                                 name:kRestoreCurrentShakeIndex
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];

    [[FIRInstanceID instanceID] instanceIDWithHandler:^(FIRInstanceIDResult * _Nullable result, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error fetching remote instance ID: %@", error);
        } else {
            NSLog(@"Remote instance ID token: %@", result.token);
            [self registerFCMRefreshedToken: result.token];
        }
    }];
    
    // Register FCM refreshed token.
//    [self registerFCMRefreshedToken:[[FIRInstanceID instanceID] token]];

    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSDictionary* launchOptions = appDelegate.launchOptions;

    if (launchOptions) {
        NSDictionary* deepLinkInfo = [launchOptions valueForKey:kDeepLinkKey];

        // In case if pressed deep link.
        if (deepLinkInfo) {
            appDelegate.launchOptions = nil;
            [DeepLinkManager handleDeepLinkForServices:deepLinkInfo tabBarController:self];
        } else {
            [NotificationManager proccessNotificationWithTabBarController:self];
        }

        return;
    }

    pr_dispatch_once({
        if ([PRDatabase ordersCount] != 0) {
            [self openOrderPage];
            return;
        }
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)startWebSocketManager
{
    PRUserProfileModel* profile = [[PRUserProfileModel MR_findAllInContext:[NSManagedObjectContext MR_rootSavingContext]] firstObject];
    [[NSUserDefaults standardUserDefaults] setValue:profile.username forKey:kUserNameKey];
    __weak PRUITabBarController* weakSelf = self;
    if (profile.username) {

        [self createTopTenViewController];

        // Get features enabled for the user.
        [PRRequestManager getProfileFeaturesWithView:self.view
            mode:PRRequestMode_ShowNothing
            success:^(NSArray<PRUserProfileFeaturesModel*>* profileFeatures) {
                PRUITabBarController* strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }

                [WebSocketManager sharedInstance];
                if (![[NSUserDefaults standardUserDefaults] boolForKey:kIsAfterRegistration]) {
                    [strongSelf getFeaturesInfoAndPresentOnTabBar];
                } else {
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kIsAfterRegistration];
                }

            }
            failure:^{
                [WebSocketManager sharedInstance];
            }];

        return;
    }

    [PRRequestManager getProfileWithView:self.view
                                    mode:PRRequestMode_ShowNothing
                                 success:^(PRUserProfileModel* userProfile) {
                                     [[NSNotificationCenter defaultCenter] postNotificationName:kProfileHasBeenLoaded
                                                                                         object:nil];
                                     [[NSUserDefaults standardUserDefaults] setValue:profile.username forKey:kUserNameKey];

                                     PRUITabBarController* strongSelf = weakSelf;
                                     if (!strongSelf) {
                                         return;
                                     }

                                     [strongSelf createTopTenViewController];
                                     [WebSocketManager sharedInstance];
                                     if (![[NSUserDefaults standardUserDefaults] boolForKey:kIsAfterRegistration]) {
                                         [strongSelf getFeaturesInfoAndPresentOnTabBar];
                                     } else {
                                         [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kIsAfterRegistration];
                                     }

                                 }
                                 failure:^{
                                 }];
}

#pragma mark - Save Task Documents

- (void)saveTaskDocuments
{
    NSArray<PRTaskDetailModel*>* allObjects = [PRDatabase getTasksForTodayAndTomorrow].fetchedObjects;

    for (PRTaskDetailModel* model in allObjects) {

        __weak PRUITabBarController* weakSelf = self;
        [PRRequestManager getTaskWithId:model.taskId
                                   view:self.view
                                   mode:PRRequestMode_ShowNothing
                                success:^(PRTaskDetailModel* task) {

                                    PRUITabBarController* strongSelf = weakSelf;
                                    if (!strongSelf) {
                                        return;
                                    }

                                    [PRTaskDocumentManager saveDocumentsForTask:task withView:strongSelf.view];
                                    strongSelf.ticketsArray = [PRTaskDocumentManager getPDFDocumentsPaths];
                                    strongSelf.currentShakeIndex = 0;

                                }
                                failure:^{

                                }];
    }
}

#pragma mark - Firebase

- (void)registerFCMRefreshedToken:(NSString*)token
{
    if (!token) {
        return;
    }

    // Send FCM registration token to server.
    [PRRequestManager registerFCMToken:token
                                  view:self.view
                                  mode:PRRequestMode_ShowNothing
                               success:^{
                               }
                               failure:^{
                               }];
}

#pragma mark - Notification Handler

- (void)refreshedFCMTokenReceived:(NSNotification*)notification
{
    // Register FCM refreshed token.
    NSString* refreshedToken = (NSString*)notification.object;
    [self registerFCMRefreshedToken:refreshedToken];
}

- (void)messageReceived:(NSNotification*)notification
{
    NSString* channelId = [notification object];

    if (![channelId isEqualToString:[ChatUtility mainChatIdWithPrefix]]) {
        [PRDatabase updateUnseenMessagesCountOfSubscriptionForChannelId:channelId];
    }
    [self showBadge];
}

#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController*)tabBarController shouldSelectViewController:(UIViewController*)viewController
{
    _shouldUpdateViewController = [self.selectedViewController isEqual:viewController];
    [self restoreCurrentShakeIndex];
    return YES;
}
- (void)tabBarController:(UITabBarController*)tabBarController didSelectViewController:(UINavigationController*)viewController
{
    if (_shouldUpdateViewController && (tabBarController.selectedIndex != MainScreenTabs_Requests && tabBarController.selectedIndex != MainScreenTabs_Profile)) {

        UIViewController<TabBarItemChanged>* rootViewController = [viewController.viewControllers firstObject];

        [rootViewController updateViewController];
    }
}

#pragma mark - First TabBarItem Image

- (void)setFirstTabBarItemImage
{
    NSArray<UITabBarItem*>* tabBarItems = self.tabBar.items;
    UIImage* kTabItem1 = [self imageWithDayOfMonth:[UIImage imageNamed:kTab1IconName]
									  dayTextColor:kTabBarDayLabelUnselectedTextColor];

    [tabBarItems[0] setImage:[kTabItem1 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];

#if defined(PrimeConciergeClub)
    kTabItem1 = [self imageWithDayOfMonth:[UIImage imageNamed:kTab1SelectedIconName] dayTextColor:kTinkoffMainColor];
    [tabBarItems[0] setSelectedImage:[kTabItem1 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
#elif defined(VTB24)
	UIImage *image = [UIImage imageNamed:kTab1SelectedIconName];
    kTabItem1 = [self imageWithDayOfMonth:image dayTextColor:kWhiteColor];
    [tabBarItems[0] setSelectedImage:[kTabItem1 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
#elif defined(PrivateBankingPRIMEClub) || defined(PrimeRRClub) || defined(Davidoff) || defined(PrimeClubConcierge)
    kTabItem1 = [self imageWithDayOfMonth:[UIImage imageNamed:kTab1SelectedIconName] dayTextColor:kTabBarDayLabelUnselectedTextColor];
    [tabBarItems[0] setSelectedImage:[kTabItem1 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
#else
    [tabBarItems[0] setSelectedImage:[kTabItem1 imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
#endif
}

#pragma mark - Helpers

/** Create image with current date*/
- (UIImage*)imageWithDayOfMonth:(UIImage*)imageWithoutNumber dayTextColor:(UIColor*)textColor
{

#if defined(PrimeConciergeClub) || defined(VTB24) || defined(PrivateBankingPRIMEClub) || defined(PrimeRRClub) || defined(PrimeClubConcierge)
    static const CGFloat dayNumberLabelYPosMultiplier = 0.3;
#else
    static const CGFloat dayNumberLabelYPosMultiplier = 0.4;
#endif

    static const CGFloat dayNumberLabelHeightMultiplier = 0.45;
    CGRect imageFrame = CGRectMake(0, 0, imageWithoutNumber.size.width, imageWithoutNumber.size.height);
    UIView* screenshotView = [[UIView alloc] initWithFrame:imageFrame];
    UIImageView* screenshotImageView = [[UIImageView alloc] initWithFrame:imageFrame];
    screenshotImageView.image = imageWithoutNumber;
    [screenshotView addSubview:screenshotImageView];
    NSDateComponents* components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:[NSDate date]];
    UILabel* dayNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(imageFrame) * dayNumberLabelYPosMultiplier, CGRectGetWidth(imageFrame), CGRectGetHeight(imageFrame) * dayNumberLabelHeightMultiplier)];
    dayNumberLabel.textAlignment = NSTextAlignmentCenter;
    dayNumberLabel.textColor = textColor;

#if defined(PrivateBankingPRIMEClub) || defined(PrimeClubConcierge)
     dayNumberLabel.font = [UIFont boldSystemFontOfSize:15];
#else
    dayNumberLabel.font = [UIFont systemFontOfSize:13.0];
#endif

    dayNumberLabel.text = [NSString stringWithFormat:@"%@", @(components.day)];
    [screenshotView addSubview:dayNumberLabel];
    UIGraphicsBeginImageContextWithOptions(imageWithoutNumber.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [screenshotView.layer renderInContext:context];
    UIImage* screenShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenShot;
}

- (void)getSubscriptions
{
    __weak PRUITabBarController* weakSelf = self;

    [PRRequestManager getSubscriptions:^(NSArray<PRSubscriptionModel*>* subscription) {

        PRUITabBarController* strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }

        [strongSelf handleSubscriptionsAndSetUnreadCount:subscription];
        [strongSelf showBadge];
    }
                               failure:^(NSInteger statusCode, NSError* error){
                               }];
}

- (void)handleSubscriptionsAndSetUnreadCount:(NSArray<PRSubscriptionModel*>*)subscriptions
{
    NSManagedObjectContext* mainContext = [NSManagedObjectContext MR_contextForCurrentThread];
    PRTaskDetailModel* task;
    for (PRSubscriptionModel* subscription in subscriptions) {
        task = [PRDatabase getTaskForChannelId:[subscription.channelId substringFromIndex:1] inContext:mainContext];
        NSString* mainChatId = [ChatUtility mainChatIdWithPrefix];
        if ([mainChatId isEqualToString:subscription.channelId]) {
            NSArray<UITabBarItem*>* tabBarItems = self.tabBar.items;
            UITabBarItem* mainChatTabBarItem = tabBarItems[2];
            NSInteger unseenMessagesMainCount = subscription.unseenMessagesCount.integerValue;

            if (unseenMessagesMainCount != 0) {
                [self showBadge];

            } else {
                [mainChatTabBarItem setBadgeValue:nil];
            }
        }
    }
    [mainContext MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError* _Nullable error){

    }];
}

- (CGRect)positionOfTabBarItemAtIndex:(NSInteger)index
{
    CGRect tabBarRect = self.tabBar.frame;
    NSInteger itemsCount = self.tabBar.items.count;
    CGFloat width = tabBarRect.size.width / itemsCount;
    CGFloat x = width * index;
    CGRect tabBarItemRect = CGRectMake(x, 0, width, CGRectGetHeight(tabBarRect));

    return tabBarItemRect;
}

- (void)getFeaturesInfoAndPresentOnTabBar
{
    if (!self.featureInfoProcessingManager) {
        self.featureInfoProcessingManager = [PRFeatureInfoProcessingManager new];
    }

    [self.featureInfoProcessingManager getFeatureInfoData:^(NSArray<UIViewController*>* pages) {
        UIStoryboard* mainStoryboard = [Utils mainStoryboard];
        PRFeaturesContainerViewController* featuresContainerViewController = (PRFeaturesContainerViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:kFeaturesContainerViewController];
        [featuresContainerViewController setViewControllers:pages];
        featuresContainerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:featuresContainerViewController animated:YES completion:nil];
    }];
}

- (void)getHelpScreenFeatureAndPresentOnTabBar:(UIViewController*)rootViewController
{
    if (!self.featureInfoProcessingManager) {
        self.featureInfoProcessingManager = [PRFeatureInfoProcessingManager new];
    }

    __weak PRUITabBarController* weakSelf = self;
    [self.featureInfoProcessingManager getHelpScreenFeatures:^(NSArray* featuresData) {
        PRUITabBarController* strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }

        UIStoryboard* mainStoryboard = [Utils mainStoryboard];
        PRInformationNavigationController* informationNavigationController = (PRInformationNavigationController*)[mainStoryboard instantiateViewControllerWithIdentifier:kInformationNavigationController];

        PRInformationViewController* helpSrceen = [[informationNavigationController viewControllers] firstObject];
        [helpSrceen setInformation:featuresData];

        informationNavigationController.modalPresentationStyle = UIModalPresentationFullScreen;
        if (rootViewController == nil) {
            [strongSelf presentViewController:informationNavigationController animated:YES completion:nil];
        } else {
            [rootViewController presentViewController:informationNavigationController animated:YES completion:nil];
        }

    }];
}

#pragma mark - Actions

- (void)handleLongPress:(UILongPressGestureRecognizer*)gesture
{
    CGRect tabBarItemFrame = [self positionOfTabBarItemAtIndex:MainScreenTabs_Chat];
    CGPoint pressPosition = [gesture locationInView:self.view];
    CGRect tabBarItemFrameInSuperView = [self.view convertRect:tabBarItemFrame fromView:self.tabBar];

    UIViewController<TabBarItemChanged>* viewController = [self.viewControllers objectAtIndex:MainScreenTabs_Chat];
    UINavigationController* navigationController;

    if ([viewController isKindOfClass:[UINavigationController class]]) {
        navigationController = (UINavigationController*)viewController;
        viewController = [[navigationController viewControllers] firstObject];
    }

    if (gesture.state == UIGestureRecognizerStateBegan && ![PRRequestManager connectionRequired]) {
        if (!CGRectContainsPoint(tabBarItemFrameInSuperView, pressPosition)) {
            return;
        }

        [self setSelectedIndex:MainScreenTabs_Chat];
        [navigationController popToRootViewControllerAnimated:YES];
    }

    if ([viewController respondsToSelector:@selector(handleLongPressOnTabBar:)]) {
        [viewController handleLongPressOnTabBar:gesture];
    }
}

#pragma mark - Dealloc

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Shake Motion

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent*)event
{
    if (motion == UIEventSubtypeMotionShake) {
        if (!_ticketsArray || _ticketsArray.count == 0) {
            _ticketsArray = [PRTaskDocumentManager getPDFDocumentsPaths];
            _currentShakeIndex = 0;
        }

        if (_currentShakeIndex == _ticketsArray.count && _ticketsArray.count != 1) {
            _currentShakeIndex = 0;
        }

        if (_currentShakeIndex < _ticketsArray.count) {
            NSString* path = [_ticketsArray objectAtIndex:_currentShakeIndex];
            NSNumber* taskId = [PRTaskDocumentManager taskIdFromPath:path];

            if (taskId && ![taskId isEqualToNumber:@(0)]) {
                WebViewController* webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
                webViewController.url = path;

                RequestsDetailViewController* requestsDetailViewController = [self openTaskWithTaskId:taskId];
                [requestsDetailViewController.navigationController pushViewController:webViewController animated:YES];
            }
            _currentShakeIndex++;
        }
    }

    if ([super respondsToSelector:@selector(motionBegan:withEvent:)]) {
        [super motionBegan:motion withEvent:event];
    }
}

- (void)restoreCurrentShakeIndex
{
    _currentShakeIndex = 0;
    _ticketsArray = nil;
}

- (void)setWidgetData
{
    PRUserDefaultsManager *manager = [PRUserDefaultsManager sharedInstance];
    [manager setWidgetRequests];
    [manager setWidgetEvents];
}

- (void)createTopTenViewController
{
    UINavigationController* topTenNavigationController = [self.viewControllers objectAtIndex:MainScreenTabs_Top10];
    TopTenViewController* topTenViewController = [topTenNavigationController.viewControllers objectAtIndex:0];
    [topTenViewController deleteCookiesWithCompletionBlock:^{
        [topTenViewController initLocationManager];
    }];
}

@end
