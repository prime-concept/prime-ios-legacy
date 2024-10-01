//
//  PRMyProfileViewController.m
//  PRIME
//
//  Created by Mariam on 1/19/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRMyProfileViewController.h"
#import "PRDatabase.h"
#import "PRInfoTableViewCell.h"
#import "PRAddNewDataTableViewCell.h"
#import "PREditProfileInfoViewController.h"
#import "PRMyProfileTableHeaderView.h"
#import "CountriesCodesViewController.h"
#import "AddDocumentViewController.h"
#import "PRPersonalDataViewController.h"
#import "XNAvatar.h"
#import "Reachability.h"
#import "SynchManager.h"
#import "PRPhoneNumberFormatter.h"
#import "DocumentTypeViewController.h"

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

typedef NS_ENUM(NSInteger, SelectedSegment) {
    SelectedSegment_Contacts = 0,
    SelectedSegment_Documents,
    SelectedSegment_FamilyPartners
};

@interface PRMyProfileViewController () <UITableViewDelegate, UITableViewDataSource, ReloadTable>

@property (strong, nonatomic) NSArray<NSArray*>* sourceArray;
@property (strong, nonatomic) NSArray<NSString*>* addInfosArray;
@property (strong, nonatomic) NSDictionary<NSString*, NSArray*>* documents;
@property (strong, nonatomic) NSArray<NSString*>* keysForIndex;

@property (strong, nonatomic) PRUserProfileModel* userProfile;

@property (weak, nonatomic) IBOutlet UISegmentedControl* segmentedControl;
@property (weak, nonatomic) IBOutlet UIView* segmentedControlHeaderView;

@property (weak, nonatomic) IBOutlet UITableView* tableView;
@property (strong, nonatomic) IBOutlet PRMyProfileTableHeaderView* tableHeaderView;
@property (strong, nonatomic) UIView* tableHeaderFooterSmallView;

@end

@implementation PRMyProfileViewController

static NSString* const kInfoCellIdentifier = @"PRInfoTableViewCell";
static NSString* const kAddInfoCellIdentifier = @"PRAddNewDataTableViewCell";
static NSString* const kPassportVisaInfoCellIdentifier = @"PassportVisaInfoCell";
static NSString* const kHeaderFooterViewIdentifier = @"HeaderFooterView";
static CGFloat kTableViewHeaderFontSize = 16.0f;
static CGFloat kTableViewHeaderHeight = 30.0f;
static CGFloat kTableViewFooterHeight = 10.0f;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

#if defined(Raiffeisen) || defined(PrivateBankingPRIMEClub)
    _segmentedControlHeaderView.backgroundColor = kNavigationBarBarTintColor;
    self.navigationController.navigationBar.translucent = NO;
#elif defined(VTB24)
    _segmentedControlHeaderView.backgroundColor = kNavigationBarBarTintColor;
#endif

    self.title = NSLocalizedString(@"My profile", nil);

    [self getProfilePersonalData];
    [self getProfileContacts];
    [self getProfileDocuments];

    _mainContext = [[RKManagedObjectStore defaultStore] newChildManagedObjectContextWithConcurrencyType:NSMainQueueConcurrencyType];

    _userProfile = [PRDatabase getUserProfile];

    [self configureSegmentedControl];
    _segmentedControl.selectedSegmentIndex = SelectedSegment_Contacts;
    [self reload];

    [self configureTableView];
    [self initPullToRefreshForScrollView:_tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    UINavigationBar* navigationBar = self.navigationController.navigationBar;
    [navigationBar hideBottomHairline];
#if Platinum || PrimeRRClub
    [navigationBar setTintColor:kNavigationBarTintColor];
#elif defined(PrivateBankingPRIMEClub)
    [navigationBar setBackgroundColor:kNavigationBarBarTintColor];
#else
    [navigationBar setTintColor:kIconsColor];
#endif
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.lazyManager shouldBeUpdatedIfViewDidAppearWithDate:[NSDate date]
        relativeToDate:nil
        then:^(PRRequestMode mode) {
            [self updateDataIfNeeded];
        }
        otherwiseIfFirstTime:^{
            [_tableView reloadData];
        }
        otherwise:^{

        }];
}

- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView*)view
{
    [self.pullToRefreshView startLoading];

    [self.lazyManager shouldBeRefreshedWithDate:[NSDate date]
        relativeToDate:nil
        then:^(PRRequestMode mode) {
            [self updateDataIfNeeded];
        }
        otherwise:^{
            [self.pullToRefreshView finishLoading];
        }];
}

- (void)updateDataIfNeeded
{
    switch (_segmentedControl.selectedSegmentIndex) {
    case SelectedSegment_Contacts: {
        [self getProfilePersonalData];
        break;
    }
    case SelectedSegment_Documents: {
        [self getProfileDocuments];
        break;
    }
    case SelectedSegment_FamilyPartners: {
        [self getProfileContacts];
        break;
    }
    default: {
        [self.pullToRefreshView finishLoading];
        break;
    }
    }
}

- (void)getProfilePersonalData
{
    __block BOOL getProfileRequestCompleted = NO;
    __block BOOL getProfilePhonesRequestCompleted = NO;
    __block BOOL getProfilePhoneTypesRequestCompleted = NO;
    __block BOOL getProfileEmailsRequestCompleted = NO;
    __block BOOL getProfileEmailTypesRequestCompleted = NO;

    __weak PRMyProfileViewController* weakSelf = self;

    [PRRequestManager getProfileWithView:self.view
        mode:PRRequestMode_ShowNothing
        success:^(PRUserProfileModel* userProfile) {

            PRMyProfileViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            getProfileRequestCompleted = YES;
            if (getProfilePhonesRequestCompleted && getProfileEmailsRequestCompleted && getProfilePhoneTypesRequestCompleted && getProfileEmailTypesRequestCompleted) {
                [strongSelf.pullToRefreshView finishLoading];
            }
            [strongSelf reload];

            [XNAvatar synchronizeWithServer:^(UIImage* image) {
                PRMyProfileViewController* strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                [strongSelf.tableHeaderView updateProfileAvatar:image];
            }];

        }
        failure:^{

            PRMyProfileViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            getProfileRequestCompleted = YES;
            if (getProfilePhonesRequestCompleted && getProfileEmailsRequestCompleted && getProfilePhoneTypesRequestCompleted && getProfileEmailTypesRequestCompleted) {
                [strongSelf.pullToRefreshView finishLoading];
            }
        }];

    [PRRequestManager getProfilePhonesWithView:self.view
        mode:PRRequestMode_ShowNothing
        success:^(NSArray* profilePhones) {
            PRMyProfileViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            getProfilePhonesRequestCompleted = YES;
            if (getProfileRequestCompleted && getProfileEmailsRequestCompleted && getProfilePhoneTypesRequestCompleted && getProfileEmailTypesRequestCompleted) {
                [strongSelf.pullToRefreshView finishLoading];
            }

            [strongSelf reload];
        }
        failure:^{
            PRMyProfileViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            getProfilePhonesRequestCompleted = YES;
            if (getProfileRequestCompleted && getProfileEmailsRequestCompleted && getProfilePhoneTypesRequestCompleted && getProfileEmailTypesRequestCompleted) {
                [strongSelf.pullToRefreshView finishLoading];
            }
        }];

    [PRRequestManager getProfilePhoneTypesWithView:self.view
        mode:PRRequestMode_ShowNothing
        success:^(NSArray* phoneTypes) {
            PRMyProfileViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            getProfilePhoneTypesRequestCompleted = YES;
            if (getProfileRequestCompleted && getProfileEmailsRequestCompleted && getProfilePhonesRequestCompleted && getProfileEmailTypesRequestCompleted) {
                [strongSelf.pullToRefreshView finishLoading];
            }
        }
        failure:^{
            PRMyProfileViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            getProfilePhoneTypesRequestCompleted = YES;
            if (getProfileRequestCompleted && getProfileEmailsRequestCompleted && getProfilePhonesRequestCompleted && getProfileEmailTypesRequestCompleted) {
                [strongSelf.pullToRefreshView finishLoading];
            }
        }];

    [PRRequestManager getProfileEmailsWithView:self.view
        mode:PRRequestMode_ShowNothing
        success:^(NSArray* profileEmails) {
            PRMyProfileViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            getProfileEmailsRequestCompleted = YES;
            if (getProfileRequestCompleted && getProfilePhonesRequestCompleted && getProfilePhoneTypesRequestCompleted && getProfileEmailTypesRequestCompleted) {
                [strongSelf.pullToRefreshView finishLoading];
            }

            [strongSelf reload];
        }
        failure:^{
            PRMyProfileViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            getProfileEmailsRequestCompleted = YES;
            if (getProfileRequestCompleted && getProfilePhonesRequestCompleted && getProfilePhoneTypesRequestCompleted && getProfileEmailTypesRequestCompleted) {
                [strongSelf.pullToRefreshView finishLoading];
            }
        }];

    [PRRequestManager getProfileEmailTypesWithView:self.view
        mode:PRRequestMode_ShowNothing
        success:^(NSArray* emailTypes) {
            PRMyProfileViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            getProfileEmailTypesRequestCompleted = YES;
            if (getProfileRequestCompleted && getProfileEmailsRequestCompleted && getProfilePhonesRequestCompleted && getProfilePhoneTypesRequestCompleted) {
                [strongSelf.pullToRefreshView finishLoading];
            }
        }
        failure:^{
            PRMyProfileViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            getProfileEmailTypesRequestCompleted = YES;
            if (getProfileRequestCompleted && getProfileEmailsRequestCompleted && getProfilePhonesRequestCompleted && getProfilePhoneTypesRequestCompleted) {
                [strongSelf.pullToRefreshView finishLoading];
            }
        }];
}

