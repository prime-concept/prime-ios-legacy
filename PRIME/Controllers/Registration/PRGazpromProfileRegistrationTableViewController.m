#import "PRGazpromProfileRegistrationTableViewController.h"
#import "UIPickerTextField.h"
#import "RegistrationStepTwoViewController.h"
#import "PRAgreementViewController.h"
#import "NSString+extended.h"
#import "CustomActionSheetViewController+Picker.h"
#import "PRUINavigationController.h"
#import "PRProfileRegistrationViewController.h"

NS_ENUM(NSInteger, PRRegistrationRow) {
    PRRegistrationRow_LastName,
    PRRegistrationRow_FirstName,
    PRRegistrationRow_MiddleName,
    PRRegistrationRow_BirthDate,
    PRRegistrationRow_Phone,
    PRRegistrationRow_Email
};

static const CGFloat kLabelsFontSize = 12.0;

@interface PRGazpromProfileRegistrationTableViewController () <UITextFieldDelegate, SelectionViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel* lastNameLabel;
@property (weak, nonatomic) IBOutlet UITextField* lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField* firstNameTextField;
@property (weak, nonatomic) IBOutlet UILabel* firstNameLabel;
@property (weak, nonatomic) IBOutlet UILabel* middleNameLabel;
@property (weak, nonatomic) IBOutlet UITextField* middleNameTextField;
@property (weak, nonatomic) IBOutlet UILabel* birthdateLabel;
@property (weak, nonatomic) IBOutlet UIPickerTextField* birthdatePickerTextField;
@property (weak, nonatomic) IBOutlet UILabel* phoneLabel;
@property (weak, nonatomic) IBOutlet UITextField* phoneTextField;
@property (weak, nonatomic) IBOutlet UILabel* emailLabel;
@property (weak, nonatomic) IBOutlet UITextField* emailTextField;
@property (weak, nonatomic) IBOutlet UIImageView* agreementCheckBoxImageView;
@property (weak, nonatomic) IBOutlet UIButton* agreementButton;

// Local variables
@property (strong, nonatomic) NSString* firstName;
@property (strong, nonatomic) NSString* lastName;
@property (strong, nonatomic) NSString* middleName;
@property (strong, nonatomic) NSString* phone;
@property (strong, nonatomic) NSString* email;
@property (strong, nonatomic) NSString* birthDate;
@property (strong, nonatomic) NSString* cardNumber;
@property (assign, nonatomic) BOOL isAgreementCheckboxSelected;
@property (strong, nonatomic) CustomActionSheetViewController* birthDaySelectionVC;
@property (strong, nonatomic) UIBarButtonItem* nextButton;

@end

@implementation PRGazpromProfileRegistrationTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self prepareNavigationBar];
    [self updateLabels];
    [self updateButtons];
    [self addTapGesture];
}

#pragma mark - Accessors

- (void)setCardNumber:(NSString*)cardNumber
{
    _cardNumber = cardNumber;
}

#pragma mark - Helpers

- (void)prepareNavigationBar
{
    self.nextButton =
        [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", )
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(registerUserProfile)];

    self.nextButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = self.nextButton;
    self.navigationController.navigationBar.tintColor = kTabBarUnselectedTextColor;
    [self setTitle:NSLocalizedString(@"Form", nil)];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{ NSForegroundColorAttributeName : [UIColor blackColor] }];
}

- (void)updateLabels
{
    [self.firstNameLabel setFont:[UIFont systemFontOfSize:kLabelsFontSize]];
    [self.lastNameLabel setFont:[UIFont systemFontOfSize:kLabelsFontSize]];
    [self.middleNameLabel setFont:[UIFont systemFontOfSize:kLabelsFontSize]];
    [self.phoneLabel setFont:[UIFont systemFontOfSize:kLabelsFontSize]];
    [self.emailLabel setFont:[UIFont systemFontOfSize:kLabelsFontSize]];
    [self.birthdateLabel setFont:[UIFont systemFontOfSize:kLabelsFontSize]];

}

