//
//  CalendarViewController.m
//  PRIME
//

//  Created by Simon on 1/29/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "CalendarViewController.h"
#import "NotificationManager.h"
#import "PRTaskCell.h"
#import "RequestsDetailViewController.h"
#import "UberManager.h"
#import "WebSocketManager.h"
#import "XNTLazyManager.h"

#import "RequestDataSource.h"
#import "PRTaskDocumentManager.h"
#import "PRPaymentView.h"
#import "WebViewController.h"
#import "DateTableViewSectionHeader.h"
#import "Utils.h"
#import "PRCellWithCustomSeparator.h"
#import "PRCalendarEventManager.h"
#import "PRUserDefaultsManager.h"
#import "UINavigationBar+Addition.h"

static const CGFloat kMonthViewHeight = 80.0f;
static const CGFloat kCalendarOpenAnimationDuration = 0.5f;
static const CGFloat kCalendarPanAnimationDuration = 0.3f;
static const CGFloat kNoDataLabelHeight = 20.0f;
static const CGFloat kHeaderHeight = 24.0f;
static const CGFloat kHeaderPositionFromLeft = 64.0f;
static const CGFloat kTableviewCellHeight = 55.0f;
static NSString* const kArrowUpImageName = @"Calendar_arrowUp";
static NSString* const kArrowDownImageName = @"Calendar_arrowDown";
static NSString* const kTodayButtonImageName = @"calendar_today";

typedef NS_ENUM(NSInteger, PRDateCompareFormat) {
    PRDateCompareFormat_None,
    PRDateCompareFormat_ByDay,
    PRDateCompareFormat_ByMonth
};

typedef NS_ENUM(NSInteger, PRCalendarState) {
    PRCalendarState_Closed,
    PRCalendarState_Opened
};

@interface CalendarViewController () <CLLocationManagerDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, PKPaymentAuthorizationViewControllerDelegate, PRPayButtonDelegate, PaymentViewDelegate>

@property (assign, nonatomic) BOOL isViewVisible;
@property (assign, nonatomic) BOOL isCalendarOpened;
@property (assign, nonatomic) BOOL isScrollingBegan;
@property (assign, nonatomic) NSInteger calendarHeight;
@property (assign, nonatomic) CGFloat calendarPositionOpened;
@property (assign, nonatomic) CGFloat calendarPositionClosed;
@property (assign, nonatomic) CGFloat tableViewEmptySpaceHeight;
@property (strong, nonatomic) NSDate* calendarStartDate;
@property (strong, nonatomic) UIPanGestureRecognizer* calendarPanGesture;
@property (strong, nonatomic) XNTLazyManager* lazyManager;
@property (strong, nonatomic) NSDate* dateToSelect;
@property (strong, nonatomic) RequestDataSource* requestDataSource;
@property (strong, nonatomic) NSFetchedResultsController* fetchedResultsController;

@property (strong, nonatomic) NSString* paymentID;
@property (strong, nonatomic) NSString* paymentUrl;
@property (strong, nonatomic) PRTaskDetailModel* taskForPayment;
@property (strong, nonatomic) PRPaymentDataModel* paymentDataModel;

@property (weak, nonatomic) IBOutlet UIView* statusBarBackgroundView;
@property (weak, nonatomic) IBOutlet JTCalendarContentView* calendarView;
@property (weak, nonatomic) IBOutlet UITableView* requestsTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* calendarHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView* arrowImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* calendarTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel* monthLabel;
@property (weak, nonatomic) IBOutlet UIView* monthContainerView;
@property (weak, nonatomic) IBOutlet UIButton* todayButton;
@property (weak, nonatomic) IBOutlet UIView *navigationBarBackgroundView;

@end