- (void)getProfileDocuments
{
    __weak PRMyProfileViewController* weakSelf = self;

    [PRRequestManager getDocumentsWithView:self.view
        mode:PRRequestMode_ShowNothing
        success:^{
            PRMyProfileViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            [strongSelf.pullToRefreshView finishLoading];
            [strongSelf reload];
        }
        failure:^{
            PRMyProfileViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            [strongSelf.pullToRefreshView finishLoading];
        }];
}

- (void)getProfileContacts
{
    __block BOOL getProfileContactsCompleted = NO;
    __block BOOL getProfileContactTypesCompleted = NO;

    __weak PRMyProfileViewController* weakSelf = self;

    [PRRequestManager getProfileContactsWithView:self.view
        mode:PRRequestMode_ShowNothing
        success:^(NSArray* selfContacts) {
            PRMyProfileViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            getProfileContactsCompleted = YES;
            if (getProfileContactTypesCompleted) {
                [strongSelf.pullToRefreshView finishLoading];
            }
            [strongSelf reload];
        }
        failure:^{
            PRMyProfileViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            getProfileContactsCompleted = YES;
            if (getProfileContactTypesCompleted) {
                [strongSelf.pullToRefreshView finishLoading];
            }
        }];

    [PRRequestManager getProfileContactTypesWithView:self.view
        mode:PRRequestMode_ShowNothing
        success:^(NSArray* contactTypes) {

            PRMyProfileViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            getProfileContactTypesCompleted = YES;
            if (getProfileContactsCompleted) {
                [strongSelf.pullToRefreshView finishLoading];
            }
        }
        failure:^{

            PRMyProfileViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            getProfileContactTypesCompleted = YES;
            if (getProfileContactsCompleted) {
                [strongSelf.pullToRefreshView finishLoading];
            }
        }];
}

