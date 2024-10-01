//
//  PREditProfileInfoViewController.m
//  PRIME
//
//  Created by Mariam on 2/16/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PREditProfileInfoViewController.h"
#import "PRInfoTableViewCell.h"
#import "PREditInfoTableViewCell.h"
#import "PRMyProfileViewController.h"
#import "CustomActionSheetViewController.h"
#import "CustomActionSheetViewController+Picker.h"
#import "SynchManager.h"
#import "Reachability.h"
#import "SHSPhoneTextField+DeleteBackward.h"
#import "PRPhoneNumberFormatter.h"

typedef NS_ENUM(NSInteger, TableInfoSection) {
    TableInfoSectionRow_Number = 0,
    TableInfoSectionRow_Type,
    TableInfoSectionRow_Comment,
};

typedef NS_ENUM(NSInteger, TableSection) {
    TableSection_Info = 0,
    TableSection_Delete,
};

@interface PREditProfileInfoViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, SelectionViewControllerDelegate> {
    BOOL _isParentProfileContact;
    BOOL _isTypesExist;
}

@property (weak, nonatomic) IBOutlet UITableView* tableView;
@property (weak, nonatomic) UITextField* activeTextField;

@property (assign, nonatomic) EditingModelType modelType;
@property (strong, nonatomic) NSNumber* selectedTypeId;

@property (strong, nonatomic) NSArray<NSString*>* sourceArray;
@property (strong, nonatomic) NSArray<PRProfileBaseTypeModel*>* typesArray;

@property (strong, nonatomic) NSManagedObjectContext* mainContext;
@property (strong, nonatomic) UIViewController* parentController;
@property (strong, nonatomic) PRProfileContactModel* contactModel;
@property (strong, nonatomic) PRModel* phoneOrEmailModel;

@property (strong, nonatomic) NSNumber* modelStatus;

@end

@implementation PREditProfileInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = _modelType == EditingModelType_Phone ? NSLocalizedString(@"Phone number", nil) : NSLocalizedString(@"E-mail", nil);
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [tapGesture setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
#if defined(Platinum) || defined(PrivateBankingPRIMEClub) || defined(PrimeRRClub)
    [self.navigationController.navigationBar setTintColor:kNavigationBarTintColor];
#else
    [self.navigationController.navigationBar setTintColor:kIconsColor];
#endif
}

#pragma mark - Setup

- (void)dismissKeyboard
{
    [_activeTextField resignFirstResponder];
}

- (void)setEditingType:(EditingModelType)type
                 model:(PRModel*)model
               context:(NSManagedObjectContext*)context
                parent:(UIViewController*)parentController
{
    _mainContext = context;
    _parentController = parentController;
    _isParentProfileContact = [_parentController isKindOfClass:[PRPersonalDataViewController class]];
    _contactModel = _isParentProfileContact ? ((PRPersonalDataViewController*)_parentController).contactModel : nil;

    _modelType = type;
    _phoneOrEmailModel = model;

    switch (_modelType) {

    case EditingModelType_Phone: {

        NSArray<PRPhoneTypeModel*>* types = [PRDatabase profilePhoneTypes:_mainContext];
        _typesArray = types;

        [self setUpViewForPhone];
        break;
    }
    case EditingModelType_Email: {

        NSArray<PREmailTypeModel*>* types = [PRDatabase profileEmailTyes:_mainContext];
        _typesArray = types;

        [self setUpViewForEmail];
        break;
    }
    default:
        break;
    }
}

- (void)createSourceArrayWithText:(NSString*)text type:(PRProfileBaseTypeModel*)type comment:(NSString*)comment
{
    _isTypesExist = _typesArray.count > 0;

    text = text ?: @"";
    comment = comment ?: @"";

    if (_isTypesExist) {
        _sourceArray = @[ text,
            type.typeName ?: [_typesArray firstObject].typeName,
            comment ];
        _selectedTypeId = _phoneOrEmailModel ? (type.typeId ?: [_typesArray firstObject].typeId) : [_typesArray firstObject].typeId;
    } else {
        _sourceArray = @[ text, @"", comment ];
        _selectedTypeId = nil;
    }

    if (_isParentProfileContact) {
        _modelStatus = _phoneOrEmailModel ? @(ModelStatus_Updated) : _contactModel ? @(ModelStatus_Added) : @(ModelStatus_AddedWithoutParent);
    } else {
        _modelStatus = _phoneOrEmailModel ? @(ModelStatus_Updated) : @(ModelStatus_Added);
    }
}

