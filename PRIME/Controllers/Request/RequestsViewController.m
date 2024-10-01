//
//  RequestsViewController.m
//  PRIME
//
//  Created by Simon on 1/30/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "CategoriesViewController.h"
#import "Constants.h"
#import "CreateRequestViewController.h"
#import "DateTableViewSectionHeader.h"
#import "PRTaskCell.h"
#import "RequestsDetailViewController.h"
#import "RequestsViewController.h"
#import "UIView+Badge.h"
#import "WebViewController.h"
#import "XNTLazyManager.h"
#import "PRTaskDocumentManager.h"
#import "PRPaymentView.h"
#import "PRPaymentDataModel.h"
#import <PassKit/PassKit.h>
#import "RequestTableViewCell.h"
#import "PRUserDefaultsManager.h"
#import "Utils.h"
#import "PRUINavigationController.h"
#import "ChatViewController.h"

#if defined(Prime)
#import "_Art_Of_Life_-Swift.h"
#elif defined(PrimeClubConcierge)
#import "PrimeClubConcierge-Swift.h"
#elif defined(Imperia)
#import "IMPERIA-Swift.h"
#elif defined(PondMobile)
#import "Pond Mobile-Swift.h"
#elif defined(Raiffeisen)
#import "Raiffeisen-Swift.h"
#elif defined(VTB24)
#import "PrimeConcierge-Swift.h"
#elif defined(Ginza)
#import "Ginza-Swift.h"
#elif defined(FormulaKino)
#import "Formula Kino-Swift.h"
#elif defined(Platinum)
#import "Platinum-Swift.h"
#elif defined(Skolkovo)
#import "Skolkovo-Swift.h"
#elif defined(PrimeConciergeClub)
#import "Tinkoff-Swift.h"
#elif defined(PrivateBankingPRIMEClub)
#import "PrivateBankingPRIMEClub-Swift.h"
#elif defined(PrimeRRClub)
#import "PRIME RRClub-Swift.h"
#elif defined(Davidoff)
#import "Davidoff-Swift.h"
#endif

@interface RequestsViewController () <PaymentViewDelegate, PKPaymentAuthorizationViewControllerDelegate> {
    XNTLazyManager* _lazyManager;
}

@property (strong, nonatomic) UIView* titleView;
@property (strong, nonatomic) NSString* paymentID;
@property (strong, nonatomic) NSString* paymentUrl;
@property (strong, nonatomic) PRTaskDetailModel* taskForPayment;
@property (strong, nonatomic) PRPaymentDataModel* paymentDataModel;
@property (strong, nonatomic) UITableView* requestsTableView;

@property (weak, nonatomic) IBOutlet UIImageView* backgroundImageView;
@property (weak, nonatomic) IBOutlet UITableView* groupedTableView;
@property (weak, nonatomic) IBOutlet UITableView* plainTableView;

@end

static const CGFloat kHeightForHeader = 24.0f;
static const CGFloat kTitleViewHeight = 30.0f;
static const CGFloat kTitleViewWidth = 230.0f;
static const CGFloat kTitleViewWidthForIPhone5 = 220.0f;
static const CGFloat kSeparatorLineHeight = 0.5f;

@implementation RequestsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupTableView];

    [PRDatabase removeExpiredRequests];
    [self updateDataSource];
    [self setupBackgroundImageView];

    [self prepareNavigationRightButton];

#ifdef NEW_IMPLEMENTATION
    [self prepareNavigationLeftButton];
#endif

    _pullToRefreshView = [[SSPullToRefreshView alloc] initWithScrollView:_requestsTableView
                                                                delegate:self];

    self->_lazyManager = [[XNTLazyManager alloc] initWithObserver:self
                                                         selector:@selector(reachabilityChanged:)];

    if (_filterForKey != RequestsFilter_Non) {
        return;
    }

    if (!_reservesOrRequestsSegmentedControl) {
        [self createReservesOrRequestsSegmentedControl];
    }
}

