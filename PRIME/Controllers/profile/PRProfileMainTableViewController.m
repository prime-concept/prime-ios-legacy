//
//  PRProfileMainTableViewController.m
//  PRIME
//
//  Created by Simon on 1/24/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "CardsViewController.h"
#import "CreatePasswordViewController.h"
#import "PRMessageAlert.h"
#import "PRProfileMainTableViewController.h"
#import "ProfileMainDataSource.h"
#import "ProfileViewController.h"
#import "WebViewController.h"
#import "FinancialReportViewController.h"
#import "PRMyProfileViewController.h"
#import "PRCarsViewController.h"
#import "ChangePasswordViewController.h"
#import "PRFeatureInfoProcessingManager.h"
#import "PRUITabBarController.h"
#import "PRInformationViewController.h"
#import "PRInformationNavigationController.h"
#import <MessageUI/MessageUI.h>
#import "UIViewController+Convenience.h"
#import "AppDelegate.h"
#import "PRMessageAlert.h"
#import "PRUINavigationController.h"

static NSInteger const kProfileSelfInfoCellHeight = 258;
static NSInteger const kProfileSelfInfoCellMinimumHeight = 214;
static NSInteger const kProfileVirtualCardHeight = 59;
static NSInteger const kProfileTableViewCellHeight = 45;
static NSInteger const kProfileTableViewFooterHeight = 30;
static NSString* const kCFBundleShortVersionString = @"CFBundleShortVersionString";
static NSString* const kCFBundleVersion = @"CFBundleVersion";
static NSString* const kInformationNavigationController = @"PRInformationNavigationController";

@implementation PRProfileMainTableViewController

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    ProfileMainDataSource* dataSource = tableView.dataSource;

#if defined(PrivateBankingPRIMEClub)
    [_rootViewController.navigationController.navigationBar setBarTintColor:kTabBarBackgroundColor];
    _rootViewController.navigationController.navigationBar.translucent = NO;
    [_rootViewController.navigationController.navigationBar setTintColor:kNavigationBarTintColor];
#endif

    switch (indexPath.section) {
    case ProfileInfoSections_Main: {
        switch (indexPath.row) {
        case ProfileMainSectionRow_MyProfile: {
            [PRGoogleAnalyticsManager sendEventWithName:kMyProfileButtonClicked parameters:nil];
            PRMyProfileViewController* viewController = [_rootViewController.storyboard instantiateViewControllerWithIdentifier:@"PRMyProfileViewController"];
            [_rootViewController.navigationController pushViewController:viewController animated:YES];
        } break;
        case ProfileMainSectionRow_MyCards: {
            [PRGoogleAnalyticsManager sendEventWithName:kMyCardsButtonClicked parameters:nil];
            NSAssert([_rootViewController isKindOfClass:[ProfileViewController class]],
                @"_rootViewController is not kind of class ProfileViewController");
            CardsViewController* viewController = [_rootViewController.storyboard
                instantiateViewControllerWithIdentifier:@"CardsViewController"];
            [_rootViewController.navigationController pushViewController:viewController animated:YES];
        } break;
        case ProfileMainSectionRow_MyCars: {
            if (isEnableCarFeature) {
                [PRGoogleAnalyticsManager sendEventWithName:kMyCarsButtonClicked parameters:nil];
                PRCarsViewController* viewController = [_rootViewController.storyboard
                    instantiateViewControllerWithIdentifier:@"PRCarsViewController"];
                [_rootViewController.navigationController pushViewController:viewController animated:YES];
                break;
            }
        };
        case ProfileMainSectionRow_Finances: {
            [PRGoogleAnalyticsManager sendEventWithName:kFinancesButtonClicked parameters:nil];
            _rootViewController.navigationItem.title = @"";
            FinancialReportViewController* financialReportViewController = (FinancialReportViewController*)[_rootViewController.storyboard
                instantiateViewControllerWithIdentifier:@"FinancialReportViewController"];

            [_rootViewController.navigationController pushViewController:financialReportViewController animated:YES];
        } break;
        }
    } break;
    case ProfileInfoSections_Additional: {
        switch (indexPath.row) {
        case ProfileAdditionalSectionRow_Club: {
#if defined(Otkritie) || defined(VTB24) || defined(FormulaKino) || defined(Skolkovo) || defined(Platinum) || defined(PrimeConciergeClub)
            if (![PRDatabase getInformation]) {
                if (dataSource.userProfile) {
                    [self pushToChangePasswordViewController];
                }
            } else {
                [self getInformationDataFromLocalDBAndPresentOnProfilePage];
            }
            break;
#else
            if (dataSource.userProfile && dataSource.userProfile.customerTypeId) {
                [PRGoogleAnalyticsManager sendEventWithName:kClubRulesButtonClicked parameters:nil];
                NSString* title = NSLocalizedString(@"Club rules", );
                [self pushToWebViewControllerWithURL:kClubRulesUrl andTitle:title];
            }
            break;
#endif
        }
        case ProfileAdditionalSectionRow_Reference: {
#if defined(Otkritie) || defined(VTB24) || defined(FormulaKino) || defined(Skolkovo) || defined(Platinum) || defined(PrimeConciergeClub)
            [self.rootViewController alert:NSLocalizedString(@"Are you sure you want to delete your account?", nil)
                                     action:^{ [self deleteAccount]; }
                                     cancel:^{}];
            break;
#else
            if (![PRDatabase getInformation]) {
                if (dataSource.userProfile) {
                    [self pushToChangePasswordViewController];
                }
            } else {
                [self getInformationDataFromLocalDBAndPresentOnProfilePage];
            }
            break;
#endif
        }
        case ProfileAdditionalSectionRow_Password: {
            if (dataSource.userProfile) {
                [self pushToChangePasswordViewController];
            }
        } break;
        case ProfileAdditionalSectionRow_Delete: {
            [self.rootViewController alert:NSLocalizedString(@"Are you sure you want to delete your account?", nil)
                                     action:^{ [self deleteAccount]; }
                                     cancel:^{}];
        } break;
        }
    } break;
    case ProfileInfoSections_PondMobile: {
        NSString* title = @"PondMobile";
        [self pushToWebViewControllerWithURL:kPondMobileRatesUrl andTitle:title];
    } break;
    }
}

