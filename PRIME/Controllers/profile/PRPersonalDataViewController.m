//
//  PRPersonalDataViewController.m
//  PRIME
//
//  Created by Mariam on 1/26/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRPersonalDataViewController.h"
#import "PRInfoTableViewCell.h"
#import "PREditInfoTableViewCell.h"
#import "PRAddNewDataTableViewCell.h"
#import "PREditProfileInfoViewController.h"
#import "AddDocumentViewController.h"
#import "CustomActionSheetViewController.h"
#import "CustomActionSheetViewController+Picker.h"
#import "TPKeyboardAvoidingTableView.h"
#import <CountryPicker.h>
#import "SynchManager.h"
#import "ProfileViewController.h"
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

#define contactNotSynchedInOfflineMode (!_contactModel.contactId || [_contactModel.contactId isEqual:@0]) && [PRRequestManager connectionRequired]

typedef NS_ENUM(NSInteger, SelectedSegment) {
    SelectedSegment_PersonalData = 0,
    SelectedSegment_Documents
};

typedef NS_ENUM(NSInteger, TableSection) {
    TableSection_Info = 0,
    TableSection_Phones,
    TableSection_Emails,
    TableSection_Delete
};

typedef NS_ENUM(NSInteger, TableInfoSectionRow) {
    TableInfoSectionRow_LastName = 0,
    TableInfoSectionRow_FirstName,
    TableInfoSectionRow_MiddleName,
    TableInfoSectionRow_BirthDate,
    TableInfoSectionRow_ContactType
};

typedef NS_ENUM(NSInteger, ActionSheetSelectedType) {
    ActionSheetSelectedType_ContactType = 0,
    ActionSheetSelectedType_BirthDate
};

@interface PRPersonalDataViewController () <SelectionViewControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, ReloadTable> {
    BOOL _saveButtonIsPressed;
}

@property (strong, nonatomic) PRUserProfileModel* userProfile;
@property (strong, nonatomic) NSMutableArray<NSString*>* personalDataArray;
@property (strong, nonatomic) NSArray<PRProfileContactPhoneModel*>* phones;
@property (strong, nonatomic) NSArray<PRProfileContactEmailModel*>* emails;
@property (strong, nonatomic) NSDictionary<NSString*, NSArray*>* documents;
@property (strong, nonatomic) NSArray<NSString*>* keysForIndex;

@property (strong, nonatomic) NSArray<PRContactTypeModel*>* contactTypes;
@property (strong, nonatomic) NSArray<NSArray*>* sourceArray;
@property (strong, nonatomic) NSArray<NSString*>* addInfosArray;
@property (strong, nonatomic) NSArray<NSString*>* placeholdersArray;

@property (strong, nonatomic) CustomActionSheetViewController* typeSelectionViewController;
@property (assign, nonatomic) ActionSheetSelectedType actionSheetSelectedType;
@property (strong, nonatomic) NSNumber* selectedTypeId;
@property (strong, nonatomic) NSNumber* contactStatus;

@property (weak, nonatomic) IBOutlet UISegmentedControl* segmentedControl;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingTableView* tableView;
@property (weak, nonatomic) IBOutlet UIView* segmentedControlHeaderView;
@property (readwrite, nonatomic, assign, setter=setContactHasChanges:) BOOL contactHasChanges;

@end

@implementation PRPersonalDataViewController
static NSString* const kInfoCellIdentifier = @"PRInfoTableViewCell";
static NSString* const kAddInfoCellIdentifier = @"PRAddNewDataTableViewCell";
static NSString* const kHeaderFooterViewIdentifier = @"HeaderFooterView";
static CGFloat kTableViewHeaderFontSize = 16.0f;
static CGFloat kTableViewHeaderHeight = 30.0f;
static CGFloat kTableViewFooterHeight = 10.0f;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];

#if defined(Raiffeisen) || defined(PrivateBankingPRIMEClub)
    _segmentedControlHeaderView.backgroundColor = kNavigationBarBarTintColor;
    self.navigationController.navigationBar.translucent = NO;
#elif defined (VTB24)
    _segmentedControlHeaderView.backgroundColor = kNavigationBarBarTintColor;