@implementation CalendarViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [_todayButton setImage:[[UIImage imageNamed:kTodayButtonImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [_arrowImageView setImage:[[UIImage imageNamed:kArrowUpImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [_arrowImageView setTintColor:kCalendarTodayButtonColor];
    [_todayButton setTintColor:kCalendarTodayButtonColor];
    [self createCalendar];
    [_monthLabel setText:[self getCurrentMonth]];
    _requestsTableView.delegate = self;
    _requestsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _lazyManager = [[XNTLazyManager alloc] initWithObserver:self
                                                   selector:@selector(reachabilityChanged:)];

    _calendarStartDate = _calendar.currentDate;
    _tableViewEmptySpaceHeight = CGFLOAT_MIN;

    [self updateRequests];
    [self setupTableViewByDate:_calendar.currentDate];
    [_requestsTableView reloadData];
    [self scrollTableViewToItemWithDate:_calendar.currentDate];

#if defined(Raiffeisen)
    _statusBarBackgroundView.backgroundColor = kNavigationBarBarTintColor;
    _navigationBarBackgroundView.backgroundColor = kNavigationBarBarTintColor;
    _monthLabel.textColor = kAquamarineColor;
#elif defined(VTB24)
    _statusBarBackgroundView.backgroundColor = kVTBBlackColor;
    _navigationBarBackgroundView.backgroundColor = kVTBBlackColor;
#elif defined(PrivateBankingPRIMEClub)
    self.statusBarBackgroundView.backgroundColor = kGazprombankMainColor;
    self.navigationBarBackgroundView.backgroundColor = kGazprombankMainColor;
    self.monthLabel.textColor = kWhiteColor;
    self.monthLabel.font = [UIFont boldSystemFontOfSize:17];
#endif

    [self registerForNotifications];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadRequests];

    [PRGoogleAnalyticsManager sendEventWithName:kCalendarTabOpened parameters:nil];
    // Deselect table view rows.
    [_requestsTableView deselectRowAtIndexPath:[_requestsTableView indexPathForSelectedRow] animated:NO];
    [self.navigationController setNavigationBarHidden:YES animated:animated];

#if defined (VTB24)
    [UINavigationBar setStatusBarBackgroundColor:kNavigationBarBarTintColor];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
#endif
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _isViewVisible = YES;

    if (_dateToSelect) {
        [self scrollTableViewToItemWithDate:_calendar.currentDate];
        _dateToSelect = nil;
    }

    static dispatch_once_t once;

    dispatch_once(&once, ^{
        [self noDataLabel];
    });

    __weak id weakSelf = self;
    [self->_lazyManager shouldBeUpdatedIfViewDidAppearWithDate:[NSDate date]
        relativeToDate:nil
        then:^(PRRequestMode mode) {
            CalendarViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            BOOL needShowProgress = NO;
            [PRRequestManager getTasksWithView:strongSelf.view
                                          mode:needShowProgress ? mode : PRRequestMode_ShowNothing
                                       success:^() {
                                           [PRDatabase removeExpiredRequests];
                                           [strongSelf updateRequests];
                                           [strongSelf saveTaskDocuments];
                                       }
                                       failure:nil];
        }
        otherwiseIfFirstTime:^{
            CalendarViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            [strongSelf updateRequests];
        }
        otherwise:^{

        }];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [_calendar repositionViews];
}

- (void)viewDidDisappear:(BOOL)animated
{
    _isViewVisible = NO;
    [super viewDidDisappear:animated];
}

#pragma mark - Calendar

- (void)noDataLabel
{
    if (_labelNoData == nil) {
        _labelNoData = [UILabel new];
        _labelNoData.text = NSLocalizedString(@"No events", nil);
        [_requestsTableView addSubview:_labelNoData];
        _labelNoData.frame = CGRectMake(0, 8, CGRectGetWidth(_requestsTableView.frame), kNoDataLabelHeight);
        _labelNoData.textColor = kAppLabelColor;
        _labelNoData.textAlignment = NSTextAlignmentCenter;
        _labelNoData.hidden = YES;
    }
}

- (void)createCalendar
{
    UIFont* const kDayTextFont = [UIFont systemFontOfSize:12];
    _calendar = [JTCalendar new];
    _monthLabel.font = [UIFont systemFontOfSize:20];
    _monthLabel.textColor = kTabBarBackgroundColor;
    _calendar.calendarAppearance.dayDotRatio = 1. / 5;
    _calendar.calendarAppearance.dayCircleRatio = 1.15;
    _calendar.calendarAppearance.dayTextFont = kDayTextFont;
    _calendar.calendarAppearance.dayTextFontSelected = kDayTextFont;
    _calendar.calendarAppearance.dayTextFontToday = kDayTextFont;
    _calendar.calendarAppearance.weekDayTextFont = kDayTextFont;
    [_calendar.calendarAppearance setDayDotColorForAll:kCalendarDotColor];
    _calendar.calendarAppearance.weekDayTextColor = _calendar.calendarAppearance.dayTextColorOtherMonth;
    _calendar.calendarAppearance.dayCircleColorSelected = kCalendarSelectedDayCircleColor;
    _calendar.calendarAppearance.dayCircleColorToday = kCalendarTodayCircleColor;
    _calendar.calendarAppearance.dayTextColorSelected = kCalendarSelectedDayTextColor;
    _calendar.calendarAppearance.dayCircleColorSelectedOtherMonth = kCalendarDayCircleColorSelectedOtherMonth;
    _calendar.calendarAppearance.weekDayFormat = JTCalendarWeekDayFormat_Single;
    _calendar.calendarAppearance.lineColor = kCalendarLineColor;
    _calendar.calendarAppearance.weekDayBackgroundColor = kCalendarWeekDayBackgroundColor;
    _calendar.calendarAppearance.ratioContentMenu = 1.0;
    _calendar.calendarAppearance.autoChangeMonth = NO;
    _calendar.calendarAppearance.isWeekMode = NO;
    _calendar.calendarAppearance.calendar.firstWeekday = 2; // Monday.
    [_calendar setContentView:_calendarView];
    [_calendar setDataSource:self];

    [self setCalendarHeight];
    [self addGestureRecognizers];

    if (_dateToSelect) {
        _calendar.currentDateSelected = _dateToSelect;
        _calendar.currentDate = _dateToSelect;
        return;
    }

    [self setDefaultDayForMonth];
}

- (void)setDefaultDayForMonth
{
    NSDate* currentDate = [NSDate new];

    if ([_calendar.currentDate mt_isWithinSameMonth:currentDate]) {
        _calendar.currentDateSelected = currentDate;
    } else {
        _calendar.currentDateSelected = [_calendar.currentDate mt_startOfCurrentMonth];
    }

    _calendar.currentDate = _calendar.currentDateSelected;
    [self scrollTableViewToItemWithDate:_calendar.currentDate];
}

- (void)setCalendarSelectedDateToDate:(NSDate*)date
{
    if (!date) {
        return;
    }

    if (!_calendar) {
        _dateToSelect = date;
        return;
    }

    [self setupTableViewByDate:date];
    [_requestsTableView reloadData];

    _dateToSelect = nil;
    _calendarStartDate = date;
    _calendar.currentDateSelected = date;
    _calendar.currentDate = date;

#if defined(Otkritie)
    [_monthLabel setText:[self textForDateLabel:date]];
#else
    [_monthLabel setText:[self getCurrentMonth]];
#endif

    [self scrollTableViewToItemWithDate:_calendar.currentDate];
}

- (void)setCalendarSelectedIdToDate:(NSNumber*)taskId
{
    if (!taskId) {
        return;
    }
    PRTaskDetailModel* request = [PRDatabase getTaskDetailById:taskId];
    [self setCalendarSelectedDateToDate:request.requestDate];
}

- (NSString*)getCurrentMonth
{
    NSDate* currentDate = _calendar.currentDate;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitMonth fromDate:currentDate];

    NSInteger monthNumber = [components month];
    NSString* dateString = [NSString stringWithFormat:@"%ld", (long)monthNumber];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM"];
    NSDate* myDate = [dateFormatter dateFromString:dateString];

    [dateFormatter setDateFormat:@"LLLL"];
    NSString* monthName = [dateFormatter stringFromDate:myDate];

#if defined(PrivateBankingPRIMEClub)
    return [monthName uppercaseString];
#endif

    return monthName;
}

- (NSString*)getMonthFromDate:(NSDate*)date
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitMonth fromDate:date];

    NSInteger monthNumber = [components month];
    NSString* dateString = [NSString stringWithFormat:@"%ld", (long)monthNumber];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM"];
    NSDate* myDate = [dateFormatter dateFromString:dateString];

    [dateFormatter setDateFormat:@"LLLL"];
    NSString* monthName = [dateFormatter stringFromDate:myDate];

    return monthName;
}

- (NSString *)textForDateLabel:(NSDate*)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSString* currentYear = [formatter stringFromDate:[NSDate date]];
    NSString* calendarYear = [formatter stringFromDate:date];
    if ([currentYear isEqualToString:calendarYear]) {
        return [NSString stringWithFormat:@"%@",[self getCurrentMonth]];
    }
    return [NSString stringWithFormat:@"%@ %@",[self getMonthFromDate:date],calendarYear];
}

