//
//  RequestsDetailViewController.m
//  PRIME
//
//  Created by Artak Tsatinyan on 2/10/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "ChatUtility.h"
#import "ChatViewController.h"
#import "CommandBuilder.h"
#import "ContainerButton.h"
#import "FontAwesomeIconView.h"
#import "PRActionModel.h"
#import "PRRequestDetailsParser.h"
#import "PRRequestDetailsViewBuilder.h"
#import "PRRequestDetailsViewFactory.h"
#import "PRTaskDetailModel.h"
#import "PRTaskItemModel.h"
#import "PRUberActionSheet.h"
#import "PRUberCell.h"
#import "PRWebSocketMessageContent.h"
#import "RequestsDetailViewController.h"
#import "UIBarButtonItem+Badge.h"
#import "UberManager.h"
#import "WebViewController.h"
#import "XNTLazyManager.h"
#import "PRPaymentView.h"
#import "PRPaymentDataModel.h"
#import "PRApplePayToken.h"
#import <CoreLocation/CoreLocation.h>
#import <PassKit/PassKit.h>
#import "PRTaskDocumentManager.h"
#import "PRUINavigationController.h"

static const NSInteger kTableViewHeaderHeight = 30;
static const NSInteger kTableViewRowCountInSection = 1;
static const NSUInteger kMinDistanceToUpdateLocation = 200;
static NSString* const kUberServiceCellReuseIdentifier = @"kUberServiceCell";

@interface RequestsDetailViewController () <PRUberActionSheetDelegate, PKPaymentAuthorizationViewControllerDelegate, PaymentViewDelegate> {
    BOOL _canOpenUberActionSheet;
    BOOL _isTaskLocationExist;
    BOOL _didNetworkOfflineAlertShow;
}

@property (weak, nonatomic) IBOutlet UITableView* tableViewRequestDetail;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* constraintTextBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* constraintTextHeigth;
@property (strong, nonatomic) XNTLazyManager* lazyManager;
@property (strong, nonatomic) PRTaskDetailModel* task;
@property (strong, nonatomic) PRTaskItemModel* taskItemForUber;
@property (strong, nonatomic) UIBarButtonItem* chatBarButton;
@property (strong, nonatomic) PRUberActionSheet* uberActionSheet;
@property (strong, nonatomic) NSMutableArray<PRUberEstimates*>* uberSourceArray;
@property (strong, nonatomic) NSMutableArray<NSString*>* groups;
@property (strong, nonatomic) NSMutableArray<UIView*>* cells;
@property (strong, nonatomic) NSString* shareString;
@property (strong, nonatomic) CLLocationManager* selfLocationManager;
@property (strong, nonatomic) CLLocation* currentLocation;
@property (strong, nonatomic) CLLocation* taskLocation;
@property (strong, nonatomic) PRUberView* uberFieldLeftView;
@property (strong, nonatomic) UILabel* uberFieldRightLabel;
@property (strong, nonatomic) NSDate* locationManagerStartDate;
@property (strong, nonatomic) NSString* paymentID;
@property (strong, nonatomic) NSString* paymentUrl;
@property (strong, nonatomic) NSString* paymentTitle;
@property (strong, nonatomic) PRPaymentDataModel* paymentDataModel;

@end

@implementation RequestsDetailViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO
                                             animated:YES];

    [self initLocationManager];

    _cells = [NSMutableArray array];
    _groups = [NSMutableArray array];

    _tableViewRequestDetail.delaysContentTouches = YES;
    _tableViewRequestDetail.separatorStyle = UITableViewCellSeparatorStyleNone;

    _pullToRefreshView = [[SSPullToRefreshView alloc] initWithScrollView:_tableViewRequestDetail
                                                                delegate:self];

    _lazyManager = [[XNTLazyManager alloc] initWithObserver:self
                                                   selector:@selector(reachabilityChanged:)];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(messageReceived:)
                                                 name:kMessageReceived
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    _tableViewRequestDetail.delegate = self;
    _tableViewRequestDetail.dataSource = self;

#if defined(PrivateBankingPRIMEClub)
    [(PRUINavigationController*)self.navigationController setNavigationBarColor:kTabBarBackgroundColor];