- (void)reachabilityChanged:(NSNotification*)note
{
    if (![PRRequestManager connectionRequired] && !_isSynchedFromOffline) {
        //

        for (PRProfilePhoneModel* phone in [PRDatabase profilePhones:_mainContext]) {
            if (!phone.phoneId && [phone.state isEqualToNumber:@(ModelStatus_Updated)]) {
                phone.state = @(ModelStatus_Added);
            }
        }

        for (PRProfileEmailModel* email in [PRDatabase profileEmails:_mainContext]) {
            if (!email.emailId && [email.state isEqualToNumber:@(ModelStatus_Updated)]) {
                email.state = @(ModelStatus_Added);
            }
        }

        for (PRProfileContactModel* contact in [PRDatabase profileContacts:_mainContext]) {
            if ((!contact.contactId || [contact.contactId isEqual:@0]) && [contact.state isEqualToNumber:@(ModelStatus_Updated)]) {
                contact.state = @(ModelStatus_Added);
            }
        }

        [[SynchManager sharedClient] synchProfilePersonalDataInContext:_mainContext
                                                                  view:nil
                                                                  mode:PRRequestMode_ShowNothing
                                                            completion:^{
                                                            }];

        [[SynchManager sharedClient] synchProfileContactsInContext:_mainContext
                                                              view:nil
                                                              mode:PRRequestMode_ShowNothing
                                                        completion:^{
                                                        }];

        _isSynchedFromOffline = YES;
    }

    [self.lazyManager shouldBeUpdatedIfReachabilityChangedWithNotification:note
                                                                      date:[NSDate date]
                                                            relativeToDate:nil
                                                                      then:^(PRRequestMode mode) {
                                                                          [self updateDataIfNeeded];
                                                                      }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    if (_segmentedControl.selectedSegmentIndex == SelectedSegment_Documents) {
        return _documents.count + 1;
    }
    return _sourceArray.count;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_segmentedControl.selectedSegmentIndex == SelectedSegment_Documents) {
        if (section == [tableView numberOfSections] - 1) {
            return 1;
        }
        return [_documents objectForKey:_keysForIndex[section]].count;
    }
    return [_sourceArray objectAtIndex:section].count + 1;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (_segmentedControl.selectedSegmentIndex == SelectedSegment_Documents) {
        if (indexPath.section == [tableView numberOfSections] - 1) {
            PRAddNewDataTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kAddInfoCellIdentifier];
            [cell configureCellWithText:_addInfosArray[0]];
            return cell;
        }
    } else {
        if ([self isLastIndexPath:indexPath]) {
                PRAddNewDataTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kAddInfoCellIdentifier];
                [cell configureCellWithText:[_addInfosArray objectAtIndex:indexPath.section]];
                return cell;
        }
    }
    switch (_segmentedControl.selectedSegmentIndex) {

    case SelectedSegment_Contacts:
        return [self infoCellForIndexPath:indexPath];

    case SelectedSegment_Documents: {

        PRInfoTableViewCell* cell = [_tableView dequeueReusableCellWithIdentifier:kPassportVisaInfoCellIdentifier];
        PRDocumentModel* data = (PRDocumentModel*)[_documents objectForKey:_keysForIndex[indexPath.section]][indexPath.row];

        NSString* country = [Utils countryNameFromCode:data.countryCode ?: COUNTRY_CODE_RUSSIA];
        UIImage* flag = [Utils countryFlagFromCode:data.countryCode ?: COUNTRY_CODE_RUSSIA];

        if ([PRDatabase isPassport:data.documentType]) {
            [cell configureCellWithInfo:data.documentNumber placeholder:NSLocalizedString(@"Passport Number", nil) detail:country andImage:flag];
        } else if ([data.documentType integerValue] == 2) {
            NSString* localizedDetail;
            if (!data.expiryDate || [data.expiryDate isEqualToString:@""]) {
                localizedDetail = @"";
            } else {
                NSString* detail = [Utils fromMillisecondsToFormattedDate:data.expiryDate];
                localizedDetail = [NSLocalizedString(@"until: ", nil) stringByAppendingString:detail];
            }
            [cell configureCellWithInfo:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Visa", nil), NSLocalizedString(country, nil)] detail:localizedDetail andImage:flag];
        } else {
            cell = [_tableView dequeueReusableCellWithIdentifier:kInfoCellIdentifier];
            [cell configureCellWithInfo:NSLocalizedString(@"Document", nil) placeholder:NSLocalizedString(@"Document Number", nil) andDetail:data.documentNumber];
        }

        return cell;
    }

    case SelectedSegment_FamilyPartners: {

        PRInfoTableViewCell* cell = [_tableView dequeueReusableCellWithIdentifier:kInfoCellIdentifier];
        PRProfileContactModel* contact = (PRProfileContactModel*)[self objectForIndexPath:indexPath];

        NSString* firstName = contact.firstName ?: @"";
        NSString* lastName = contact.lastName ?: @"";
        NSString* space = contact.firstName.length > 0 ? @" " : @"";
        NSString* contactName = [NSString stringWithFormat:@"%@%@%@", firstName, space, lastName];

        [cell configureCellWithInfo:contactName andDetail:contact.contactType.typeName];
        return cell;
    }
    default:
        return nil;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    if (_segmentedControl.selectedSegmentIndex == SelectedSegment_Documents) {
        if (section == [tableView numberOfSections] - 1) {
            return kTableViewHeaderHeight;
        }
        return kTableViewFooterHeight;
    }
    return section == 0 ? kTableViewHeaderHeight : CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    if (_segmentedControl.selectedSegmentIndex == SelectedSegment_Documents) {
        if (section == [tableView numberOfSections] - 1) {
            return 0;
        }
        return kTableViewHeaderHeight;
    }
    return CGFLOAT_MIN;
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    if (_segmentedControl.selectedSegmentIndex == SelectedSegment_Documents) {
        if ([tableView numberOfRowsInSection:section] == 0) {
            return nil;
        }
        NSString* sectionTitle = nil;
        if (section != [tableView numberOfSections] - 1) {
            sectionTitle = _keysForIndex[section];
        }

        UITableViewHeaderFooterView* headerView = [self headerFooterViewForTableView:tableView];

        headerView.textLabel.font = [UIFont systemFontOfSize:kTableViewHeaderFontSize];
        [headerView.textLabel setText:[NSLocalizedString(sectionTitle, ) uppercaseString]];
        return headerView;
    }
    return  nil;
}

- (UITableViewHeaderFooterView*)headerFooterViewForTableView:(UITableView*)tableView
{
    UITableViewHeaderFooterView* headerFooterView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kHeaderFooterViewIdentifier];
    if (!headerFooterView) {
        headerFooterView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:kHeaderFooterViewIdentifier];
    }

    return headerFooterView;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 45.f;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    switch (_segmentedControl.selectedSegmentIndex) {
    case SelectedSegment_Contacts: {
        [self openAddInfoViewControllerWithIndexpath:indexPath];
        break;
    }
    case SelectedSegment_Documents: {
        [self openAddDocumentViewControllerWithIndexpath:indexPath];
        break;
    }
    case SelectedSegment_FamilyPartners: {
        [self openPersonalDataViewControllerWithIndexpath:indexPath];
        break;
    }
    default:
        break;
    }
}