- (void)addGestureRecognizers
{
   UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openCalendar)];
   [_monthContainerView addGestureRecognizer:tapGesture];

   UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveCalendar:)];
   panGesture.delegate = self;
   [_monthContainerView addGestureRecognizer:panGesture];
}

- (void)setCalendarHeight
{
    const CGFloat kScreenHeightInStoryBoard = 618;
    const CGFloat kCalendarHeightInStoryBoard = 250;
    const CGFloat kCalendarMinHeight = 212;

    CGFloat screenCurrentHeight = CGRectGetHeight([[UIScreen mainScreen] bounds]);
    CGFloat coefficent = screenCurrentHeight / kScreenHeightInStoryBoard;
    NSInteger height = kCalendarHeightInStoryBoard * coefficent;

    if (height > kCalendarHeightInStoryBoard) {
        height = kCalendarHeightInStoryBoard;
    } else if (height < kCalendarMinHeight) {
        height = kCalendarMinHeight;
    }

    _calendarHeightConstraint.constant = height;
    _calendarHeight = height;
    _calendarPositionClosed = -_calendarHeight + 1; // +1 - is the calendar bottom line height. We do not hide the calendar fully, in order to keep visible the calendar's bottom line.
    _calendarPositionOpened = 0.f;
    _calendarTopConstraint.constant = _calendarPositionOpened;
    [self setIsCalendarOpened:YES];
}