#endif

    if (_contactModel) {

        self.title = [NSString stringWithFormat:@"%@ %@", _contactModel.firstName ?: @"", _contactModel.lastName ?: @""];
        _profileContactType = ProfileContactType_Update;
        _contactStatus = @(ModelStatus_Updated);

        if (contactNotSynchedInOfflineMode) {
            _phones = [_contactModel.phones array];
            _emails = [_contactModel.emails array];
            NSArray* docs = [_contactModel.documents array];
            NSArray<PRDocumentTypeModel*>* documentTypes = [PRDocumentTypeModel MR_findAll];
            for (NSInteger i=0; i<documentTypes.count; i++) {
                NSPredicate* predicate = [NSPredicate predicateWithFormat:@"documentType = %@", documentTypes[i].typeId];
                NSArray* docsByType = [docs filteredArrayUsingPredicate:predicate];
                [_documents setValue:docsByType forKey:documentTypes[i].name];
            }
        } else {
            _phones = [PRDatabase profileContactNonDeletedPhonesForContactId:_contactModel.contactId inContext:_mainContext];
            _emails = [PRDatabase profileContactNonDeletedEmailsForContactId:_contactModel.contactId inContext:_mainContext];
            _documents = [PRDatabase getProfileContactDocumentsDictionaryForContact:_contactModel.contactId inContext:_mainContext];
        }
    } else {
        self.title = NSLocalizedString(@"add contact", nil);
        _contactStatus = @(ModelStatus_Added);
        _phones = [NSArray new];
        _emails = [NSArray new];
        _documents = [NSDictionary new];
    }

    _placeholdersArray = @[ NSLocalizedString(@"Last name", nil), NSLocalizedString(@"First name", nil), NSLocalizedString(@"Middle name", nil), NSLocalizedString(@"Date of Birth", nil) ];

    _contactTypes = [self contactTypes];
    [self configurePersonalData];

    [self configureSegmentedControl];
    _segmentedControl.selectedSegmentIndex = 0;
    [self segmentedControlAction:_segmentedControl];

    [self configureTableView];

    if (_contactModel && ![PRRequestManager connectionRequired]) {
        [self getContactDataFromServer];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    UINavigationBar* navigationBar = self.navigationController.navigationBar;
    [navigationBar hideBottomHairline];
#if defined(Platinum) || defined(PrivateBankingPRIMEClub) || defined(PrimeRRClub)
    [navigationBar setTintColor:kNavigationBarTintColor];
#else
    [navigationBar setTintColor:kIconsColor];
#endif
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound && !_saveButtonIsPressed) {
        [_myProfileViewController.mainContext rollback];
    }
    [super viewWillDisappear:animated];
}

- (void)reload
{
    [self segmentedControlAction:_segmentedControl];
}

