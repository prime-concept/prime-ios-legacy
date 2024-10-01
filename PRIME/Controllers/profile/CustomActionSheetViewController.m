//
//  CustomActionSheetViewController.m
//  PRIME
//
//  Created by Artak on 2/14/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "CustomActionSheetViewController.h"

static const NSInteger kPickerHeightPortrait = 216;
static const NSInteger kPickerHeightLandscape = 162;

#import "CustomActionSheetViewController.h"
#import <QuartzCore/QuartzCore.h>

typedef NS_ENUM(NSInteger, CustomActionSheetViewControllerPresentationType) {
    CustomActionSheetViewControllerPresentationType_Window,
    CustomActionSheetViewControllerPresentationType_ViewController,
    CustomActionSheetViewControllerPresentationType_Popover
};

@interface CustomActionSheetViewController () <UIPopoverControllerDelegate>

@property (nonatomic, assign) CustomActionSheetViewControllerPresentationType presentationType;
@property (nonatomic, strong) UIWindow* window;
@property (nonatomic, strong) UIViewController* rootViewController;
@property (nonatomic, strong) UIView* backgroundView;
@property (nonatomic, strong) UIPopoverController* popover;

@property (nonatomic, weak) NSLayoutConstraint* xConstraint;
@property (nonatomic, weak) NSLayoutConstraint* yConstraint;
@property (nonatomic, weak) NSLayoutConstraint* widthConstraint;

@property (nonatomic, strong) UIView* titleLabelContainer;
@property (nonatomic, strong, readwrite) UILabel* titleLabel;

@property (nonatomic, strong) UIView* pickerContainer;

@property (nonatomic, strong) UIView* cancelAndSelectButtonContainer;
@property (nonatomic, strong) UIView* cancelAndSelectButtonSeparator;
@property (nonatomic, strong) UIButton* cancelButton;
@property (nonatomic, strong) UIButton* selectButton;

@property (nonatomic, strong) UIMotionEffectGroup* motionEffectGroup;

@property (nonatomic, assign) BOOL hasBeenDismissed;

@end

@implementation CustomActionSheetViewController

@synthesize selectedBackgroundColor = _selectedBackgroundColor;

static NSString* _localizedCancelTitle = @"Cancel";
static NSString* _localizedSelectTitle = @"Select";

+ (NSString*)localizedTitleForCancelButton
{
    return NSLocalizedString(_localizedCancelTitle, nil);
}

+ (NSString*)localizedTitleForSelectButton
{
    return NSLocalizedString(_localizedSelectTitle, nil);
}

+ (void)setLocalizedTitleForCancelButton:(NSString*)newLocalizedTitle
{
    _localizedCancelTitle = newLocalizedTitle;
}

+ (void)setLocalizedTitleForSelectButton:(NSString*)newLocalizedTitle
{
    _localizedSelectTitle = newLocalizedTitle;
}

