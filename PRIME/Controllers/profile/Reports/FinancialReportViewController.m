//
//  FinancialReportViewController.m
//  PRIME
//
//  Created by Nerses Hakobyan on 11/20/15.
//  Copyright © 2015 XNTrends. All rights reserved.
//

#import "ContainerViewController.h"
#import "FinancialReportViewController.h"
#import "PRBalanceModel.h"
#import "PRDatabase.h"
#import "PRRequestManager.h"
#import "PRTaskTypeModel.h"
#import "PRTransactionModel.h"
#import "RequestsDetailViewController.h"
#import "SVPullToRefresh.h"
#import "StatisticViewController.h"
#import "TaskIcons.h"
#import "TransactionHistoryCell.h"
#import "TransactionHistoryViewController.h"
#import "UITableView+HeaderView.h"
#import "XNTLazyManager.h"

#if defined(Prime)
#import "_Art_Of_Life_-Swift.h"
#elif defined(PrimeClubConcierge)
#import "PrimeClubConcierge-Swift.h"
#elif defined(Imperia)
#import "IMPERIA-Swift.h"
#elif defined(PondMobile)
#import "Pond Mobile-Swift.h"
#elif defined(Raiffeisen)
#import "Raiffeisen-Swift.h"
#elif defined(VTB24)
#import "PrimeConcierge-Swift.h"
#elif defined(Ginza)
#import "Ginza-Swift.h"
#elif defined(FormulaKino)
#import "Formula Kino-Swift.h"
#elif defined(Platinum)
#import "Platinum-Swift.h"
#elif defined(Skolkovo)
#import "Skolkovo-Swift.h"
#elif defined(PrimeConciergeClub)
#import "Tinkoff-Swift.h"
#elif defined(PrivateBankingPRIMEClub)
#import "PrivateBankingPRIMEClub-Swift.h"
#elif defined(PrimeRRClub)
#import "PRIME RRClub-Swift.h"
#elif defined(Davidoff)
#import "Davidoff-Swift.h"
#endif

@interface FinancialReportViewController ()

@property (strong, nonatomic) UISegmentedControl* segmentedControllHistoryExpenses;
@property (strong, nonatomic) NSString* currentSegueIdentifier;

@property (assign, nonatomic) BOOL isTransitionInProgress;
@property (strong, nonatomic) NSMutableDictionary* segueViewControllerMaping;

@property (nonatomic, weak) ContainerViewController* containerViewController;
@property (nonatomic, weak) UIStoryboardSegue* segue;

@end

@implementation FinancialReportViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initSegmentedControlHistoryExpenses];
    [self prepareNavigationBar];
}

#pragma mark - Segue

- (BOOL)shouldPerformSegueWithIdentifier:(NSString*)identifier sender:(id)sender
{
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"embedContainer"]) {
        _containerViewController = segue.destinationViewController;
        _segue = segue;
    }
}

#pragma mark - Segmented Control

- (void)initSegmentedControlHistoryExpenses
{
    NSArray<NSString*>* itemArray = [NSArray arrayWithObjects:NSLocalizedString(@"History", nil), NSLocalizedString(@"Expenses", nil), nil];
    _segmentedControllHistoryExpenses = [[UISegmentedControl alloc] initWithItems:itemArray];
    _segmentedControllHistoryExpenses.frame = CGRectMake(10, 20, 180, 30);
    [_segmentedControllHistoryExpenses setTintColor:[UIColor blackColor]];
    self.navigationItem.titleView = _segmentedControllHistoryExpenses;
    [_segmentedControllHistoryExpenses addTarget:self
                                          action:@selector(segmentedControlHistoryExpensesClick:)
                                forControlEvents:UIControlEventValueChanged];
    _segmentedControllHistoryExpenses.selectedSegmentIndex = Segment_History;
    [_segmentedControllHistoryExpenses setTintColor:kReservesOrRequestsSegmentColor];
    _segmentedControllHistoryExpenses.backgroundColor = [self getNavigationBarColor];
#if defined(VTB24) || defined(Raiffeisen) || defined(PrivateBankingPRIMEClub)
    [_segmentedControllHistoryExpenses ensureiOS12Style];
#endif
}

- (IBAction)segmentedControlHistoryExpensesClick:(UISegmentedControl*)sender
{
    if (_segmentedControllHistoryExpenses.selectedSegmentIndex == Segment_History) {
        [PRGoogleAnalyticsManager sendEventWithName:kFinancesHistorySegmentClicked parameters:nil];
        [_containerViewController swapToViewControllers:SegueTransactionView];
    } else if (_segmentedControllHistoryExpenses.selectedSegmentIndex == Segment_Expenses) {
        [PRGoogleAnalyticsManager sendEventWithName:kFinancesExpensesSegmentClicked parameters:nil];
        [_containerViewController swapToViewControllers:SegueStatistics];
    }
}

- (void)prepareNavigationBar
{
    self.navigationController.navigationBar.hidden = NO;
    UIButton* buttonForIcon = [[UIButton alloc] init];
#ifdef VTB24
    UIImage* image = [UIImage imageNamed:@"vtb_settings"];
#else
    UIImage* image = [UIImage imageNamed:@"settings"];
#endif

    [buttonForIcon setFrame:CGRectMake(0, 0, 24, 24)];
    [buttonForIcon setImage:image forState:UIControlStateNormal];
    [buttonForIcon addTarget:self
                      action:@selector(openFilter)
            forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem* button = [[UIBarButtonItem alloc]
        initWithCustomView:buttonForIcon];

    self.navigationItem.rightBarButtonItem = button;
}

- (void)openFilter
{
    FilterViewController* viewController = [_containerViewController.currentViewController getFilterViewController];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