- (void)getContactDataFromServer
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    __block BOOL getProfileContactEmailsRequestCompleted = NO;
    __block BOOL getProfileContactPhonesRequestCompleted = NO;
    __block BOOL getProfileContactDocumentsRequestCompleted = NO;

    __weak PRPersonalDataViewController* weakSelf = self;

    [PRRequestManager getProfileContactEmailsWithContactId:_contactModel.contactId
        view:self.view
        mode:PRRequestMode_ShowNothing
        success:^(NSArray* contactEmails) {

            PRPersonalDataViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            for (PRProfileContactEmailModel* email in contactEmails) {
                if (!email.profileContact) {
                    PRProfileContactEmailModel* emailModel = [email MR_inContext:strongSelf.mainContext];
                    emailModel.profileContact = strongSelf.contactModel;
                    [strongSelf.mainContext saveToPersistentStore:nil];
                }
            }

            strongSelf.emails = [PRDatabase profileContactNonDeletedEmailsForContactId:strongSelf.contactModel.contactId inContext:strongSelf.mainContext];
            [strongSelf reload];

            getProfileContactEmailsRequestCompleted = YES;
            if (getProfileContactPhonesRequestCompleted && getProfileContactDocumentsRequestCompleted) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }
        }
        failure:^{

            PRPersonalDataViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            strongSelf.emails = [PRDatabase profileContactNonDeletedEmailsForContactId:strongSelf.contactModel.contactId
                                                                             inContext:strongSelf.mainContext];
            [strongSelf reload];

            getProfileContactEmailsRequestCompleted = YES;
            if (getProfileContactPhonesRequestCompleted && getProfileContactDocumentsRequestCompleted) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }
        }];

    [PRRequestManager getProfileContactPhonesWithContactId:_contactModel.contactId
        view:self.view
        mode:PRRequestMode_ShowNothing
        success:^(NSArray* contactPhones) {

            PRPersonalDataViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            for (PRProfileContactPhoneModel* phone in contactPhones) {
                if (!phone.profileContact) {
                    PRProfileContactPhoneModel* phoneModel = [phone MR_inContext:strongSelf.mainContext];
                    phoneModel.profileContact = strongSelf.contactModel;
                    [strongSelf.mainContext saveToPersistentStore:nil];
                }
            }

            strongSelf.phones = [PRDatabase profileContactNonDeletedPhonesForContactId:strongSelf.contactModel.contactId inContext:strongSelf.mainContext];
            ;
            [strongSelf reload];

            getProfileContactPhonesRequestCompleted = YES;
            if (getProfileContactEmailsRequestCompleted && getProfileContactDocumentsRequestCompleted) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }
        }
        failure:^{

            PRPersonalDataViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            strongSelf.phones = [PRDatabase profileContactNonDeletedPhonesForContactId:strongSelf.contactModel.contactId
                                                                             inContext:strongSelf.mainContext];
            [strongSelf reload];

            getProfileContactPhonesRequestCompleted = YES;
            if (getProfileContactEmailsRequestCompleted && getProfileContactDocumentsRequestCompleted) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }
        }];

    [PRRequestManager getProfileContactDocumentsWithContactId:_contactModel.contactId
        view:self.view
        mode:PRRequestMode_ShowNothing
        success:^(NSArray* contactDocuments) {

            PRPersonalDataViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            for (PRProfileContactDocumentModel* document in contactDocuments) {
                if (!document.profileContact) {
                    PRProfileContactDocumentModel* documentModel = [document MR_inContext:strongSelf.mainContext];
                    documentModel.profileContact = strongSelf.contactModel;
                    [strongSelf.mainContext saveToPersistentStore:nil];
                }
            }

            strongSelf.documents = [PRDatabase getProfileContactDocumentsDictionaryForContact:strongSelf.contactModel.contactId inContext:_mainContext];
            ;

            [strongSelf reload];

            getProfileContactDocumentsRequestCompleted = YES;
            if (getProfileContactEmailsRequestCompleted && getProfileContactPhonesRequestCompleted) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }
        }
        failure:^{

            PRPersonalDataViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            strongSelf.documents = [PRDatabase getProfileContactDocumentsDictionaryForContact:strongSelf.contactModel.contactId inContext:_mainContext];
            [strongSelf reload];

            getProfileContactDocumentsRequestCompleted = YES;
            if (getProfileContactEmailsRequestCompleted && getProfileContactPhonesRequestCompleted) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }
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
    if (_segmentedControl.selectedSegmentIndex == SelectedSegment_PersonalData && (section == TableSection_Info || section == TableSection_Delete)) {
        return [_sourceArray objectAtIndex:section].count;
    }
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
        if (indexPath.section != TableSection_Delete && [self isLastIndexPath:indexPath] && indexPath.section != TableSection_Info) {
            PRAddNewDataTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"PRAddNewDataTableViewCell"];
            [cell configureCellWithText:[_addInfosArray objectAtIndex:indexPath.section - 1]];
            return cell;
        }
    }

    switch (_segmentedControl.selectedSegmentIndex) {
    case SelectedSegment_PersonalData: {
        switch (indexPath.section) {
        case TableSection_Info: {
            if (indexPath.row != TableInfoSectionRow_ContactType) {
                return [self editCellForIndexPath:indexPath andPlaceholder:[_placeholdersArray objectAtIndex:indexPath.row]];
            }
            return [self infoCellWithInfo:[self objectForIndexPath:indexPath] andDetail:@""];
        }
        case TableSection_Phones: {
            PRProfileContactPhoneModel* phone = (PRProfileContactPhoneModel*)[self objectForIndexPath:indexPath];
            return [self infoCellWithInfo:[PRPhoneNumberFormatter formatedStringForPhone:phone.phone] andDetail:phone.phoneType.typeName];
        }
        case TableSection_Emails: {
            PRProfileContactEmailModel* email = (PRProfileContactEmailModel*)[self objectForIndexPath:indexPath];
            return [self infoCellWithInfo:email.email andDetail:email.emailType.typeName];
        }
        case TableSection_Delete: {
            return [self deleteCellWithIndexPath:indexPath];
        }
        default:
            return nil;
        }
    }
    case SelectedSegment_Documents: {
        PRProfileContactDocumentModel* data = (PRProfileContactDocumentModel*)[_documents objectForKey:_keysForIndex[indexPath.section]][indexPath.row];
        PRInfoTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"PassportVisaInfoCell"];

        NSString* country = [Utils countryNameFromCode:data.countryCode ?: COUNTRY_CODE_RUSSIA];
        UIImage* flag = [Utils countryFlagFromCode:data.countryCode ?: COUNTRY_CODE_RUSSIA];

        if ([PRDatabase isPassport:data.documentType]) {
            [cell configureCellWithInfo:data.documentNumber placeholder:NSLocalizedString(@"Passport number", nil) detail:country andImage:flag];
        }
        else if ([data.documentType integerValue] == DocumentType_Visa) {
            NSString* localizedDetail;
            if (!data.expiryDate || [data.expiryDate isEqualToString:@""]) {
                localizedDetail = @"";
            } else {
                NSString* detail;
                if ([data.expiryDate containsString:@"-"]) {
                    detail = data.expiryDate;
                } else {
                    detail = [Utils fromMillisecondsToFormattedDate:data.expiryDate];
                }
                localizedDetail = [NSLocalizedString(@"until: ", nil) stringByAppendingString:detail];
            }
            [cell configureCellWithInfo:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Visa", ), NSLocalizedString(country, nil)] detail:localizedDetail andImage:flag];
        } else {
            cell = [_tableView dequeueReusableCellWithIdentifier:kInfoCellIdentifier];
            NSString* detail = [Utils fromMillisecondsToFormattedDate:data.expiryDate];
            NSString* localizedDetail = [NSLocalizedString(@"until: ", nil) stringByAppendingString:detail];
            [cell configureCellWithInfo:NSLocalizedString(@"Document", nil) andDetail:localizedDetail];
        }

        return cell;
    }
    default:
        return nil;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 45.0f;
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    if (_segmentedControl.selectedSegmentIndex == SelectedSegment_Documents) {
        if (section == [tableView numberOfSections] - 1) {
            return kTableViewHeaderHeight;
        }
        return kTableViewFooterHeight;
    }
    return section == _sourceArray.count ? CGFLOAT_MIN : 30.f;
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

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (_segmentedControl.selectedSegmentIndex) {
    case SelectedSegment_PersonalData: {
        if (indexPath.section == TableSection_Info && indexPath.row == TableInfoSectionRow_BirthDate) {
            [PRGoogleAnalyticsManager sendEventWithName:kPersonalDataBirthDateClicked parameters:nil];
            [self showDatePickerForIndexpath:indexPath];
            return;
        }

        if (indexPath.section == TableSection_Info && indexPath.row == TableInfoSectionRow_ContactType) {
            [self showContactTypePickerForIndexpath:indexPath];
            return;
        }

        if (indexPath.section == TableSection_Phones || indexPath.section == TableSection_Emails) {
            [PRGoogleAnalyticsManager sendEventWithName:(indexPath.section == TableSection_Phones ? kPersonalDataAddPhoneClicked : kPersonalDataAddEmailClicked) parameters:nil];
            [self openAddInfoViewControllerWithIndexpath:indexPath];
            return;
        }

        if (indexPath.section == TableSection_Delete) {
            _contactStatus = @(ModelStatus_Deleted);
            [PRGoogleAnalyticsManager sendEventWithName:kMyProfileDeleteFamilyPartnerButtonClicked parameters:nil];
            [self saveAction];
        }
        break;
    }
    case SelectedSegment_Documents: {
        [self openAddDocumentViewControllerWithIndexpath:indexPath];
        break;
    }
    default:
        break;
    }
}