#endif
    if (self.isMovingToParentViewController) {
        return;
    }
    [self setBadgeValue];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    _tableViewRequestDetail.delegate = nil;
    _tableViewRequestDetail.dataSource = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self updateRequestDetails];

    [_lazyManager shouldBeUpdatedIfViewDidAppearWithDate:[NSDate date]
        relativeToDate:nil
        then:^(PRRequestMode mode) {
            [self dataLoading:mode];
        }
        otherwiseIfFirstTime:^{

        }
        otherwise:^{

        }];

    [_tableViewRequestDetail reloadData];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kMessageReceived
                                                  object:nil];
}

#pragma mark - Navigation Bar

- (void)prepareNavigationBar
{
    if (self.navigationItem.rightBarButtonItem) {
        return;
    }

    NSMutableArray<UIBarButtonItem*>* buttons = [NSMutableArray array];

#ifdef REQUEST_SHARING_FUNC
    UIBarButtonItem* shareButtonItem = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                             target:self
                             action:@selector(shareAction)];

#if defined(VTB24) || defined(Prime) || defined(PrivateBankingPRIMEClub) || defined(PrimeRRClub)
    UIImage* image = [[UIImage imageNamed:@"share"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    shareButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(shareAction)];

#endif

    self.navigationItem.rightBarButtonItem = shareButtonItem;
    [buttons addObject:shareButtonItem];

#endif

#ifdef CHAT_FUNC

    const CGRect buttonRect = CGRectMake(0, 0, kTableViewHeaderHeight, kTableViewHeaderHeight);

    UIImage* iconView = [UIImage imageNamed:@"wechat"];
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self
                  action:@selector(openChat)
        forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:buttonRect];
    [button setImage:iconView
            forState:UIControlStateNormal];
    [button setTintColor:kWeChatImageColor];

    _chatBarButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    [buttons addObject:_chatBarButton];
    [self setBadgeValue];
    [self.navigationItem setRightBarButtonItems:buttons];

#endif
}

- (void)prepareNavigationControllerTitleView
{
    if (self.navigationItem.titleView) {
        return;
    }

    UILabel* label = [[UILabel alloc] init];
    [label setFont:[UIFont systemFontOfSize:17 weight:UIFontWeightSemibold]];
    [label setTextColor:kNavigationBarTitleTextColor];
    [label setText:_task.taskName];
    [label sizeToFit];

#if defined(Raiffeisen) || defined(VTB24) || defined(PrivateBankingPRIMEClub) || defined(Davidoff)
    [label setTextColor:kNavigationBarTitleColor];
#endif

    self.navigationItem.titleView = label;
}

#pragma mark - Location Manager

- (void)initLocationManager
{
    _selfLocationManager = [[CLLocationManager alloc] init];
    _selfLocationManager.delegate = self;
    _selfLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    _selfLocationManager.distanceFilter = kMinDistanceToUpdateLocation;
    _locationManagerStartDate = [NSDate date];
    [_selfLocationManager requestWhenInUseAuthorization];
    [_selfLocationManager startUpdatingLocation];
}

#pragma mark - Uber Estimates

