//
//  AddCardViewController.m
//  PRIME
//
//  Created by Artak on 2/1/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "AddCardViewController.h"
#import "InputFieldObserver.h"
#import "PRCreditCardValidator.h"
#import <AVFoundation/AVFoundation.h>

static NSString* const kPaymentCardPlaceholderText = @"---- ---- ---- ----";
static NSString* const kExpDatePlaceholderText = @"--/--";

@interface AddCardViewController ()

@property (weak, nonatomic) IBOutlet UILabel* cardLabel;
@property (weak, nonatomic) IBOutlet UILabel* dateLabel;
@property (weak, nonatomic) IBOutlet SHSPhoneTextField* cardNumberTextField;
@property (weak, nonatomic) IBOutlet SHSPhoneTextField* dateTextField;

@property (weak, nonatomic) IBOutlet UIImageView* cameraImageView;
@property (weak, nonatomic) IBOutlet UIView* numbersView;
@property (weak, nonatomic) IBOutlet UILabel* keychanInfoLabel;
@property (weak, nonatomic) IBOutlet UIButton* scanCardButton;
@property (weak, nonatomic) IBOutlet UIButton* deleteButton;

@property (weak, nonatomic) IBOutlet UITextField* placeholderTextField;
@property (weak, nonatomic) IBOutlet UITextField* expDatePlaceholderTextField;

@property BOOL editMode;

@end

@implementation AddCardViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addTextFieldsObservers];
    [self prepareTextFields];
    [self prepareViews];
    [self prepareNavigationBar];
    self.view.backgroundColor = kTableViewBackgroundColor;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [CardIOUtilities preload];
}

#pragma mark - View Preparation

- (void)prepareTextFields
{
    _cardNumberTextField.delegate = self;
    _dateTextField.delegate = self;

    _cardNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
    _dateTextField.keyboardType = UIKeyboardTypeNumberPad;

    _cardLabel.textColor = kAppLabelColor;
    _dateLabel.textColor = kAppLabelColor;

    // Setting mask for Card Number Field.
    [_cardNumberTextField.formatter setDefaultOutputPattern:@"#### #### #### ####"];

    // Setting mask for Expiration Date.
    [_dateTextField.formatter setDefaultOutputPattern:@"##/##"];

    [_placeholderTextField setText:kPaymentCardPlaceholderText];
    _placeholderTextField.userInteractionEnabled = NO;

    [_expDatePlaceholderTextField setText:kExpDatePlaceholderText];
    _expDatePlaceholderTextField.userInteractionEnabled = NO;

    _cardNumberTextField.font = [UIFont fontWithName:@"OCRA" size:16];
    [_dateTextField setFont:[_cardNumberTextField font]];
    [_placeholderTextField setFont:[_cardNumberTextField font]];
    [_expDatePlaceholderTextField setFont:[_cardNumberTextField font]];
}

- (void)addTextFieldsObservers
{
    _cardNumberTextField.textDidChangeBlock = ^(UITextField* textField) {
        //- Update Card Number.
        _placeholderTextField.text =
            [_cardNumberTextField.text stringByAppendingString:[kPaymentCardPlaceholderText substringFromIndex:[_cardNumberTextField.text length]]];
    };

    _dateTextField.textDidChangeBlock = ^(UITextField* textField) {
        //- Update Exp Date.
        _expDatePlaceholderTextField.text =
            [_dateTextField.text stringByAppendingString:[kExpDatePlaceholderText substringFromIndex:[_dateTextField.text length]]];
    };

    [self addValidators];
}

- (void)addValidators
{
    [InputFieldObserver observInputFieldForValidation:_cardNumberTextField
                                        withValidator:^BOOL(NSString* text) {
                                            if (text.length == 19) {
                                                CreditCardType type = [PRCreditCardValidator checkWithCardNumber:text];
                                                if (type != CreditCardType_Mastercard && type != CreditCardType_Visa) {
                                                    return NO;
                                                }
                                            }
                                            return YES;
                                        }];

    [InputFieldObserver observInputFieldForValidation:_dateTextField
                                        withValidator:^BOOL(NSString* text) {
                                            if ([_dateTextField.text length] == 5 && ![PRCreditCardValidator isValidExpDate:_dateTextField.text]) {
                                                return NO;
                                            }
                                            return YES;
                                        }];
}