#pragma mark - UISegmentedControl

- (IBAction)segmentedControlAction:(UISegmentedControl*)sender
{
    switch (sender.selectedSegmentIndex) {
    case SelectedSegment_PersonalData: {
        NSArray<NSString*>* delete = !_contactModel ? [NSArray new] : @[ NSLocalizedString(@"Delete contacts", nil) ];

        [self loadTableWithSourceArray:@[ _personalDataArray, _phones ?: @[], _emails ?: @[], delete ]
                         addInfosArray:@[ NSLocalizedString(@"add phone", nil), NSLocalizedString(@"add email", nil) ]
                            showHeader:YES];
        break;
    }
    case SelectedSegment_Documents: {
        if ([PRDocumentTypeModel MR_findAll].count == 0) {
            __weak PRPersonalDataViewController* weakSelf = self;
            [PRRequestManager getDocumentTypesWithView:self.view
                                                  mode:PRRequestMode_ShowNothing
                                               success:^(NSArray* result) {
                                                   PRPersonalDataViewController* strongSelf = weakSelf;
                                                   if (!strongSelf) {
                                                       return ;
                                                   }
                                                   [strongSelf reload];
                                               }
                                               failure:^{
                                                   
                                               }];
        }
        [self loadTableWithSourceDictionary:_documents ?: [NSDictionary new]
                         addInfosArray:@[ NSLocalizedString(@"add document", ) ]
                            showHeader:NO];
        break;
    }
    default:
        break;
    }
}

- (void)addContactPhone:(PRProfileContactPhoneModel*)phone
{
    NSMutableArray<PRProfileContactPhoneModel*>* tempArray = [_phones mutableCopy];

    if ([phone.state isEqualToNumber:@(ModelStatus_Deleted)]) {
        [tempArray removeObject:phone];
    } else if ([phone.state isEqualToNumber:@(ModelStatus_Added)] || [phone.state isEqualToNumber:@(ModelStatus_AddedWithoutParent)]) {
        [tempArray addObject:phone];
    } else if ([phone.state isEqualToNumber:@(ModelStatus_Updated)]) {
        if (!_contactModel) {
            phone.state = @(ModelStatus_AddedWithoutParent);
        } else if (_contactModel && !phone.phoneId) {
            phone.state = @(ModelStatus_Added);
        }

        NSInteger index = [tempArray indexOfObject:phone];
        [tempArray removeObjectAtIndex:index];
        [tempArray insertObject:phone atIndex:index];
    }
    _phones = tempArray;
    [self reload];
    self.contactHasChanges = YES;
}

- (void)addContactEmail:(PRProfileContactEmailModel*)email
{
    NSMutableArray<PRProfileContactEmailModel*>* tempArray = [_emails mutableCopy];

    if ([email.state isEqualToNumber:@(ModelStatus_Deleted)]) {
        [tempArray removeObject:email];
    } else if ([email.state isEqualToNumber:@(ModelStatus_Added)] || [email.state isEqualToNumber:@(ModelStatus_AddedWithoutParent)]) {
        [tempArray addObject:email];
    } else if ([email.state isEqualToNumber:@(ModelStatus_Updated)]) {
        if (!_contactModel) {
            email.state = @(ModelStatus_AddedWithoutParent);
        } else if (_contactModel && !email.emailId) {
            email.state = @(ModelStatus_Added);
        }

        NSInteger index = [tempArray indexOfObject:email];
        [tempArray removeObjectAtIndex:index];
        [tempArray insertObject:email atIndex:index];
    }
    _emails = tempArray;
    [self reload];
    self.contactHasChanges = YES;
}

