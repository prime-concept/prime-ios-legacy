//
//  WelcomeViewController.m
//  PRIME
//
//  Created by Admin on 1/28/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "Interactor.h"
#import "WelcomeViewController.h"
#import "RegistrationStepOneViewController.h"
#import "PRUINavigationController.h"

@interface WelcomeViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nextButtonBottomConstraint;

@end

@implementation WelcomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _buttonNext.layer.zPosition = 1;
    _imageNext.layer.zPosition = 1;

    _labelDescryption.textColor = kWelcomeScreenTextColor;
    _labelDescryption.textAlignment = NSTextAlignmentCenter;

    [_buttonNext setTitleColor:kWelcomeScreenNextButtonColor forState:UIControlStateNormal];
    [_imageNext setTintColor:kWelcomeScreenNextButtonColor];

    [self.view setBackgroundColor:kWelcomeScreenBackgroundColor];
#ifdef VTB24
    _nextButtonBottomConstraint.constant += 30;
#endif
}

- (void)hideButtons
{
    _buttonNext.hidden = YES;
    _imageNext.hidden = YES;
}

- (void)viewDidLayoutSubviews
{
#ifndef PondMobile
    _welcomeTitleImage.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    _welcomeTitleImage.contentMode = UIViewContentModeScaleAspectFill;
#endif

    _welcomeTitleImage.image = [UIImage imageNamed:@"welcome_title_image"];
}

- (IBAction)continueButtonPressed:(UIButton*)sender
{
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NSString* identifier;

#if defined(Otkritie) || defined(PrivateBankingPRIMEClub) || defined(PrimeClubConcierge)
    identifier = @"PRRegistrationWithCardViewController";
#elif defined(PrimeRRClub)
    identifier = @"PRRRClubRegistrationWithCardViewController";
#else
    identifier = @"RegistrationStepOneViewController";
#endif

    UIViewController* registrationViewController = [mainStoryboard instantiateViewControllerWithIdentifier:identifier];
    PRUINavigationController* navigationController = [[PRUINavigationController alloc] initWithRootViewController:registrationViewController];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
