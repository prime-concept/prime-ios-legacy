//
//  PRWGRequestsViewController.m
//  PRWidgetPrime
//
//  Created by Armen on 4/4/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import "PRWGRequestsViewController.h"
#import "PRWGRequestTableViewCell.h"
#import "Constants.h"
#import "PRURLSessionRequestManager.h"
#import "AccessTokenGenerator.h"
#import "Config.h"

static NSString* const kPRWGRequestTableViewCell = @"PRWGRequestTableViewCell";
static const CGFloat kSmallDeviceScreenHeight = 568.0f;
static const CGFloat kMediumDeviceScreenHeight = 667.0f;
static const NSInteger kMediumDeviceCityGuideMaxCount = 7;
static const NSInteger kSmallDeviceTasksMaxCount = 6;

@interface PRWGRequestsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray* dataArray;
@property (weak, nonatomic) IBOutlet UITableView* tableView;
@property (weak, nonatomic) IBOutlet UILabel* noDataLabel;
@property (strong, nonatomic) PRURLSessionRequestManager* sessionManager;
@property (strong, nonatomic) NSUserDefaults* defaults;

@end

@implementation PRWGRequestsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_noDataLabel setText:NSLocalizedString(@"No requests", )];
    self.defaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];

    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:kTasksUpdateTimeout
                                                      target:self
                                                    selector:@selector(refreshAccessTokenForTasks)
                                                    userInfo:nil
                                                     repeats:YES];
    [timer fire];

    [self filterRequests];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDefaultsDidChange:)
                                                 name:NSUserDefaultsDidChangeNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidDisappear:animated];
}

- (void)refreshAccessTokenForTasks
{
    NSString* userName = [self.defaults valueForKey:kCustomerId];
    NSString* accessToken = [self.defaults valueForKey:kAccessTokenKey];

    AccessTokenGenerator* tokenGenerator = [AccessTokenGenerator new];
    __weak PRWGRequestsViewController* weakSelf = self;
    if (accessToken) {
        [tokenGenerator refreshAccessTokenWithSuccess:^{
            PRWGRequestsViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            [strongSelf getTasksHttpRequest];
        }
            failure:^{
            }];
    } else {
        [tokenGenerator authorizeWithUsername:userName
            success:^(AFOAuthCredential* credential) {
                PRWGRequestsViewController* strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                NSString* newAccessToken = credential.accessToken;
                [self.defaults setObject:newAccessToken forKey:kAccessTokenKey];
                [strongSelf getTasksHttpRequest];
            }
            failure:^{
            }];
    }
}

- (void)getTasksHttpRequest
{
    NSString* urlString = [NSString stringWithFormat:@"%@/tasks", Config.crmEndpoint];
    if (!self.sessionManager) {
        self.sessionManager = [[PRURLSessionRequestManager alloc] init];
    }

    __weak PRWGRequestsViewController* weakSelf = self;
    [self.sessionManager makeURLSessionRequest:urlString
        success:^(NSArray* response) {
            PRWGRequestsViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            NSArray* tasks = [response valueForKey:@"data"];

            [strongSelf.sessionManager setWidgetRequestsWithURLSession:tasks];
            [strongSelf.sessionManager setWidgetEventsWithURLSession:tasks];
            [strongSelf filterRequests];
            [strongSelf.tableView reloadData];
        }
        failure:^{
            PRWGRequestsViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            [strongSelf filterRequests];
            [strongSelf.tableView reloadData];
        }];
}

- (void)userDefaultsDidChange:(NSNotification*)notification
{
    NSMutableArray* array = [[[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName] valueForKey:kWidgetRequests];
    if (![_dataArray isEqual:array]) {
        self.dataArray = array;
        _noDataLabel.hidden = self.dataArray.count ? YES : NO;
        [_tableView reloadData];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if (screenHeight == kSmallDeviceScreenHeight && _dataArray.count > kSmallDeviceTasksMaxCount) {
        return kSmallDeviceTasksMaxCount;
    }  else if (screenHeight == kMediumDeviceScreenHeight && _dataArray.count > kMediumDeviceCityGuideMaxCount) {
        return kMediumDeviceCityGuideMaxCount;
    }
    return _dataArray.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    PRWGRequestTableViewCell* cell = (PRWGRequestTableViewCell*)[tableView dequeueReusableCellWithIdentifier:kPRWGRequestTableViewCell];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:kPRWGRequestTableViewCell owner:self options:nil] objectAtIndex:0];
    }
    [cell updateCellWithData:_dataArray[indexPath.row]];
    [cell setRequestStatus:_dataArray[indexPath.row]];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{

    NSString* taskId = [_dataArray[indexPath.row] valueForKey:kWidgetRequestID];
    NSURL* URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@taskinfo/%@", kURLSchemesPrefix, taskId]];
    [self.extensionContext openURL:URL completionHandler:nil];
}

- (void)setDataArray:(NSArray*)dataArray
{
    NSMutableArray* array = [NSMutableArray new];

    for (NSInteger i = 0; i < dataArray.count; i++) {
        NSMutableDictionary* currentData = [dataArray[i] mutableCopy];
        NSString* currentHeader = [currentData valueForKey:kWidgetEventType];
        if ([self hasEqualHeader:currentHeader inDataArray:dataArray beforeCurrentIndex:i]) {
            [currentData setValue:nil forKey:kWidgetEventType];
        }

        [array addObject:currentData];
    }
    _dataArray = array;
}

- (BOOL)hasEqualHeader:(NSString*)previewHeader inDataArray:(NSArray*)array beforeCurrentIndex:(NSInteger)index
{

    for (NSInteger i = index - 1; i >= 0; i--) {

        NSString* header = [array[i] valueForKey:kWidgetEventType];
        if ([previewHeader isEqualToString:header]) {
            return YES;
        }
    }
    return NO;
}

- (void)filterRequests
{
    NSDateComponents* monthOffsetFromNowComponents = [[NSDateComponents alloc] init];
    monthOffsetFromNowComponents.month = -kDataExpirationMonthOffset;

    NSDate* offsetMonthsAgo = [[NSCalendar currentCalendar] dateByAddingComponents:monthOffsetFromNowComponents
                                                        toDate:[NSDate date]
                                                       options:0];

    NSArray* allrequests = [self.defaults valueForKey:kWidgetRequests];
    NSMutableArray* filteredRequests = [NSMutableArray new];

    for (NSInteger i = 0; i < allrequests.count; i++) {
        NSDate* dateOfCurrentRequest = [allrequests[i] valueForKey:@"requestDate"];

        // dateOfCurrentRequest is later than offsetMonthsAgo
        if([dateOfCurrentRequest compare:offsetMonthsAgo] == NSOrderedDescending) {
            [filteredRequests addObject:allrequests[i]];
        }
    }

    [self.defaults setValue:filteredRequests forKey:kWidgetRequests];
    _dataArray = filteredRequests;
    _noDataLabel.hidden = _dataArray.count > 0;
}

@end
