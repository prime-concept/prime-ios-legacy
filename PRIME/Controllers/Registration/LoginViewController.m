//
//  LoginViewController.m
//  PRIME
//
//  Created by Artak Tsatinyan on 2/4/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "LoginViewController.h"
@import AudioToolbox;
#import "AppDelegate.h"
#import "PRUINavigationController.h"
#import "PRUITabBarController.h"
#import "TouchIdAuth.h"
#import "AESCrypt.h"

#define TOUCHID_BUTTON_LEFT_SPACE SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(11) ? 5.8f : 0.f
#define TOUCHID_BUTTON_TOP_SPACE SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(11) ? 4.8f : 0.3f
#define TOUCHID_BUTTON_RIGHT_SPACE SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(11) ? 7.5f : 2.3f
#define TOUCHID_BUTTON_BOTTOM_SPACE SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(11) ? 7.8f : 0.f
#define TOUCHID_BUTTON_SHADOW_OFFSET CGSizeMake(0.f, 0.26f)

@interface LoginViewController () {
    BOOL _shouldOpenKeyboard;
}

@property (weak, nonatomic) IBOutlet UILabel* labelInfo;
@property (weak, nonatomic) IBOutlet PRPasswordField* textFieldPassword;
@property (weak, nonatomic) IBOutlet UILabel* labelNote;
@property (weak, nonatomic) IBOutlet UIButton* buttonForgotPassword;
@end

// For IPhone X,XS,XR and XS MAX bottom inset of keyboard buttons is 75
static const CGFloat kKeyboardButtonBottomInset = 75.0f;
static const CGFloat kTouchIDButtonShadowRadius = 0.3f;
static const CGFloat kTouchIDButtonShadowOpacity = 0.8f;
static const CGFloat kTouchIDButtonCornerRadiusCoefficient = 7.0f;
static const NSInteger kCountOfButtonsOnKeyboardInHorizontalDirection = 3;
static const NSInteger kCountOfButtonsOnKeyboardInVerticalDirection = 4;
static NSString* const kTouchIDButtonIconName = @"scan";

@implementation LoginViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _labelInfo.text = NSLocalizedString(@"Enter password", );
    _labelInfo.textColor = kPhoneLabelTextColor;
    _labelInfo.backgroundColor = kPhoneLabelBackgroundColor;
    _labelNote.text = NSLocalizedString(@"Enter password to login", );
    _labelNote.textColor = kAppLabelColor;
    [_buttonForgotPassword setTitle:NSLocalizedString(@"«Forgot password»", ) forState:UIControlStateNormal];

    [_textFieldPassword addTarget:self
                           action:@selector(passwordEditingChanged)
                 forControlEvents:UIControlEventEditingChanged];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _shouldOpenKeyboard = YES;
    [_textFieldPassword becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self registerForNotifications];

    if ([TouchIDAuth canAuthenticate]) {
        [self loginWithTouch];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self unregisterForNotifications];
    [self removeTouchButton];
    [super viewWillDisappear:animated];
}

#pragma mark - Login

- (void)login
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* customerId = [defaults objectForKey:kCustomerId];
    NSString* phone = [defaults objectForKey:kUserPhoneNumber];

    [[self view] endEditing:YES];

    __weak id weakSelf = self;

    void (^vibrate)(void) = ^(void) {

        LoginViewController* strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }

        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        [strongSelf.textFieldPassword setPasscode:@""];
        [strongSelf.textFieldPassword becomeFirstResponder];
    };

    NSString* username = customerId ? customerId : phone;
    NSString* encryptedPassword = [AESCrypt encrypt:_textFieldPassword.passcode password:kClientSecret];

    [PRRequestManager authorizeWithUsername:username
        password:_textFieldPassword.passcode
        setupCoreData:!_isFromBackground
        view:self.view
        mode:PRRequestMode_ShowErrorMessagesAndProgress
        success:^{
            LoginViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            [TouchIDAuth activateWithPasscode:encryptedPassword];
            [strongSelf done];
        }
        failure:^{

            vibrate();

        }
        offline:^{

            LoginViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            NSString* password = [TouchIDAuth storedPassForPhone:username];
            NSString* storedPassword = password.length > 4 ? password : [AESCrypt encrypt:password password:kClientSecret];

            if ([encryptedPassword isEqualToString:storedPassword]) {
                [strongSelf done];
            } else {

                vibrate();
            }
        }
        incorrectPasswordBlock:^{
        }];
}