- (void)initUberActionSheetAndGetEstimates
{
    if (!_uberSourceArray) {
        _uberSourceArray = [NSMutableArray array];
    }

    if (!_taskItemForUber.latitude || !_taskItemForUber.longitude) {
        return;
    }

    __weak id weakSelf = self;
    [[UberManager sharedManager] getEstimatedPricesWithStartLatitude:@(_currentLocation.coordinate.latitude)
                                                      startLongitude:@(_currentLocation.coordinate.longitude)
                                                         endLatitude:_taskItemForUber.latitude
                                                        endLongitude:_taskItemForUber.longitude
                                                         withSuccess:^(NSArray<PRUberEstimates*>* uberEstimates) {
                                                             RequestsDetailViewController* strongSelf = weakSelf;
                                                             if (!strongSelf) {
                                                                 return;
                                                             }

                                                             [strongSelf.uberSourceArray removeAllObjects];
                                                             [strongSelf.uberSourceArray addObjectsFromArray:uberEstimates];
                                                             for (PRUberEstimates* estimate in strongSelf.uberSourceArray) {
                                                                 estimate.startLatitude = @(strongSelf.currentLocation.coordinate.latitude);
                                                                 estimate.startLongitude = @(strongSelf.currentLocation.coordinate.longitude);
                                                                 estimate.endLatitude = strongSelf.taskItemForUber.latitude;
                                                                 estimate.endLongitude = strongSelf.taskItemForUber.longitude;
                                                                 estimate.dropoffAddress = _taskItemForUber.itemValue ?: @"";
                                                             }
                                                             if (!strongSelf.uberActionSheet) {

                                                                 strongSelf.uberActionSheet = [[PRUberActionSheet alloc] initWithSourceArray:strongSelf.uberSourceArray andRootViewController:strongSelf];
                                                                 strongSelf.uberActionSheet.delegate = strongSelf;
                                                             }
                                                             [[UberManager sharedManager] getUberCarsImagesForStartLatitude:@(strongSelf.currentLocation.coordinate.latitude)
                                                                                                             startlongitude:@(strongSelf.currentLocation.coordinate.longitude)
                                                                                                                withSuccess:^(NSArray<NSDictionary*>* products) {
                                                                                                                    RequestsDetailViewController* strongSelf = weakSelf;
                                                                                                                    if (!strongSelf) {
                                                                                                                        return;
                                                                                                                    }

                                                                                                                    for (PRUberEstimates* uberEstimate in strongSelf.uberSourceArray) {
                                                                                                                        for (int i = 0; i < products.count; i++) {
                                                                                                                            if ([[products[i] valueForKey:@"product_id"] isEqualToString:uberEstimate.productId]) {

                                                                                                                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                                                                                                    NSURL* url = [NSURL URLWithString:[products[i] valueForKey:@"image"]];
                                                                                                                                    NSData* data = [NSData dataWithContentsOfURL:url];
                                                                                                                                    UIImage* carImage = [[UIImage alloc] initWithData:data];

                                                                                                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                                                                                                        RequestsDetailViewController* strongSelf = weakSelf;
                                                                                                                                        if (!strongSelf) {
                                                                                                                                            return;
                                                                                                                                        }
                                                                                                                                        uberEstimate.carImage = carImage;
                                                                                                                                        strongSelf.uberActionSheet.sourceArray = strongSelf.uberSourceArray;
                                                                                                                                        [strongSelf.uberActionSheet reload];
                                                                                                                                    });
                                                                                                                                });
                                                                                                                                break;
                                                                                                                            }
                                                                                                                        }
                                                                                                                    }

                                                                                                                }
                                                                                                                    failure:nil];
                                                             [strongSelf getGroups];
                                                             [strongSelf.tableViewRequestDetail reloadData];
                                                         }
                                                             failure:nil];
}

#pragma mark - Messages

- (void)messageReceived:(NSNotification*)notification
{
    [self setBadgeValue];
}

- (void)setBadgeValue
{
    if (!_chatBarButton || _task.completed.boolValue) {
        return;
    }
    NSInteger unseenMessagesCount = [PRDatabase requestsUnseenMessagesCountFromSubscriptionsForChannelId: [ChatUtility chatIdWithPrefix:_task.chatId.stringValue]];
    _chatBarButton.badgeMinSize = 1;
    _chatBarButton.badgePadding = 0;

    if (unseenMessagesCount) {
        NSLog(@"-------%@", _chatBarButton.badgeValue);
        if (_chatBarButton.badgeValue && _chatBarButton.badgeValue.integerValue == unseenMessagesCount) {
            return;
        }
        _chatBarButton.badgeValue = [NSString stringWithFormat:@"%lu", (unsigned long)unseenMessagesCount];
        return;
    }

    _chatBarButton.badgeValue = nil;
}

- (void)openChat
{
    ChatViewController* viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
    _task = [PRDatabase getTaskDetailById:_taskId]; // Force getting of chat id.
    viewController.chatId = _task.chatId.stringValue;

    [self.navigationController pushViewController:viewController
                                         animated:YES];
}

#pragma mark - Tasks

- (void)dataLoading:(PRRequestMode)mode
{
    if (!_taskId)
    {
        [self.pullToRefreshView finishLoading];
        return;
    }

    __weak id weakSelf = self;
    [PRRequestManager getTaskWithId:_taskId
        view:self.view
        mode:mode
        success:^(PRTaskDetailModel* task) {
            RequestsDetailViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            [strongSelf updateRequestDetails];
            [strongSelf.pullToRefreshView finishLoading];
            [PRTaskDocumentManager saveDocumentsForTask:task withView:strongSelf.view];
        }
        failure:^{
            RequestsDetailViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            [strongSelf.pullToRefreshView finishLoading];
        }];
}

#pragma mark - Refresh Task