- (void)getInformationDataFromLocalDBAndPresentOnProfilePage
{
    [PRGoogleAnalyticsManager sendEventWithName:kReferenceButtonClicked parameters:nil];
    PRInformationModel* informationModel = [PRDatabase getInformation];
    UIStoryboard* mainStoryboard = [Utils mainStoryboard];
    PRInformationNavigationController* informationNavigationController = (PRInformationNavigationController*)[mainStoryboard instantiateViewControllerWithIdentifier:kInformationNavigationController];

    PRInformationViewController* helpSrceen = [[informationNavigationController viewControllers] firstObject];
    [helpSrceen setInformation:informationModel.informationsArray];
    informationNavigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.rootViewController.navigationController presentViewController:informationNavigationController animated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
#if defined(PrimeClubConcierge)
    if (indexPath.section == ProfileInfoSections_Additional && indexPath.row == ProfileAdditionalSectionRow_Club) {
        return CGFLOAT_MIN;
    }
#endif
    if (indexPath.section == ProfileInfoSections_Main && indexPath.row == ProfileMainSectionRow_ProfileCard) {
        return [self cardHeight];
    } else {
        return kProfileTableViewCellHeight;
    }
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
#ifdef Prime
    if ([self needToShowFooterForSection:section]) {
        return kProfileTableViewFooterHeight;
    }
#endif

    return kProfileTableViewFooterHeight + (section == tableView.numberOfSections - 1 ? kProfileTableViewFooterHeight / 2 : 0);
}