+ (void)showCustomActionSheetViewController:(CustomActionSheetViewController*)selectionViewController animated:(BOOL)animated
{
    if (selectionViewController.presentationType == CustomActionSheetViewControllerPresentationType_Window) {
        [selectionViewController.window makeKeyAndVisible];

        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            selectionViewController.window.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);
        }
    }

    if (selectionViewController.presentationType != CustomActionSheetViewControllerPresentationType_Popover) {
        selectionViewController.backgroundView.alpha = 0;
        [selectionViewController.rootViewController.view addSubview:selectionViewController.backgroundView];

        [selectionViewController.rootViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:selectionViewController.backgroundView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:selectionViewController.rootViewController.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        [selectionViewController.rootViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:selectionViewController.backgroundView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:selectionViewController.rootViewController.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
        [selectionViewController.rootViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:selectionViewController.backgroundView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:selectionViewController.rootViewController.view attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
        [selectionViewController.rootViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:selectionViewController.backgroundView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:selectionViewController.rootViewController.view attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    }

    [selectionViewController willMoveToParentViewController:selectionViewController.rootViewController];
    [selectionViewController viewWillAppear:YES];

    [selectionViewController.rootViewController addChildViewController:selectionViewController];
    [selectionViewController.rootViewController.view addSubview:selectionViewController.view];

    [selectionViewController viewDidAppear:YES];
    [selectionViewController didMoveToParentViewController:selectionViewController.rootViewController];

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            selectionViewController.pickerHeightConstraint.constant = kPickerHeightLandscape;
        }
        else {
            selectionViewController.pickerHeightConstraint.constant = kPickerHeightPortrait;
        }
    }

    selectionViewController.xConstraint = [NSLayoutConstraint constraintWithItem:selectionViewController.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:selectionViewController.rootViewController.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    selectionViewController.yConstraint = [NSLayoutConstraint constraintWithItem:selectionViewController.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:selectionViewController.rootViewController.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    selectionViewController.widthConstraint = [NSLayoutConstraint constraintWithItem:selectionViewController.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:selectionViewController.rootViewController.view attribute:NSLayoutAttributeWidth multiplier:1 constant:0];

    [selectionViewController.rootViewController.view addConstraint:selectionViewController.xConstraint];
    [selectionViewController.rootViewController.view addConstraint:selectionViewController.yConstraint];
    [selectionViewController.rootViewController.view addConstraint:selectionViewController.widthConstraint];

    [selectionViewController.rootViewController.view setNeedsUpdateConstraints];
    [selectionViewController.view layoutIfNeeded];

    [selectionViewController.rootViewController.view removeConstraint:selectionViewController.yConstraint];
    selectionViewController.yConstraint = [NSLayoutConstraint constraintWithItem:selectionViewController.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:selectionViewController.rootViewController.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-10];
    [selectionViewController.rootViewController.view addConstraint:selectionViewController.yConstraint];

    [selectionViewController.rootViewController.view setNeedsUpdateConstraints];

    if (animated) {
        CGFloat damping = 1.0f;
        CGFloat duration = 0.3f;
        if (!selectionViewController.disableBouncingWhenShowing) {
            damping = 0.6f;
            duration = 1.0f;
        }

        [UIView animateWithDuration:duration
                              delay:0
             usingSpringWithDamping:damping
              initialSpringVelocity:1
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             selectionViewController.backgroundView.alpha = 1;

                             [selectionViewController.view layoutIfNeeded];
                             [self sendPickerOpenNotification:selectionViewController];

                         }
                         completion:^(BOOL finished){
                         }];
        return;
    }

    selectionViewController.backgroundView.alpha = 0;

    [selectionViewController.view layoutIfNeeded];

    [self sendPickerOpenNotification:selectionViewController];
}

+ (void)dismissCustomActionSheetViewController:(CustomActionSheetViewController*)selectionViewController
{
    [selectionViewController.rootViewController.view removeConstraint:selectionViewController.yConstraint];
    selectionViewController.yConstraint = [NSLayoutConstraint constraintWithItem:selectionViewController.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:selectionViewController.rootViewController.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [selectionViewController.rootViewController.view addConstraint:selectionViewController.yConstraint];

    [selectionViewController.rootViewController.view setNeedsUpdateConstraints];

    [UIView animateWithDuration:0.3
        delay:0
        options:UIViewAnimationOptionBeginFromCurrentState
        animations:^{
            selectionViewController.backgroundView.alpha = 0;

            [selectionViewController.view layoutIfNeeded];
            [self sendPickerCloseNotification:selectionViewController];

        }
        completion:^(BOOL finished) {

            [selectionViewController willMoveToParentViewController:nil];
            [selectionViewController viewWillDisappear:YES];

            [selectionViewController.view removeFromSuperview];
            [selectionViewController removeFromParentViewController];

            [selectionViewController didMoveToParentViewController:nil];
            [selectionViewController viewDidDisappear:YES];

            [selectionViewController.backgroundView removeFromSuperview];
            selectionViewController.window = nil;
            selectionViewController.hasBeenDismissed = NO;
        }];
}

+ (void)sendPickerOpenNotification:(CustomActionSheetViewController*)selectionViewController
{
/**
     * Send UIKeyboardWillChangeFrameNotification Notification to avoid Picker
     */
#define _UIKeyboardFrameEndUserInfoKey (&UIKeyboardFrameEndUserInfoKey != NULL ? UIKeyboardFrameEndUserInfoKey : @"UIKeyboardBoundsUserInfoKey")

    CGPoint point = [selectionViewController.view convertPoint:CGPointMake(0, 0) toView:nil];
    CGSize size = selectionViewController.pickerContainer.frame.size;

    [[NSNotificationCenter defaultCenter]
        postNotificationName:UIKeyboardWillChangeFrameNotification
                      object:nil
                    userInfo:@{ _UIKeyboardFrameEndUserInfoKey : [NSValue valueWithCGRect:CGRectMake(point.x, point.y, size.width, size.height)],
                        UIKeyboardAnimationCurveUserInfoKey : @7,
                        UIKeyboardAnimationDurationUserInfoKey : @0.25f }];
}

+ (void)sendPickerCloseNotification:(CustomActionSheetViewController*)selectionViewController
{
    /**
     * Send UIKeyboardWillHideNotification Notification to avoid Picker
     */

    CGPoint point = [selectionViewController.view convertPoint:CGPointMake(0, 0) toView:nil];
    CGSize size = selectionViewController.pickerContainer.frame.size;

    [[NSNotificationCenter defaultCenter]
        postNotificationName:UIKeyboardWillHideNotification
                      object:nil
                    userInfo:@{ _UIKeyboardFrameEndUserInfoKey : [NSValue valueWithCGRect:CGRectMake(point.x, point.y, size.width, size.height)],
                        UIKeyboardAnimationCurveUserInfoKey : @7,
                        UIKeyboardAnimationDurationUserInfoKey : @0.25f }];
}

#pragma mark - Init and Dealloc
- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)setupUIElements
{

    self.blurEffectStyle = UIBlurEffectStyleExtraLight;

    //Instantiate elements
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];

    self.cancelAndSelectButtonSeparator = [[UIView alloc] initWithFrame:CGRectZero];
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.selectButton = [UIButton buttonWithType:UIButtonTypeSystem];

    //Setup properties of elements
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = [UIColor grayColor];
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.numberOfLines = 0;

    self.picker.layer.cornerRadius = 4;
    self.picker.translatesAutoresizingMaskIntoConstraints = NO;

    [self.cancelButton setTitle:[CustomActionSheetViewController localizedTitleForCancelButton] forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:[UIFont buttonFontSize]];
    self.cancelButton.layer.cornerRadius = 4;
    self.cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cancelButton setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];

    [self.selectButton setTitle:[CustomActionSheetViewController localizedTitleForSelectButton] forState:UIControlStateNormal];
    [self.selectButton addTarget:self action:@selector(doneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.selectButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont buttonFontSize]];
    self.selectButton.layer.cornerRadius = 4;
    self.selectButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.selectButton setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
}

