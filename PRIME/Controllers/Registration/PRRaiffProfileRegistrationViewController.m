//
//  PRRaiffProfileRegistrationViewController.m
//  Raiffeisen
//
//  Created by Davit Nahapetyan on 7/4/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import "PRRaiffProfileRegistrationViewController.h"
#import "RegistrationStepTwoViewController.h"
#import "PRAgreementViewController.h"
#import "NSString+extended.h"
#import "CustomActionSheetViewController+Picker.h"
#import "PRUINavigationController.h"

NS_ENUM(NSInteger, PRRegistrationRow) {
    PRRegistrationRow_LastName,
    PRRegistrationRow_FirstName,
    PRRegistrationRow_MiddleName,
    PRRegistrationRow_BirthDate,
    PRRegistrationRow_Phone,
    PRRegistrationRow_Email
};

NS_ENUM(NSInteger, PRRegistrationCellGroup) {
    PRRegistrationCellGroup_ProfileCard,
    PRRegistrationCellGroup_ProfileHeader,
    PRRegistrationCellGroup_ProfileName,
    PRRegistrationCellGroup_ProfileBirthDate,
    PRRegistrationCellGroup_ProfilePhone,
    PRRegistrationCellGroup_ProfileEmail,
    PRRegistrationCellGroup_ProfileAgreement,
    PRRegistrationCellGroup_ProfileBecomeClient
};

static const NSInteger kProfileCardCellHeight = 245;
static const NSInteger kProfileCardCellHeightForSmalDevices = 200;
static const NSInteger kProfileCardCellHeightForLargeDevices = 265;
static const NSInteger kProfileNameGroupCellHeight = 180;
static const NSInteger kProfileBirthDateCellHeight = 76;
static const NSInteger kProfileDefaultCellHeight = 44;

@interface PRRaiffProfileRegistrationViewController () <UITextFieldDelegate, SelectionViewControllerDelegate>

// Outlets
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *middleNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIPickerTextField *birthdatePickerTextField;
@property (weak, nonatomic) IBOutlet SHSPhoneTextField *cardNumberTextField;
@property (weak, nonatomic) IBOutlet UIImageView *agreementCheckBoxImageView;
@property (weak, nonatomic) IBOutlet UIButton *becomeClientButton;
@property (weak, nonatomic) IBOutlet UIButton *agreementButton;
@property (weak, nonatomic) IBOutlet UILabel *clientProfileLabel;
@property (weak, nonatomic) IBOutlet UILabel *conciergeServiceLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *middleNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *birthdateLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstSectionLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondSectionLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdSectionLabel;
@property (weak, nonatomic) IBOutlet UILabel *fourthSectionLabel;

// Local variables
@property (strong, nonatomic) NSString* firstName;
@property (strong, nonatomic) NSString* lastName;
@property (strong, nonatomic) NSString* middleName;
@property (strong, nonatomic) NSString* phone;
@property (strong, nonatomic) NSString* email;
@property (strong, nonatomic) NSString* birthDate;
@property (strong, nonatomic) NSString* cardNumber;

@property (strong, nonatomic) CustomActionSheetViewController* birthDaySelectionVC;

@property (assign, nonatomic) BOOL isAgreementCheckboxSelected;

@end

@implementation PRRaiffProfileRegistrationViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateButtonState];
    [self updateCardNumberField];
    [self updateLabels];
    [self updateButtons];
    [self addTapGesture];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [(PRUINavigationController*)self.navigationController setNavigationBarColor:[UIColor whiteColor]];
}

#pragma mark - Accessors

- (void)setCardNumber:(NSString*)cardNumber
{
    _cardNumber = cardNumber;
}

#pragma mark - UI Updates

- (void)updateButtonState
{
    BOOL enabled = YES;

    if (!self.firstName || !self.lastName || !self.birthDate || !self.phone || !self.email || !self.isAgreementCheckboxSelected || ![self.email isValidEmail]) {
        enabled = NO;
    }
    else {
        for (NSString* text in @[ self.firstName, self.lastName, self.birthDate, self.phone, self.email ]) {
            NSString* finalString = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
            if ([finalString isEqualToString:@""]) {
                enabled = NO;
                break;
            }
        }
    }
    self.becomeClientButton.enabled = enabled;
    self.becomeClientButton.backgroundColor = enabled ? kBecomeClientEnabledColor : kRLightGreyColor;
}