- (void)refresh
{
    [_selfLocationManager startUpdatingLocation];

    _didNetworkOfflineAlertShow = NO;

    [_pullToRefreshView startLoading];

    [_lazyManager shouldBeRefreshedWithDate:[NSDate date]
        relativeToDate:nil
        then:^(PRRequestMode mode) {
            [self dataLoading:mode];
        }
        otherwise:^{
            [_pullToRefreshView finishLoading];
            [self refreshUberField];
        }];
}

- (void)refreshUberField
{
    if (!_uberFieldLeftView) {
        return;
    }

    _uberSourceArray = nil;
    if (_isTaskLocationExist &&
        [[UberManager sharedManager] isUberAvailableInCurrentLocation:_currentLocation
                                                     forEventLocation:_taskLocation]
        &&
        [[UberManager sharedManager] isUberAvailableAtTime:_task.requestDate]) {
        [_uberFieldLeftView.uberViewNameLabel setText:NSLocalizedString(@"Waiting for UBER", nil)];
        if (_uberFieldRightLabel) {
            [_uberFieldLeftView.uberViewNameLabel setFrame:CGRectMake(CGRectGetMinX(_uberFieldLeftView.uberViewNameLabel.frame),
                                                               CGRectGetMinY(_uberFieldLeftView.uberViewNameLabel.frame),
                                                               CGRectGetWidth(_uberFieldLeftView.uberViewNameLabel.frame) + CGRectGetWidth(_uberFieldRightLabel.frame),
                                                               CGRectGetHeight(_uberFieldLeftView.uberViewNameLabel.frame))];
            [_uberFieldRightLabel setText:@""];
        }
    } else {
        [self dataLoading:PRRequestMode_ShowNothing];
    }
}

- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView*)view
{
    [self refresh];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    [self updateRequestDetails];
}

#pragma mark - Reachibility

// Called by Reachability whenever status changes.
- (void)reachabilityChanged:(NSNotification*)note
{
    [_lazyManager shouldBeUpdatedIfReachabilityChangedWithNotification:note
                                                                  date:[NSDate date]
                                                        relativeToDate:nil
                                                                  then:^(PRRequestMode mode) {
                                                                      [self dataLoading:mode];
                                                                  }];
}

#pragma mark - Task Groups