- (void)createReservesOrRequestsSegmentedControl
{
    NSArray<NSString*>* itemArray = [NSArray arrayWithObjects:@"In progress", @"Completed", nil];

    CGFloat width = (IS_IPHONE_5 && SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(11)) ? kTitleViewWidthForIPhone5 : kTitleViewWidth;
    _titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, kTitleViewHeight)];
    self.navigationItem.titleView = _titleView;

    _reservesOrRequestsSegmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
    _reservesOrRequestsSegmentedControl.frame = _titleView.frame;
    [_reservesOrRequestsSegmentedControl addTarget:self action:@selector(filterRequest:) forControlEvents:UIControlEventValueChanged];
    _reservesOrRequestsSegmentedControl.selectedSegmentIndex = (_reservesOrRequestsSegmentedControl.selectedSegmentIndex > 0) ?: PRRequestSegment_InProgress;
    [_titleView addSubview:_reservesOrRequestsSegmentedControl];

    _reservesOrRequestsSegmentedControl.tintColor = kReservesOrRequestsSegmentColor;
    _reservesOrRequestsSegmentedControl.backgroundColor = [self getNavigationBarColor];
#if defined(VTB24) || defined(Raiffeisen) || defined(PrivateBankingPRIMEClub)
    [_reservesOrRequestsSegmentedControl ensureiOS12Style];
#endif
    [_reservesOrRequestsSegmentedControl setTitle:NSLocalizedString(@"Completed", nil) forSegmentAtIndex:1];
    [_reservesOrRequestsSegmentedControl setTitle:NSLocalizedString(@"In progress", nil) forSegmentAtIndex:0];
    _reservesOrRequestsSegmentedControl.hidden = NO;
    _titleView.badgeValue = [NSString stringWithFormat:@"%lu", _reservesOrRequestsSegmentedControl.selectedSegmentIndex == PRRequestSegment_Completed ? 0 : (long)[PRDatabase ordersCount]];
    [_titleView bringSubviewToFront:_titleView.badge];
    [_titleView setBadgeBGColor:kBadgeBackgroundColor];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadVisibleCells)
                                                 name:kMessageReceived
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadVisibleCells)
                                                 name:kUnseenMessageUpdate
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

#if defined(PrivateBankingPRIMEClub)
    [(PRUINavigationController*)self.navigationController setNavigationBarColor:kTabBarBackgroundColor];
#endif

    [PRGoogleAnalyticsManager sendEventWithName:kRequestTabOpened parameters:nil];
    // Deselect table view rows.
    [_requestsTableView deselectRowAtIndexPath:[_requestsTableView indexPathForSelectedRow] animated:NO];
}

- (void)reloadVisibleCells
{
    [_requestsTableView reloadData];
}

- (void)noDataLabel
{
    if (_labelNoData != nil) {
        return;
    }
    _labelNoData = [[UILabel alloc] init];
    _labelNoData.text = NSLocalizedString(kNoRequestsLabelTitle, nil);
    [_requestsTableView addSubview:_labelNoData];
    CGRect frame = _requestsTableView.bounds;
    _labelNoData.frame = frame;
    _labelNoData.textColor = kAppLabelColor;
    _labelNoData.textAlignment = NSTextAlignmentCenter;
    _labelNoData.hidden = YES;
}

- (void)setupBackgroundImageView
{
    if (kRequestsBackgroundImage) {
        [_requestsTableView setBackgroundColor:[UIColor clearColor]];
        [_labelNoData setBackgroundColor:[UIColor clearColor]];
        [_backgroundImageView setImage:[UIImage imageNamed:kRequestsBackgroundImage]];
        _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        _backgroundImageView.clipsToBounds = YES;
    }
}

