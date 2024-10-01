//
//  RegistrationStepOneViewController.m
//  PRIME
//
//  Created by Simon on 1/29/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

@import CoreTelephony;
#import "Constants.h"
#import "PRUINavigationController.h"
#import "RegistrationStepOneViewController.h"
#import "RegistrationStepTwoViewController.h"
#import <NBPhoneNumber.h>
#import <NBPhoneNumberUtil.h>

static NSString* const kDefaultCountryName = @"Russia";
static NSString* const kDefaultCountryCode = @"7";

@implementation RegistrationStepOneViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [PRGoogleAnalyticsManager sendEventWithName:kRegistrationScreenOpened parameters:nil];
    // Do any additional setup after loading the view.
    _phoneNumberView.touchDelegate = self;
    _phoneNumberView.backgroundColor = klightGrayColor;
    _phoneNumberView.textFieldIsoCode.delegate = self;
    _phoneNumberView.textFieldPhoneNumber.delegate = self;
    _phoneNumberView.textFieldPhoneNumber.backspaceDelegate = self;

    NSDictionary<NSString*, NSString*>* dictCodes = [CountriesCodesViewController countryIsoMaping];

    [_labelNote setTextColor:kAppLabelColor];
    [_labelNote setText:[NSString stringWithFormat:NSLocalizedString(@"To use the application %@ please enter your phone number", nil),
                                  NSLocalizedString([[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey], nil)]];

    [self prepareNavigationRightButton];

    CTTelephonyNetworkInfo* network_Info = [CTTelephonyNetworkInfo new];
    CTCarrier* carrier = network_Info.subscriberCellularProvider;
    NSString* iso = [carrier.isoCountryCode uppercaseString];
    if (!iso) {
        iso = @"RU";
    }
    NSString* country = [self nameFromCountryCode:iso];

    _phoneNumberView.labelCountryName.text = country;
    NSString* countryCode = dictCodes[iso];

    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* phone = [defaults objectForKey:kUserPhoneNumber];

    NBPhoneNumberUtil* phoneUtil = [[NBPhoneNumberUtil alloc] init];
    NSString* nationalNumber = nil;
    NSNumber* countryCodeInteger = [phoneUtil extractCountryCode:phone nationalNumber:&nationalNumber];

    if (countryCodeInteger && phone) {
        countryCode = [NSString stringWithFormat:@"%@", countryCodeInteger];
        _phoneNumberView.labelCountryName.text = [self countryNameFromIsoCode:countryCode];
    }

    if (!countryCode) {
        countryCode = @"79";
    }
    _phoneNumberView.textFieldIsoCode.text = [@"+" stringByAppendingString:countryCode];
    _phoneNumberView.textFieldPhoneNumber.text = nationalNumber;

    _labelPhone.backgroundColor = kPhoneLabelBackgroundColor;
    _labelPhone.textColor = kPhoneLabelTextColor;
//    @[][1];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    for (UIScrollView* view in _parentController.view.subviews) {

        if ([view isKindOfClass:[UIScrollView class]]) {

            view.scrollEnabled = NO;
        }
    }

    [self performSelector:@selector(openKeyboard) withObject:nil afterDelay:0.1];

    [self enableRightButtonAccordingToText:_phoneNumberView.textFieldPhoneNumber.text];
}

#pragma mark - Prepare UI

- (void)enableRightButtonAccordingToText:(NSString*)text
{
    if ([text length] < kMinPhoneNumberLength ||
        [_phoneNumberView.labelCountryName.text isEqualToString:NSLocalizedString(@"Invalid country code", nil)]) {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];

        return;
    }
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
}

- (void)openKeyboard
{
    [_phoneNumberView.textFieldPhoneNumber becomeFirstResponder];
}

- (void)prepareNavigationRightButton
{
    UIBarButtonItem* nextButton =
        [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", )
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(registerMobileRequest)];

    self.navigationItem.rightBarButtonItem = nextButton;

    [nextButton setEnabled:NO];
}

#pragma mark - Registration

- (void)registerMobileRequest
{
    [[self view] endEditing:YES];

    if ([_phoneNumberView.textFieldPhoneNumber.text length] == 0) {
        [self openKeyboard];
        return;
    }

    [PRGoogleAnalyticsManager sendEventWithName:kPhoneNumberEntered parameters:nil];
    if (self.navigationItem.rightBarButtonItem) {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    }

    __weak id weakSelf = self;
    [PRRequestManager registerMobileWithPhone:_phoneNumberView.phoneNumberWihtCode
        view:self.view
        mode:PRRequestMode_ShowErrorMessagesAndProgress
        success:^{
            RegistrationStepOneViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            [strongSelf nextStep];
        }
        failure:^() {
            RegistrationStepOneViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            [strongSelf.phoneNumberView.textFieldPhoneNumber becomeFirstResponder];

            if (strongSelf.navigationItem.rightBarButtonItem &&
                [strongSelf.phoneNumberView.textFieldPhoneNumber.text length] != 0) {
                [strongSelf.navigationItem.rightBarButtonItem setEnabled:YES];
            }
        }];
}

