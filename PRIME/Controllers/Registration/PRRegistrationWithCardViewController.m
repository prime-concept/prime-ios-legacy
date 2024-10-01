//
//  PRRegistrationWithCardViewController.m
//  PRIME
//
//  Created by Aram on 8/7/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRRegistrationWithCardViewController.h"
#import "PRProfileRegistrationViewController.h"
#import "PRRaiffProfileRegistrationViewController.h"
#import "PRGazpromProfileRegistrationTableViewController.h"
#import "PRAClubProfileRegistrationTableViewController.h"
#import "ClubInformationViewController.h"
#import "InputFieldObserver.h"
#import "PRUINavigationController.h"

@import AudioToolbox;

@interface PRRegistrationWithCardViewController () <UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITextField* placeholderTextField;
@property (weak, nonatomic) IBOutlet SHSPhoneTextField* cardNumberTextField;
@property (weak, nonatomic) IBOutlet UILabel* noteLabel;
@property (weak, nonatomic) IBOutlet UIView* textFieldUpperView;
@property (weak, nonatomic) IBOutlet UIImageView *cardImageView;

@end

#if defined(PrimeClubConcierge)
    static NSString* const kCardEmptyText = @"--- --- ---";
#else
    static NSString* const kCardEmptyText = @"---- ---- ---- ----";
#endif

#if defined(PrimeClubConcierge)
    static NSString* const kCardDefaultText = @"000 000 000";
#else
    static NSString* const kCardDefaultText = @"0000 0000 0000 0000";
#endif
static const NSInteger kCardNumberTextFieldTextFont = 18;

@implementation PRRegistrationWithCardViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self addTextFieldObservers];
    [self prepareTextField];
    [self prepareNavigationRightButton];

    [_noteLabel setTextColor:kAppLabelColor];
    [_noteLabel setText:NSLocalizedString(kLoginWithCardText, nil)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [_placeholderTextField setText:kCardDefaultText];
    [_placeholderTextField setTextColor:[UIColor lightGrayColor]];

#if defined(Raiffeisen) || defined(PrivateBankingPRIMEClub)
    [(PRUINavigationController*)self.navigationController setNavigationBarColor:[UIColor whiteColor]];
#endif

#if defined(PrivateBankingPRIMEClub)
    self.navigationController.navigationBar.tintColor = kTabBarUnselectedTextColor;
    _cardImageView.image = [UIImage imageNamed: @"registration_card"];
#endif

#if defined(PrimeClubConcierge)
	self.navigationController.navigationBar.tintColor = kAppPassCodeColor;
#endif

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    for (UIScrollView* view in _parentController.view.subviews) {

        if ([view isKindOfClass:[UIScrollView class]]) {
            view.scrollEnabled = NO;
        }
    }

    [self performSelector:@selector(textFieldTapped) withObject:nil afterDelay:0.1];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField*)textField
{
    _placeholderTextField.userInteractionEnabled = NO;
    _cardNumberTextField.text = @"";
}

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
    if ([_placeholderTextField.text isEqualToString:kCardDefaultText] && [string isEqualToString:@""]) {
        return NO;
    }

    [_placeholderTextField setTextColor:[UIColor whiteColor]];
    [self setupNavigationRightButton];

    return YES;
}

- (void)textFieldTapped
{
    [_cardNumberTextField becomeFirstResponder];
}

#pragma mark - Helpers

- (void)nextStep
{
#if defined(Otkritie)
    PRProfileRegistrationViewController* profileRegistrationViewController = [[Utils mainStoryboard] instantiateViewControllerWithIdentifier:@"PRProfileRegistrationViewController"];
#elif defined(PrimeClubConcierge)
    PRAClubProfileRegistrationTableViewController* profileRegistrationViewController = [[Utils mainStoryboard] instantiateViewControllerWithIdentifier:@"PRAClubProfileRegistrationTableViewController"];
#elif defined(PrivateBankingPRIMEClub)
    PRGazpromProfileRegistrationTableViewController* profileRegistrationViewController = [[Utils mainStoryboard] instantiateViewControllerWithIdentifier:@"PRGazpromProfileRegistrationTableViewController"];
#else
    PRRaiffProfileRegistrationViewController* profileRegistrationViewController = [[Utils mainStoryboard] instantiateViewControllerWithIdentifier:@"PRRaiffProfileRegistrationViewController"];
#endif
    profileRegistrationViewController.cardNumber = [_cardNumberTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    [self.navigationController pushViewController:profileRegistrationViewController animated:YES];
}

- (void)openClubInformationView
{
    ClubInformationViewController* clubInformationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ClubInformationViewController"];
    clubInformationViewController.cardNumber = _cardNumberTextField.text;
    [self.navigationController pushViewController:clubInformationViewController animated:YES];
}

- (void)vibrate
{
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}

- (void)prepareNavigationRightButton
{
    UIBarButtonItem* nextButton =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", )
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(checkCardNumber)];

    self.navigationItem.rightBarButtonItem = nextButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)setupNavigationRightButton
{
    BOOL enabled = [_placeholderTextField.text isEqualToString:kCardEmptyText] ? NO : YES;
    self.navigationItem.rightBarButtonItem.enabled = enabled;
}

- (void)prepareTextField
{
    _cardNumberTextField.delegate = self;
    _cardNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
    _placeholderTextField.userInteractionEnabled = NO;

    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textFieldTapped)];
    [_textFieldUpperView addGestureRecognizer:tap];

    // Setting mask for Card Number Field.
    [_cardNumberTextField.formatter setDefaultOutputPattern:DEFAULT_CARD_FORMAT];

    _cardNumberTextField.font = [UIFont fontWithName:@"OCRA" size:kCardNumberTextFieldTextFont];
    [_placeholderTextField setFont:_cardNumberTextField.font];
    [_cardNumberTextField setTintColor:[UIColor clearColor]];
}

- (void)addTextFieldObservers
{
    _cardNumberTextField.textDidChangeBlock = ^(UITextField* textField) {
        //- Update Card Number.
        _placeholderTextField.text =
        [_cardNumberTextField.text stringByAppendingString:[kCardEmptyText substringFromIndex:[_cardNumberTextField.text length]]];
    };
}

- (void)checkCardNumber
{
    [[self view] endEditing:YES];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];

    __weak PRRegistrationWithCardViewController* weakSelf = self;
    [PRRequestManager verifyCardNumber:[_cardNumberTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""]
                                  view:self.view
                                  mode:PRRequestMode_ShowErrorMessagesAndProgress
                               success:^{
                                   PRRegistrationWithCardViewController* strongSelf = weakSelf;
                                   if (!strongSelf) {
                                       return;
                                   }

                                   [strongSelf nextStep];
                               }
                               failure:^{
                               }
                           unknownCard:^{
                               PRRegistrationWithCardViewController* strongSelf = weakSelf;
                               if (!strongSelf) {
                                   return;
                               }

                               [strongSelf vibrate];
                               [strongSelf openClubInformationView];
                           }];
}

@end