- (void)refresh
{
    [_pullToRefreshView startLoading];

    [self->_lazyManager shouldBeRefreshedWithDate:[NSDate date]
        relativeToDate:nil
        then:^(PRRequestMode mode) {
            __weak id weakSelf = self;
            [PRRequestManager getTasksWithView:self.view
                mode:mode
                success:^() {
                    RequestsViewController* strongSelf = weakSelf;
                    if (!strongSelf) {
                        return;
                    }

                    [strongSelf updateRequestsListByFilter];
                    [strongSelf saveTaskDocuments];
                    [strongSelf.pullToRefreshView finishLoading];
                }
                failure:^{
                    RequestsViewController* strongSelf = weakSelf;
                    if (!strongSelf) {
                        return;
                    }

                    [strongSelf.pullToRefreshView finishLoading];
                }];
        }
        otherwise:^{
            [_pullToRefreshView finishLoading];
        }];
}

- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView*)view
{
    [self refresh];
}

- (void)viewDidLayoutSubviews
{
    if (_pullToRefreshView != nil) {
        return;
    }
    _pullToRefreshView = [[SSPullToRefreshView alloc] initWithScrollView:_requestsTableView delegate:self];
}

// Called by Reachability whenever status changes.
- (void)reachabilityChanged:(NSNotification*)note
{
    __weak id weakSelf = self;
    [self->_lazyManager shouldBeUpdatedIfReachabilityChangedWithNotification:note
                                                                        date:[NSDate date]
                                                              relativeToDate:nil
                                                                        then:^(PRRequestMode mode) {
                                                                            [PRRequestManager getTasksWithView:self.view
                                                                                                          mode:mode
                                                                                                       success:^() {
                                                                                                           RequestsViewController* strongSelf = weakSelf;
                                                                                                           if (!strongSelf) {
                                                                                                               return;
                                                                                                           }
                                                                                                           [strongSelf updateRequestsListByFilter];
                                                                                                           [strongSelf saveTaskDocuments];
                                                                                                       }
                                                                                                       failure:nil];
                                                                        }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self noDataLabel];

    __weak id weakSelf = self;
    [self->_lazyManager shouldBeUpdatedIfViewDidAppearWithDate:[NSDate date]
        relativeToDate:nil
        then:^(PRRequestMode mode) {
            RequestsViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            BOOL needShowProgress = NO;
            [PRRequestManager getTasksWithView:strongSelf.view
                                          mode:needShowProgress ? mode : PRRequestMode_ShowNothing
                                       success:^() {
                                           [strongSelf updateRequestsListByFilter];
                                           [strongSelf saveTaskDocuments];
                                       }
                                       failure:nil];
        }
        otherwiseIfFirstTime:^{
            RequestsViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            [strongSelf updateRequestsListByFilter];
        }
        otherwise:^{

        }];
}

