//
//  ProfileMainDataSource.m
//  PRIME
//
//  Created by Artak on 2/3/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "ProfileMainDataSource.h"
#import "XNAvatar.h"
#import "PRProfileDataCell.h"

static NSString* const kPRProfileDataCell = @"PRProfileDataCell";
static NSString* const kProfileImageCell = @"ProfileImageCell";
static NSString* const kAeroflotProfileImageCell = @"AeroflotProfileImageCell";

@implementation ProfileMainDataSource

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return ProfileInfoSections_Count - 1;

    //Use instead of above code in case, when PondMobile active.
    /*
#ifdef VTB24
    return ProfileInfoSections_Count - 1;
#else
    return [PRDatabase isUserProfileFeatureEnabled:ProfileFeature_PondMobile] ? ProfileInfoSections_Count : ProfileInfoSections_Count - 1;
#endif
 */
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == ProfileInfoSections_Main) {
#if PrimeConciergeClub
        return isEnableCarFeature ? ProfileMainSectionRow_Count - 2 : ProfileMainSectionRow_Count - 3;
#endif
        return isEnableCarFeature ? ProfileMainSectionRow_Count : ProfileMainSectionRow_Count - 1;
    } else if (section == ProfileInfoSections_Additional) {

#if defined(Imperia) || defined(Otkritie) || defined(Raiffeisen) || defined(VTB24) || defined(FormulaKino) || defined(Skolkovo) || defined(Platinum) || defined(PrimeConciergeClub)
        if (![PRDatabase getInformation]) {
            return ProfileAdditionalSectionRow_Count - 2;
        }
        return ProfileAdditionalSectionRow_Count - 1;
#else
        if (![PRDatabase getInformation]) {
            return ProfileAdditionalSectionRow_Count - 1;
        }
        return ProfileAdditionalSectionRow_Count;
#endif
    } else {
        return 1;
    }
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == ProfileInfoSections_Main && indexPath.row == ProfileMainSectionRow_ProfileCard) {
        return [self selfInfoCellForTableView:tableView];
    }

    return [self dataCellForTableView:tableView forIndexPath:indexPath];
}

#pragma mark - Profile Card

- (UITableViewCell*)selfInfoCellForTableView:(UITableView*)tableView
{
    UITableViewCell<PRProfileCardDataSource>* cell;

#if defined(Otkritie) || defined(Platinum)
    cell = [tableView dequeueReusableCellWithIdentifier:kAeroflotProfileImageCell];
#else
    cell = [tableView dequeueReusableCellWithIdentifier:kProfileImageCell];
#endif

    if (!_userProfile) {
        _userProfile = [PRDatabase getUserProfile];
    }

    return [cell configureCellForUserProfile:_userProfile withWidth:CGRectGetWidth(tableView.bounds) isWalletFeatureEnabled:isEnableWalletFeature _:self.displayWeb];
}

#pragma mark - Functionality