- (void)setUpViewForPhone
{
    if (_isParentProfileContact) {
        PRProfileContactPhoneModel* contactPhoneModel = (PRProfileContactPhoneModel*)_phoneOrEmailModel;
        [self createSourceArrayWithText:contactPhoneModel.phone
                                   type:contactPhoneModel.phoneType
                                comment:contactPhoneModel.comment];
    } else {
        PRProfilePhoneModel* profilePhoneModel = (PRProfilePhoneModel*)_phoneOrEmailModel;
        profilePhoneModel ? [PRGoogleAnalyticsManager sendEventWithName:kMyProfileEditPhoneButtonClicked parameters:nil] :
                            [PRGoogleAnalyticsManager sendEventWithName:kMyProfileAddPhoneButtonClicked parameters:nil];
        [self createSourceArrayWithText:profilePhoneModel.phone
                                   type:profilePhoneModel.phoneType
                                comment:profilePhoneModel.comment];
    }
}

- (void)setUpViewForEmail
{
    if (_isParentProfileContact) {
        PRProfileContactEmailModel* contactEmailModel = (PRProfileContactEmailModel*)_phoneOrEmailModel;
        [self createSourceArrayWithText:contactEmailModel.email
                                   type:contactEmailModel.emailType
                                comment:contactEmailModel.comment];
    } else {
        PRProfileEmailModel* profileEmailModel = (PRProfileEmailModel*)_phoneOrEmailModel;
        profileEmailModel ? [PRGoogleAnalyticsManager sendEventWithName:kMyProfileEditEmailButtonClicked parameters:nil] :
                            [PRGoogleAnalyticsManager sendEventWithName:kMyProfileAddEmailButtonClicked parameters:nil];
        [self createSourceArrayWithText:profileEmailModel.email
                                   type:profileEmailModel.emailType
                                comment:profileEmailModel.comment];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return _phoneOrEmailModel ? 2 : 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == TableSection_Info ? _sourceArray.count : 1;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == TableSection_Delete) {
        UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Delete"];
        cell.textLabel.text = NSLocalizedString(_modelType == EditingModelType_Phone ? @"Delete phone" : @"Delete e-mail", nil);
        cell.textLabel.textColor = kDeleteButtonColor;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        return cell;
    }

    PREditInfoTableViewCell* (^editCellBlockWithPlaceholder)(NSString*) = ^(NSString* placeholder) {
        PREditInfoTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"PREditInfoTableViewCell"];

        if (_modelType == EditingModelType_Phone && indexPath.row == TableInfoSectionRow_Number) {

            [cell configurePhoneCellWithTextfieldText:[_sourceArray objectAtIndex:indexPath.row]
                                       andPlaceholder:placeholder
                                                  tag:indexPath.row
                                             delegate:self];
        } else {

            [cell configureCellWithTextfieldText:[_sourceArray objectAtIndex:indexPath.row]
                                  andPlaceholder:placeholder
                                             tag:indexPath.row
                                        delegate:self];
            cell.textField.keyboardType = indexPath.row == TableInfoSectionRow_Number ? UIKeyboardTypeEmailAddress : UIKeyboardTypeDefault;
        }
        return cell;
    };

    switch (indexPath.row) {
    case TableInfoSectionRow_Number: {
        return editCellBlockWithPlaceholder(self.title);
    }
    case TableInfoSectionRow_Type: {
        PRInfoTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"PRInfoTableViewCell"];
        [cell configureCellWithInfo:[_sourceArray objectAtIndex:indexPath.row]];
        return cell;
    }
    case TableInfoSectionRow_Comment:
        return editCellBlockWithPlaceholder(NSLocalizedString(@"Comments", nil));
    default:
        return nil;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.row) {
    case TableInfoSectionRow_Comment:
        return 0;
    default:
        return 45.f;
    }
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == TableInfoSectionRow_Type && _isTypesExist) {
        [self dismissKeyboard];
        CustomActionSheetViewController* typeSelectionVC = [[CustomActionSheetViewController alloc] init];
        typeSelectionVC.delegate = self;
        typeSelectionVC.picker = [self getTypePicker];

        UIPickerTextField* textfield = [[UIPickerTextField alloc] init];
        textfield.text = ((PRInfoTableViewCell*)[_tableView cellForRowAtIndexPath:indexPath]).labelInfo.text;
        [typeSelectionVC showForField:textfield];
        return;
    }
    if (indexPath.section == TableSection_Delete) {
        _modelStatus = @(ModelStatus_Deleted);
        [self saveAction];
    }
}

