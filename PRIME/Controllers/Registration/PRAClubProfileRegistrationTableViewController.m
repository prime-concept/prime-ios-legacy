#import "PRAClubProfileRegistrationTableViewController.h"
#import "UIPickerTextField.h"
#import "RegistrationStepTwoViewController.h"
#import "PRAgreementViewController.h"
#import "NSString+extended.h"
#import "CustomActionSheetViewController+Picker.h"
#import "PRUINavigationController.h"
#import "PRProfileRegistrationViewController.h"

NS_ENUM(NSInteger, PRRegistrationRow) {
    PRRegistrationRow_CardNumber,
    PRRegistrationRow_FirstName,
    PRRegistrationRow_LastName,
    PRRegistrationRow_Phone,
    PRRegistrationRow_Email
};

@interface PRAClubProfileRegistrationTableViewController () <UITextFieldDelegate, SelectionViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField* lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField* firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField* cardNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField* phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField* emailTextField;
@property (weak, nonatomic) IBOutlet UIImageView* agreementCheckBoxImageView;
@property (weak, nonatomic) IBOutlet UILabel *cardNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *agreementLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstSectionLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondSectionLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdSectionLabel;

// Local variables
@property (strong, nonatomic) NSString* firstName;
@property (strong, nonatomic) NSString* lastName;
@property (strong, nonatomic) NSString* phone;
@property (strong, nonatomic) NSString* email;
@property (strong, nonatomic) NSString* cardNumber;
@property (assign, nonatomic) BOOL isAgreementCheckboxSelected;
@property (strong, nonatomic) UIBarButtonItem* nextButton;

@end

@implementation PRAClubProfileRegistrationTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self prepareNavigationBar];
    [self updateButtons];
    [self addTapGesture];
    [self updateCardNumber];
    [self updateLabels];
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
    [self.cardNumberLabel setFont:[UIFont systemFontOfSize:12]];
    [self.firstNumberLabel setFont:[UIFont systemFontOfSize:12]];
    [self.lastNameLabel setFont:[UIFont systemFontOfSize:12]];
    [self.phoneLabel setFont:[UIFont systemFontOfSize:12]];
    [self.emailLabel setFont:[UIFont systemFontOfSize:12]];
    [self.agreementLabel setFont:[UIFont systemFontOfSize:14]];

    [self.firstSectionLabel setFont:[UIFont boldSystemFontOfSize:50]];
    [self.secondSectionLabel setFont:[UIFont boldSystemFontOfSize:50]];
    [self.thirdSectionLabel setFont:[UIFont boldSystemFontOfSize:50]];

    [self.cardNumberLabel setText:NSLocalizedString(@"Card number", nil)];
    [self.firstNumberLabel setText:NSLocalizedString(@"First name", nil)];
    [self.lastNameLabel setText:NSLocalizedString(@"Last name", nil)];

    [self.firstNameTextField setPlaceholder:NSLocalizedString(@"First name", nil)];
    [self.lastNameTextField setPlaceholder:NSLocalizedString(@"Last name", nil)];

    [self.phoneLabel setText:NSLocalizedString(@"Phone", nil)];
    [self.emailLabel setText:NSLocalizedString(@"Email (optional)", nil)];
    [self.agreementLabel setText:NSLocalizedString(@"I accept the contract and the rules of service", nil)];
}

- (void)updateButtons
{
    self.agreementCheckBoxImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(agreementCheckBoxTaped)];
    [self.agreementCheckBoxImageView addGestureRecognizer:tapGesture];
}

- (void)updateCardNumber
{
    self.cardNumberTextField.text = self.cardNumber;
    [self.cardNumberTextField setEnabled:NO];
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

    if (!self.firstName || !self.lastName || !self.phone || !self.isAgreementCheckboxSelected) {
        enabled = NO;
    } else {
        if (self.email && ![self.email isValidEmail]) {
            enabled = [self.email isEqualToString:@""];
        }

        for (NSString* text in @[ self.firstName, self.lastName, self.phone ]) {
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

#pragma mark - Registration

- (void)registerUserProfile
{
    [self.navigationItem.rightBarButtonItem setEnabled:NO];

    NSDictionary* userParams = [[NSDictionary alloc] initWithObjectsAndKeys:self.cardNumber, kCardNumber, self.firstName, kFirstName, self.lastName, kLastName, @"", kMiddleName, @"", kBirthday, self.phone, kPhone, self.email ?: @"", kEmail, nil];

    __weak PRAClubProfileRegistrationTableViewController* weakSelf = self;
    [PRRequestManager registerUserProfile:userParams
        view:self.view
        mode:PRRequestMode_ShowErrorMessagesAndProgress
        success:^{
            PRAClubProfileRegistrationTableViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            [strongSelf registerWithPhone];
        }
        failure:^{
            PRAClubProfileRegistrationTableViewController* strongSelf = weakSelf;
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
        case PRRegistrationRow_CardNumber:
        {
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
    if (textField.tag == PRRegistrationRow_Email) {
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
    [self setupNavigationRightButton];
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

@end
