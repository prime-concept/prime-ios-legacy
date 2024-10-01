//
//  PRProfileRegistrationViewController.m
//  PRIME
//
//  Created by Aram on 8/8/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRProfileRegistrationViewController.h"
#import "PRProfileRegistrationCell.h"
#import "PRUINavigationController.h"
#import "CustomActionSheetViewController+Picker.h"
#import "PRProfileRegistrationFooterView.h"
#import "RegistrationStepTwoViewController.h"
#import "NSString+extended.h"

NS_ENUM(NSInteger, RegistrationMainSectionRow){
    RegistrationMainSectionRow_LastName,
    RegistrationMainSectionRow_FirstName,
    RegistrationMainSectionRow_MiddleName,
    RegistrationMainSectionRow_DateOfBirth,
    RegistrationMainSectionRow_Count
};

NS_ENUM(NSInteger, RegistrationAdditionalSectionRow){
    RegistrationAdditionalSectionRow_Phone,
    RegistrationAdditionalSectionRow_Email,
    RegistrationAdditionalSectionRow_Count
};

NS_ENUM(NSInteger, RegistrationSections){
    RegistrationSections_Main,
    RegistrationSections_Additional,
    RegistrationSections_Count,
};

static const CGFloat kHeaderHeight = 30.0f;
static const CGFloat kIAcceptCheckboxSize = 19.0f;
static const CGFloat kIAcceptLabelTextFont = 10.0f;

@interface PRProfileRegistrationViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, SelectionViewControllerDelegate, PRCheckboxDelegate>

@property (weak, nonatomic) IBOutlet UITableView* tableView;
@property (weak, nonatomic) IBOutlet UILabel* titleLabel;
@property (weak, nonatomic) IBOutlet UIView* contentView;

@property (strong, nonatomic) NSString* docFirstName;
@property (strong, nonatomic) NSString* docLastName;
@property (strong, nonatomic) NSString* docMiddleName;
@property (strong, nonatomic) NSString* docBirthDate;
@property (strong, nonatomic) NSString* docPhone;
@property (strong, nonatomic) NSString* docEmail;

@property (strong, nonatomic) CustomActionSheetViewController* birthDaySelectionVC;
@property (strong, nonatomic) UITextField* activeField;
@property (nonatomic) BOOL isCheckboxSelected;

@end

@implementation PRProfileRegistrationViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self prepareNavigationBar];

    [_titleLabel setText:NSLocalizedString(@"Registration", nil)];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableView.backgroundColor = [UIColor whiteColor];

    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard)];
    [_contentView addGestureRecognizer:tapGesture];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registerForNotifications];
    [self setupNavigationRightButton];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.view endEditing:YES];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self unregisterForNotifications];
    [super viewDidDisappear:animated];
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return RegistrationSections_Count;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowsCount;
    switch (section) {
    case RegistrationSections_Main:
        rowsCount = RegistrationMainSectionRow_Count;
        break;
    case RegistrationSections_Additional:
        rowsCount = RegistrationAdditionalSectionRow_Count;
    default:
        break;
    }

    return rowsCount;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    PRProfileRegistrationCell* cell = [tableView dequeueReusableCellWithIdentifier:@"PRProfileRegistrationCell"];
    NSInteger tag = [self tagForSection:indexPath.section andRow:indexPath.row];

    switch (indexPath.section) {
    case RegistrationSections_Main: {

        switch (indexPath.row) {
        case RegistrationMainSectionRow_LastName:
            [cell configureCellWithTextfieldText:_docLastName placeholder:@"Last name" tag:tag delegate:self arrowImageHidden:YES];
            break;
        case RegistrationMainSectionRow_FirstName:
            [cell configureCellWithTextfieldText:_docFirstName placeholder:@"First name" tag:tag delegate:self arrowImageHidden:YES];
            break;
        case RegistrationMainSectionRow_MiddleName:
            [cell configureCellWithTextfieldText:_docMiddleName placeholder:@"Middle name" tag:tag delegate:self arrowImageHidden:YES];
            break;
        case RegistrationMainSectionRow_DateOfBirth: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"PRProfileRegistrationCellWithPicker"];
            [cell configureCellWithTextfieldText:_docBirthDate placeholder:@"Date of Birth" tag:tag delegate:self arrowImageHidden:NO];
        }
        default:
            break;
        }
    } break;
    case RegistrationSections_Additional: {

        switch (indexPath.row) {
        case RegistrationAdditionalSectionRow_Phone:
            [cell configureCellWithTextfieldText:_docPhone placeholder:@"Phone" tag:tag delegate:self arrowImageHidden:YES];
            break;
        case RegistrationAdditionalSectionRow_Email: {
            [cell configureCellWithTextfieldText:_docEmail placeholder:@"Email" tag:tag delegate:self arrowImageHidden:YES];
        }
        default:
            break;
        }
    } break;
    default:
        break;
    }

    return cell;
}