- (void)getGroups
{
    [_groups removeAllObjects];
    [_cells removeAllObjects];

    __block PRRequestDetailsViewBuilder* builder = nil;
    _shareString = [NSString string];
    [PRRequestDetailsParser parseTaskDetail:_task
        item:^(RequestDetailItemType type, NSString* name, NSString* value, NSString* icon, BOOL shareable) {

            UITapGestureRecognizer* uberViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(openUberProducts)];
            UITapGestureRecognizer* tapOnUberPriceLabel = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                  action:@selector(openUberProducts)];
            NSArray<UITapGestureRecognizer*>* uberTapGestureRecognizers = [NSArray arrayWithObjects:uberViewTap, tapOnUberPriceLabel, nil];
            NSString* uberEsimatedPickupTimeValue = nil;
            if (_uberSourceArray.count) {
                PRUberEstimates* uberEstimate = [_uberSourceArray firstObject];

                if ([[uberEstimate duration] integerValue] > 0) {
                    NSString* estimate = [[UberManager sharedManager] getEstimateForUber:uberEstimate];
                    NSString* currencySign = [[UberManager sharedManager] getCurrencySignForCode:uberEstimate.currencyCode];

                    uberEsimatedPickupTimeValue = [NSString stringWithFormat:@"%@ %@, %@ %@",
                                                            @([[uberEstimate duration] integerValue] / 60), NSLocalizedString(@"mins", nil),
                                                            estimate, currencySign];
                } else {
                    uberEsimatedPickupTimeValue = [NSString stringWithFormat:@"unknown, %@",
                                                            [uberEstimate estimatedPrice]];
                }
            }

            switch (type) {
            case RequestDetailItemType_text:

                if (name.length && shareable) {
                    _shareString = [NSString stringWithFormat:@"%@ %@\n\r %@\n\r", _shareString, name ? name : @"", value ? value : @""];
                } else if (value && shareable) {
                    _shareString = [NSString stringWithFormat:@"%@ %@\n\r", _shareString, value];
                }

                [builder makeTextWithName:name
                                    value:value
                                     icon:icon];

                break;

            case RequestDetailItemType_field:

                if (shareable) {
                    _shareString = [NSString stringWithFormat:@"%@ %@: %@\n\r", _shareString, name ? name : @"", value ? value : @""];
                }
                [builder makeLabelsWithName:name
                                      value:value];

                break;

            case RequestDetailItemType_link:

                if (shareable) {
                    if (![icon isEqualToString:@"map-marker"]) {
                        _shareString = [NSString stringWithFormat:@"%@ %@: %@\n\r", _shareString, name ? name : @"",
                                                 value && ![value isEqualToString:name] ? value : @""];
                    } else {
                        _shareString = [NSString stringWithFormat:@"%@ %@\n\r", _shareString, name ? name : @""];
                    }
                }

                [builder makeLinkViewWithTitle:name
                                           url:value
                                          icon:icon
                                        target:self
                                        action:@selector(openWebPage:)];

                break;

            case RequestDetailItemType_button:

                [builder makeButtonWithTitle:name
                                         url:value
                                      target:self
                                      action:@selector(openWebPage:)];

                break;

            case RequestDetailItemType_separator:

                if (shareable) {
                    _shareString = [NSString stringWithFormat:@"%@\n\r", _shareString];
                }

                [builder makeSeparatorViewWithName:name
                                             value:value];

                break;

            case RequestDetailItemType_uber:

                if (shareable) {
                    _shareString = [NSString stringWithFormat:@"%@\n\r", _shareString];
                }

                if (_isTaskLocationExist && [[UberManager sharedManager] isUberAvailableAtTime:_task.requestDate]) {
                    if ([self hasAllRequiredLocations] && _uberSourceArray.count && [[UberManager sharedManager] isUberAvailableInCurrentLocation:_currentLocation forEventLocation:_taskLocation]) {
                        [builder makeUberFieldWithValue:uberEsimatedPickupTimeValue
                                  andGestureRecognizers:uberTapGestureRecognizers
                                              withBlock:^(PRUberView* left, UILabel* right) {
                                                  _uberFieldLeftView = left;
                                                  _uberFieldRightLabel = right;
                                              }];
                    } else {
                        [builder makeUberFieldWithValue:nil
                                  andGestureRecognizers:nil
                                              withBlock:^(PRUberView* left, UILabel* right) {
                                                  _uberFieldLeftView = left;
                                                  _uberFieldRightLabel = right;
                                              }];
                    }
                }

                break;

            default:
                break;
            }

        }
        groupStart:^(NSString* name, BOOL shareable) {

#ifdef USE_REQUEST_DETAIL_TITLE
            BOOL isFirstGroup = ([groups count] == 0);
#endif //USE_REQUEST_DETAIL_TITLE

            if (name.length && shareable) {
                _shareString = [NSString stringWithFormat:@"%@\n\r %@\n\r", _shareString, name];
            }
            PRRequestDetailsViewFactory* factory = [[PRRequestDetailsViewFactory alloc] init];
            factory.parentViewDelegate = self;
            builder = [[PRRequestDetailsViewBuilder alloc] initForTableView:_tableViewRequestDetail
                                                                    factory:factory];

#ifdef USE_REQUEST_DETAIL_TITLE
            if (isFirstGroup) {
                [builder makeHeaderForTaskId:_taskId
                                    withDate:((!_requestDate) ? _task.requestDate : _requestDate)];
            }
#endif //USE_REQUEST_DETAIL_TITLE

            [_groups addObject:name];
        }
        groupEnd:^(NSString* name) {
            UIView* viewForGroup = [builder build];
            [_cells addObject:viewForGroup];

        }];
}

- (NSNumber*)getTaskId:(NSString*)url
{
    NSString* urlRegexp = @"prime://tasks/[0-9]+/cancel/?";
    NSPredicate* testPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegexp];

    if (![testPredicate evaluateWithObject:url]) {
        return nil;
    }

    NSArray<NSString*>* components = [url componentsSeparatedByString:@"/"];

    if ([components count] > 2) {
        return [NSNumber numberWithInteger:[components[3] integerValue]];
    }

    return nil;
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel*)label
    didSelectLinkWithPhoneNumber:(NSString*)phoneNumber
{
    NSString* phoneNumberToCall = [@"telprompt://" stringByAppendingString:phoneNumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumberToCall]];
}

#pragma mark - Open WEB