- (void)loginWithTouch
{
    [[self view] endEditing:YES];

    [TouchIDAuth authenticateWithView:self.view
        setupCoreData:!_isFromBackground
        success:^{
            _shouldOpenKeyboard = NO;
            [self done];
        }
        offline:^(NSString* phone, NSString* passCode) {
            _shouldOpenKeyboard = NO;
            [self done];
        }

        fallback:^{
            //TODO message.
            _shouldOpenKeyboard = YES;
            [_textFieldPassword setPasscode:@""];
            [_textFieldPassword becomeFirstResponder];
        }];
}

- (void)goLoginPage
{
    [self dismissViewControllerAnimated:YES
                             completion:^{

                             }];
}

#pragma mark - Actions

- (void)done
{
    if (_isFromBackground) {
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            [self dismissViewControllerAnimated:YES completion:nil];
        }];

        [self.view endEditing:YES];

        [CATransaction commit];

        return;
    }
    PRUITabBarController* tabBarController = [PRUITabBarController instantiateFromStoryboard];
    tabBarController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:tabBarController animated:YES completion:nil];
}

- (IBAction)buttonForgotPasswordPressed:(id)sender
{

    [PRGoogleAnalyticsManager sendEventWithName:kLoginScreenForgotPasswordButtonClicked parameters:nil];
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NSString* identifier;

#if defined(Otkritie)
    identifier = @"PRRegistrationWithCardViewController";
#elif defined(PrimeRRClub)
    identifier = @"PRRRClubRegistrationWithCardViewController";
#else
    identifier = @"RegistrationStepOneViewController";
#endif

    BaseViewController* baseViewController = [mainStoryboard instantiateViewControllerWithIdentifier:identifier];
    UINavigationController* navigationController = [[PRUINavigationController alloc] initWithRootViewController:baseViewController];

    [baseViewController.navigationItem setHidesBackButton:YES animated:YES];

    UIBarButtonItem* login =
        [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", )
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(goLoginPage)];

    baseViewController.navigationItem.leftBarButtonItem = login;

#if defined(PrivateBankingPRIMEClub)
     baseViewController.navigationController.navigationBar.tintColor = kTabBarUnselectedTextColor;
#endif

    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navigationController
                       animated:YES
                     completion:^{

                     }];
}

#pragma mark - Notifications

- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

    // Register for keyboard notifications.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(recreateTouchButton)
                                                 name:kRefreshTouchIDButton
                                               object:nil];
}

- (void)unregisterForNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillResignActiveNotification
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];

    // Unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kRefreshTouchIDButton
                                                  object:nil];
}

#pragma mark - Notification Handler

- (void)appWillResignActive:(NSNotification*)notification
{
    [_textFieldPassword resignFirstResponder];
}

- (void)appDidBecomeActive:(NSNotification*)notification
{
    for (UIView* obj in [self.view subviews]) {
        if ([[obj description] containsString:@"MBProgressHUD"] || !_shouldOpenKeyboard) {
            return;
        }
    }

    if (![_textFieldPassword isFirstResponder]) {
        [_textFieldPassword becomeFirstResponder];
    }
}

- (void)keyboardWillShow:(NSNotification*)notification
{
    [self addTouchButton];
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    [self removeTouchButton];
}

#pragma mark - Text Field

- (void)passwordEditingChanged
{
    if ([_textFieldPassword.passcode length] == 4) {
        [PRGoogleAnalyticsManager sendEventWithName:kLoginScreenPasswordEntered parameters:nil];
        [self login];
    }
}

#pragma mark - Touch Button