- (void)updateButtons
{
    NSAttributedString* titleUnderlined = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Consent to personal data processing", nil)
                                                                          attributes:@{ NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle) }];
    self.agreementButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.agreementButton setFont:[UIFont systemFontOfSize:14]];
    [self.agreementButton setAttributedTitle:titleUnderlined forState:UIControlStateNormal];
    self.agreementCheckBoxImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(agreementCheckBoxTaped)];
    [self.agreementCheckBoxImageView addGestureRecognizer:tapGesture];
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

- (void)setupNavigationRightButton
{
    BOOL enabled = YES;

    if (!self.firstName || !self.lastName || !self.birthDate || !self.phone || !self.email || !self.isAgreementCheckboxSelected || ![self.email isValidEmail]) {
        enabled = NO;
    } else {
        for (NSString* text in @[ self.firstName, self.lastName, self.birthDate, self.phone, self.email ]) {
            NSString* finalString = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
            if ([finalString isEqualToString:@""]) {
                enabled = NO;
                break;
            }
        }
    }

    self.navigationItem.rightBarButtonItem.enabled = enabled;
}

- (void) agreementCheckBoxTaped
{
    [self closeKeyboard];
    NSString* imageName = self.isAgreementCheckboxSelected ? @"unselectedCheckbox" : @"selectedCheckbox";
    [self.agreementCheckBoxImageView setImage:[UIImage imageNamed:imageName]];

    self.isAgreementCheckboxSelected = !self.isAgreementCheckboxSelected;
    [self setupNavigationRightButton];
}

#pragma mark - Actions

- (IBAction)agreementButtonPressed:(id)sender
{
    PRAgreementViewController* agreementViewController = [[Utils mainStoryboard] instantiateViewControllerWithIdentifier:@"PRAgreementViewController"];
    [self.navigationController pushViewController:agreementViewController animated:YES];
}

#pragma mark - Registration

- (void)registerUserProfile
{
    [self.navigationItem.rightBarButtonItem setEnabled:NO];

    NSDictionary* userParams = [[NSDictionary alloc] initWithObjectsAndKeys:self.cardNumber, kCardNumber, self.firstName, kFirstName, self.lastName, kLastName, self.middleName ?: @"", kMiddleName, self.birthDate, kBirthday, self.phone, kPhone, self.email, kEmail, nil];

    __weak PRGazpromProfileRegistrationTableViewController* weakSelf = self;
    [PRRequestManager registerUserProfile:userParams
        view:self.view
        mode:PRRequestMode_ShowErrorMessagesAndProgress
        success:^{
            PRGazpromProfileRegistrationTableViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            [strongSelf registerWithPhone];
        }
        failure:^{
            PRGazpromProfileRegistrationTableViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            strongSelf.nextButton.enabled = YES;
        }];
}

- (void)registerWithPhone
{
    RegistrationStepTwoViewController* registrationStepTwoViewController = [[Utils mainStoryboard] instantiateViewControllerWithIdentifier:@"RegistrationStepTwoViewController"];
    registrationStepTwoViewController.phoneNumber = [self.phone stringByReplacingOccurrencesOfString:@"+" withString:@""];
    [self.navigationController pushViewController:registrationStepTwoViewController animated:YES];
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
            [self setupNavigationRightButton];
            return NO;
        }
        case PRRegistrationRow_FirstName:
        {
            finalString = [self correctNameText:finalString];
            self.firstName = finalString;
            textField.text = finalString;
            [self setupNavigationRightButton];
            return NO;
        }
        case PRRegistrationRow_MiddleName:
        {
            finalString = [self correctNameText:finalString];
            self.middleName = finalString;
            textField.text = finalString;
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
            [self setupNavigationRightButton];
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

    [self setupNavigationRightButton];

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
    } else if (textField.tag == PRRegistrationRow_Email) {
        textField.textColor = [UIColor blackColor];
        return YES;
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
    [self setupNavigationRightButton];
}

- (void)createDatePickerForPickerController:(CustomActionSheetViewController*)pickerViewController
{
    if (!pickerViewController.picker) {
        pickerViewController.picker = [UIDatePicker new];
    }
}



@end