- (void)openWebPage:(ContainerButton*)sender
{
    NSNumber* taskId = [self getTaskId:sender.content];

    if (taskId) {
        __weak id weakSelf = self;
        [PRRequestManager cancelTask:self.view
            mode:PRRequestMode_ShowOnlyProgress
            taskId:taskId
            success:^{
                RequestsDetailViewController* strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }

                [strongSelf refresh];
            }
            failure:^{
                RequestsDetailViewController* strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }

                //Show only error message.
                [strongSelf refresh];
            }];
        return;
    }

    if ([sender.content containsString:@"/payments/order/"] &&
        [PRDatabase isUserProfileFeatureEnabled:ProfileFeature_ApplePay] &&
        [PKPaymentAuthorizationViewController canMakePayments]) {

        _paymentUrl = sender.content;
        _paymentTitle = sender.currentTitle;
        _paymentID = [_task.orders firstObject].paymentUid;

        // Get payment information.
        [self getPaymentInformation];
        return;
    }

    WebViewController* webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    webViewController.title = [sender currentTitle];

    NSString* PDFDocumentPath = [PRTaskDocumentManager getDocumentWithTaskId:_taskId name:sender.titleLabel.text];
    webViewController.url = [[NSFileManager defaultManager] fileExistsAtPath:PDFDocumentPath] ? PDFDocumentPath : sender.content;
    [self.navigationController pushViewController:webViewController animated:YES];
}

#pragma mark - Payment

- (void)getPaymentInformation
{
    [self payWithCard];
}

- (void)showPaymentView
{
    PRPaymentView* paymentView = [[[NSBundle mainBundle] loadNibNamed:@"PRPaymentView"
                                                                owner:self
                                                              options:nil] objectAtIndex:0];
    [paymentView setFrame:[[UIScreen mainScreen] bounds]];
    [paymentView setDelegate:self];
    [paymentView setupViewWithTask:_task
                       paymentInfo:_paymentDataModel];

    [self.tabBarController.view addSubview:paymentView];
}

- (void)showApplePayErrorAlertWithMessage:(NSString*)message
{
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction* _Nonnull action) {
                                                             [alertController dismissViewControllerAnimated:YES
                                                                                                 completion:nil];
                                                         }];

    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)payWithCard
{
    WebViewController* webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    webViewController.url = _paymentUrl;
    webViewController.title = _paymentTitle;
    [self.navigationController pushViewController:webViewController
                                         animated:YES];
}

#pragma mark - PaymentViewDelegate

- (void)paymentViewCloseButtonDidPress:(PRPaymentView*)paymentView
{
    [paymentView removeFromSuperview];
}

- (void)paymentViewPayWithCardButtonDidPress:(PRPaymentView*)paymentView
{
    [paymentView removeFromSuperview];
    [self payWithCard];
}

- (void)paymentViewPayWithApplePayButtonDidPress:(PRPaymentView*)paymentView
{
    [paymentView removeFromSuperview];

    PRApplePayInfoModel* applePayInfoModel = _paymentDataModel.data;

    PKPaymentRequest* request = [[PKPaymentRequest alloc] init];
    request.supportedNetworks = applePayInfoModel.supportedNetworks;
    request.merchantIdentifier = applePayInfoModel.merchantIdentifier;
    if (!request.merchantIdentifier) {
        [self showApplePayErrorAlertWithMessage:NSLocalizedString(@"ApplePay method is not available for this payment.", nil)];
        return;
    }
    request.merchantCapabilities = applePayInfoModel.merchantCapability;
    request.currencyCode = applePayInfoModel.currencyCode;
    request.countryCode = applePayInfoModel.countryCode;

    NSMutableArray* items = [NSMutableArray array];
    for (PRApplePayItemModel* item in applePayInfoModel.paymentSummaryItems) {
        [items addObject:[PKPaymentSummaryItem summaryItemWithLabel:item.name
                                                             amount:[[NSDecimalNumber alloc] initWithString:item.amount]]];
    }
    [items addObject:[PKPaymentSummaryItem summaryItemWithLabel:kOrganizationName
                                                         amount:[[NSDecimalNumber alloc] initWithString:applePayInfoModel.amount]]]; // Total amount.
    request.paymentSummaryItems = items;

    PKPaymentAuthorizationViewController* paymentViewController = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
    if (paymentViewController) {
        paymentViewController.delegate = self;
        [paymentView removeFromSuperview];
        paymentViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:paymentViewController animated:YES completion:nil];
        return;
    }
}