- (void)setIsCalendarOpened:(BOOL)isCalendarOpened
{
    [_requestsTableView setScrollEnabled:!isCalendarOpened];

    if (isCalendarOpened) {

        if (!_calendarPanGesture) {
            _calendarPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveCalendar:)];
            _calendarPanGesture.delegate = self;
        }

        [_requestsTableView addGestureRecognizer:_calendarPanGesture];
    } else {
        [_requestsTableView removeGestureRecognizer:_calendarPanGesture];
    }

    _isCalendarOpened = isCalendarOpened;
}

#pragma mark - Reachibility

// Called by Reachability whenever status changes.
- (void)reachabilityChanged:(NSNotification*)note
{
    __weak id weakSelf = self;
    [self->_lazyManager shouldBeUpdatedIfReachabilityChangedWithNotification:note
                                                                        date:[NSDate date]
                                                              relativeToDate:nil
                                                                        then:^(PRRequestMode mode) {
                                                                            CalendarViewController* strongSelf = weakSelf;
                                                                            if (!strongSelf) {
                                                                                return;
                                                                            }

                                                                            [PRRequestManager getTasksWithView:strongSelf.view
                                                                                                          mode:mode
                                                                                                       success:^() {

                                                                                                           [PRDatabase removeExpiredRequests];
                                                                                                           [strongSelf updateRequests];
                                                                                                           [strongSelf saveTaskDocuments];
                                                                                                       }
                                                                                                       failure:nil];
                                                                        }];
}

#pragma mark - JTCalendarDataSource

- (void)calendarDidLoadPreviousPage
{
    [PRGoogleAnalyticsManager sendEventWithName:kCalendarSwiped parameters:nil];
    [self calendarDidLoadPage];
}

