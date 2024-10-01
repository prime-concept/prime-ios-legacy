//
//  TopTenViewController.m
//  PRIME
//
//  Created by Artak on 1/31/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "Reachability.h"
#import "TopTenViewController.h"
#import "UINavigationBar+Addition.h"
#import "PRUserDefaultsManager.h"

@interface TopTenViewController () {
    BOOL _linkClicked;
    BOOL _pageLoaded;
    BOOL _openWithDeepLink;
    BOOL _shouldNavBarBeHidden;
    NetworkStatus _networkStatus;
}

@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) NSString* urlString;

@end

@implementation TopTenViewController

- (void)viewDidLoad
{
    [self setHideProgressHUD:YES];

    [super viewDidLoad];
    [self initLocationManager];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
}

- (void)initLocationManager
{
    [self initializeWebView];

#if defined(Otkritie)
    [self.webView addObserver:self forKeyPath:@"URL" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    [self.webView addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew context:NULL];
    [self.navigationItem setTitle:NSLocalizedString(@"Services", nil)];
#endif

    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        [_locationManager requestWhenInUseAuthorization];
        [_locationManager startUpdatingLocation];
    }
}

- (void)setCityGuideWithDeepLink:(NSString*)url
{
    _urlString = url;
    _openWithDeepLink = YES;
}

- (BOOL)shouldHideNavigationBar
{
    return ![self isNavigationBarNeeded];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [PRGoogleAnalyticsManager sendEventWithName:kCityGuideTabOpened parameters:nil];
#if defined (VTB24) || Raiffeisen
    [UINavigationBar setStatusBarBackgroundColor:kWhiteColor];
    if (@available(iOS 13.0, *)) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDarkContent];
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
#endif
}

- (void)viewWillDisappear:(BOOL)animated
{
#if defined (VTB24) || Raiffeisen
    [UINavigationBar setStatusBarBackgroundColor:kNavigationBarBarTintColor];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
#endif
    [super viewWillDisappear:animated];
}

- (UIStatusBarStyle)getStatusBarColor
{

    return UIStatusBarStyleDefault;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"hidden"] && ![change[@"new"] isKindOfClass:[NSNull class]]) {
        NSString *hidden = change[@"new"];
        if (hidden.integerValue) {
            [UINavigationBar setStatusBarBackgroundColor:kWhiteColor];
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        } else {
            [UINavigationBar setStatusBarBackgroundColor:kNavigationBarBarTintColor];
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        }
        return;
    }
    if ([keyPath isEqualToString:@"URL"]) {
        if (![change[@"old"] isKindOfClass:[NSNull class]]&&![change[@"new"] isKindOfClass:[NSNull class]]) {
            NSString* newURLString = ((NSURL*)(change[@"new"])).absoluteString;
            if ([newURLString containsString:[kCityGuideBaseUrl substringFromIndex:8]]) {
                if (![self.url isEqualToString:newURLString]) {
                    _linkClicked = YES;
                    [self.navigationController setNavigationBarHidden:NO animated:self.navigationController.navigationBarHidden? YES : NO];
                } else {
                    _linkClicked = NO;
                    _shouldNavBarBeHidden = YES;
                }
            } else {
                _linkClicked = YES;
            }
        }
    } else if (![change[@"new"] isKindOfClass:[NSNull class]] && _shouldNavBarBeHidden) {
        if (self.webView.estimatedProgress == 1) {
            [self.navigationController setNavigationBarHidden:YES animated:self.navigationController.navigationBarHidden? NO : YES];
            _shouldNavBarBeHidden = NO;
        }
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager*)manager didFailWithError:(NSError*)error
{
    [self loadWebViewWithLocation:nil];
}

- (void)locationManager:(CLLocationManager*)manager didUpdateToLocation:(CLLocation*)newLocation fromLocation:(CLLocation*)oldLocation
{
    [[PRUserDefaultsManager sharedInstance] getCityGuideDataWithLocation];
    [self loadWebViewWithLocation:newLocation];
}

- (void)locationManager:(CLLocationManager*)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusDenied) {
        [PRGoogleAnalyticsManager sendEventWithName:kLocationDoNotAllowButtonClicked parameters:nil];
        [self loadWebViewWithLocation:nil];
        return;
    }
    [PRGoogleAnalyticsManager sendEventWithName:kLocationAllowButtonClicked parameters:nil];
}

- (void)reachabilityChanged:(NSNotification*)notification
{
    Reachability* curReach = [notification object];
    BOOL firstTime = [PRRequestManager internetReachability].currentReachabilityStatus != _networkStatus;
    _networkStatus = [PRRequestManager internetReachability].currentReachabilityStatus;

    if (!_pageLoaded && curReach.currentReachabilityStatus != NotReachable && curReach.currentReachabilityStatus != firstTime) {
        [self loadWebViewWithLocation:nil];
    }
}