#pragma mark - PKPaymentAuthorizationViewControllerDelegate

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController*)controller
                       didAuthorizePayment:(PKPayment*)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus status))completion
{
    if (!_paymentID || !payment.token) {
        return;
    }

    PRApplePayToken* applePayToken = [[PRApplePayToken alloc] init];
    applePayToken.paymentUid = _paymentID;
    applePayToken.paymentToken = [payment.token.paymentData base64EncodedStringWithOptions:0];

    __weak RequestsDetailViewController* weakSelf = self;
    [PRRequestManager sendApplePayToken:applePayToken
        view:self.view
        mode:PRRequestMode_ShowNothing
        success:^(PRApplePayResponseModel* applePayResponseModel) {

            RequestsDetailViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            if ([applePayResponseModel.success boolValue] && [applePayResponseModel.paymentResult boolValue]) {
                completion(PKPaymentAuthorizationStatusSuccess);
                return;
            }

            if (![applePayResponseModel.success boolValue] && applePayResponseModel.error) {
                completion(PKPaymentAuthorizationStatusFailure);
                [controller dismissViewControllerAnimated:YES completion:nil];
                [self showApplePayErrorAlertWithMessage:applePayResponseModel.error.errorDescription];
                return;
            }

            completion(PKPaymentAuthorizationStatusFailure);
            [controller dismissViewControllerAnimated:YES completion:nil];
        }
        failure:^(NSInteger statusCode, NSError* error) {

            RequestsDetailViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            completion(PKPaymentAuthorizationStatusFailure);
        }];
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController*)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Sharing

- (void)shareAction
{
    NSArray<__kindof UIViewController*>* objectsToShare = @[ self ];

    UIActivityViewController* activityVC = [[UIActivityViewController alloc]
        initWithActivityItems:objectsToShare
        applicationActivities:nil];
    [self.navigationController presentViewController:activityVC
                                            animated:YES
                                          completion:nil];
}

- (NSString*)activityViewController:(UIActivityViewController*)activityViewController
                itemForActivityType:(NSString*)activityType
{
    NSUInteger twitterLength = 140;
    if (_shareString.length > twitterLength && [activityType isEqualToString:UIActivityTypePostToTwitter]) {
        return [_shareString substringToIndex:twitterLength];
    }

    if ([activityType isEqualToString:@"net.whatsapp.WhatsApp.ShareExtension"]) {
        _shareString = [_shareString stringByReplacingOccurrencesOfString:@"\n"
                                                               withString:@""];
    }
    return _shareString;
}

- (NSString*)activityViewControllerPlaceholderItem:(UIActivityViewController*)activityViewController
{
    return @"";
}

- (NSString*)activityViewController:(UIActivityViewController*)activityViewController subjectForActivityType:(NSString*)activityType
{
    return self.title;
}

#pragma mark - Create Cell

- (UITableViewCell*)createRowSection:(NSUInteger)section
{
    NSString* const kTypeCellIdentifier = [NSString stringWithFormat:@"TypeCell%lu", (unsigned long)section];

    UITableViewCell* cell = [_tableViewRequestDetail dequeueReusableCellWithIdentifier:kTypeCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:kTypeCellIdentifier];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    if (section < [_groups count]) {
        for (UIView* view in [cell subviews]) {
            [view removeFromSuperview];
        }
        [cell addSubview:_cells[section]];
    }
    return cell;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return [_groups count];
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_task items] ? kTableViewRowCountInSection : 0;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == [_groups count]) {
        return 10; // Todo.
    }
    return CGRectGetHeight(((UIView*)_cells[indexPath.section]).bounds);
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return [self createRowSection:indexPath.section];
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    return _groups[section];
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0 ? 0 : kTableViewHeaderHeight;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView*)tableView willDisplayHeaderView:(UIView*)view forSection:(NSInteger)section
{
    const CGFloat kHeaderLayerDefaultValue = 0.26;
    UITableViewHeaderFooterView* header = (UITableViewHeaderFooterView*)view;
    header.layer.borderWidth = kHeaderLayerDefaultValue;
    header.layer.borderColor = kAppTintColor.CGColor;
    [header.layer setShadowColor:kAppPassCodeColor.CGColor];
    [header.layer setShadowOpacity:kHeaderLayerDefaultValue];
    [header.layer setShadowRadius:kHeaderLayerDefaultValue];
    [header.layer setShadowOffset:CGSizeMake(0, kHeaderLayerDefaultValue)];
}

#pragma mark - Requests