- (void)calendarDidLoadNextPage
{
    [PRGoogleAnalyticsManager sendEventWithName:kCalendarSwiped parameters:nil];
    [self calendarDidLoadPage];
}

- (BOOL)calendarHaveEvent:(JTCalendar*)calendar date:(NSDate*)date
{
    return [self eventForDate:date orEventAfterThatDate:NO] != nil;
}

- (void)calendarDidDateSelected:(JTCalendar*)calendar date:(NSDate*)date
{
    NSLog(@"Selected: %@", date);
    _calendarStartDate = date;
    [self setupTableViewByDate:date];
    [_requestsTableView reloadData];
    [self scrollTableViewToItemWithDate:date];
}

- (void)calendarDidLoadPage
{
    [self setupTableViewByDate:_calendar.currentDate];
    [_requestsTableView reloadData];
    [self setDefaultDayForMonth];

#if defined(Otkritie)
    [_monthLabel setText:[self textForDateLabel:_calendar.currentDate]];
#else
    [_monthLabel setText:[self getCurrentMonth]];
#endif

    _calendarStartDate = _calendar.currentDate;
}

#pragma mark - Functionality

- (void)saveTaskDocuments
{
    NSArray<PRTaskDetailModel*>* allObjects = [PRDatabase getTasksForTodayAndTomorrow].fetchedObjects;

    for (PRTaskDetailModel* model in allObjects) {

        __weak id weakSelf = self;
        [PRRequestManager getTaskWithId:model.taskId
                                   view:self.view
                                   mode:PRRequestMode_ShowNothing
                                success:^(PRTaskDetailModel* task) {

                                    CalendarViewController* strongSelf = weakSelf;
                                    if (!strongSelf) {
                                        return;
                                    }

                                    [PRTaskDocumentManager saveDocumentsForTask:task withView:strongSelf.view];
                                }
                                failure:^{

                                }];
    }
}

- (PRTaskDetailModel*)eventForDate:(NSDate*)date orEventAfterThatDate:(BOOL)needToFindEventAfterThatDate
{
    NSDate* eventDate = [self dateWithComponentsFromDate:date units:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)];

    for (PRTaskDetailModel* request in [_fetchedResultsController fetchedObjects]) {
        if ((needToFindEventAfterThatDate && [request.requestDate mt_isOnOrAfter:eventDate]) || (!needToFindEventAfterThatDate && [request.requestDate mt_isWithinSameDay:eventDate])) {
            return request;
        }
    }

    return nil;
}

- (void)reloadRequests
{
    [_requestsTableView reloadData];
}

- (void)findTopVisibleCellAndSetupCalendarAppropriately
{
    NSDate* dateToSelect = _calendarStartDate;
    NSArray<NSIndexPath*>* indexPathsForVisibleRows = [self indexPathsForVisibleRows];

    if ([indexPathsForVisibleRows count]) {

        NSIndexPath* indexPath = [indexPathsForVisibleRows firstObject];
        PRTaskDetailModel* request = [_fetchedResultsController objectAtIndexPath:indexPath];

        if (!request || !request.requestDate) {
            return;
        }

        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDateComponents* components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:request.requestDate];
        dateToSelect = [calendar dateFromComponents:components];
    }

    _dateToSelect = dateToSelect;
#if defined(Otkritie)
    [_monthLabel setText:[self textForDateLabel:dateToSelect]];
#else
    [_monthLabel setText:[self getMonthFromDate:dateToSelect]];
#endif
}

- (void)updateRequests
{
    _fetchedResultsController = [PRDatabase getTasksReserved];
    _requestDataSource = [[RequestDataSource alloc] initWithFetchedResultsForRequest:@[ _fetchedResultsController ] payButtonDelegate:self];
    _requestsTableView.dataSource = _requestDataSource;
    [_requestsTableView reloadData];
    [_calendar reloadData];
    [self synchronizeWithNativeCalendar];

    PRUserDefaultsManager *manager = [PRUserDefaultsManager sharedInstance];
    [manager setWidgetRequests];
    [manager setWidgetEvents];

    _labelNoData.hidden = (_fetchedResultsController.sections.count != 0);
}

