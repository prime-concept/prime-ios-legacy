//
//  PRAgreementViewController.m
//  PRIME
//
//  Created by Davit Nahapetyan on 7/7/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import "PRAgreementViewController.h"
#import "PRUINavigationController.h"

@interface PRAgreementViewController()

@property (weak, nonatomic) IBOutlet UITextView* agreementTextView;
@property (weak, nonatomic) IBOutlet UITextView* gazprombankAgreementTextView;
@property (weak, nonatomic) IBOutlet UITextView* rrclubAgreementTextView;

@end

@implementation PRAgreementViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupAgreementTextView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)setupAgreementTextView
{
#if defined(PrivateBankingPRIMEClub)
    [self.navigationController.navigationBar setTintColor:kNavigationBarBarTintColor];
    self.agreementTextView.hidden = YES;
    self.rrclubAgreementTextView.hidden = YES;
    self.gazprombankAgreementTextView.hidden = NO;
#elif defined(PrimeRRClub)
    [self.navigationController.navigationBar setTintColor:kTabBarUnselectedTextColor];
    self.agreementTextView.hidden = YES;
    self.gazprombankAgreementTextView.hidden = YES;
    self.rrclubAgreementTextView.hidden = NO;
#else
    [(PRUINavigationController*)self.navigationController setNavigationBarColor:[UIColor whiteColor]];
    self.gazprombankAgreementTextView.hidden = YES;
    self.rrclubAgreementTextView.hidden = YES;
    self.agreementTextView.hidden = NO;
#endif
}

@end