- (void)prepareViews
{
    _keychanInfoLabel.numberOfLines = 2;
    _keychanInfoLabel.text = NSLocalizedString(@"The card will be encrypted in the KeyChain and is only available on this device.", nil);
    _keychanInfoLabel.font = [UIFont systemFontOfSize:14.f];
    _keychanInfoLabel.textColor = kAppLabelColor;

    [_deleteButton setTitleColor:kDeleteButtonColor forState:UIControlStateNormal];

    _numbersView.layer.borderWidth = 0.3;
    _numbersView.layer.borderColor = kAppLabelColor.CGColor;

    _deleteButton.layer.borderWidth = 0.3;
    _deleteButton.layer.borderColor = kAppLabelColor.CGColor;
    [_deleteButton setBackgroundColor:[UIColor whiteColor]];
    [_deleteButton setTitle:NSLocalizedString(@"Delete", nil) forState:UIControlStateNormal];

    [_scanCardButton setTitle:NSLocalizedString(@"Scan the card", nil) forState:UIControlStateNormal];

    [_scanCardButton setTitleColor:kScanButtonColor forState:UIControlStateNormal];

    [_cameraImageView setTintColor:kScanButtonColor];

    if (_selectedCardIndex >= 0) {
        _deleteButton.hidden = NO;
    } else {
        _deleteButton.hidden = YES;
        _editMode = YES;
        [_cardNumberTextField becomeFirstResponder];
    }

    if (_selectedCardIndex >= 0 && _selectedCardIndex < [_cardData count]) {
        [InputFieldObserver removeObserverFromInputField:_cardNumberTextField];
        [InputFieldObserver removeObserverFromInputField:_dateTextField];

        PRCardData* cardData = _cardData[_selectedCardIndex];
        NSString* cardNumber = [PRCreditCardValidator getLongHiddenCardNumberWithStars:cardData.cardNumber];
        [_cardNumberTextField setText:cardNumber];
        [_placeholderTextField setText:cardNumber];
        [_dateTextField setText:cardData.expDate];
        [_expDatePlaceholderTextField setText:cardData.expDate];
    }
}

#pragma mark - Check Card

- (void)checkPaymentCardAndExpDateAndShowMessageIfNeedded:(BOOL)showMessages isScanned:(BOOL)isScanned
{
    NSString* cardNumber = _cardNumberTextField.text;
    CreditCardType type = [PRCreditCardValidator checkWithCardNumber:cardNumber];

    if (type == CreditCardType_Mastercard || type == CreditCardType_Visa) {
        if ([_dateTextField.text length] == 5) {

            if ([PRCreditCardValidator isValidExpDate:_dateTextField.text]) {
                [self.navigationItem.rightBarButtonItem setEnabled:YES];
            } else if (showMessages) {

                [PRMessageAlert showToastWithMessage:Message_InvalidExpDate];
            }
            return;
        }
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
        return;
    }
    [self.navigationItem.rightBarButtonItem setEnabled:NO];

    if (([_dateTextField.text length] == 5) && ([_cardNumberTextField.text length] == 16 + 3) && showMessages) {
        if (type != CreditCardType_Invalid) {
            [PRMessageAlert showToastWithMessage:Message_OnlyMasterVisaSupported];
            return;
        }
        [PRMessageAlert showToastWithMessage:Message_InvalidCard];
    } else if (isScanned) {
#ifdef Otkritie
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [PRMessageAlert showToastWithMessage:Message_InvalidCard];
        });
#endif
    }
}

- (void)passwordEditingChanged:(BOOL)showMessages
{
    [self checkPaymentCardAndExpDateAndShowMessageIfNeedded:showMessages isScanned:NO];

    if ([_cardNumberTextField.text length] == 16 + 3) { // +3 spaces.
        [_dateTextField becomeFirstResponder];
    }
}

- (void)expDateEditingChanged:(BOOL)showMessages
{
    [self checkPaymentCardAndExpDateAndShowMessageIfNeedded:showMessages isScanned:NO];
}

#pragma mark - Navigation Bar

- (void)prepareNavigationBar
{
    UIBarButtonItem* doneButton =
        [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", )
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(done)];
    self.navigationItem.rightBarButtonItem = doneButton;

    UIBarButtonItem* cancelButton =
        [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", )
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(cancel)];

    self.navigationItem.leftBarButtonItem = cancelButton;

    [self.navigationItem.rightBarButtonItem setEnabled:NO];

#if defined(PrivateBankingPRIMEClub) || defined(VTB24)
    self.extendedLayoutIncludesOpaqueBars = YES;
#endif
}

- (void)done
{
    CreditCardType type = [PRCreditCardValidator checkWithCardNumber:_cardNumberTextField.text];

    if (type == CreditCardType_Invalid) {
        [PRMessageAlert showToastWithMessage:Message_InvalidCard];
        return;
    }

    if (type != CreditCardType_Mastercard && type != CreditCardType_Visa) {
        [PRMessageAlert showToastWithMessage:Message_OnlyMasterVisaSupported];
        return;
    }

    if ([PRCreditCardValidator isCardExist:_cardNumberTextField.text expDate:_dateTextField.text]) {
        [PRMessageAlert showToastWithMessage:Message_PaymentCardAlreadyRegistered];
        return;
    }

    PRCardData* cardData = nil;
    if (_selectedCardIndex < [_cardData count]) {
        cardData = _cardData[_selectedCardIndex];
        _cardData = [NSMutableArray arrayWithObject:cardData];
        [PRGoogleAnalyticsManager sendEventWithName:kMyCardsSaveEditedPaymentCardButtonClicked parameters:nil];
    } else {
        cardData = [[PRCardData alloc] init];
        [_cardData addObject:cardData];
        [PRGoogleAnalyticsManager sendEventWithName:kMyCardsSaveNewPaymentCardButtonClicked parameters:nil];
    }
    cardData.cardNumber = _cardNumberTextField.text;
    cardData.expDate = _dateTextField.text;

    [_cardData storeToKeychainWithKey:kCardDataKeyPath];
    [_reloadDelegate reload];

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancel
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
    if ([_dateTextField isEqual:textField]) {
        if (range.length == 0 && string.length == 0) {
            if ([textField.text length] == 0) {
                NSLog(@"backspace tapped");
                dispatch_async(dispatch_get_main_queue(), ^{
                    //Your main thread task here.
                    [_cardNumberTextField becomeFirstResponder];
                });
            }
            return YES;
        }
        [self expDateEditingChanged:(string.length != 0)];
        return YES;
    }

    if ([_cardNumberTextField isEqual:textField]) {
        [self passwordEditingChanged:(string.length != 0)];
    }

    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField*)textField
{
    if (_selectedCardIndex < 0 || _editMode != NO) {
        return;
    }
    [_placeholderTextField setText:kPaymentCardPlaceholderText];
    _placeholderTextField.userInteractionEnabled = NO;

    [_expDatePlaceholderTextField setText:kExpDatePlaceholderText];
    _expDatePlaceholderTextField.userInteractionEnabled = NO;

    _cardNumberTextField.text = @"";
    _dateTextField.text = @"";

    _editMode = YES;

    [self addValidators];
}

