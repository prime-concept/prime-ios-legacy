//
//  PRWGCityGuideViewController.m
//  PRWidgetPrime
//
//  Created by Armen on 4/4/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import "PRWGCityGuideViewController.h"
#import "PRWGCityguideTableViewCell.h"
#import "Constants.h"
#import "PRURLSessionRequestManager.h"
#import <CoreLocation/CoreLocation.h>
#import "AccessTokenGenerator.h"

static NSString* const kPRWGCityguideTableViewCell = @"PRWGCityguideTableViewCell";
static const CGFloat kCityGuideCellHeight = 64.0f;
static const CGFloat kMediumDeviceScreenHeight = 667.0f;
static const CGFloat kLargeDeviceScreenHeight = 736.0f;
static const CGFloat kSmallDeviceScreenHeight = 568.0f;
static const NSInteger kSmallDeviceCityGuideMaxCount = 6;
static const NSInteger kMediumDeviceCityGuideMaxCount = 7;
static const NSInteger kLargeDeviceCityGuideMaxCount = 8;

@interface PRWGCityGuideViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray* dataArray;
@property (weak, nonatomic) IBOutlet UITableView* tableView;
@property (strong, nonatomic) PRURLSessionRequestManager* sessionManager;
@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) NSUserDefaults* defaults;

@end

@implementation PRWGCityGuideViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.locationManager = [[CLLocationManager alloc] init];
    self.defaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    _dataArray = [self.defaults valueForKey:kWidgetCityguideData];

    [NSTimer scheduledTimerWithTimeInterval:kCityGuideUpdateTimeout
                                     target:self
                                   selector:@selector(refreshAccessTokenForCityGuide)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
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

- (void)refreshAccessTokenForCityGuide
{
    NSString* userName = [self.defaults valueForKey:kCustomerId];
    NSString* accessToken = [self.defaults valueForKey:kAccessTokenKey];

    AccessTokenGenerator* tokenGenerator = [AccessTokenGenerator new];
    __weak PRWGCityGuideViewController* weakSelf = self;
    if (accessToken) {
        [tokenGenerator refreshAccessTokenWithSuccess:^{
            PRWGCityGuideViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            [strongSelf getCityGuideWithHttpRequest];
        }
            failure:^{
            }];
    } else {
        [tokenGenerator authorizeWithUsername:userName
            success:^(AFOAuthCredential* credential) {
                PRWGCityGuideViewController* strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                NSString* newAccessToken = credential.accessToken;
                [self.defaults setObject:newAccessToken forKey:kAccessTokenKey];
                [strongSelf getCityGuideWithHttpRequest];
            }
            failure:^{
            }];
    }
}

- (void)getCityGuideWithHttpRequest
{
    CGFloat longitude = _locationManager.location.coordinate.longitude;
    CGFloat latitude = _locationManager.location.coordinate.latitude;
    NSString* urlString = [NSString stringWithFormat:kCityGuideUrl, longitude, latitude];
    if (!self.sessionManager) {
        self.sessionManager = [[PRURLSessionRequestManager alloc] init];
    }

    __weak PRWGCityGuideViewController* weakSelf = self;
    [self.sessionManager makeURLSessionRequest:urlString
        success:^(NSArray* response) {
            PRWGCityGuideViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            [strongSelf.sessionManager createDataForCityGuideInWIdgetWithURLSession:response];
            [strongSelf.tableView reloadData];
        }
        failure:^{
            PRWGCityGuideViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            [strongSelf.tableView reloadData];
        }];
}

- (void)userDefaultsDidChange:(NSNotification*)notification
{
    NSMutableArray* array = [[[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName] valueForKey:kWidgetCityguideData];
    if (![_dataArray isEqual:array]) {
        self.dataArray = array;
        [_tableView reloadData];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if (screenHeight == kMediumDeviceScreenHeight && _dataArray.count > kMediumDeviceCityGuideMaxCount) {
        return kMediumDeviceCityGuideMaxCount;
    } else if (screenHeight == kLargeDeviceScreenHeight && _dataArray.count > kLargeDeviceCityGuideMaxCount) {
        return kLargeDeviceCityGuideMaxCount;
    } else if (screenHeight == kSmallDeviceScreenHeight) {
        return kSmallDeviceCityGuideMaxCount;
    }
    return _dataArray.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{

    PRWGCityguideTableViewCell* cell = [_tableView dequeueReusableCellWithIdentifier:kPRWGCityguideTableViewCell];
    [cell updateCellWithData:_dataArray[indexPath.row]];

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return kCityGuideCellHeight;
}

- (CGFloat)tableView:(UITableView*)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return kCityGuideCellHeight;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSString* link = [_dataArray[indexPath.row] valueForKey:kWidgetCityguideInner_link];
    NSURL* URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@cityguide/%@", kURLSchemesPrefix, [link substringFromIndex:1]]];
    [self.extensionContext openURL:URL completionHandler:nil];
}

@end