#pragma mark - UISegmentedControl

- (IBAction)segmentedControlAction:(UISegmentedControl*)sender
{
    [self.pullToRefreshView finishLoading];

    switch (sender.selectedSegmentIndex) {
    case SelectedSegment_Contacts: {
        [PRGoogleAnalyticsManager sendEventWithName:kMyProfileSegmentContactsClicked parameters:nil];
        [self loadTableWithSourceArray:@[ [PRDatabase profilePhones:_mainContext], [PRDatabase profileEmails:_mainContext] ]
                         addInfosArray:@[ NSLocalizedString(@"add phone", nil), NSLocalizedString(@"add email", nil) ]
                            showHeader:YES];
        break;
    }
    case SelectedSegment_Documents: {
        [PRGoogleAnalyticsManager sendEventWithName:kMyProfileSegmentDocumentsClicked parameters:nil];
        if ([PRDocumentTypeModel MR_findAll].count == 0) {
            __weak PRMyProfileViewController* weakSelf = self;
            [PRRequestManager getDocumentTypesWithView:self.view
                                                  mode:PRRequestMode_ShowNothing
                                               success:^(NSArray* result) {
                                                   PRMyProfileViewController* strongSelf = weakSelf;
                                                   if (!strongSelf) {
                                                       return ;
                                                   }
                                                   [strongSelf reload];
                                               }
                                               failure:^{
                                                   
                                               }];
        }
        [self loadTableWithSourceDictionary:[PRDatabase getDocumentsDictionary]
                              addInfosArray:@[ NSLocalizedString(@"add document", nil) ]
                                 showHeader:NO];
        break;
    }
    case SelectedSegment_FamilyPartners: {
        [PRGoogleAnalyticsManager sendEventWithName:kMyProfileSegmentFamilyPartnersClicked parameters:nil];
        NSMutableArray<PRProfileContactModel*>* contactsArray = [[PRDatabase profileContacts:_mainContext] mutableCopy];

        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"SELF.contactType.typeId IN %@", @[ @1, @5, @6 ]];
        NSArray<PRProfileContactModel*>* familyArray = [contactsArray filteredArrayUsingPredicate:predicate];
        [contactsArray removeObjectsInArray:familyArray];

        [self loadTableWithSourceArray:@[ familyArray, contactsArray ]
                         addInfosArray:@[ NSLocalizedString(@"add family", nil), NSLocalizedString(@"add partner", nil) ]
                            showHeader:NO];
        break;
    }
    default:
        break;
    }
}