- (void)recreateTouchButton
{
    [self removeTouchButton];
    [self addTouchButton];
}

- (void)removeTouchButton
{
    UIView* keyboardView = [[[[[[[UIApplication sharedApplication] windows] lastObject] subviews] firstObject] subviews] firstObject];
    for (UIView* touchButton in [keyboardView subviews]) {
        if (touchButton.tag == 12) {
            [touchButton removeFromSuperview];
        }
    }

    UIView* remoteKeyboardView = [[[UIApplication sharedApplication] windows] lastObject];
    for (UIView* touchButtonView in [remoteKeyboardView subviews]) {
        if (touchButtonView.tag == 13) {
            [touchButtonView removeFromSuperview];
        }
    }
}

- (void)addTouchButton
{
    if ([TouchIDAuth canAuthenticate]) {
        __weak LoginViewController* weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{

            UIView* remoteKeyboardView = [[[UIApplication sharedApplication] windows] lastObject];
            UIView* keyboardView = [[[[[[[UIApplication sharedApplication] windows] lastObject] subviews] firstObject] subviews] firstObject];
            CGFloat keyboardViewWidth = CGRectGetWidth(keyboardView.bounds);
            CGFloat keyboardViewHeight = CGRectGetHeight(keyboardView.bounds) - (IS_IPHONE_X_SERIES ? kKeyboardButtonBottomInset : 0);

            CGFloat y = keyboardViewHeight - keyboardViewHeight / kCountOfButtonsOnKeyboardInVerticalDirection;
            CGFloat width = keyboardViewWidth / kCountOfButtonsOnKeyboardInHorizontalDirection;
            CGFloat height = keyboardViewHeight / kCountOfButtonsOnKeyboardInVerticalDirection;

            // Adjusting touchID button to look like the other buttons on the keyboard.
            // in >=iOS11 devices there are some extra spaces on all sides of the buttons.
            // in <iOS11 devices there are no extra spaces, but there are separators between the buttons.
            CGRect touchButtonFrame = CGRectMake(TOUCHID_BUTTON_LEFT_SPACE, y + (TOUCHID_BUTTON_TOP_SPACE), width - (TOUCHID_BUTTON_RIGHT_SPACE), height - (TOUCHID_BUTTON_BOTTOM_SPACE));

            UIButton* touchButton = [[UIButton alloc] initWithFrame:touchButtonFrame];
            [touchButton setImage:[UIImage imageNamed:kTouchIDButtonIconName] forState:UIControlStateNormal];
            [touchButton setBackgroundColor:[UIColor whiteColor]];
            touchButton.tag = 12;

            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(11)) {
                [touchButton.layer setCornerRadius:CGRectGetHeight(touchButtonFrame) / kTouchIDButtonCornerRadiusCoefficient];
                touchButton.layer.shadowColor = [[UIColor blackColor] CGColor];
                touchButton.layer.shadowOffset = TOUCHID_BUTTON_SHADOW_OFFSET;
                touchButton.layer.shadowRadius = kTouchIDButtonShadowRadius;
                touchButton.layer.shadowOpacity = kTouchIDButtonShadowOpacity;
            }

            [keyboardView addSubview:touchButton];

            CGRect touchButtonViewFrame = [keyboardView convertRect:touchButtonFrame toView:[keyboardView superview]];
            UIView* touchButtonView = [[UIView alloc] initWithFrame:touchButtonViewFrame];
            [touchButtonView setBackgroundColor:[UIColor clearColor]];
            touchButtonView.tag = 13;

            UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:weakSelf
                                                                                         action:@selector(touchButtonPressed:)];
            [touchButtonView addGestureRecognizer:tapGesture];
            [remoteKeyboardView addSubview:touchButtonView];
        });
    }
}

#pragma mark - Gesture

- (void)touchButtonPressed:(UITapGestureRecognizer*)recognizer
{
    [PRGoogleAnalyticsManager sendEventWithName:kFingerTouchButtonClicked parameters:nil];
    [self loginWithTouch];
}

@end