- (PRProfileDataCell*)dataCellForTableView:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath
{
    PRProfileDataCell* cell = [tableView dequeueReusableCellWithIdentifier:kPRProfileDataCell];
    cell.separatorInset = UIEdgeInsetsMake(0.f, CGRectGetWidth(tableView.bounds), 0.f, CGRectGetWidth(tableView.bounds) - 50);

    switch (indexPath.section) {
    case ProfileInfoSections_Main: {
        switch (indexPath.row) {
        case ProfileMainSectionRow_MyProfile: {
            [cell configureCellByText:NSLocalizedString(@"My profile", nil) andImage:[self imageWithName:@"profile"]];
        } break;
        case ProfileMainSectionRow_MyCards: {
            [cell configureCellByText:NSLocalizedString(@"My cards", nil) andImage:[self imageWithName:@"profileCard"]];
        } break;
        case ProfileMainSectionRow_MyCars: {
            if (isEnableCarFeature) {
                [cell configureCellByText:NSLocalizedString(@"My cars", nil) andImage:[self imageWithName:@"profileCar"]];
                break;
            }
        }
        case ProfileMainSectionRow_Finances: {
            [cell configureCellByText:NSLocalizedString(@"Finances", nil) andImage:[self imageWithName:@"profileFinance"]];
        } break;
        default: {
            return nil;
        }
        }

        return cell;
    } break;
    case ProfileInfoSections_Additional: {
        switch (indexPath.row) {
        case ProfileAdditionalSectionRow_Club: {
#if defined(Imperia) || defined(Otkritie) || defined(VTB24) || defined(FormulaKino) || defined(Skolkovo) || defined(Platinum) || defined(PrimeConciergeClub)
            if (![PRDatabase getInformation]) {
                [cell configureCellByText:NSLocalizedString(@"Change password", nil)
                                 andImage:[self imageWithName:@"profilePassword"]];
            } else {
                [cell configureCellByText:NSLocalizedString(@"Reference", nil)
                                 andImage:[self imageWithName:@"profileReference"]];
            }

            break;
#else
            [cell configureCellByText:NSLocalizedString(@"Club rules", nil)
                             andImage:[self imageWithName:@"profileRules"]];
            break;
#endif
        }

        case ProfileAdditionalSectionRow_Reference: {
#if defined(Imperia) || defined(Otkritie) || defined(VTB24) || defined(FormulaKino) || defined(Skolkovo) || defined(Platinum) || defined(PrimeConciergeClub)
            [cell configureCellByText:NSLocalizedString(@"Delete account", nil) andImage: nil];
            break;
#else
            if (![PRDatabase getInformation]) {
                [cell configureCellByText:NSLocalizedString(@"Change password", nil) andImage:[self imageWithName:@"profilePassword"]];

            } else {
                [cell configureCellByText:NSLocalizedString(@"Reference", nil)
                                 andImage:[self imageWithName:@"profileReference"]];
            }
            break;
#endif
        }
        case ProfileAdditionalSectionRow_Password: {
            [cell configureCellByText:NSLocalizedString(@"Change password", nil) andImage:[self imageWithName:@"profilePassword"]];
        } break;
        case ProfileAdditionalSectionRow_Delete: {
            [cell configureCellByText:NSLocalizedString(@"Delete account", nil) andImage: nil];
        } break;
        default: {
            return nil;
        }
        }

        return cell;
    } break;
    case ProfileInfoSections_PondMobile: {
        [cell configureCellByText:NSLocalizedString(@"PondMobile", nil) andImage:nil];

        return cell;
    } break;
    default: {
        return nil;
    }
    }
}

- (UIImage*)imageWithName:(NSString*)name
{
#ifdef Otkritie
    return [UIImage imageNamed:[@"open_" stringByAppendingString:name]];
#endif

#ifdef Platinum
    return [UIImage imageNamed:[@"aeroflot_" stringByAppendingString:name]];
#endif

#ifdef Skolkovo
    return [UIImage imageNamed:[@"skolkovo_" stringByAppendingString:name]];
#endif

#ifdef PrimeConciergeClub
    return [UIImage imageNamed:[@"tinkoff_" stringByAppendingString:name]];
#endif

#ifdef VTB24
    return [UIImage imageNamed:[@"vtb_" stringByAppendingString:name]];
#endif

#ifdef PrivateBankingPRIMEClub
    return [UIImage imageNamed:[@"gazprombank_" stringByAppendingString:name]];
#endif

#ifdef PrimeRRClub
    return [UIImage imageNamed:[@"rrclub_" stringByAppendingString:name]];
#endif

#ifdef Davidoff
    return [UIImage imageNamed:[@"davidoff_" stringByAppendingString:name]];
#endif

#ifdef PrimeClubConcierge
    return [UIImage imageNamed:[@"aclub_" stringByAppendingString:name]];
#endif

    return [[UIImage imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

@end