#pragma mark - TableViewDelegate

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat headerHeight = CGFLOAT_MIN;
    if (section == RegistrationSections_Additional) {
        headerHeight = kHeaderHeight;
    }

    return headerHeight;
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat footerHeight = CGFLOAT_MIN;
    if (section == RegistrationSections_Additional) {
        footerHeight = kHeaderHeight;
    }

    return footerHeight;
}

- (UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section
{
    UITableViewHeaderFooterView* footerView;
    if (section == RegistrationSections_Additional) {
        footerView = [self footerView];
    }

    return footerView;
}

#pragma mark - TextFieldDelegate

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
    NSString* finalString = [textField.text stringByReplacingCharactersInRange:range withString:string];

    if (textField.tag == [self tagForSection:RegistrationSections_Main andRow:RegistrationMainSectionRow_LastName]) {

        finalString = [self correctNameText:finalString];
        _docLastName = finalString;
        textField.text = finalString;
        [self setupNavigationRightButton];
        return NO;
    } else if (textField.tag == [self tagForSection:RegistrationSections_Main andRow:RegistrationMainSectionRow_FirstName]) {

        finalString = [self correctNameText:finalString];
        _docFirstName = finalString;
        textField.text = finalString;
        [self setupNavigationRightButton];
        return NO;
    } else if (textField.tag == [self tagForSection:RegistrationSections_Main andRow:RegistrationMainSectionRow_MiddleName]) {

        finalString = [self correctNameText:finalString];
        _docMiddleName = finalString;
        textField.text = finalString;
        [self setupNavigationRightButton];
        return NO;
    } else if (textField.tag == [self tagForSection:RegistrationSections_Additional andRow:RegistrationAdditionalSectionRow_Phone]) {

        NSCharacterSet* set = [[NSCharacterSet characterSetWithCharactersInString:@"+0123456789"] invertedSet];
        if ([string rangeOfCharacterFromSet:set].location != NSNotFound) {
            return NO;
        }
        if (range.location == 0 && [string isEqualToString:@""]) {
            textField.text = finalString;
        }
        else {
            textField.text = [NSString stringWithFormat:@"+%@",[self correctPhoneNumber:finalString]];
        }
        PRProfileRegistrationCell* cell;
        cell = [_tableView cellForRowAtIndexPath:[self indexPathForTextField:textField]];
        [cell changePlaceholderText:textField.text];

        _docPhone = [NSString stringWithFormat:@"+%@", [Utils removeAllSeparatorsInString:finalString]];
        [self setupNavigationRightButton];
        return NO;

    } else if (textField.tag == [self tagForSection:RegistrationSections_Additional andRow:RegistrationAdditionalSectionRow_Email]) {

        _docEmail = finalString;
    }

    if (textField.tag == [self tagForSection:RegistrationSections_Main andRow:RegistrationMainSectionRow_DateOfBirth]) {

        _docBirthDate = finalString;
    }

    [self setupNavigationRightButton];

    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField*)textField
{
    if (textField.tag == [self tagForSection:RegistrationSections_Main andRow:RegistrationMainSectionRow_LastName] ||
        textField.tag == [self tagForSection:RegistrationSections_Main andRow:RegistrationMainSectionRow_FirstName] ||
        textField.tag == [self tagForSection:RegistrationSections_Main andRow:RegistrationMainSectionRow_MiddleName]) {
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    }

    if (textField.tag == [self tagForSection:RegistrationSections_Main andRow:RegistrationMainSectionRow_DateOfBirth]) {
        [_activeField resignFirstResponder];

        if (!_birthDaySelectionVC) {
            _birthDaySelectionVC = [[CustomActionSheetViewController alloc] init];
        }

        CustomActionSheetViewController* pickerViewController = _birthDaySelectionVC;
        [self createDatePickerForPickerController:pickerViewController];
        [(UIDatePicker*)pickerViewController.picker setMaximumDate:[NSDate date]];

        pickerViewController.delegate = self;
        ((UIDatePicker*)pickerViewController.picker).datePickerMode = UIDatePickerModeDate;
        if (@available(iOS 13.4, *)) {
            ((UIDatePicker*)pickerViewController.picker).preferredDatePickerStyle = UIDatePickerStyleWheels;
        }
        NSDate* currentDate = [NSDate new];
        NSString* dateFormat = DATE_DAY_FORMAT;

#if defined(Otkritie)
        currentDate = [currentDate mt_dateYearsBefore:30];
        dateFormat = DATE_FORMAT_ddMMyyyy;
#endif

        if (!textField.text || [textField.text isEqualToString:@""]) {
            ((UIDatePicker*)pickerViewController.picker).date = currentDate;
        } else {
            ((UIDatePicker*)pickerViewController.picker).date = [NSDate mt_dateFromString:textField.text usingFormat:dateFormat] ?: currentDate;
        }
        [pickerViewController showForField:(UIPickerTextField*)textField];

        return NO;
    }

    UIKeyboardType keyboardType = UIKeyboardTypeDefault;

    if (textField.tag == [self tagForSection:RegistrationSections_Additional andRow:RegistrationAdditionalSectionRow_Phone]) {
        keyboardType = UIKeyboardTypePhonePad;
    } else if (textField.tag == [self tagForSection:RegistrationSections_Additional andRow:RegistrationAdditionalSectionRow_Email]) {
        keyboardType = UIKeyboardTypeEmailAddress;
        textField.textColor = [UIColor blackColor];
    }

    [textField setKeyboardType:keyboardType];
    [self setSelectedTextField:textField];
    _activeField = textField;

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];

    return YES;
}