- (void)updateRequestDetails
{
    _task = [PRDatabase getTaskDetailById:_taskId];
    if (!_task) {
        return;
    }

    for (PRTaskItemModel* item in _task.items) {
        if ([item.longitude floatValue] != 0 || [item.latitude floatValue] != 0) {
            _taskItemForUber = item;
            _taskLocation = [[CLLocation alloc] initWithLatitude:[_taskItemForUber.latitude floatValue]
                                                       longitude:[_taskItemForUber.longitude floatValue]];
        }
    }

    if ([self hasAllRequiredLocations]) {
        [self initUberActionSheetAndGetEstimates];
    }

    [self getGroups];

    [_tableViewRequestDetail reloadData];

    [self prepareNavigationControllerTitleView];
    [self prepareNavigationBar]; //Todo check chat badge.
}

- (void)openUberProducts
{
    if (![PRRequestManager connectionRequired]) {
        _didNetworkOfflineAlertShow = NO;
        if (_isTaskLocationExist && [[UberManager sharedManager] isUberAvailableInCurrentLocation:_currentLocation forEventLocation:_taskLocation]) {
            if ([[UberManager sharedManager] isUberAvailableAtTime:_task.requestDate]) {
                [self setModalPresentationStyle:UIModalPresentationCurrentContext];

                _uberActionSheet.providesPresentationContextTransitionStyle = YES;
                _uberActionSheet.definesPresentationContext = YES;
                [_uberActionSheet setModalPresentationStyle:UIModalPresentationOverCurrentContext];

                [self presentViewController:_uberActionSheet
                                   animated:NO
                                 completion:^{
                                     [_uberActionSheet showAnimated];
                                 }];
                return;
            }

            [PRMessageAlert showToastWithMessage:Message_UberTimeIsExpired];
            [self dataLoading:PRRequestMode_ShowNothing];
            return;
        }

        [self dataLoading:PRRequestMode_ShowNothing];
        return;
    }

    [self refreshUberField];
    if (!_didNetworkOfflineAlertShow) {
        [PRMessageAlert showToastWithMessage:Message_InternetConnectionOffline];
        _didNetworkOfflineAlertShow = YES;
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager*)manager didUpdateLocations:(nonnull NSArray<CLLocation*>*)locations
{
    CLLocation* newLocation = [locations lastObject];

    if ([newLocation.timestamp timeIntervalSinceDate:_locationManagerStartDate] <= 0) {
        return;
    }

    if (_currentLocation) {
        double distance = [_currentLocation distanceFromLocation:newLocation];
        if (distance < kMinDistanceToUpdateLocation || [newLocation.timestamp timeIntervalSinceDate:_currentLocation.timestamp] <= 0) {
            return;
        }
    }

    _currentLocation = newLocation;

    if ([self hasAllRequiredLocations]) {
        [self initUberActionSheetAndGetEstimates];
        return;
    }

    [self getGroups];
    [_tableViewRequestDetail reloadData];
}

- (void)locationManager:(CLLocationManager*)manager didFailWithError:(NSError*)error
{
    _currentLocation = nil;

    [self getGroups];
    [_tableViewRequestDetail reloadData];
}

#pragma mark - Task Requirements

- (BOOL)hasAllRequiredLocations
{
    _isTaskLocationExist = NO;
    for (PRTaskItemModel* item in _task.items) {
        if ([item.longitude integerValue] != 0 || [item.latitude integerValue] != 0) {
            _isTaskLocationExist = YES;
        }
    }
    return (_currentLocation.coordinate.latitude && _currentLocation.coordinate.longitude
        && _isTaskLocationExist && [[UberManager sharedManager] isUberAvailableInCurrentLocation:_currentLocation forEventLocation:_taskLocation]);
}

#pragma mark - PRUberActionSheetDelegate

- (void)uberActionSheetDidClose
{
    if (![PRRequestManager connectionRequired]) {
        if (_isTaskLocationExist &&
            [[UberManager sharedManager] isUberAvailableInCurrentLocation:_currentLocation
                                                         forEventLocation:_taskLocation]
            && ![[UberManager sharedManager] isUberAvailableAtTime:_task.requestDate]) {
            [PRMessageAlert showToastWithMessage:Message_UberTimeIsExpired];
        }

        [self dataLoading:PRRequestMode_ShowNothing];
        return;
    }

    [PRMessageAlert showToastWithMessage:Message_InternetConnectionOffline];
    _didNetworkOfflineAlertShow = YES;
    [self refreshUberField];
}

@end