- (UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section
{
    return [self footerViewForTableView:tableView];
}

- (void)tableView:(UITableView*)tableView willDisplayFooterView:(UIView*)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView* footer = (UITableViewHeaderFooterView*)view;
    footer.contentView.backgroundColor = [UIColor whiteColor];
    footer.textLabel.textColor = [UIColor colorWithRed:205. / 255 green:205. / 255 blue:205. / 255 alpha:1];

    if ([self needToShowFooterForSection:section]) {
        NSString* buildVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:kCFBundleShortVersionString];
        NSString* buildNumber = [[[NSBundle mainBundle] infoDictionary] objectForKey:kCFBundleVersion];

        NSString* footerText = [NSString stringWithFormat:@"%@ build %@", buildVersion, buildNumber];
        footer.textLabel.font = [UIFont systemFontOfSize:17];
        footer.textLabel.textAlignment = NSTextAlignmentCenter;
#ifndef Prime
        footer.textLabel.numberOfLines = 0;
        footerText = [@"Provided by PRIME\n" stringByAppendingString:footerText];
#ifndef VTB24
        footer.textLabel.font = [UIFont systemFontOfSize:13];
#else
        footer.textLabel.font = [UIFont systemFontOfSize:14];
        footer.textLabel.textColor = [UIColor colorWithRed:180. / 255 green:180. / 255 blue:178. / 255 alpha:1];
        footer.textLabel.textAlignment = NSTextAlignmentLeft;
#endif
        footer.contentView.backgroundColor = [UIColor clearColor];
#endif
        [footer.textLabel setText:footerText];
    }
}

- (UITableViewHeaderFooterView*)footerViewForTableView:(UITableView*)tableView
{
    UITableViewHeaderFooterView* footer = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"Footer"];
    if (!footer) {
        footer = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"Footer"];
    }
    return footer;
}

- (CGFloat)cardHeight
{
    CGFloat screenWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]);
    CGFloat cardHeight = kProfileSelfInfoCellHeight * screenWidth / 400;

#if defined (Prime)  || defined(PrimeClubConcierge)
    cardHeight += isEnableWalletFeature ? kProfileVirtualCardHeight : 0;
#endif

    return cardHeight > kProfileSelfInfoCellMinimumHeight ? cardHeight : kProfileSelfInfoCellMinimumHeight;
}

- (BOOL)needToShowFooterForSection:(NSInteger)section
{
    //Use instead of below code in case, when PondMobile active.
    /*
#ifdef VTB24
    if (section == ProfileInfoSections_Additional) {
        return YES;
    }
#else
    if ([PRDatabase isUserProfileFeatureEnabled:ProfileFeature_PondMobile]) {
        if (section == ProfileInfoSections_PondMobile) {
            return YES;
        }
    } else {
        if (section == ProfileInfoSections_Additional) {
            return YES;
        }
    }
#endif

    return NO;
*/

    return section == ProfileInfoSections_Additional;
}

#pragma mark - Transition

- (void)pushToWebViewControllerWithURL:(NSString*)url andTitle:(NSString*)title
{
    WebViewController* viewController = [_rootViewController.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    viewController.url = url;
    viewController.title = title;
    [_rootViewController.navigationController pushViewController:viewController animated:YES];
}

- (void)pushToChangePasswordViewController
{
    [PRGoogleAnalyticsManager sendEventWithName:kChangePasswordButtonClicked parameters:nil];
    ChangePasswordViewController* changePasswordViewController = [_rootViewController.storyboard instantiateViewControllerWithIdentifier:@"ChangePasswordViewController"];
    [_rootViewController.navigationController pushViewController:changePasswordViewController animated:YES];
}

#pragma mark - Account deletion

- (void)deleteAccount
{
    __weak PRProfileMainTableViewController* weakSelf = self;
    [PRRequestManager deleteAccount:self.rootViewController.view
                               mode:PRRequestMode_ShowErrorMessagesAndProgress
                            success:^{
                                PRProfileMainTableViewController* strongSelf = weakSelf;
                                if (!strongSelf) {
                                    return;
                                }
                                [PRMessageAlert showMessage:Message_AccountDeleted ok:^{
                                    [strongSelf logOut];
                                }];
                            }
                            failure:^{}];
}

- (void)logOut
{
    __weak PRProfileMainTableViewController* weakSelf = self;
    [PRRequestManager logoutWithView:self.rootViewController.view
                                mode:PRRequestMode_ShowNothing
                             success:^{
        PRProfileMainTableViewController* strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }

        [NSUserDefaults.standardUserDefaults setBool:NO forKey:kUserRegistered];
        [NSUserDefaults.standardUserDefaults synchronize];

        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate setInitalViewController];
    } failure:^{}];
}

@end