#pragma mark - Actions

- (IBAction)actionScanCard:(UIButton*)sender
{
    if ([self checkAuthorizationStatusForCamera]) {
        [PRGoogleAnalyticsManager sendEventWithName:kMyCardsScanPaymentCardButtonClicked parameters:nil];
        [self presentCardIOPaymentViewController];
    }
}

- (IBAction)actionDelete:(UIButton*)sender
{
    if (_selectedCardIndex >= [_cardData count]) {
        return;
    }
    [PRGoogleAnalyticsManager sendEventWithName:kMyCardsDeletePaymentCardButtonClicked parameters:nil];
    [_cardData removeObjectAtIndex:_selectedCardIndex];
    [_cardData storeToKeychainWithKey:kCardDataKeyPath];

    [_reloadDelegate reload];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - CardIOPaymentViewControllerDelegate

- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController*)scanViewController
{
    NSLog(@"User canceled payment info");
    // Handle user cancellation here...
    [scanViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo*)info inPaymentViewController:(CardIOPaymentViewController*)scanViewController
{
    // The full card number is available as info.cardNumber, but don't log that!

    if (info) {
        NSLog(@"Received card info. Number: %@, expiry: %02lu/%lu, cvv: %@.", info.redactedCardNumber, (unsigned long)info.expiryMonth, (unsigned long)info.expiryYear, info.cvv);

        NSString* cardNumber = [PRCreditCardValidator getLongHiddenCardNumberWithStars:info.cardNumber];
        [_cardNumberTextField setText:info.cardNumber];
        [_placeholderTextField setText:cardNumber];

        if (info.expiryMonth > 0 && info.expiryYear > 0) {
            NSString* date = [NSString stringWithFormat:@"%02lu/%lu", info.expiryMonth, info.expiryYear % 2000];

            [_dateTextField setText:date];
            [_expDatePlaceholderTextField setText:date];
        }

        [self checkPaymentCardAndExpDateAndShowMessageIfNeedded:NO isScanned:YES];
    }

    [scanViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private methods

- (BOOL)checkAuthorizationStatusForCamera
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    __weak AddCardViewController* weakSelf = self;
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                                 completionHandler:^(BOOL granted) {
                                     if (!granted) { // Don't allow access.
                                         [weakSelf dismissCameraRollViewControler];
                                     }
                                 }];
    } else if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
        UIAlertController* alert = [UIAlertController
            alertControllerWithTitle:NSLocalizedString(@"This application does not have access to your camera", nil)
                             message:NSLocalizedString(@"You can enable access in Privacy Settings", nil)
                      preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* cancelButton = [UIAlertAction
            actionWithTitle:NSLocalizedString(@"OK", nil)
                      style:UIAlertActionStyleCancel
                    handler:^(UIAlertAction* _Nonnull action) {
                        [weakSelf presentCardIOPaymentViewController];
                    }];

        [alert addAction:cancelButton];
        [self presentViewController:alert animated:YES completion:nil];
        return NO;
    }

    return YES;
}

- (void)dismissCameraRollViewControler
{
    UIViewController* presentedView = self.presentedViewController;
    if ([presentedView isKindOfClass:[CardIOPaymentViewController class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [presentedView dismissViewControllerAnimated:YES completion:nil];
        });
    }
}

- (void)presentCardIOPaymentViewController
{
    CardIOPaymentViewController* scanViewController = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
    scanViewController.collectCVV = NO;
    scanViewController.hideCardIOLogo = YES;
#if defined(PrivateBankingPRIMEClub)
    scanViewController.navigationBar.translucent = NO;
    scanViewController.navigationBarTintColorForCardIO = kTabBarBackgroundColor;
    [scanViewController.navigationBar setTitleTextAttributes:
                                          @{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
    scanViewController.navigationBar.tintColor = kWhiteColor;
#endif
    scanViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:scanViewController
                       animated:YES
                     completion:nil];
}

@end