- (void)textFieldDidEndEditing:(UITextField*)textField
{
    if (textField.tag == [self tagForSection:RegistrationSections_Additional andRow:RegistrationAdditionalSectionRow_Email] && ![textField.text isValidEmail]) {
        textField.textColor = [UIColor redColor];
    }
}

- (NSString*)correctNameText:(NSString*)string
{
    if (string.length == 1) {
        string = [string localizedUppercaseString];
    } else if (string.length > 1) {
        if ([[string substringWithRange:NSMakeRange(string.length - 2, 1)] isEqualToString:@" "]) {
            NSString* prefixString = [string substringToIndex:string.length - 1];
            NSString* suffixString = [[string substringFromIndex:string.length - 1] localizedUppercaseString];
            string = [NSString stringWithFormat:@"%@%@",prefixString,suffixString];
        }
    }
    return string;
}

- (NSString*)correctPhoneNumber:(NSString*)number
{
    NSString* correctNumber = [Utils removeAllSeparatorsInString:number];
    return [Utils applyFormatForFormattedString:correctNumber];
}

#pragma mark - CheckboxDelegate

- (void)didSelectCheckbox:(BOOL)selection
{
    _isCheckboxSelected = selection;
    [self setupNavigationRightButton];
}

#pragma mark - Helpers

- (void)prepareNavigationBar
{
    UIBarButtonItem* nextButton =
        [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", )
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(registerUserProfile)];

    nextButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = nextButton;
}

- (void)setupNavigationRightButton
{
    BOOL enabled = YES;

    if (!_docFirstName || !_docLastName || !_docBirthDate || !_docPhone || !_docEmail || !_isCheckboxSelected || ![_docEmail isValidEmail]) {
        enabled = NO;
    } else {
        for (NSString* text in @[ _docFirstName, _docLastName, _docBirthDate, _docPhone, _docEmail ]) {
            NSString* finalString = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
            if ([finalString isEqualToString:@""]) {
                enabled = NO;
                break;
            }
        }
    }

    self.navigationItem.rightBarButtonItem.enabled = enabled;
}

- (NSInteger)tagForSection:(NSInteger)section andRow:(NSInteger)row
{
    return 100 + (section + 1) * 10 + row;
}

- (void)createDatePickerForPickerController:(CustomActionSheetViewController*)pickerViewController
{
    if (!pickerViewController.picker) {
        pickerViewController.picker = [UIDatePicker new];
    }
}