#pragma mark - Private Methods

- (PRProfileBaseTypeModel*)typeModelFromName:(NSString*)name
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"typeName == %@", name];
    return [[_typesArray filteredArrayUsingPredicate:predicate] firstObject];
}

- (PRProfileBaseTypeModel*)typeModelFromId:(NSNumber*)typeId
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"typeId == %@", typeId];
    return [[_typesArray filteredArrayUsingPredicate:predicate] firstObject];
}

- (void)updateObjectWithInfo:(NSString*)info atIndex:(NSUInteger)index
{
    NSMutableArray<NSString*>* tempArray = [_sourceArray mutableCopy];
    [tempArray removeObjectAtIndex:index];
    [tempArray insertObject:info atIndex:index];
    _sourceArray = tempArray;
    NSIndexPath* indexPathToReload = [NSIndexPath indexPathForRow:index inSection:TableSection_Info];
    [_tableView reloadRowsAtIndexPaths:@[ indexPathToReload ] withRowAnimation:UITableViewRowAnimationNone];
}

- (BOOL)isNumberExist
{
    NSString* number = [((PREditInfoTableViewCell*)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:TableInfoSectionRow_Number inSection:TableSection_Info]])currentTextValue];
    return number.length > 0;
}

- (void)showSaveButton:(BOOL)show
{
    if ((self.navigationItem.rightBarButtonItem && show) || (!self.navigationItem.rightBarButtonItem && !show)) {
        return;
    }
    self.navigationItem.rightBarButtonItem = show ? [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil)
                                                                                     style:UIBarButtonItemStylePlain
                                                                                    target:self
                                                                                    action:@selector(saveAction)]
                                                  : nil;
}

- (id)dataFromInfoSectionCellForRow:(NSInteger)row
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:TableSection_Info];
    if (row != TableInfoSectionRow_Type) {
        return [((PREditInfoTableViewCell*)[_tableView cellForRowAtIndexPath:indexPath])currentTextValue];
    }

    if (!_isTypesExist) {
        return nil;
    }

    return _modelType == EditingModelType_Phone ? (PRPhoneTypeModel*)[self typeModelFromId:_selectedTypeId] : (PREmailTypeModel*)[self typeModelFromId:_selectedTypeId];
}