#pragma mark - Private Methods

- (void)loadTableWithSourceArray:(NSArray<NSArray*>*)sourceArray addInfosArray:(NSArray*)infosArray showHeader:(BOOL)show
{
    _sourceArray = sourceArray;
    _addInfosArray = infosArray;
    _tableView.tableHeaderView = show ? _tableHeaderView : _tableHeaderFooterSmallView;
    [_tableView reloadData];
}

- (void)loadTableWithSourceDictionary:(NSDictionary<NSString*, NSArray*>*)sourceDictionary addInfosArray:(NSArray*)infosArray showHeader:(BOOL)show
{
    _documents = sourceDictionary;
    _keysForIndex = [_documents allKeys];
    _addInfosArray = infosArray;
    _tableView.tableHeaderView = show ? _tableHeaderView : _tableHeaderFooterSmallView;
    [_tableView reloadData];
}

- (void)configureTableView
{
    _tableView.delegate = self;
    _tableView.dataSource = self;

    [_tableView setBackgroundView:nil];
    _tableView.backgroundColor = kWhiteColor;
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, -20, 0);

    _tableHeaderFooterSmallView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
    _tableView.tableFooterView = _tableHeaderFooterSmallView;
}

- (void)configureSegmentedControl
{
#if defined(Platinum) || defined(VTB24)
    _segmentedControl.tintColor = kSegmentedControlTaskStatusColor;
#elif defined(PrivateBankingPRIMEClub) || defined(PrimeRRClub)
    _segmentedControl.tintColor = kReservesOrRequestsSegmentColor;
#else
    _segmentedControl.tintColor = kIconsColor;
#endif

    _segmentedControl.backgroundColor = [self getNavigationBarColor];
#if defined(VTB24) || defined(Raiffeisen) || defined(PrivateBankingPRIMEClub)
    [_segmentedControl ensureiOS12Style];
#endif

    [_segmentedControl setTitle:NSLocalizedString(@"Contacts", nil)
              forSegmentAtIndex:0];
    [_segmentedControl setTitle:NSLocalizedString(@"Documents", nil) forSegmentAtIndex:1];
    [_segmentedControl setTitle:NSLocalizedString(@"Family/Partners", nil) forSegmentAtIndex:2];

    for (int i = 0; i < [_segmentedControl subviews].count; i++) {
        for (UIView* view in [[[_segmentedControl subviews] objectAtIndex:i] subviews]) {
            if ([view isKindOfClass:[UILabel class]]) {
                [(UILabel*)view setAdjustsFontSizeToFitWidth:YES];
            }
        }
    }
}