- (NSIndexPath*)indexPathForTextField:(UITextField*)textField
{
    NSIndexPath* indexPath;

    if (textField.tag == [self tagForSection:RegistrationSections_Main andRow:RegistrationMainSectionRow_LastName]) {

        indexPath = [NSIndexPath indexPathForRow:RegistrationMainSectionRow_LastName inSection:RegistrationSections_Main];
    } else if (textField.tag == [self tagForSection:RegistrationSections_Main andRow:RegistrationMainSectionRow_FirstName]) {

        indexPath = [NSIndexPath indexPathForRow:RegistrationMainSectionRow_FirstName inSection:RegistrationSections_Main];
    } else if (textField.tag == [self tagForSection:RegistrationSections_Main andRow:RegistrationMainSectionRow_MiddleName]) {

        indexPath = [NSIndexPath indexPathForRow:RegistrationMainSectionRow_MiddleName inSection:RegistrationSections_Main];
    } else if (textField.tag == [self tagForSection:RegistrationSections_Additional andRow:RegistrationAdditionalSectionRow_Phone]) {

        indexPath = [NSIndexPath indexPathForRow:RegistrationAdditionalSectionRow_Phone inSection:RegistrationSections_Additional];
    } else if (textField.tag == [self tagForSection:RegistrationSections_Additional andRow:RegistrationAdditionalSectionRow_Email]) {

        indexPath = [NSIndexPath indexPathForRow:RegistrationAdditionalSectionRow_Email inSection:RegistrationSections_Additional];
    }

    if (textField.tag == [self tagForSection:RegistrationSections_Main andRow:RegistrationMainSectionRow_DateOfBirth]) {

        indexPath = [NSIndexPath indexPathForRow:RegistrationMainSectionRow_DateOfBirth inSection:RegistrationSections_Main];
    }

    return indexPath;
}

- (UITableViewHeaderFooterView*)footerView
{

    PRProfileRegistrationFooterView* footerView = [[[NSBundle mainBundle] loadNibNamed:@"PRProfileRegistrationView" owner:self options:nil] firstObject];
    [footerView configureViewWithTitle:NSLocalizedString(@"I accept the contract and the rules of service", nil)
                             titleFont:[UIFont systemFontOfSize:kIAcceptLabelTextFont]
                              delegate:self
                          checkboxSize:CGSizeMake(kIAcceptCheckboxSize, kIAcceptCheckboxSize)];

    return footerView;
}

- (void)setSelectedTextField:(UITextField*)textField
{
    PRProfileRegistrationCell* cell;

    if (_activeField) {
        cell = [_tableView cellForRowAtIndexPath:[self indexPathForTextField:_activeField]];
        [cell setSelection:NO];
    }

    if (textField) {
        cell = [_tableView cellForRowAtIndexPath:[self indexPathForTextField:textField]];
        [cell setSelection:YES];
    }
}

#pragma mark - Registration

- (void)registerUserProfile
{
    [self.navigationItem.rightBarButtonItem setEnabled:NO];

    NSDictionary* userParams = [[NSDictionary alloc] initWithObjectsAndKeys:_cardNumber, @"card_number", _docFirstName, @"first_name", _docLastName, @"last_name", _docMiddleName ?: @"", @"middle_name", _docBirthDate, @"birthday", _docPhone, @"phone", _docEmail, @"email", nil];

    __weak PRProfileRegistrationViewController* weakSelf = self;
    [PRRequestManager registerUserProfile:userParams
        view:self.view
        mode:PRRequestMode_ShowErrorMessagesAndProgress
        success:^{
            PRProfileRegistrationViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            [strongSelf nextStep];
        }
        failure:^{
            PRProfileRegistrationViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            [strongSelf setupNavigationRightButton];
        }];
}

- (void)nextStep
{
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RegistrationStepTwoViewController* viewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"RegistrationStepTwoViewController"];
    viewController.phoneNumber = [_docPhone stringByReplacingOccurrencesOfString:@"+" withString:@""];

    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Notifications

- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)unregisterForNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

#pragma mark - Notification Handler

- (void)keyboardWillHide:(NSNotification*)notification
{
    [self setSelectedTextField:nil];
    _activeField = nil;
}

#pragma mark - SelectionViewControllerDelegate

- (void)selectionViewControllerDidDoneFor:(CustomActionSheetViewController*)sheet
{
    NSString* dateString = nil;
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

    _docBirthDate = dateString;

    NSIndexPath* indexPathToReload = [NSIndexPath indexPathForRow:RegistrationMainSectionRow_DateOfBirth inSection:RegistrationSections_Main];
    [_tableView reloadRowsAtIndexPaths:@[ indexPathToReload ] withRowAnimation:UITableViewRowAnimationNone];
    [self setupNavigationRightButton];
}

#pragma mark - Actions

- (void)closeKeyboard
{
    [self.view endEditing:YES];
}

@end