- (void)popViewController
{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Save Methods

- (void)saveContactPhone
{
    PRProfileContactPhoneModel* contactPhone = (PRProfileContactPhoneModel*)_phoneOrEmailModel;
    if (!contactPhone) {
        contactPhone = [PRProfileContactPhoneModel MR_createEntityInContext:_mainContext];
    } else {
        contactPhone = [contactPhone MR_inContext:_mainContext];
    }

    contactPhone.state = _modelStatus;
    if (![contactPhone.state isEqualToNumber:@(ModelStatus_Deleted)]) {
        contactPhone.phone = [self dataFromInfoSectionCellForRow:TableInfoSectionRow_Number];
        contactPhone.phoneType = [self dataFromInfoSectionCellForRow:TableInfoSectionRow_Type];
        contactPhone.comment = [self dataFromInfoSectionCellForRow:TableInfoSectionRow_Comment];
    }

    contactPhone.profileContact = _contactModel;
    [(PRPersonalDataViewController*)_parentController addContactPhone:contactPhone];
    [self popViewController];
}

- (void)saveProfilePhone
{
    PRProfilePhoneModel* profilePhone = (PRProfilePhoneModel*)_phoneOrEmailModel;

    if (!profilePhone) {
        profilePhone = [PRProfilePhoneModel MR_createEntityInContext:_mainContext];
    } else {
        [PRGoogleAnalyticsManager sendEventWithName:kMyProfileDeletePhoneButtonClicked parameters:nil];
        profilePhone = [profilePhone MR_inContext:_mainContext];
    }

    profilePhone.state = _modelStatus;

    if (!profilePhone.phoneId && [profilePhone.state isEqualToNumber:@(ModelStatus_Deleted)]) {
        [profilePhone MR_deleteEntityInContext:_mainContext];
    }

    if (![profilePhone.state isEqualToNumber:@(ModelStatus_Deleted)]) {
        profilePhone.phone = [self dataFromInfoSectionCellForRow:TableInfoSectionRow_Number];
        profilePhone.phoneType = [self dataFromInfoSectionCellForRow:TableInfoSectionRow_Type];
        profilePhone.comment = [self dataFromInfoSectionCellForRow:TableInfoSectionRow_Comment];
    }

    [_mainContext refreshObject:profilePhone mergeChanges:YES];
    [self saveToPersistentStore];
}

- (void)saveContactEmail
{
    PRProfileContactEmailModel* contactEmail = (PRProfileContactEmailModel*)_phoneOrEmailModel;

    if (!contactEmail) {
        contactEmail = [PRProfileContactEmailModel MR_createEntityInContext:_mainContext];
    } else {
        contactEmail = [contactEmail MR_inContext:_mainContext];
    }

    contactEmail.state = _modelStatus;
    if (![contactEmail.state isEqualToNumber:@(ModelStatus_Deleted)]) {
        contactEmail.email = [self dataFromInfoSectionCellForRow:TableInfoSectionRow_Number];
        contactEmail.emailType = [self dataFromInfoSectionCellForRow:TableInfoSectionRow_Type];
        contactEmail.comment = [self dataFromInfoSectionCellForRow:TableInfoSectionRow_Comment];
    }

    contactEmail.profileContact = _contactModel;
    [(PRPersonalDataViewController*)_parentController addContactEmail:contactEmail];
    [self popViewController];
}

- (void)saveProfileEmail
{
    PRProfileEmailModel* profileEmail = (PRProfileEmailModel*)_phoneOrEmailModel;

    if (!profileEmail) {
        profileEmail = [PRProfileEmailModel MR_createEntityInContext:_mainContext];
    } else {
        [PRGoogleAnalyticsManager sendEventWithName:kMyProfileDeleteEmailButtonClicked parameters:nil];
        profileEmail = [profileEmail MR_inContext:_mainContext];
    }

    profileEmail.state = _modelStatus;

    if (!profileEmail.emailId && [profileEmail.state isEqualToNumber:@(ModelStatus_Deleted)]) {
        [profileEmail MR_deleteEntityInContext:_mainContext];
    }

    if (![profileEmail.state isEqualToNumber:@(ModelStatus_Deleted)]) {
        profileEmail.email = [self dataFromInfoSectionCellForRow:TableInfoSectionRow_Number];
        profileEmail.emailType = [self dataFromInfoSectionCellForRow:TableInfoSectionRow_Type];
        profileEmail.comment = [self dataFromInfoSectionCellForRow:TableInfoSectionRow_Comment];
    }

    [_mainContext refreshObject:profileEmail mergeChanges:YES];
    [self saveToPersistentStore];
}

- (void)saveToPersistentStore
{
    [self dismissKeyboard];
    self.navigationItem.rightBarButtonItem.enabled = NO;
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
            [[SynchManager sharedClient] synchProfilePersonalDataInContext:_mainContext
                                                                      view:self.view
                                                                      mode:PRRequestMode_ShowErrorMessagesAndProgress
                                                                completion:^{
                                                                    [(PRMyProfileViewController*)_parentController reload];
                                                                    [self popViewController];
                                                                }];
        } else {
            ((PRMyProfileViewController*)_parentController).isSynchedFromOffline = NO;
            [(PRMyProfileViewController*)_parentController reload];
            [self popViewController];
        }
    }];
}