- (PRInfoTableViewCell*)infoCellForIndexPath:(NSIndexPath*)indexpath
{
    PRInfoTableViewCell* cell = [_tableView dequeueReusableCellWithIdentifier:kInfoCellIdentifier];
    if (indexpath.section == 0) {
        PRProfilePhoneModel* phone = [self objectForIndexPath:indexpath];
        [cell configureCellWithInfo:[PRPhoneNumberFormatter formatedStringForPhone:phone.phone] andDetail:phone.phoneType.typeName];
        return cell;
    }

    PRProfileEmailModel* email = [self objectForIndexPath:indexpath];
    [cell configureCellWithInfo:email.email andDetail:email.emailType.typeName];
    return cell;
}

- (BOOL)isLastIndexPath:(NSIndexPath*)indexPath
{
    return indexPath.row == [_tableView numberOfRowsInSection:indexPath.section] - 1;
}

- (id)objectForIndexPath:(NSIndexPath*)indexPath
{
    return [[_sourceArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
}

#pragma mark - Public Methods

- (void)reload
{
    [self segmentedControlAction:_segmentedControl];
}

#pragma mark - Actions

- (void)openAddDocumentViewControllerWithIndexpath:(NSIndexPath*)indexPath
{
    if (indexPath.section == _keysForIndex.count) {
        DocumentTypeViewController* viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DocumentTypeViewController"];
        viewController.dataSource = self;
        viewController.documentData = nil;
        viewController.title = NSLocalizedString(@"Document types", );
        [self.navigationController pushViewController:viewController animated:YES];
        return;
    }
    AddDocumentViewController* viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddDocumentViewController"];
    viewController.parentView = self;
    viewController.userProfile = _userProfile;

    NSArray<PRDocumentModel*>* items = [_documents objectForKey:_keysForIndex[indexPath.section]];

    if (items != nil && indexPath.row < [items count]) {
        PRDocumentModel* model = ((PRDocumentModel*)items[indexPath.row]);
        viewController.documentId = model.documentId;
        viewController.type = model.documentType;

        if (model.documentType != nil) {
        NSString* typeName = [PRDatabase getDocumentTypeForId:model.documentType].name;
        viewController.title = NSLocalizedString(typeName, );
        }
    }
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)openAddInfoViewControllerWithIndexpath:(NSIndexPath*)indexPath
{
    PREditProfileInfoViewController* viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PREditProfileInfoViewController"];

    [viewController setEditingType:(indexPath.section == 0) ? EditingModelType_Phone : EditingModelType_Email
                             model:[self isLastIndexPath:indexPath] ? nil : [self objectForIndexPath:indexPath]
                           context:_mainContext
                            parent:self];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)openPersonalDataViewControllerWithIndexpath:(NSIndexPath*)indexPath
{
    PRPersonalDataViewController* viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PRPersonalDataViewController"];
    viewController.contactModel = [self isLastIndexPath:indexPath] ? nil : (PRProfileContactModel*)[self objectForIndexPath:indexPath];
    viewController.mainContext = _mainContext;
    viewController.myProfileViewController = self;
    viewController.profileContactType = indexPath.section == 0 ? ProfileContactType_AddFamily : ProfileContactType_AddPartner;
    viewController.contactModel ?
                    [PRGoogleAnalyticsManager sendEventWithName:(indexPath.section == 0 ? kMyProfileEditFamilyButtonClicked : kMyProfileEditPartnerButtonClicked)
                                                     parameters:nil] :
                    [PRGoogleAnalyticsManager sendEventWithName:(indexPath.section == 0 ? kMyProfileAddFamilyButtonClicked : kMyProfileAddPartnerButtonClicked)
                                                     parameters:nil];
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)deleteDocumentWithId:(NSNumber*)documentId
{
    PRDocumentModel* model = [PRDatabase getDocumentById:documentId];
    if (!model) {
        return;
    }

    __weak PRMyProfileViewController* weakSelf = self;
    [PRRequestManager deleteDocument:model
                                view:self.view
                                mode:PRRequestMode_ShowErrorMessagesAndProgress
                             success:^{
                                 PRMyProfileViewController* strongSelf = weakSelf;
                                 if (!strongSelf) {
                                     return;
                                 }
                                 [strongSelf reload];
                             }
                             failure:^{}];
}

@end
