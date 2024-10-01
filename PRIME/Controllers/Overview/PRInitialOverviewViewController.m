//
//  PRInitialOverviewViewController.m
//  PRIME
//
//  Created by Davit on 8/16/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "PRInitialOverviewViewController.h"
#import "PRUINavigationController.h"
#import "RegistrationStepOneViewController.h"

typedef NS_ENUM(NSInteger, PRPrimeSegment) {
    PRPrimeSegment_iAmPrime = 0,
    PRPrimeSegment_register
};

@interface PRInitialOverviewViewController ()

@property (weak, nonatomic) IBOutlet UIView* containerView;
@property (weak, nonatomic) IBOutlet UIImageView* primeImageView;
@property (weak, nonatomic) IBOutlet UILabel* primeOverviewLabel;
@property (weak, nonatomic) IBOutlet UITextView* primeOverviewDetailsTextView;
@property (weak, nonatomic) IBOutlet UISegmentedControl* primeSegmentedControl;
@property (weak, nonatomic) IBOutlet UIButton* iAmPrimeButton;

@end

@implementation PRInitialOverviewViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [_primeOverviewDetailsTextView setContentInset:UIEdgeInsetsMake(0, 0, 60, 0)];

    [_primeSegmentedControl setTitle:NSLocalizedString(@"I am PRIME", nil) forSegmentAtIndex:PRPrimeSegment_iAmPrime];
    [_primeSegmentedControl setTitle:NSLocalizedString(@"Register", nil) forSegmentAtIndex:PRPrimeSegment_register];
    [_primeSegmentedControl.layer setCornerRadius:10.0f];
    [_primeSegmentedControl.layer setMasksToBounds:YES];
    [_primeSegmentedControl.layer setBorderColor:[UIColor colorWithRed:180.0 / 255.0 green:154.0 / 255.0 blue:112.0 / 255.0 alpha:1.0].CGColor];
    [_primeSegmentedControl.layer setBorderWidth:1.0f];

    // Hiding segmented control temporarily until the functionality of "Register" segment will be ready.
    [_primeSegmentedControl setHidden:YES];

    // Showing only "I am PRIME" button temporarily.
    [_iAmPrimeButton.layer setCornerRadius:10.0f];
    [_iAmPrimeButton.layer setMasksToBounds:YES];
    [_iAmPrimeButton.layer setBorderColor:[UIColor colorWithRed:180.0 / 255.0 green:154.0 / 255.0 blue:112.0 / 255.0 alpha:1.0].CGColor];
    [_iAmPrimeButton.layer setBorderWidth:1.0f];
    [_iAmPrimeButton setTitle:NSLocalizedString(@"I am PRIME", nil) forState:UIControlStateNormal];
    [PRGoogleAnalyticsManager sendEventWithName:kOverviewScreenOpened parameters:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_primeOverviewDetailsTextView scrollRangeToVisible:NSMakeRange(0, 0)];
    [_primeSegmentedControl setSelectedSegmentIndex:-1];
}

#pragma mark - Fill Screen

- (void)fillScreenWithData:(NSDictionary*)dataDict
{
    [_primeImageView setImage:[UIImage imageNamed:dataDict[kOverviewImageKey]]];
    [_primeOverviewLabel setText:NSLocalizedString(dataDict[kOverviewTitleKey], nil)];
    [_primeOverviewDetailsTextView setText:NSLocalizedString(dataDict[kOverviewContentKey], nil)];

    // This forced the cut off text (in iPhone 5S) to render correctly.
    _primeOverviewDetailsTextView.scrollEnabled = NO;
    _primeOverviewDetailsTextView.scrollEnabled = YES;
}

#pragma mark - Layout

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    // Apply gradient to text view bottom area.
    [self applyGradientToView:_containerView];

    // Start from the top of the text view at the beginning.
    [_primeOverviewDetailsTextView setContentOffset:CGPointZero animated:NO];
}

#pragma mark - Registration

- (void)openRegistrationPage
{
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle:nil];
    RegistrationStepOneViewController* registrationStepOneViewController = (RegistrationStepOneViewController*)[mainStoryboard
        instantiateViewControllerWithIdentifier:@"RegistrationStepOneViewController"];
    UINavigationController* navigationController = [[PRUINavigationController alloc] initWithRootViewController:registrationStepOneViewController];
    [[UIApplication sharedApplication].keyWindow setRootViewController:navigationController];
}

#pragma mark - Actions

- (IBAction)primeSegmentedControlValueChanged:(id)sender
{
    if (_primeSegmentedControl.selectedSegmentIndex == PRPrimeSegment_iAmPrime) {
        [self openRegistrationPage];
        return;
    }

    if ([_delegate respondsToSelector:@selector(registerPrimeSegmentDidSelect)]) {
        [_delegate registerPrimeSegmentDidSelect];
    }
}

- (IBAction)iAmPrimeButtonPressed:(id)sender
{
    [PRGoogleAnalyticsManager sendEventWithName:kOverviewScreenIAmPrimeButtonClicked parameters:nil];
    [self openRegistrationPage];
}

@end