- (void)prepareNavigationRightButton
{
    if (_filterForKey != RequestsFilter_Non) {
        return;
    }
    UIImage* imageSettings = [[UIImage imageNamed:@"menu"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    CGRect frame = CGRectMake(0, 0, imageSettings.size.width, imageSettings.size.height);
    UIButton* buttonSettings = [[UIButton alloc] initWithFrame:frame];
    [buttonSettings setBackgroundImage:imageSettings forState:UIControlStateNormal];
    [buttonSettings setShowsTouchWhenHighlighted:NO];
#ifdef VTB24
    [buttonSettings setTintColor:kNavigationBarTintColor];
#else
    [buttonSettings setTintColor:kSegmentedControlTaskStatusColor];
#endif
    [buttonSettings addTarget:self action:@selector(openMenu) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* barButtonItemSettings = [[UIBarButtonItem alloc] initWithCustomView:buttonSettings];

    self.navigationItem.rightBarButtonItem = barButtonItemSettings;
}

#ifdef NEW_IMPLEMENTATION

- (void)prepareNavigationLeftButton
{
    if (_filterForKey != RequestsFilter_Non) {
        return;
    }
    UIImage* imageSettings = [UIImage imageNamed:@"add_task"];
    CGRect frame = CGRectMake(0, 0, imageSettings.size.width, imageSettings.size.height);

    UIButton* buttonSettings = [[UIButton alloc] initWithFrame:frame];
    [buttonSettings setBackgroundImage:imageSettings forState:UIControlStateNormal];
    [buttonSettings setShowsTouchWhenHighlighted:NO];

    [buttonSettings addTarget:self action:@selector(addTask) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* barButtonItemSettings = [[UIBarButtonItem alloc] initWithCustomView:buttonSettings];

    self.navigationItem.leftBarButtonItem = barButtonItemSettings;
}

#endif //NEW_IMPLEMENTATION

- (void)openMenu
{
    [PRGoogleAnalyticsManager sendEventWithName:kCategoriesMenuButtonClicked parameters:nil];
    CategoriesViewController* categoriesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CategoriesViewController"];
    [self.navigationController pushViewController:categoriesViewController animated:YES];
}

- (void)addTask
{
    CreateRequestViewController* requestViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateRequestViewController"];
    [self.navigationController pushViewController:requestViewController animated:YES];
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    id sectionInfo = [_requestDataSource sectionInfo:section];
    NSString* name = [sectionInfo name];
    BOOL isTableViewHasGroupedStyle = ([tableView style] == UITableViewStyleGrouped);

    NSString* sectionTitle = [[Utils stringFromDateString:name] uppercaseString];

    DateTableViewSectionHeader* headerView = [[DateTableViewSectionHeader alloc] init:tableView withSectionTitle:sectionTitle andTitlePositionFromLeft:64.0f];
    headerView.backgroundColor = isTableViewHasGroupedStyle ? [UIColor clearColor] : kTasksHeaderColor;

    // "count" greater than 1 only when selected 'InProgress' tab and in that case the first fetchedResultsController contains 'To Pay' requests.
    if ([_requestDataSource.fetchedResultsControllers count] > 1) {
        NSInteger toPayRequestsSectionsCount = [[[_requestDataSource.fetchedResultsControllers firstObject] sections] count];
        if (section < toPayRequestsSectionsCount) {
            headerView.backgroundColor = isTableViewHasGroupedStyle ? kToPayRequestTransparentBackgroundColor : kToPayRequestBackgroundColor;
        }
    }

    return headerView;
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return kHeightForHeader;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    id<PRTaskCell> cell = (id<PRTaskCell>)[tableView cellForRowAtIndexPath:indexPath];

    PRTaskDetailModel* taskDetail = [PRDatabase getTaskDetailById:[cell taskId]];
    NSString* channelId = [kChatPrefix stringByAppendingString:taskDetail.chatId.stringValue];
    NSInteger unseenMessagesCount = [PRDatabase requestsUnseenMessagesCountFromSubscriptionsForChannelId: channelId];

    if (unseenMessagesCount > 0) {
        [self openChatForChannel:taskDetail.chatId.stringValue];
        return;
    }

    [PRGoogleAnalyticsManager sendEventWithName:kRequestDetailsPageOpened parameters:nil];
    [self openRequestDetails:[cell taskId] andRequestDate:[cell requestDate] withAnimation:YES];
}

- (UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section
{
    UIView* lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), kSeparatorLineHeight)];
    lineView.backgroundColor = kLineColor;

    return lineView;
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat lineHeight = CGFLOAT_MIN;
    for (NSIndexPath* obj in [_requestDataSource extraLinesPosition]) {
        if (obj.section == section) {
            lineHeight = kSeparatorLineHeight;
        }
    }

    return lineHeight;
}

- (void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    UIColor* backgroundColor = kToPayRequestBackgroundColor;

    if ([tableView style] == UITableViewStyleGrouped) {
        backgroundColor = kToPayRequestTransparentBackgroundColor;
        NSInteger rowsCount = [[_requestDataSource sectionInfo:indexPath.section] numberOfObjects];

        if ([cell respondsToSelector:@selector(setSeparatorLineHidden:)]) {
            id<PRCellWithCustomSeparator> tempCell = (id)cell;
            [tempCell setSeparatorLineHidden:YES];

            if (rowsCount > 1 && indexPath.row != (rowsCount - 1)) {
                [tempCell setSeparatorLineHidden:NO];
            }
        }
    }

    if ([cell isKindOfClass:[RequestTableViewCell class]] && !_filterById) {
        [cell setBackgroundColor:backgroundColor];
    }
}

- (RequestsDetailViewController*)openRequestDetails:(NSNumber*)taskId
                                     andRequestDate:(NSDate*)requestDate
                                      withAnimation:(BOOL)animation
{
    RequestsDetailViewController* requestsDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RequestsDetailViewController"];

    NSAssert(requestsDetailViewController, nil);

    requestsDetailViewController.taskId = taskId;
    requestsDetailViewController.requestDate = requestDate;

    [self.navigationController pushViewController:requestsDetailViewController animated:animation];

    return requestsDetailViewController;
}

- (void)updateRequestsWithSegment:(NSInteger)segment
{
    if (!_reservesOrRequestsSegmentedControl) {
        [self createReservesOrRequestsSegmentedControl];
    }

    [_reservesOrRequestsSegmentedControl setSelectedSegmentIndex:segment];
    if (segment != PRRequestSegment_InProgress) {
        [self updateDataSource];
    }
}

#pragma mark - Save Task Documents

- (void)saveTaskDocuments
{
    NSArray<PRTaskDetailModel*>* allObjects = [PRDatabase getTasksForTodayAndTomorrow].fetchedObjects;

    for (PRTaskDetailModel* model in allObjects) {

        __weak id weakSelf = self;
        [PRRequestManager getTaskWithId:model.taskId
                                   view:self.view
                                   mode:PRRequestMode_ShowNothing
                                success:^(PRTaskDetailModel* task) {

                                    RequestsViewController* strongSelf = weakSelf;
                                    if (!strongSelf) {
                                        return;
                                    }

                                    [PRTaskDocumentManager saveDocumentsForTask:task withView:self.view];
                                }
                                failure:^{

                                }];
    }
}

#pragma mark - Private functions

- (void)setupTableView
{
#if defined(Otkritie)
    _requestsTableView = _groupedTableView;
    [_plainTableView setHidden:YES];
#else
    _requestsTableView = _plainTableView;
    [_backgroundImageView setHidden:YES];
    [_groupedTableView setHidden:YES];
#endif

    _requestsTableView.delegate = self;
    _requestsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)reloadRequests
{
    [_requestsTableView reloadData];
}

- (void)updateDataSource
{

    [[PRUserDefaultsManager sharedInstance] setWidgetRequests];
    if (_filterById) {
        NSFetchedResultsController* result = [PRDatabase getTasksForId:_filterById];
        _requestDataSource = [[RequestDataSource alloc] initWithFetchedResultsForRequest:@[ result ] payButtonDelegate:self];
    } else {
        switch (_reservesOrRequestsSegmentedControl.selectedSegmentIndex) {
        case PRRequestSegment_InProgress: {
            [PRGoogleAnalyticsManager sendEventWithName:kRequestSegmentInProgressClicked parameters:nil];
            _requestDataSource = [[RequestDataSource alloc] initWithFetchedResultsForRequest:@[ [PRDatabase getTasksNeedToPay], [PRDatabase getTasksOpened] ] payButtonDelegate:self];
        } break;
        case PRRequestSegment_Completed:
            [PRGoogleAnalyticsManager sendEventWithName:kRequestSegmentCompletedClicked parameters:nil];
            _titleView.badgeValue = 0;
            _requestDataSource = [[RequestDataSource alloc] initWithFetchedResultsForRequest:@[ [PRDatabase getTasksClosed] ] payButtonDelegate:self];
            break;
        default:
            break;
        }
    }
    _labelNoData.hidden = ([_requestDataSource rowsCount] != 0);

    _requestsTableView.dataSource = _requestDataSource;
    [_requestsTableView reloadData];
}

- (void)updateRequestsListByFilter
{
    [PRDatabase removeExpiredRequests];
    [self updateDataSource];

    [(PRUITabBarController*)self.tabBarController showBadge];

    [self reloadRequests];

    _titleView.badgeValue = [NSString stringWithFormat:@"%lu", _reservesOrRequestsSegmentedControl.selectedSegmentIndex == PRRequestSegment_Completed ? 0 :(long)[PRDatabase ordersCount]];
}

- (void)pay:(NSString*)paymentLink withSender:(id)sender
{
    _paymentUrl = paymentLink;
    [self payWithCard];
}

#pragma mark - Payment

- (void)getPaymentInformation
{
    if (!_paymentID) {
        [self payWithCard];
        return;
    }

    __weak RequestsViewController* weakSelf = self;
    [PRRequestManager getApplePayOrderInfoWithPaymentID:_paymentID
        view:self.view
        mode:PRRequestMode_ShowOnlyProgress
        success:^(PRPaymentDataModel* paymentDataModel) {

            RequestsViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            strongSelf.paymentDataModel = paymentDataModel;

            // Continue only if status is not "Paid" or "Canceled".
            if ([strongSelf.paymentDataModel.data.status integerValue] == 1 && [strongSelf.paymentDataModel.data.status integerValue] == 3) {
                return;
            }

            if (![PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:strongSelf.paymentDataModel.data.supportedNetworks]) {
                [strongSelf payWithCard];
                return;
            }

            // Show payment view with payment information.
            [strongSelf showPaymentViewWithTaskDetails:strongSelf.taskForPayment];
        }
        failure:^{

            RequestsViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            [strongSelf payWithCard];
        }];
}

- (void)showPaymentViewWithTaskDetails:(PRTaskDetailModel*)taskDetails
{
    PRPaymentView* paymentView = [[[NSBundle mainBundle] loadNibNamed:@"PRPaymentView"
                                                                owner:self
                                                              options:nil] objectAtIndex:0];
    [paymentView setFrame:[[UIScreen mainScreen] bounds]];
    [paymentView setDelegate:self];
    [paymentView setupViewWithTask:taskDetails
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
    webViewController.title = NSLocalizedString(@"Pay", );
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

    __weak RequestsViewController* weakSelf = self;
    [PRRequestManager sendApplePayToken:applePayToken
        view:self.view
        mode:PRRequestMode_ShowNothing
        success:^(PRApplePayResponseModel* applePayResponseModel) {

            RequestsViewController* strongSelf = weakSelf;
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

            RequestsViewController* strongSelf = weakSelf;
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

#pragma mark - Actions

- (IBAction)filterRequest:(UISegmentedControl*)sender
{
    [self updateDataSource];
}

- (IBAction)filterTaskStatus:(UISegmentedControl*)sender
{
    [self updateDataSource];
}

- (void)updateViewController
{
    [self.navigationController popToRootViewControllerAnimated:NO];

    [_reservesOrRequestsSegmentedControl setSelectedSegmentIndex:(_reservesOrRequestsSegmentedControl.selectedSegmentIndex > 0) ?: PRRequestSegment_InProgress];

    [_reservesOrRequestsSegmentedControl sendActionsForControlEvents:UIControlEventValueChanged];

    NSLog(@"Starting update view controller %@", self.class);
}

- (void)dealloc
{

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)openChatForChannel:(NSString*)channelId
{
    ChatViewController* viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
    viewController.chatId = channelId;

    [self.navigationController pushViewController:viewController
                                         animated:YES];
}

@end