- (void)addContactDocument:(PRProfileContactDocumentModel*)document
{
    NSMutableDictionary<NSString*,NSMutableArray<PRProfileContactDocumentModel*>*>* tempDictionary = [_documents mutableCopy];
    NSString* documentTypeName = [PRDatabase getDocumentTypeForId:document.documentType].name;
    NSMutableArray<PRProfileContactDocumentModel*>* tempArray = [[tempDictionary objectForKey:documentTypeName] mutableCopy] ? [[tempDictionary objectForKey:documentTypeName] mutableCopy] : [NSMutableArray new];

    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"documentId == %@", document.documentId];
    PRProfileContactDocumentModel* model = [[tempArray filteredArrayUsingPredicate:predicate] firstObject];

    if ([document.state isEqualToNumber:@(ModelStatus_Deleted)]) {
        [tempArray removeObject:document];
    } else if ([document.state isEqualToNumber:@(ModelStatus_Added)] || [document.state isEqualToNumber:@(ModelStatus_AddedWithoutParent)]) {
        if (![tempArray containsObject:document]) {
            [tempArray addObject:document];
        } else if (model) {
                [tempArray removeObject:model];
                [tempArray addObject:document];
        }
    } else if ([document.state isEqualToNumber:@(ModelStatus_Updated)]) {
        if (!_contactModel) {
            document.state = @(ModelStatus_AddedWithoutParent);
        } else if (_contactModel && !document.documentId) {
            document.state = @(ModelStatus_Added);
        }
        if (model) {
            [tempArray removeObject:model];
            [tempArray addObject:document];
        }
    }

    [tempDictionary setObject:tempArray forKey:documentTypeName];
    _documents = tempDictionary;

    [self reload];
    self.contactHasChanges = YES;
}

#pragma mark - Private Methods

- (void)configureSegmentedControl
{
#if defined(Platinum) || defined(VTB24) || defined(Raiffeisen)
    _segmentedControl.tintColor = kSegmentedControlTaskStatusColor;
#elif defined(PrivateBankingPRIMEClub)
    _segmentedControl.tintColor = kWhiteColor;
#elif defined(PrimeRRClub)
    _segmentedControl.tintColor = kRRClubMainColor
#else
    _segmentedControl.tintColor = kIconsColor;
#endif
    [_segmentedControl setTitle:NSLocalizedString(@"Personal data", nil)
              forSegmentAtIndex:0];
    [_segmentedControl setTitle:NSLocalizedString(@"Documents", nil) forSegmentAtIndex:1];

#if defined(VTB24) || defined(Raiffeisen) || defined(PrivateBankingPRIMEClub)
    _segmentedControl.backgroundColor = [self getNavigationBarColor];
    [_segmentedControl ensureiOS12Style];
#endif

    for (int i = 0; i < [_segmentedControl subviews].count; i++) {
        for (UIView* view in [[[_segmentedControl subviews] objectAtIndex:i] subviews]) {
            if ([view isKindOfClass:[UILabel class]]) {
                [(UILabel*)view setAdjustsFontSizeToFitWidth:YES];
            }
        }
    }
}

- (PREditInfoTableViewCell*)editCellForIndexPath:(NSIndexPath*)indexPath andPlaceholder:(NSString*)placeholder
{
    PREditInfoTableViewCell* editCell = [_tableView dequeueReusableCellWithIdentifier:@"PREditInfoTableViewCell"];
    [editCell configureCellWithTextfieldText:[self objectForIndexPath:indexPath] andPlaceholder:placeholder tag:indexPath.row delegate:self];
    editCell.textField.enabled = indexPath.row != TableInfoSectionRow_BirthDate;
    return editCell;
}

- (PRInfoTableViewCell*)infoCellWithInfo:(NSString*)info andDetail:(NSString*)detail
{
    PRInfoTableViewCell* typeInfoCell = [_tableView dequeueReusableCellWithIdentifier:@"PRInfoTableViewCell"];
    [typeInfoCell configureCellWithInfo:info andDetail:detail];
    return typeInfoCell;
}

- (UITableViewCell*)deleteCellWithIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Delete"];
    cell.textLabel.text = [self objectForIndexPath:indexPath];
    cell.textLabel.textColor = kDeleteButtonColor;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;

    UIView* topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 1)];
    topLine.backgroundColor = kTableViewHeaderColor;
    [cell addSubview:topLine];

    UIView* bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(cell.frame) - 1, CGRectGetWidth(self.view.frame), 1)];
    bottomLine.backgroundColor = kTableViewHeaderColor;
    [cell addSubview:bottomLine];

    return cell;
}