- (void)nextStep
{
    RegistrationStepTwoViewController* viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RegistrationStepTwoViewController"];
    viewController.phoneNumber = _phoneNumberView.phoneNumberWihtCode;

    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)countryNameTouched
{
    CountriesCodesViewController* countriesCodesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CountriesCodesViewController"];
    countriesCodesViewController.selectedCountry = _phoneNumberView.labelCountryName.text;
    countriesCodesViewController.selectCountryDelegate = self;
    PRUINavigationController* nav = [[PRUINavigationController alloc] initWithRootViewController:countriesCodesViewController];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:nav
                                            animated:YES
                                          completion:^{
                                          }];
}

- (void)countrySelected:(CountryInfo*)countryInfo
{
    _phoneNumberView.labelCountryName.text = countryInfo.countryName;
    _phoneNumberView.textFieldIsoCode.text = countryInfo.isoCode;
}

- (void)changeField
{
    [_phoneNumberView.textFieldIsoCode becomeFirstResponder];
}

- (NSString*)nameFromCountryCode:(NSString*)code
{
    NSDictionary<NSString*, NSString*>* map = [CountriesCodesViewController countryIsoMaping];
    if ([code isEqualToString:@"RU"]) {
        return @"Russia";
    }
    NSString* iso = map[code];

    return [self countryNameFromIsoCode:iso];
}

- (NSString*)countryNameFromIsoCode:(NSString*)isoCode
{
    NSDictionary<NSString*, NSString*>* map = [CountriesCodesViewController counrtyNameIsoCodesMaping];
    return [[map allKeysForObject:isoCode] firstObject];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
    NSCharacterSet* set = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    if ([string rangeOfCharacterFromSet:set].location != NSNotFound) {
        return NO;
    }

    NSString* finalString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([_phoneNumberView.textFieldIsoCode isEqual:textField]) {
        if ([finalString length] == 0) {
            return NO;
        }

        if ([finalString length] > 5) {
            [_phoneNumberView.textFieldPhoneNumber becomeFirstResponder];
            _phoneNumberView.textFieldPhoneNumber.text = [_phoneNumberView.textFieldPhoneNumber.text stringByAppendingString:string];
            [self enableRightButtonAccordingToText:_phoneNumberView.textFieldPhoneNumber.text];
            return NO;
        }

        NSString* isoCode = [[finalString substringToIndex:1] isEqualToString:@"+"] ? [finalString substringFromIndex:1] : finalString;
        NSString* countryName = nil;
        if ([isoCode isEqualToString:kDefaultCountryCode]) {
            countryName = kDefaultCountryName;
        } else {
            countryName = [self countryNameFromIsoCode:isoCode];
        }
        if (countryName) {
            _phoneNumberView.labelCountryName.text = countryName;
        } else {
            _phoneNumberView.labelCountryName.text = NSLocalizedString(@"Invalid country code", nil);
        }
        [self enableRightButtonAccordingToText:_phoneNumberView.textFieldPhoneNumber.text];
    } else if ([_phoneNumberView.textFieldPhoneNumber isEqual:textField]) {
        //Check max length.
        if ([finalString length] > kMaxPhoneNumberLength) {
            return NO;
        }

        //Check min length.
        [self enableRightButtonAccordingToText:finalString];
    }
    return YES;
}

#pragma mark - TextView Actions

- (void)backspasePressedForTextView:(UITextField*)textField
{
    if ([textField.text length] == 0) {
        NSLog(@"backspace tapped");

        dispatch_async(dispatch_get_main_queue(), ^{
            //Your main thread task here.
            [_phoneNumberView.textFieldIsoCode becomeFirstResponder];
        });
    }
}

#pragma mark - Number Formatter

- (NSString*)formatPhoneNumber:(NSString*)number
{
    NBPhoneNumberUtil* phoneUtil = [[NBPhoneNumberUtil alloc] init];
    NSError* anError = nil;
    NBPhoneNumber* myNumber = [phoneUtil parse:number
                                 defaultRegion:@"AT"
                                         error:&anError];

    return [phoneUtil format:myNumber
                numberFormat:NBEPhoneNumberFormatNATIONAL
                       error:&anError];
}

@end
