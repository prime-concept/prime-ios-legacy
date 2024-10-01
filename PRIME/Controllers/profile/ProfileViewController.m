//
//  ProfileViewController.m
//  PRIME
//
//  Created by Artak on 1/31/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "AppDelegate.h"
#import "ProfileViewController.h"
#import "XNAvatar.h"
#import "FDTakeController.h"
#import "PRProfileDataCell.h"
#import "ProfileMainDataSource.h"
#import "PRProfileMainTableViewController.h"
#import "SynchManager.h"
#import "UINavigationBar+Addition.h"
#import "PRFeatureInfoProcessingManager.h"

@interface ProfileViewController () <FDTakeDelegate>

@property (weak, nonatomic) IBOutlet UITableView* tableView;
@property (strong, nonatomic) ProfileMainDataSource* tableViewDataSource;
@property (strong, nonatomic) PRProfileMainTableViewController* tableViewDelegate;
@property (strong, nonatomic) PRUserProfileModel* userProfile;
@property (strong, nonatomic) PRFeatureInfoProcessingManager* featureInfoProcessingManager;
@property void (^displayWeb)(void);

@end

static NSString* const kProfileCell = @"ProfileCell";

@implementation ProfileViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self createDataSource];

    if (!_userProfile.synched) {
        [self createSyncTask];
        [self synchProfileWithServer];
    }

    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;

    _tableView.backgroundColor = kProfileTableViewBackgroundColor;
    self.navigationController.navigationBar.barTintColor = kWhiteColor;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [PRGoogleAnalyticsManager sendEventWithName:kMeTabOpened parameters:nil];
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:NO];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
#if defined (VTB24) || Raiffeisen
    [UINavigationBar setStatusBarBackgroundColor:kWhiteColor];
    if (@available(iOS 13.0, *)) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDarkContent];
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
#endif
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

#if defined (VTB24) || Raiffeisen
    [UINavigationBar setStatusBarBackgroundColor:kWhiteColor];
    if (@available(iOS 13.0, *)) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDarkContent];
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
#endif

    if (_tableView.contentSize.height < CGRectGetHeight(_tableView.frame)) {
        [_tableView setScrollEnabled:NO];
    }

    [self.lazyManager shouldBeUpdatedIfViewDidAppearWithDate:[NSDate date]
        relativeToDate:nil
        then:^(PRRequestMode mode) {

            __weak ProfileViewController* weakSelf = self;

            if (_userProfile.synched) {

                [PRRequestManager getProfileWithView:self.view
                                                mode:_userProfile ? PRRequestMode_ShowNothing : mode
                                             success:^(PRUserProfileModel* userProfile) {
                                                 ProfileViewController* strongSelf = weakSelf;
                                                 if (!strongSelf) {
                                                     return;
                                                 }
                                                 [strongSelf synchronizeInformationWithServer];
                                                 [strongSelf updateProfile];

                                                 [XNAvatar synchronizeWithServer:^(UIImage* image) {
                                                     ProfileViewController* strongSelf = weakSelf;
                                                     if (!strongSelf) {
                                                         return;
                                                     }
                                                     [strongSelf.tableView reloadData];
                                                 }];
                                             }
                                             failure:^{
                                             }];
            } else {
                [XNAvatar synchronizeWithServer:^(UIImage* image) {
                    ProfileViewController* strongSelf = weakSelf;
                    if (!strongSelf) {
                        return;
                    }
                    [strongSelf.tableView reloadData];
                }];
            }

        }
        otherwiseIfFirstTime:^{
            [self updateProfile];
        }
        otherwise:^{
        }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
#if defined (VTB24) || Raiffeisen
    [UINavigationBar setStatusBarBackgroundColor:kNavigationBarBarTintColor];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
#endif
    [super viewWillDisappear:animated];
}

#pragma mark - Functionality

- (void)createDataSource
{
    _tableViewDataSource = [ProfileMainDataSource new];
    _userProfile = [PRDatabase getUserProfile];

    ProfileViewController * __weak weakSelf = self;
    _displayWeb = ^{
        [weakSelf displaySafari];
    };

    _tableViewDataSource.userProfile = _userProfile;
    _tableViewDataSource.displayWeb = _displayWeb;

    _tableViewDelegate = [[PRProfileMainTableViewController alloc] init];
    _tableViewDelegate.rootViewController = self;

    _tableView.delegate = _tableViewDelegate;
    _tableView.dataSource = _tableViewDataSource;
}

- (UIStatusBarStyle)getStatusBarColor
{
    return UIStatusBarStyleDefault;
}

- (UIColor*)getNavigationBarColor
{
    return kWhiteColor;
}