- (void)loadWebViewWithLocation:(CLLocation*)newLocation
{
    [_locationManager stopUpdatingLocation];

    PRUserProfileModel* profile = [[PRUserProfileModel MR_findAllInContext:[NSManagedObjectContext MR_rootSavingContext]] firstObject];

    NSString* stringUrl = nil;
    NSString* profileClubPhone = nil;
    NSString* locationUrl = @"null";

    if ([profile.clubPhone length] > 0 && [[profile.clubPhone substringToIndex:1] isEqualToString:@"+"]) {
        profileClubPhone = [profile.clubPhone substringFromIndex:1];
    } else {
        profileClubPhone = profile.clubPhone;
    }

    if (newLocation) {
        NSString* LocationLongitude = [NSString stringWithFormat:@"%f", newLocation.coordinate.longitude];
        NSString* LocationLatitude = [NSString stringWithFormat:@"%f", newLocation.coordinate.latitude];
        locationUrl = [NSString stringWithFormat:@"%%7B%%22lat%%22:%@,%%22lng%%22:%@%%7D", LocationLatitude, LocationLongitude];

        _locationManager = nil;
    }

    NSString* clientID = (profile.username && ![profile.username isEqualToString:@""]) ? profile.username : kClientID;
    NSString* accessToken = [AFOAuthCredential objectFromKeychainWithKey:kCredentialKeyPath].accessToken;

    BOOL isOpenWithDeeplink = _openWithDeepLink;
    if (_openWithDeepLink) {
        stringUrl = _urlString;
        _urlString = nil;
        _openWithDeepLink = NO;
    } else {
        stringUrl = [NSString stringWithFormat:kTopTenPage, kCityGuideBaseUrl, kCityGuideBaseUtm, clientID, locationUrl, kTargetName, profileClubPhone, accessToken];
    }

    if (!isOpenWithDeeplink) {
        #if defined(VTB24)
            stringUrl = [stringUrl stringByAppendingString:@"&env=webview&showcase=5ef201a580e4dd0019115c40"];
        #elif defined(Platinum)
            stringUrl = [stringUrl stringByAppendingString:@"&env=webview&showcase=5fc778252837bf0019ea5a53"];
        #elif defined(PrimeClubConcierge) || defined(Davidoff) || defined(Prime) || defined(PrimeConciergeClub) || defined(Raiffeisen) || defined(PrivateBankingPRIMEClub)
            stringUrl = [stringUrl stringByAppendingString:@"&env=webview"];
        #endif
    }

    if (![stringUrl isEqualToString:self.webView.URL.absoluteString]) {
        if (isOpenWithDeeplink && ![stringUrl containsString:@"prime.travel"]) {
            NSString* deeplinkAccessToken = [NSString stringWithFormat: @"/?access_token=%@", accessToken];
            stringUrl = [stringUrl stringByAppendingString: deeplinkAccessToken];
        } else {
            NSString* longitude = [NSString stringWithFormat:@"%f", newLocation.coordinate.longitude];
            NSString* latitude = [NSString stringWithFormat:@"%f", newLocation.coordinate.latitude];
            NSString* suffix = [NSString stringWithFormat:kTopTenFlowers, clientID, longitude, latitude, profileClubPhone, kTargetName, accessToken];
            stringUrl = [stringUrl stringByAppendingString: suffix];
        }
        [self setUrl:stringUrl];
    }
}

- (void)updateViewController
{
    NSLog(@"Starting update view controller %@", self.class);

    if (self.webView != nil) {
        [self loadWebViewWithLocation:nil];
        _linkClicked = NO;
    }
}

- (void)webView:(WKWebView*)webView didFinishNavigation:(WKNavigation*)navigation
{
    [super webView:webView didFinishNavigation:navigation];
    _pageLoaded = YES;
}

- (void)webView:(WKWebView*)webView decidePolicyForNavigationAction:(WKNavigationAction*)navigationAction
                    decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {

        _linkClicked = YES;
    }

    [super webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kReachabilityChangedNotification
                                                  object:nil];

#if defined(Otkritie)
    [self.webView removeObserver:self forKeyPath:@"URL"];
    [self.webView removeObserver:self forKeyPath:@"loading"];
#endif
}

- (void)deleteCookiesWithCompletionBlock:(void (^)())completionBlock
{
    NSHTTPCookieStorage* storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray<NSHTTPCookie*>* storageCookies = [storage cookies];
    if (storageCookies.count == 0)
    {
        completionBlock();
        return;
    }
    for (NSHTTPCookie *cookie in storageCookies)
    {
        [storage deleteCookie:cookie];
    }
    completionBlock();
}

@end