- (void)updateObjectWithInfo:(NSString*)info atIndex:(NSInteger)index
{
    [self updatePersonalDataArrayWithInfo:info atIndex:index];
    NSIndexPath* indexPathToReload = [NSIndexPath indexPathForRow:index inSection:TableSection_Info];
    [_tableView reloadRowsAtIndexPaths:@[ indexPathToReload ] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)updatePersonalDataArrayWithInfo:(NSString*)info atIndex:(NSInteger)index
{
    [_personalDataArray removeObjectAtIndex:index];
    [_personalDataArray insertObject:info atIndex:index];
}

- (void)showDatePickerForIndexpath:(NSIndexPath*)indexPath
{
    _typeSelectionViewController = [[CustomActionSheetViewController alloc] init];
    _typeSelectionViewController.delegate = self;
    if (!_typeSelectionViewController.picker) {
        _typeSelectionViewController.picker = [UIDatePicker new];
    }

    UIPickerTextField* pickerTextField = [[UIPickerTextField alloc] init];
    pickerTextField.text = [((PREditInfoTableViewCell*)[_tableView cellForRowAtIndexPath:indexPath])currentTextValue];
    NSString* dateFormat = DATE_DAY_FORMAT;
    NSDate* currentDate = [NSDate new];

#if defined(Otkritie)
    currentDate = [currentDate mt_dateYearsBefore:30];
    dateFormat = DATE_FORMAT_ddMMyyyy;
#endif

    ((UIDatePicker*)_typeSelectionViewController.picker).datePickerMode = UIDatePickerModeDate;
    if (@available(iOS 13.4, *)) {
        ((UIDatePicker*)_typeSelectionViewController.picker).preferredDatePickerStyle = UIDatePickerStyleWheels;
    }
    if (!pickerTextField.text || [pickerTextField.text isEqualToString:@""]) {
        ((UIDatePicker*)_typeSelectionViewController.picker).date = currentDate;
    } else {
        ((UIDatePicker*)_typeSelectionViewController.picker).date = [NSDate mt_dateFromString:pickerTextField.text usingFormat:dateFormat] ?: currentDate;
    }
    [(UIDatePicker*)_typeSelectionViewController.picker setMaximumDate:[NSDate date]];
    [_typeSelectionViewController showForField:pickerTextField];
    _actionSheetSelectedType = ActionSheetSelectedType_BirthDate;
}

- (void)showContactTypePickerForIndexpath:(NSIndexPath*)indexPath
{
    _typeSelectionViewController = [[CustomActionSheetViewController alloc] init];
    _typeSelectionViewController.delegate = self;
    _typeSelectionViewController.picker = [self getTypePicker];

    UIPickerTextField* textfield = [[UIPickerTextField alloc] init];
    textfield.text = ((PRInfoTableViewCell*)[_tableView cellForRowAtIndexPath:indexPath]).labelInfo.text;
    [_typeSelectionViewController showForField:textfield];
    _actionSheetSelectedType = ActionSheetSelectedType_ContactType;
}

- (void)loadTableWithSourceArray:(NSArray<NSArray*>*)sourceArray addInfosArray:(NSArray<NSString*>*)infosArray showHeader:(BOOL)show
{
    _sourceArray = sourceArray;
    _addInfosArray = infosArray;
    [_tableView reloadData];
}

- (void)loadTableWithSourceDictionary:(NSDictionary<NSString*, NSArray*>*)sourceDictionary addInfosArray:(NSArray<NSString*>*)infosArray showHeader:(BOOL)show
{
    _documents = sourceDictionary;
    _keysForIndex = [_documents allKeys];
    _addInfosArray = infosArray;
    [_tableView reloadData];
}

- (void)configurePersonalData
{
    NSString* lastName = _contactModel.lastName ?: @"";
    NSString* firstName = _contactModel.firstName ?: @"";
    NSString* middleName = _contactModel.middleName ?: @"";
    NSString* birthDate = _contactModel.birthDate ?: @"";
    if (birthDate && ![birthDate isEqualToString:@""]) {
        birthDate = [Utils fromMillisecondsToFormattedDate:birthDate];
    }
    PRContactTypeModel* contactType = _contactModel.contactType ?: [_contactTypes firstObject];
    _personalDataArray = [[NSMutableArray alloc] initWithObjects:lastName, firstName, middleName, birthDate, contactType.typeName, nil];

    _selectedTypeId = contactType.typeId;
}

- (void)configureTableView
{
    _tableView.delegate = self;
    _tableView.dataSource = self;

    [_tableView setBackgroundView:nil];
    _tableView.backgroundColor = kWhiteColor;
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, -20, 0);

    UIView* tableHeaderFooterSmallView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
    _tableView.tableHeaderView = tableHeaderFooterSmallView;
    _tableView.tableFooterView = tableHeaderFooterSmallView;
}

- (BOOL)isLastIndexPath:(NSIndexPath*)indexPath
{
    return indexPath.row == [_tableView numberOfRowsInSection:indexPath.section] - 1;
}