- (void)updateLabels
{
    [self.clientProfileLabel setFont:[UIFont boldSystemFontOfSize:22]];
    [self.conciergeServiceLabel setFont:[UIFont systemFontOfSize:17]];
    [self.firstNameLabel setFont:[UIFont systemFontOfSize:10]];
    [self.lastNameLabel setFont:[UIFont systemFontOfSize:10]];
    [self.middleNameLabel setFont:[UIFont systemFontOfSize:10]];
    [self.phoneLabel setFont:[UIFont systemFontOfSize:10]];
    [self.emailLabel setFont:[UIFont systemFontOfSize:10]];
    [self.birthdateLabel setFont:[UIFont systemFontOfSize:10]];
    [self.firstSectionLabel setFont:[UIFont boldSystemFontOfSize:50]];
    [self.secondSectionLabel setFont:[UIFont boldSystemFontOfSize:50]];
    [self.thirdSectionLabel setFont:[UIFont boldSystemFontOfSize:50]];
    [self.fourthSectionLabel setFont:[UIFont boldSystemFontOfSize:50]];
}

- (void)updateButtons
{
    NSAttributedString* titleUnderlined = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Consent to personal data processing", nil)
                                                                          attributes:@{ NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle) }];
    self.agreementButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.agreementButton setFont:[UIFont systemFontOfSize:12]];
    [self.agreementButton setAttributedTitle:titleUnderlined forState:UIControlStateNormal];
    [self.becomeClientButton setTitle:NSLocalizedString(@"Become a client", nil) forState:UIControlStateNormal];
}

- (void)updateCardNumberField
{
    [self.cardNumberTextField setFont:[UIFont fontWithName:@"OCRA" size:20]];
    [self.cardNumberTextField.formatter setDefaultOutputPattern:DEFAULT_CARD_FORMAT];
    [self.cardNumberTextField setFormattedText:self.cardNumber];
}

- (void)addTapGesture
{
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)closeKeyboard
{
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
    NSString* finalString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    switch (textField.tag) {
        case PRRegistrationRow_LastName:
        {
            finalString = [self correctNameText:finalString];
            self.lastName = finalString;
            textField.text = finalString;
            [self updateButtonState];
            return NO;
        }
        case PRRegistrationRow_FirstName:
        {
            finalString = [self correctNameText:finalString];
            self.firstName = finalString;
            textField.text = finalString;
            [self updateButtonState];
            return NO;
        }
        case PRRegistrationRow_MiddleName:
        {
            finalString = [self correctNameText:finalString];
            self.middleName = finalString;
            textField.text = finalString;
            [self updateButtonState];
            return NO;
        }
        case PRRegistrationRow_Phone:
        {
            NSCharacterSet* set = [[NSCharacterSet characterSetWithCharactersInString:@"+0123456789"] invertedSet];
            if ([string rangeOfCharacterFromSet:set].location != NSNotFound) {
                return NO;
            }
            if (range.location == 0 && [string isEqualToString:@""]) {
                textField.text = finalString;
            }
            else {
                textField.text = [NSString stringWithFormat:@"+%@", [self correctPhoneNumber:finalString]];
            }

            self.phone = [NSString stringWithFormat:@"+%@", [Utils removeAllSeparatorsInString:finalString]];
            [self updateButtonState];
            return NO;
        }
        case PRRegistrationRow_BirthDate:
        {
            self.birthDate = finalString;
        }
        case PRRegistrationRow_Email:
        {
            self.email = finalString;
        }
    }

    [self updateButtonState];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField.tag == PRRegistrationRow_BirthDate)
    {
        [self closeKeyboard];
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

        NSDate* currentDate = [[NSDate new] mt_dateYearsBefore:30];
        NSString* dateFormat = DATE_FORMAT_ddMMyyyy;

        if (!textField.text || [textField.text isEqualToString:@""]) {
            ((UIDatePicker*)pickerViewController.picker).date = currentDate;
        }
        else {
            ((UIDatePicker*)pickerViewController.picker).date = [NSDate mt_dateFromString:textField.text usingFormat:dateFormat] ?: currentDate;
        }
        [pickerViewController showForField:(UIPickerTextField*)textField];

        return NO;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField*)textField
{
    if (textField.tag == PRRegistrationRow_Email && ![textField.text isValidEmail]) {
        textField.textColor = [UIColor redColor];
    }
}