- (void)createSyncTask
{
    _userProfile.synched = NO;
    [_userProfile save];
    __weak id weakSelf = self;
    [[SynchManager sharedClient] addOperationWithBlock:^{
        ProfileViewController* strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        // As users cannot modify features, so excluding features from the user profile model when updaing it.
        NSOrderedSet<PRUserProfileFeaturesModel*>* cachedFeatures = _userProfile.features;
        _userProfile.features = nil;
        [PRRequestManager updateProfile:_userProfile
            view:strongSelf.view
            mode:PRRequestMode_ShowNothing
            success:^{

                ProfileViewController* strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                strongSelf.userProfile.synched = YES;
                [strongSelf.userProfile save];

                [strongSelf updateProfile];
            }
            failure:^{

                ProfileViewController* strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                [[NSManagedObjectContext MR_defaultContext] refreshObject:strongSelf.userProfile mergeChanges:NO];

                [strongSelf updateProfile];
            }];
        _userProfile.features = cachedFeatures;
    }];
}

- (void)synchProfileWithServer
{
    _userProfile.synched = NO;
    [_userProfile save];
    __weak id weakSelf = self;
    if (![PRRequestManager connectionRequired]) {
        // As users cannot modify features, so excluding features from the user profile model when updaing it.
        NSOrderedSet<PRUserProfileFeaturesModel*>* cachedFeatures = _userProfile.features;
        _userProfile.features = nil;
        [PRRequestManager updateProfile:_userProfile
            view:self.view
            mode:PRRequestMode_ShowErrorMessagesAndProgress
            success:^{
                ProfileViewController* strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                strongSelf.userProfile.synched = YES;
                [strongSelf.userProfile save];
                [strongSelf updateProfile];
            }
            failure:^{
                ProfileViewController* strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                [[NSManagedObjectContext MR_defaultContext] refreshObject:strongSelf.userProfile mergeChanges:NO];
                [strongSelf updateProfile];
            }];
        _userProfile.features = cachedFeatures;
    } else {
        [self createSyncTask];
        [self updateProfile];
    }
}

// Called by Reachability whenever status changes.
- (void)reachabilityChanged:(NSNotification*)note
{
    [self.lazyManager shouldBeUpdatedIfReachabilityChangedWithNotification:note
                                                                      date:[NSDate date]
                                                            relativeToDate:nil
                                                                      then:^(PRRequestMode mode) {

                                                                          __weak ProfileViewController* weakSelf = self;
                                                                          [PRRequestManager getProfileWithView:self.view
                                                                                                          mode:_userProfile ? PRRequestMode_ShowNothing : mode
                                                                                                       success:^(PRUserProfileModel* userProfile) {

                                                                                                           ProfileViewController* strongSelf = weakSelf;
                                                                                                           if (!strongSelf) {
                                                                                                               return;
                                                                                                           }
                                                                                                           [strongSelf updateProfile];

                                                                                                           [PRRequestManager getDocumentsWithView:strongSelf.view
                                                                                                                                             mode:PRRequestMode_ShowNothing
                                                                                                                                          success:^{
                                                                                                                                          }
                                                                                                                                          failure:nil];

                                                                                                           [XNAvatar synchronizeWithServer:^(UIImage* image) {
                                                                                                               ProfileViewController* strongSelf = weakSelf;
                                                                                                               if (!strongSelf) {
                                                                                                                   return;
                                                                                                               }
                                                                                                               [strongSelf.tableView reloadData];
                                                                                                           }];
                                                                                                       }
                                                                                                       failure:nil];
                                                                      }];
}

- (void)updateProfile
{
    _userProfile = [PRDatabase getUserProfile];
    _tableViewDataSource.userProfile = _userProfile;
    _tableViewDataSource.displayWeb = _displayWeb;

    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.tableView reloadData];
    });
}

- (void)synchronizeInformationWithServer
{
    if (!self.featureInfoProcessingManager) {
        self.featureInfoProcessingManager = [PRFeatureInfoProcessingManager new];
    }

    __weak ProfileViewController* strongSelf = self;
    [self.featureInfoProcessingManager getHelpScreenFeatures:^(NSArray* featuresData){
        if (!strongSelf) {
            return;
        }

        [strongSelf updateProfile];
    }];
}

- (void)displaySafari
{
    NSString* accessToken = [AFOAuthCredential objectFromKeychainWithKey:kCredentialKeyPath].accessToken;
    NSString *url;

#if defined(Prime)
    url = [NSString stringWithFormat:@"https://primeconcept.co.uk/wallet#token=%@", accessToken];
#elif defined(PrimeClubConcierge)
    url = [NSString stringWithFormat:@"https://a-club.concierge.ru/wallet/success?token=%@", accessToken];
#endif

    SFSafariViewController *safariVC = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:url] entersReaderIfAvailable:NO];
    [self presentViewController:safariVC animated:YES completion:nil];
}

#pragma mark - TabBarItemChanged

- (void)updateViewController
{
    [self.navigationController popToRootViewControllerAnimated:NO];

    NSLog(@"Starting update view controller %@", self.class);
}

@end