- (id)objectForIndexPath:(NSIndexPath*)indexPath
{
    return [[_sourceArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
}

- (id)dataFromInfoSectionCellForRow:(NSInteger)row
{
    if (row == TableInfoSectionRow_ContactType) {
        return [self typeModelFromId:_selectedTypeId];
    }

    if ((_segmentedControl.selectedSegmentIndex == SelectedSegment_PersonalData) || (_segmentedControl.selectedSegmentIndex == SelectedSegment_Documents && !_saveButtonIsPressed)) {

        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:TableSection_Info];
        if ([[_tableView indexPathsForVisibleRows] containsObject:indexPath]) {
            return [(PREditInfoTableViewCell*)[_tableView cellForRowAtIndexPath:indexPath] currentTextValue];
        }
    }

    return [_personalDataArray objectAtIndex:row];
}

- (void)getContactDataForSave
{
    [PRGoogleAnalyticsManager sendEventWithName:(_profileContactType == ProfileContactType_AddFamily ? kMyProfileSaveFamilyButtonClicked :
                                                                                                       kMyProfileSavePartnerButtonClicked)
                                     parameters:nil];

    _contactModel.state = _contactStatus;

    _contactModel.lastName = [self dataFromInfoSectionCellForRow:TableInfoSectionRow_LastName];
    _contactModel.firstName = [self dataFromInfoSectionCellForRow:TableInfoSectionRow_FirstName];
    _contactModel.middleName = [self dataFromInfoSectionCellForRow:TableInfoSectionRow_MiddleName];
    _contactModel.birthDate = [self dataFromInfoSectionCellForRow:TableInfoSectionRow_BirthDate];
    _contactModel.contactType = [self dataFromInfoSectionCellForRow:TableInfoSectionRow_ContactType];

    if (contactNotSynchedInOfflineMode) {
        _contactModel.phones = [NSMutableOrderedSet orderedSetWithArray:_phones];
        _contactModel.emails = [NSMutableOrderedSet orderedSetWithArray:_emails];
        _contactModel.documents = [NSMutableOrderedSet orderedSetWithArray:[[_documents allValues] mutableCopy]];
        return;
    }
    _contactModel.phones = [NSMutableOrderedSet orderedSetWithArray:[PRDatabase profileContactPhonesForContactId:_contactModel.contactId inContext:_mainContext]];
    _contactModel.emails = [NSMutableOrderedSet orderedSetWithArray:[PRDatabase profileContactEmailsForContactId:_contactModel.contactId inContext:_mainContext]];
    _contactModel.documents = [NSMutableOrderedSet orderedSetWithArray:[PRDatabase profileContactDocumentsForContactId:_contactModel.contactId inContext:_mainContext]];
}

- (PRContactTypeModel*)typeModelFromId:(NSNumber*)typeId
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"typeId == %@", typeId];
    return [[_contactTypes filteredArrayUsingPredicate:predicate] firstObject];
}

- (NSArray<PRContactTypeModel*>*)contactTypes
{
    NSArray<PRContactTypeModel*>* profileContactTypes = [PRDatabase profileContactTypesWithContext:_mainContext];
    NSArray<NSNumber*>* contactTypesForFamily = @[ @1, @5, @6 ];

    switch (_profileContactType) {
    case ProfileContactType_AddFamily: {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"SELF.typeId IN %@", contactTypesForFamily];
        return [profileContactTypes filteredArrayUsingPredicate:predicate];
    }
    case ProfileContactType_AddPartner: {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"NOT (SELF.typeId IN %@)", contactTypesForFamily];
        return [profileContactTypes filteredArrayUsingPredicate:predicate];
    }
    case ProfileContactType_Update: {
        return profileContactTypes;
    }
    default:
        break;
    }
}

- (void)updateContactForPhonesAndEmails
{

    for (PRProfileContactPhoneModel* phone in _phones) {
        if (!phone.profileContact) {
            phone.profileContact = _contactModel;
        }
    }

    for (PRProfileContactEmailModel* email in _emails) {
        if (!email.profileContact) {
            email.profileContact = _contactModel;
        }
    }
}

- (void)updateContactForDocuments
{
    for (NSArray* currentArray in [_documents allValues]) {
        for (id value in currentArray) {
            PRProfileContactDocumentModel* document = (PRProfileContactDocumentModel*)value;
            if (!document.profileContact) {
                document.profileContact = _contactModel;
            }
        }
    }
    
}

- (void)popViewController
{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Actions

- (void)saveAction
{
    _saveButtonIsPressed = YES;
    [self.view endEditing:YES];

    if (!_contactModel) {
        _contactModel = [PRProfileContactModel MR_createEntityInContext:_mainContext];
        [self updateContactForPhonesAndEmails];
        [self updateContactForDocuments];
    } else {
        _contactModel = [_contactModel MR_inContext:_mainContext];
    }

    [self getContactDataForSave];

    self.navigationItem.rightBarButtonItem.enabled = NO;
    [_mainContext refreshObject:_contactModel mergeChanges:YES];
    [_mainContext MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError* error) {

        if (error) {
            [PRMessageAlert showToastWithMessage:Message_SaveContactFailed];
            return;
        }

        if (!contextDidSave) {
            [self popViewController];
            return;
        }

        if (![PRRequestManager connectionRequired]) {
            [[SynchManager sharedClient] synchProfileContactsInContext:_mainContext
                                                                  view:self.view
                                                                  mode:PRRequestMode_ShowErrorMessagesAndProgress
                                                            completion:^{
                                                                [_myProfileViewController reload];
                                                                [self popViewController];
                                                            }];
        } else {
            _myProfileViewController.isSynchedFromOffline = NO;
            [_myProfileViewController reload];
            [self popViewController];
        }
    }];
}