- (NSString*)correctNameText:(NSString*)string
{
    if (string.length == 1) {
        string = [string localizedUppercaseString];
    }
    else if (string.length > 1) {
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

#pragma mark - SelectionViewControllerDelegate

- (void)selectionViewControllerDidDoneFor:(CustomActionSheetViewController*)sheet
{
    NSDate* currentDate = [[NSDate new] mt_dateYearsBefore:30];
    NSString* dateFormat = DATE_FORMAT_ddMMyyyy;
    NSString* dateString = (!((UIDatePicker*)sheet.picker).date) ? [currentDate mt_stringFromDateWithFormat:dateFormat localized:NO] : [((UIDatePicker*)sheet.picker).date mt_stringFromDateWithFormat:dateFormat localized:NO];
    self.birthDate = dateString;
    [self.birthdatePickerTextField setText:dateString];
    [self updateButtonState];
}

- (void)createDatePickerForPickerController:(CustomActionSheetViewController*)pickerViewController
{
    if (!pickerViewController.picker) {
        pickerViewController.picker = [UIDatePicker new];
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.row) {

    case PRRegistrationCellGroup_ProfileCard:
        if (IS_IPHONE_5) {
            return kProfileCardCellHeightForSmalDevices;
        } else if (IS_IPHONE_6P) {
            return kProfileCardCellHeightForLargeDevices;
        }
        return kProfileCardCellHeight;
    case PRRegistrationCellGroup_ProfileName:
        return kProfileNameGroupCellHeight;
    case PRRegistrationCellGroup_ProfileBirthDate:
        return kProfileBirthDateCellHeight;
    case PRRegistrationCellGroup_ProfilePhone:
        return kProfileBirthDateCellHeight;
    case PRRegistrationCellGroup_ProfileEmail:
        return kProfileBirthDateCellHeight;
    case PRRegistrationCellGroup_ProfileAgreement:
        return kProfileBirthDateCellHeight;
    case PRRegistrationCellGroup_ProfileBecomeClient:
        return kProfileDefaultCellHeight;
    default:
        return UITableViewAutomaticDimension;
    }
}

#pragma mark - Actions

- (IBAction)becomeClientButtonPressed:(id)sender
{
    NSDictionary* userParams = [[NSDictionary alloc] initWithObjectsAndKeys:self.cardNumber, kCardNumber, self.firstName, kFirstName, self.lastName, kLastName, self.middleName ?: @"", kMiddleName, self.birthDate, kBirthday, self.phone, kPhone, self.email, kEmail, nil];

    __weak PRRaiffProfileRegistrationViewController* weakSelf = self;
    [PRRequestManager registerUserProfile:userParams
                                     view:self.view
                                     mode:PRRequestMode_ShowErrorMessagesAndProgress
                                  success:^{
                                      PRRaiffProfileRegistrationViewController* strongSelf = weakSelf;
                                      if (!strongSelf) {
                                          return;
                                      }

                                      [strongSelf registerWithPhone];
                                  }
                                  failure:^{
                                      PRRaiffProfileRegistrationViewController* strongSelf = weakSelf;
                                      if (!strongSelf) {
                                          return;
                                      }

                                      [strongSelf updateButtonState];
                                  }];
}

- (IBAction)agreementCheckboxTapped
{
    [self closeKeyboard];
    NSString* imageName = self.isAgreementCheckboxSelected ? @"unselectedCheckbox" : @"selectedCheckbox";
    [self.agreementCheckBoxImageView setImage:[UIImage imageNamed:imageName]];

    self.isAgreementCheckboxSelected = !self.isAgreementCheckboxSelected;
    [self updateButtonState];
}

- (IBAction)agreementButtonPressed:(id)sender
{
    PRAgreementViewController* agreementViewController = [[Utils mainStoryboard] instantiateViewControllerWithIdentifier:@"PRAgreementViewController"];
    [self.navigationController pushViewController:agreementViewController animated:YES];
}

- (void)registerWithPhone
{
    RegistrationStepTwoViewController* registrationStepTwoViewController = [[Utils mainStoryboard] instantiateViewControllerWithIdentifier:@"RegistrationStepTwoViewController"];
    registrationStepTwoViewController.phoneNumber = [self.phone stringByReplacingOccurrencesOfString:@"+" withString:@""];
    [self.navigationController pushViewController:registrationStepTwoViewController animated:YES];
}

@end