- (void)setupTableViewByDate:(NSDate*)date
{
    CGFloat tabBarHeight = CGRectGetHeight(self.tabBarController.tabBar.frame);
    NSDate* currentDate = [self dateWithComponentsFromDate:date units:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)];
    NSArray<PRTaskDetailModel*>* allRequests = [_fetchedResultsController fetchedObjects];

    NSMutableArray<PRTaskDetailModel*>* requestsForDate = [NSMutableArray new];
    NSMutableArray<NSIndexPath*>* visibleIndexPaths = [NSMutableArray new];

    CGFloat tableViewHeight = SCREEN_HEIGHT - kMonthViewHeight - tabBarHeight - 1; // (-1) is the calendar bottom line height.
    NSInteger i = [allRequests count] - 1;

    for (; i >= 0; i--) {
        if ([allRequests[i].requestDate mt_isOnOrAfter:currentDate]) {

            [requestsForDate addObject:allRequests[i]];
            [visibleIndexPaths addObject:[_fetchedResultsController indexPathForObject:allRequests[i]]];

            if (([requestsForDate count] * kTableviewCellHeight) >= tableViewHeight) {
                _tableViewEmptySpaceHeight = CGFLOAT_MIN;
                return;
            }
        }
    }

    NSInteger tableViewVisibleSectionsCount = [self getSectionsCountFromVisibleIndexPaths:visibleIndexPaths];

    CGFloat tableViewVisibleComponentsHeight = ([requestsForDate count] * kTableviewCellHeight) + (tableViewVisibleSectionsCount * kHeaderHeight);
    CGFloat tableViewEmptySpaceHeight = tableViewHeight - tableViewVisibleComponentsHeight;
    _tableViewEmptySpaceHeight = tableViewEmptySpaceHeight > 0 ? tableViewEmptySpaceHeight : CGFLOAT_MIN;
}

- (void)scrollTableViewToItemWithDate:(NSDate*)date
{
    PRTaskDetailModel* request = [self eventForDate:date orEventAfterThatDate:YES];

    if (!request) {
        [_requestsTableView setContentOffset:CGPointMake(0, _requestsTableView.contentSize.height)];
        return;
    }

    NSIndexPath* indexPath = [_fetchedResultsController indexPathForObject:request];

    if (indexPath && indexPath.section < [_requestsTableView numberOfSections] && indexPath.row < [_requestsTableView numberOfRowsInSection:indexPath.section]) {
        [_requestsTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)updateViewController
{
    NSLog(@"Starting update view controller %@", self.class);
    [self.navigationController popToRootViewControllerAnimated:NO];

    if (_isViewVisible) {
        [self setCalendarSelectedDateToDate:[NSDate new]];
    }
}

- (NSArray<NSIndexPath*>*)indexPathsForVisibleRows
{
    NSMutableArray<NSIndexPath*>* indexPathsForVisibleRows = [NSMutableArray new];
    NSArray* visibleCells = [_requestsTableView visibleCells];

    for (UITableViewCell* cell in visibleCells) {
        [indexPathsForVisibleRows addObject:[_requestsTableView indexPathForCell:cell]];
    }

    return indexPathsForVisibleRows;
}

- (NSInteger)getSectionsCountFromVisibleIndexPaths:(NSArray<NSIndexPath*>*)indexPaths
{
    NSMutableArray* sections = [NSMutableArray new];
    for (NSIndexPath* indexPath in indexPaths) {
        [sections addObject:[NSNumber numberWithInteger:indexPath.section]];
    }

    return [[Utils removeDuplicateItemsFromArray:sections] count];
}

- (void)stopTableViewScrolling
{
    CGPoint offset = _requestsTableView.contentOffset;
    [_requestsTableView setContentOffset:offset animated:YES];
}

- (void)synchronizeWithNativeCalendar
{
    PRCalendarEventManager* manager = [PRCalendarEventManager sharedInstance];
    [manager syncEventsWithNativeCalendar:_fetchedResultsController.fetchedObjects];
}

#pragma mark - Notifications

- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillBecomeActiveAfterTimeout)
                                                 name:kAppWillEnterForegroundAfterTimeout
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(messageReceived)
                                                 name:kMessageReceived
                                               object:nil];
}