- (void)openAddInfoViewControllerWithIndexpath:(NSIndexPath*)indexPath
{
    PREditProfileInfoViewController* viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PREditProfileInfoViewController"];
    [viewController setEditingType:indexPath.section == TableSection_Phones ? EditingModelType_Phone : EditingModelType_Email
                             model:[self isLastIndexPath:indexPath] ? nil : [self objectForIndexPath:indexPath]
                           context:_mainContext
                            parent:self];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)openAddDocumentViewControllerWithIndexpath:(NSIndexPath*)indexPath //Temporary
{
    if (indexPath.section == _keysForIndex.count) {
        DocumentTypeViewController* viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DocumentTypeViewController"];
        viewController.dataSource = self;
        viewController.userProfile = [PRDatabase getUserProfile];
        viewController.mainContext = _mainContext;
        viewController.documentData = nil;
        viewController.isContactDocument = YES;
        viewController.contactModel = _contactModel;
        viewController.title = NSLocalizedString(@"Document types", );
        [self.navigationController pushViewController:viewController animated:YES];
        return;
    }
    AddDocumentViewController* viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddDocumentViewController"];
    viewController.parentView = self;
    viewController.userProfile = [PRDatabase getUserProfile];

    viewController.contactModel = _contactModel;
    viewController.mainContext = _mainContext;
    viewController.isContactDocument = YES;

    PRProfileContactDocumentModel* document =  [_documents objectForKey:_keysForIndex[indexPath.section]][indexPath.row];
    viewController.documentId = document.documentId;
    viewController.contactDocumentModel = document;
    viewController.type = document.documentType;

    if (document.documentType != nil) {
        NSString* typeName = [PRDatabase getDocumentTypeForId:document.documentType].name;
        viewController.title = NSLocalizedString(typeName, );
    }

    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - UIPickerView

- (UIPickerView*)getTypePicker
{
    UIPickerView* typePicker = [[UIPickerView alloc] init];
    typePicker.delegate = self;
    typePicker.dataSource = self;

    for (int i = 0; i < _contactTypes.count; ++i) {
        PRContactTypeModel* type = [_contactTypes objectAtIndex:i];
        if ([type.typeId isEqualToNumber:_selectedTypeId]) {
            [typePicker selectRow:i inComponent:0 animated:NO];
            break;
        }
    }

    return typePicker;
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _contactTypes.count;
}

#pragma mark - UIPickerViewDelegate

- (void)pickerView:(UIPickerView*)pV didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _selectedTypeId = [_contactTypes objectAtIndex:row].typeId;
}

- (NSString*)pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_contactTypes objectAtIndex:row].typeName;
}

- (void)selectionViewControllerDidDoneFor:(CustomActionSheetViewController*)sheet
{
    self.contactHasChanges = YES;
    switch (_actionSheetSelectedType) {
    case ActionSheetSelectedType_ContactType: {
        [PRGoogleAnalyticsManager sendEventWithName:(_profileContactType == ProfileContactType_AddFamily ? kFamilyTypePickerSelectButtonClicked :
                                                                                                           kPartnerTypePickerSelectButtonClicked)
                                         parameters:nil];
        PRContactTypeModel* contactType = [self typeModelFromId:_selectedTypeId];
        [self updateObjectWithInfo:contactType.typeName atIndex:TableInfoSectionRow_ContactType];
        break;
    }
    case ActionSheetSelectedType_BirthDate: {
        [PRGoogleAnalyticsManager sendEventWithName:kDatePickerSelectButtonClicked parameters:nil];
        NSString* dateString;
        NSString* dateFormat = DATE_DAY_FORMAT;
        NSDate* currentDate = [NSDate new];

#if defined(Otkritie)
        currentDate = [currentDate mt_dateYearsBefore:30];
        dateFormat = DATE_FORMAT_ddMMyyyy;
#endif

        if (!((UIDatePicker*)sheet.picker).date) {
            dateString = [currentDate mt_stringFromDateWithFormat:dateFormat localized:NO];
        } else {
            dateString = [((UIDatePicker*)sheet.picker).date mt_stringFromDateWithFormat:dateFormat localized:NO];
        }
        [self updateObjectWithInfo:dateString atIndex:TableInfoSectionRow_BirthDate];
        break;
    }
    default:
        break;
    }
}

- (void)selectionViewControllerDidCancelFor:(CustomActionSheetViewController*)sheet
{
    if (_actionSheetSelectedType == ActionSheetSelectedType_ContactType) {
        [PRGoogleAnalyticsManager sendEventWithName:(_profileContactType == ProfileContactType_AddFamily ? kFamilyTypePickerCancelButtonClicked :
                                                                                                           kPartnerTypePickerCancelButtonClicked)
                                         parameters:nil];
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"typeName == %@", [_personalDataArray objectAtIndex:TableInfoSectionRow_ContactType]];
        PRContactTypeModel* model = [[_contactTypes filteredArrayUsingPredicate:predicate] firstObject];
        _selectedTypeId = model.typeId;
    }
    [PRGoogleAnalyticsManager sendEventWithName:kDatePickerCancelButtonClicked parameters:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
    self.contactHasChanges = YES;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField*)textField
{
    [self updatePersonalDataArrayWithInfo:textField.text atIndex:textField.tag];
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)setContactHasChanges:(BOOL)contactHasChanges
{
    if ((self.navigationItem.rightBarButtonItem && contactHasChanges) || (!self.navigationItem.rightBarButtonItem && !contactHasChanges)) {
        return;
    }
    self.navigationItem.rightBarButtonItem = contactHasChanges ? [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil)
                                                                                                  style:UIBarButtonItemStylePlain
                                                                                                 target:self
                                                                                                 action:@selector(saveAction)]
                                                               : nil;
}

@end