- (void)setupContainerElements
{
    if (!self.disableBlurEffects) {
        UIBlurEffect* blur = [UIBlurEffect effectWithStyle:self.blurEffectStyle];
        UIVibrancyEffect* vibrancy = [UIVibrancyEffect effectForBlurEffect:blur];

        UIVisualEffectView* vibrancyView = [[UIVisualEffectView alloc] initWithEffect:vibrancy];
        vibrancyView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

        self.titleLabelContainer = [[UIVisualEffectView alloc] initWithEffect:blur];
        [((UIVisualEffectView*)self.titleLabelContainer).contentView addSubview:vibrancyView];
    }
    else {
        self.titleLabelContainer = [[UIView alloc] initWithFrame:CGRectZero];
    }

    if (!self.disableBlurEffects) {
        UIBlurEffect* blur = [UIBlurEffect effectWithStyle:self.blurEffectStyle];
        UIVibrancyEffect* vibrancy = [UIVibrancyEffect effectForBlurEffect:blur];

        UIVisualEffectView* vibrancyView = [[UIVisualEffectView alloc] initWithEffect:vibrancy];
        vibrancyView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

        self.pickerContainer = [[UIVisualEffectView alloc] initWithEffect:blur];
        [((UIVisualEffectView*)self.pickerContainer).contentView addSubview:vibrancyView];
    }
    else {
        self.pickerContainer = [[UIView alloc] initWithFrame:CGRectZero];
    }

    if (!self.disableBlurEffects) {
        UIBlurEffect* blur = [UIBlurEffect effectWithStyle:self.blurEffectStyle];
        UIVibrancyEffect* vibrancy = [UIVibrancyEffect effectForBlurEffect:blur];

        UIVisualEffectView* vibrancyView = [[UIVisualEffectView alloc] initWithEffect:vibrancy];
        vibrancyView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

        self.cancelAndSelectButtonContainer = [[UIVisualEffectView alloc] initWithEffect:blur];
        [((UIVisualEffectView*)self.cancelAndSelectButtonContainer).contentView addSubview:vibrancyView];
    }
    else {
        self.cancelAndSelectButtonContainer = [[UIView alloc] initWithFrame:CGRectZero];
    }

    if (!self.disableBlurEffects) {
        [[[[(UIVisualEffectView*)self.titleLabelContainer contentView] subviews][0] contentView] addSubview:self.titleLabel];
        [[(UIVisualEffectView*)self.pickerContainer contentView] addSubview:self.picker];

        [[[[(UIVisualEffectView*)self.cancelAndSelectButtonContainer contentView] subviews][0] contentView] addSubview:self.cancelAndSelectButtonSeparator];
        [[[[(UIVisualEffectView*)self.cancelAndSelectButtonContainer contentView] subviews][0] contentView] addSubview:self.cancelButton];
        [[[[(UIVisualEffectView*)self.cancelAndSelectButtonContainer contentView] subviews][0] contentView] addSubview:self.selectButton];

        self.titleLabelContainer.backgroundColor = [UIColor clearColor];
        self.pickerContainer.backgroundColor = [UIColor clearColor];
        self.cancelAndSelectButtonContainer.backgroundColor = [UIColor clearColor];
    }
    else {
        [self.titleLabelContainer addSubview:self.titleLabel];
        [self.pickerContainer addSubview:self.picker];

        [self.cancelAndSelectButtonContainer addSubview:self.cancelAndSelectButtonSeparator];
        [self.cancelAndSelectButtonContainer addSubview:self.cancelButton];
        [self.cancelAndSelectButtonContainer addSubview:self.selectButton];

        self.titleLabelContainer.backgroundColor = [UIColor whiteColor];
        self.pickerContainer.backgroundColor = [UIColor whiteColor];
        self.cancelAndSelectButtonContainer.backgroundColor = [UIColor whiteColor];
    }

    self.titleLabelContainer.layer.cornerRadius = 4;
    self.titleLabelContainer.clipsToBounds = YES;
    self.titleLabelContainer.translatesAutoresizingMaskIntoConstraints = NO;

    self.pickerContainer.layer.cornerRadius = 4;
    self.pickerContainer.clipsToBounds = YES;
    self.pickerContainer.translatesAutoresizingMaskIntoConstraints = NO;

    self.cancelAndSelectButtonContainer.layer.cornerRadius = 4;
    self.cancelAndSelectButtonContainer.clipsToBounds = YES;
    self.cancelAndSelectButtonContainer.translatesAutoresizingMaskIntoConstraints = NO;

    self.cancelAndSelectButtonSeparator.backgroundColor = [UIColor lightGrayColor];
    self.cancelAndSelectButtonSeparator.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)setupConstraints
{
    UIView* pickerContainer = self.pickerContainer;
    UIView* cancelSelectContainer = self.cancelAndSelectButtonContainer;
    UIView* separator = self.cancelAndSelectButtonSeparator;
    UIButton* cancel = self.cancelButton;
    UIButton* select = self.selectButton;
    UIView* picker = self.picker;
    UIView* labelContainer = self.titleLabelContainer;
    UILabel* label = self.titleLabel;

    NSDictionary* bindingsDict = NSDictionaryOfVariableBindings(cancelSelectContainer, separator, pickerContainer, cancel, select, picker, labelContainer, label);

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(10)-[pickerContainer]-(10)-|" options:0 metrics:nil views:bindingsDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(10)-[cancelSelectContainer]-(10)-|" options:0 metrics:nil views:bindingsDict]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[pickerContainer]-(10)-[cancelSelectContainer(44)]-(0)-|" options:0 metrics:nil views:bindingsDict]];
    self.pickerHeightConstraint = [NSLayoutConstraint constraintWithItem:self.pickerContainer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:kPickerHeightPortrait];
    [self.view addConstraint:self.pickerHeightConstraint];

    [self.pickerContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(0)-[picker]-(0)-|" options:0 metrics:nil views:bindingsDict]];
    if (!_shouldDisableSelectButton) {
        [self.cancelAndSelectButtonContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(0)-[cancel]-(0)-[separator(0.5)]-(0)-[select]-(0)-|" options:0 metrics:nil views:bindingsDict]];
        [self.cancelAndSelectButtonContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[separator]-(0)-|" options:0 metrics:nil views:bindingsDict]];
        [self.cancelAndSelectButtonContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[select]-(0)-|" options:0 metrics:nil views:bindingsDict]];
    }
    else {
        self.selectButton.hidden = YES;
        [self.cancelAndSelectButtonContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(0)-[cancel]-(0)-|" options:0 metrics:nil views:bindingsDict]];
    }
    [self.cancelAndSelectButtonContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.cancelAndSelectButtonSeparator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.cancelAndSelectButtonContainer attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];

    [self.pickerContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[picker]-(0)-|" options:0 metrics:nil views:bindingsDict]];
    [self.cancelAndSelectButtonContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[cancel]-(0)-|" options:0 metrics:nil views:bindingsDict]];

    BOOL showTitle = self.titleLabel.text && self.titleLabel.text.length != 0;

    if (showTitle) {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(10)-[labelContainer]-(10)-|" options:0 metrics:nil views:bindingsDict]];

        [self.titleLabelContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(10)-[label]-(10)-|" options:0 metrics:nil views:bindingsDict]];
        [self.titleLabelContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(10)-[label]-(10)-|" options:0 metrics:nil views:bindingsDict]];
    }

    NSDictionary* metricsDict = @{ @"TopMargin" : @(self.presentationType == CustomActionSheetViewControllerPresentationType_Popover ? 10 : 0) };

    if (showTitle) {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(TopMargin)-[labelContainer]-(10)-[now(44)]-(10)-[pickerContainer]" options:0 metrics:metricsDict views:bindingsDict]];
        return;
    }
    if (!showTitle) {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(TopMargin)-[pickerContainer]" options:0 metrics:metricsDict views:bindingsDict]];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.view.backgroundColor = [UIColor clearColor];
    self.view.layer.masksToBounds = YES;

    [self setupContainerElements];

    if (self.titleLabel.text && self.titleLabel.text.length != 0)
        [self.view addSubview:self.titleLabelContainer];

    [self.view addSubview:self.pickerContainer];
    [self.view addSubview:self.cancelAndSelectButtonContainer];

    [self setupConstraints];

    if (self.disableBlurEffects) {
        if (self.tintColor) {
            self.cancelButton.tintColor = self.tintColor;
            self.selectButton.tintColor = self.tintColor;
        }
        else {
            self.cancelButton.tintColor = [UIColor colorWithRed:0 green:122. / 255. blue:1 alpha:1];
            self.selectButton.tintColor = [UIColor colorWithRed:0 green:122. / 255. blue:1 alpha:1];
        }
    }

    if (self.backgroundColor) {
        if (!self.disableBlurEffects) {
            [((UIVisualEffectView*)self.titleLabelContainer).contentView setBackgroundColor:self.backgroundColor];
            [((UIVisualEffectView*)self.pickerContainer).contentView setBackgroundColor:self.backgroundColor];
            [((UIVisualEffectView*)self.cancelAndSelectButtonContainer).contentView setBackgroundColor:self.backgroundColor];
        }
        else {
            self.titleLabelContainer.backgroundColor = self.backgroundColor;
            self.pickerContainer.backgroundColor = self.backgroundColor;
            self.cancelAndSelectButtonContainer.backgroundColor = self.backgroundColor;
        }
    }

    if (self.selectedBackgroundColor) {
        if (!self.disableBlurEffects) {
            [self.cancelButton setBackgroundImage:[self imageWithColor:[self.selectedBackgroundColor colorWithAlphaComponent:0.3]] forState:UIControlStateHighlighted];
            [self.selectButton setBackgroundImage:[self imageWithColor:[self.selectedBackgroundColor colorWithAlphaComponent:0.3]] forState:UIControlStateHighlighted];
        }
        else {
            [self.cancelButton setBackgroundImage:[self imageWithColor:self.selectedBackgroundColor] forState:UIControlStateHighlighted];
            [self.selectButton setBackgroundImage:[self imageWithColor:self.selectedBackgroundColor] forState:UIControlStateHighlighted];
        }
    }

    if (!self.disableMotionEffects)
        [self addMotionEffects];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismiss)
                                                 name:kAppWillEnterForegroundAfterTimeout
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kAppWillEnterForegroundAfterTimeout
                                                  object:nil];
    [super viewDidDisappear:animated];
}

#pragma mark - Helper
- (void)addMotionEffects
{
    [self.view addMotionEffect:self.motionEffectGroup];
}

- (void)removeMotionEffects
{
    [self.view removeMotionEffect:self.motionEffectGroup];
}

- (UIImage*)imageWithColor:(UIColor*)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);

    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

#pragma mark - Properties
- (BOOL)disableBlurEffects
{
    if (NSClassFromString(@"UIBlurEffect") && NSClassFromString(@"UIVibrancyEffect") && NSClassFromString(@"UIVisualEffectView") && !_disableBlurEffects) {
        return NO;
    }

    return YES;
}

- (void)setDisableMotionEffects:(BOOL)newDisableMotionEffects
{
    if (_disableMotionEffects != newDisableMotionEffects) {
        _disableMotionEffects = newDisableMotionEffects;

        if ([self isViewLoaded]) {
            if (newDisableMotionEffects) {
                [self removeMotionEffects];
                return;
            }

            [self addMotionEffects];
        }
    }
}

- (UIMotionEffectGroup*)motionEffectGroup
{
    if (!_motionEffectGroup) {
        UIInterpolatingMotionEffect* verticalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
        verticalMotionEffect.minimumRelativeValue = @(-10);
        verticalMotionEffect.maximumRelativeValue = @(10);

        UIInterpolatingMotionEffect* horizontalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
        horizontalMotionEffect.minimumRelativeValue = @(-10);
        horizontalMotionEffect.maximumRelativeValue = @(10);

        _motionEffectGroup = [UIMotionEffectGroup new];
        _motionEffectGroup.motionEffects = @[ horizontalMotionEffect, verticalMotionEffect ];
    }

    return _motionEffectGroup;
}

- (UIWindow*)window
{
    if (!_window) {
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _window.windowLevel = UIWindowLevelStatusBar;
        UIViewController* rootViewController = [[UIViewController alloc] init];
        _window.rootViewController = rootViewController;
    }

    return _window;
}

- (UIView*)backgroundView
{
    if (!_backgroundView) {
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        _backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        _backgroundView.translatesAutoresizingMaskIntoConstraints = NO;

        UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundViewTapped:)];
        [_backgroundView addGestureRecognizer:tapRecognizer];
    }

    return _backgroundView;
}

- (void)setTintColor:(UIColor*)newTintColor
{
    if (_tintColor != newTintColor) {
        _tintColor = newTintColor;

        self.cancelButton.tintColor = newTintColor;
        self.selectButton.tintColor = newTintColor;
    }
}

- (void)setBackgroundColor:(UIColor*)newBackgroundColor
{
    if (_backgroundColor != newBackgroundColor) {
        _backgroundColor = newBackgroundColor;

        if ([self isViewLoaded]) {
            if (!self.disableBlurEffects &&
                [self.titleLabelContainer isKindOfClass:[UIVisualEffectView class]] &&
                [self.pickerContainer isKindOfClass:[UIVisualEffectView class]] &&
                [self.cancelAndSelectButtonContainer isKindOfClass:[UIVisualEffectView class]]) {
                [((UIVisualEffectView*)self.titleLabelContainer).contentView setBackgroundColor:newBackgroundColor];
                [((UIVisualEffectView*)self.pickerContainer).contentView setBackgroundColor:newBackgroundColor];
                [((UIVisualEffectView*)self.cancelAndSelectButtonContainer).contentView setBackgroundColor:newBackgroundColor];

                return;
            }

            self.titleLabelContainer.backgroundColor = newBackgroundColor;
            self.pickerContainer.backgroundColor = newBackgroundColor;
            self.cancelAndSelectButtonContainer.backgroundColor = newBackgroundColor;
        }
    }
}

- (UIColor*)selectedBackgroundColor
{
    if (!_selectedBackgroundColor) {
        self.selectedBackgroundColor = [UIColor colorWithWhite:230. / 255. alpha:1];
    }

    return _selectedBackgroundColor;
}

- (void)setSelectedBackgroundColor:(UIColor*)newSelectedBackgroundColor
{
    if (_selectedBackgroundColor != newSelectedBackgroundColor) {
        _selectedBackgroundColor = newSelectedBackgroundColor;

        if (!self.disableBlurEffects) {
            [self.cancelButton setBackgroundImage:[self imageWithColor:[newSelectedBackgroundColor colorWithAlphaComponent:0.3]] forState:UIControlStateHighlighted];
            [self.selectButton setBackgroundImage:[self imageWithColor:[newSelectedBackgroundColor colorWithAlphaComponent:0.3]] forState:UIControlStateHighlighted];
            return;
        }

        [self.cancelButton setBackgroundImage:[self imageWithColor:newSelectedBackgroundColor] forState:UIControlStateHighlighted];
        [self.selectButton setBackgroundImage:[self imageWithColor:newSelectedBackgroundColor] forState:UIControlStateHighlighted];
    }
}

#pragma mark - Presenting

- (void)show
{
    [self setupUIElements];
    self.presentationType = CustomActionSheetViewControllerPresentationType_Window;
    self.rootViewController = self.window.rootViewController;
    [CustomActionSheetViewController showCustomActionSheetViewController:self animated:YES];
}

- (void)dismiss
{
    [CustomActionSheetViewController dismissCustomActionSheetViewController:self];
}

#pragma mark - Actions

- (IBAction)doneButtonPressed:(id)sender
{
    if (!self.hasBeenDismissed) {
        self.hasBeenDismissed = YES;

        [self dismiss];
        [self.delegate selectionViewControllerDidDoneFor:self];
    }
}

- (IBAction)cancelButtonPressed:(id)sender
{
    if (!self.hasBeenDismissed) {
        self.hasBeenDismissed = YES;

        if ([self.delegate respondsToSelector:@selector(selectionViewControllerDidCancelFor:)]) {
            [self.delegate selectionViewControllerDidCancelFor:self];
        }
        [self performSelector:@selector(dismiss) withObject:nil afterDelay:0.1];
    }
}

- (IBAction)backgroundViewTapped:(UIGestureRecognizer*)sender
{
    if (!self.backgroundTapsDisabled && !self.hasBeenDismissed) {
        self.hasBeenDismissed = YES;

        if ([self.delegate respondsToSelector:@selector(selectionViewControllerDidCancelFor:)]) {
            [self.delegate selectionViewControllerDidCancelFor:self];
        }

        [self performSelector:@selector(dismiss) withObject:nil afterDelay:0.1];
    }
}

@end