- (void)unregisterForNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kAppWillEnterForegroundAfterTimeout
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kMessageReceived
                                                  object:nil];
}

#pragma mark - Notification Handler

- (void)appWillBecomeActiveAfterTimeout
{
    [self setCalendarState:PRCalendarState_Opened];
}

- (void)setCalendarState:(PRCalendarState)state
{
    if (_isCalendarOpened == state) {
        return;
    }

    NSString* arrowImageName = state ? kArrowUpImageName : kArrowDownImageName;
    NSInteger topSpace = state ? _calendarPositionOpened : _calendarPositionClosed;

    _calendarTopConstraint.constant = topSpace;
    _arrowImageView.image = [self imageNamed:arrowImageName];
    [self setIsCalendarOpened:state];
    [self.view layoutIfNeeded];
}

- (void)messageReceived
{
    [self reloadRequests];
}

#pragma mark - Helpers

- (UIImage*)imageNamed:(NSString*)imageName
{
    return [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (NSDate*)dateWithComponentsFromDate:(NSDate*)date units:(NSCalendarUnit)units
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:units fromDate:date];

    return [calendar dateFromComponents:components];
}

#pragma mark - Actions

- (IBAction)switchToCurrentDate:(UIButton*)sender
{
    [self stopTableViewScrolling];
    [self setCalendarSelectedDateToDate:[NSDate new]];
    [PRGoogleAnalyticsManager sendEventWithName:kTodayButtonClicked parameters:nil];
}

- (void)openCalendar
{
    [self stopTableViewScrolling];

    NSString* arrowImageName = _isCalendarOpened ? kArrowDownImageName : kArrowUpImageName;
    NSInteger topSpace = _isCalendarOpened ? _calendarPositionClosed : _calendarPositionOpened;

    _calendarTopConstraint.constant = topSpace;
    [self setIsCalendarOpened:!_isCalendarOpened];
    [PRGoogleAnalyticsManager sendEventWithName: kNavigationBarDateLabelClicked parameters:nil];
    _arrowImageView.image = [self imageNamed:arrowImageName];

    // Fully opens the calendar.
    [UIView animateWithDuration:kCalendarOpenAnimationDuration
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:nil];
}

- (void)moveCalendar:(UIPanGestureRecognizer*)sender
{
    [self stopTableViewScrolling];
    CGPoint translation = [sender translationInView:self.view];
    CGFloat verticalTranslation = translation.y;

    switch (sender.state) {
    case UIGestureRecognizerStateChanged: {

        CGFloat calendarCurrentPosition = _calendarTopConstraint.constant;
        NSInteger calendarTopConstraint = roundf(calendarCurrentPosition + verticalTranslation);

        if (calendarTopConstraint > _calendarPositionOpened) {
            calendarTopConstraint = _calendarPositionOpened;
        } else if (calendarTopConstraint < _calendarPositionClosed) {
            calendarTopConstraint = _calendarPositionClosed;
        }

        _calendarTopConstraint.constant = calendarTopConstraint;

        [self.view layoutIfNeeded];
    } break;
    case UIGestureRecognizerStateEnded: {

        CGFloat topSpace = _calendarPositionOpened;
        BOOL isCalendarOpend = YES;

        if (_calendarTopConstraint.constant <= -(_calendarHeight / 2)) {
            topSpace = _calendarPositionClosed;
            isCalendarOpend = NO;
        }

        _calendarTopConstraint.constant = topSpace;

        // Closes the calendar when user takes a finger during swiping.
        [UIView animateWithDuration:kCalendarPanAnimationDuration
            animations:^{
                [self.view layoutIfNeeded];
            }
            completion:^(BOOL finished) {

                _arrowImageView.image = [self imageNamed:isCalendarOpend ? kArrowUpImageName : kArrowDownImageName];
                [self setIsCalendarOpened:isCalendarOpend];
            }];
    } break;
    default:
        break;
    }

    [sender setTranslation:CGPointMake(0, 0) inView:self.view];
}