#pragma mark - Actions

- (void)saveAction
{
    switch (_modelType) {
    case EditingModelType_Phone:
        [PRGoogleAnalyticsManager sendEventWithName:kMyProfileSavePhoneButtonClicked parameters:nil];
        if (_isParentProfileContact) {
            [self saveContactPhone];
        } else {
            [self saveProfilePhone];
        }
        break;
    case EditingModelType_Email:
        [PRGoogleAnalyticsManager sendEventWithName:kMyProfileSaveEmailButtonClicked parameters:nil];
        if (_isParentProfileContact) {
            [self saveContactEmail];
        } else {
            [self saveProfileEmail];
        }
    default:
        break;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField*)textField
{
    _activeTextField = textField;
    return YES;
}

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
    if (textField.tag == TableInfoSectionRow_Number) {
        if (((_modelType == EditingModelType_Phone && range.location < 2) || (_modelType == EditingModelType_Email && range.location == 0)) && (string.length == 0)) {
            [self showSaveButton:NO];
            return YES;
        }

        SHSPhoneTextField* phoneTextField = (SHSPhoneTextField*)textField;
        if ((_modelType == EditingModelType_Phone) && phoneTextField.phoneNumber.length <= 3) {
            NSString* phoneNumber = phoneTextField.phoneNumber;
            if ([PRPhoneNumberFormatter formatForCountryCode:[phoneNumber integerValue]].length > 0) {
                [phoneTextField.formatter setDefaultOutputPattern:[PRPhoneNumberFormatter formatWithPrefixForPhoneNumber:phoneNumber]];
                [phoneTextField.formatter addOutputPattern:[PRPhoneNumberFormatter formatWithPrefixForPhoneNumber:phoneNumber] forRegExp:@"^\\d\\d\\d\\d[0-9]\\d*$" imagePath:nil];
            }
        }
        [self showSaveButton:YES];
    } else {
        [self showSaveButton:[self isNumberExist]];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIPickerView

- (UIPickerView*)getTypePicker
{
    UIPickerView* typePicker = [[UIPickerView alloc] init];
    typePicker.delegate = self;
    typePicker.dataSource = self;

    for (int i = 0; i < _typesArray.count; ++i) {
        PRProfileBaseTypeModel* type = [_typesArray objectAtIndex:i];
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
    return _typesArray.count;
}

#pragma mark - UIPickerViewDelegate

- (void)pickerView:(UIPickerView*)pV didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _selectedTypeId = [_typesArray objectAtIndex:row].typeId;
}

- (NSString*)pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_typesArray objectAtIndex:row].typeName;
}

- (void)selectionViewControllerDidDoneFor:(CustomActionSheetViewController*)sheet
{
    [PRGoogleAnalyticsManager sendEventWithName:(_modelType == EditingModelType_Phone ? kPhoneTypePickerSelectButtonClicked : kEmailTypePickerSelectButtonClicked) parameters:nil];
    [self updateObjectWithInfo:[self typeModelFromId:_selectedTypeId].typeName atIndex:TableInfoSectionRow_Type];
    if ([self isNumberExist]) {
        [self showSaveButton:YES];
    }
}

- (void)selectionViewControllerDidCancelFor:(CustomActionSheetViewController*)sheet
{
    [PRGoogleAnalyticsManager sendEventWithName:(_modelType == EditingModelType_Phone ? kPhoneTypePickerCancelButtonClicked : kEmailTypePickerCancelButtonClicked) parameters:nil];
    _selectedTypeId = [self typeModelFromName:[_sourceArray objectAtIndex:TableInfoSectionRow_Type]].typeId;
}

@end