#pragma mark - UITableViewDelegate

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    id sectionInfo = [_requestDataSource sectionInfo:section];
    NSString* name = [sectionInfo name];

    NSString* sectionTitle = [[Utils stringFromDateString:name] uppercaseString];

    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, kHeaderHeight)];
    [headerView setBackgroundColor:kTasksHeaderColor];

    UILabel* headerLabel = [UILabel new];
    [headerView addSubview:headerLabel];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor colorWithWhite:0.1f alpha:0.9];
    headerLabel.font = [UIFont systemFontOfSize:12.0];
    headerLabel.text = sectionTitle;

    CGSize size = [sectionTitle sizeWithAttributes:@{ NSFontAttributeName : headerLabel.font }];
    CGRect frame = CGRectMake(kHeaderPositionFromLeft, (kHeaderHeight - size.height), size.width, size.height);
    [headerLabel setFrame:frame];

    return headerView;
}

- (void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSInteger rowsCount = [[_fetchedResultsController sections][indexPath.section] numberOfObjects];

    if ([cell respondsToSelector:@selector(setSeparatorLineHidden:)]) {
        id<PRCellWithCustomSeparator> tempCell = (id)cell;
        [tempCell setSeparatorLineHidden:YES];

        if (rowsCount > 1 && indexPath.row != (rowsCount - 1)) {
            [tempCell setSeparatorLineHidden:NO];
        }
    }
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return kHeaderHeight;
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat height = CGFLOAT_MIN;

    if (section == ([[_fetchedResultsController sections] count] - 1)) {
        height = _tableViewEmptySpaceHeight;
    }

    return height;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    id<PRTaskCell> cell = (id<PRTaskCell>)[tableView cellForRowAtIndexPath:indexPath];

    RequestsDetailViewController* requestsDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RequestsDetailViewController"];
    NSAssert(requestsDetailViewController, nil);

    requestsDetailViewController.taskId = [cell taskId];
    requestsDetailViewController.requestDate = [cell requestDate];

    [PRGoogleAnalyticsManager sendEventWithName:kEventIsClicked parameters:nil];

    [self.navigationController pushViewController:requestsDetailViewController animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView*)scrollView
{
    _isScrollingBegan = YES;
}

- (void)scrollViewDidScroll:(UIScrollView*)scrollView
{
    if (_isScrollingBegan) {
        [self findTopVisibleCellAndSetupCalendarAppropriately];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self scrollingFinished];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView*)scrollView
{
    [self scrollingFinished];
}

- (void)scrollingFinished
{
    _isScrollingBegan = NO;

    if (_dateToSelect) {
        _calendar.currentDateSelected = _dateToSelect;
        _calendar.currentDate = _dateToSelect;
        _dateToSelect = nil;
    }
}

#pragma mark - Pay

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

    __weak CalendarViewController* weakSelf = self;
    [PRRequestManager getApplePayOrderInfoWithPaymentID:_paymentID
        view:self.view
        mode:PRRequestMode_ShowOnlyProgress
        success:^(PRPaymentDataModel* paymentDataModel) {

            CalendarViewController* strongSelf = weakSelf;
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

            CalendarViewController* strongSelf = weakSelf;
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

    [self.view addSubview:paymentView];
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

    __weak CalendarViewController* weakSelf = self;
    [PRRequestManager sendApplePayToken:applePayToken
        view:self.view
        mode:PRRequestMode_ShowNothing
        success:^(PRApplePayResponseModel* applePayResponseModel) {

            CalendarViewController* strongSelf = weakSelf;
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
                [strongSelf showApplePayErrorAlertWithMessage:applePayResponseModel.error.errorDescription];
                return;
            }

            completion(PKPaymentAuthorizationStatusFailure);
            [controller dismissViewControllerAnimated:YES completion:nil];
        }
        failure:^(NSInteger statusCode, NSError* error) {

            CalendarViewController* strongSelf = weakSelf;
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

#pragma mark - Dealloc

- (void)dealloc
{
    [self unregisterForNotifications];
}

@end
