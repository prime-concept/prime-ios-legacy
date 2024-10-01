//
//  StatisticViewController.m
//  PRIME
//
//  Created by Artak on 3/15/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "MonthsCollectionViewCell.h"
#import "StatisticCollectionViewCell.h"
#import "StatisticViewController.h"
#import "XNTLazyManager.h"

@interface StatisticViewController () {
    BOOL _isFirstTime;
    CGPoint _expansesCollectionViewInitialContentOffset;
}

@property (strong, nonatomic) XNTLazyManager* lazyManager;

@property (strong, nonatomic) NSArray<NSString*>* filters;
@property (strong, nonatomic) NSArray<NSString*>* filtersHeader;

@property (nonatomic, assign) CurrencyFilter filter;

@end

@implementation StatisticViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _lazyManager = [[XNTLazyManager alloc] initWithObserver:self
                                                   selector:@selector(reachabilityChanged:)];

    _collectionViewHeader.backgroundColor = kTableViewHeaderColor;
    self.view.backgroundColor = kTableViewHeaderColor;

    _isFirstTime = YES;

    NSMutableArray<NSString*>* currencies = [NSMutableArray arrayWithArray:[self.class localizedCurrences]];
    [currencies insertObject:NSLocalizedString(@"MULTY CURRENCY", ) atIndex:0];
    _filters = currencies;

    _filtersHeader = @[ NSLocalizedString(@"Currency", ) ];

    _filter = [PRDatabase getSelectedFilterForCurrency];

    self.title = NSLocalizedString(@"Expenses", );

    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    [self reload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [_lazyManager shouldBeUpdatedIfViewDidAppearWithDate:[NSDate new]
        relativeToDate:[NSDate new]
        then:^(PRRequestMode mode) {
            [PRRequestManager getBalanceWithYear:[[NSDate new] mt_stringFromDateWithFormat:@"yyyy" localized:NO]
                               startingWithMonth:[[NSDate new] mt_stringFromDateWithFormat:@"MM" localized:NO]
                                      monthCount:7
                                            view:self.view
                                            mode:PRRequestMode_ShowNothing
                                         success:^(NSArray* result) {
                                             [_collectionViewStatistics reloadItemsAtIndexPaths:@[ [NSIndexPath indexPathForRow:super.monthOffset inSection:0] ]];
                                         }
                                         failure:^(NSInteger statusCode, NSError* error){

                                         }];
        }
        otherwiseIfFirstTime:^{

        }
        otherwise:^{

        }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Layout

- (void)viewDidLayoutSubviews
{
    if (_isFirstTime) {
        [_collectionViewStatistics scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:super.monthOffset inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        _isFirstTime = NO;
        _expansesCollectionViewInitialContentOffset = _collectionViewStatistics.contentOffset;
    }

    [super viewWillLayoutSubviews];
}

#pragma mark - Currencies

+ (NSArray*)localizedCurrences
{
    return @[ @"EUR", @"USD", @"RUB" ]; //Don't change order.
}

+ (NSString*)currenctyForFilter:(enum CurrencyFilter)filter
{
    switch (filter) {
    case CurrencyFilter_RUB:
        return @"RUB";
        break;

    case CurrencyFilter_EUR:
        return @"EUR";
        break;

    case CurrencyFilter_USD:
        return @"USD";
        break;

    default:
        return @"RUB";
        break;
    }
}

- (void)reload
{
    _filter = [PRDatabase getSelectedFilterForCurrency];
    [_collectionViewStatistics reloadData];
}

#pragma mark - Transaction Filter

- (void)setFilterIndex:(NSInteger)filter
{
    if (filter == 0) {
        [PRDatabase setSelectedFilterForCurrency:CurrencyFilter_All];
    } else if (filter == 1) {
        [PRDatabase setSelectedFilterForCurrency:CurrencyFilter_EUR];
    } else if (filter == 2) {
        [PRDatabase setSelectedFilterForCurrency:CurrencyFilter_USD];
    } else if (filter == 3) {
        [PRDatabase setSelectedFilterForCurrency:CurrencyFilter_RUB];
    }
}

- (FilterViewController*)getFilterViewController
{
    [PRGoogleAnalyticsManager sendEventWithName:kFinancesExpensesCurrencyOpened parameters:nil];
    FilterViewController* viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FilterViewController"];

    viewController.filters = _filters;
    viewController.filtersHeader = _filtersHeader;
    viewController.parentViewDelegate = self;
    viewController.selectedFilter = _filter;
    return viewController;
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath
{

    NSLog(@"%@", indexPath);
    UICollectionViewCell* cell = nil;

    if ([_collectionViewHeader isEqual:collectionView]) {

        MonthsCollectionViewCell* monthCell = (MonthsCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"MonthsCollectionViewCell" forIndexPath:indexPath];

        monthCell.date = [self getDateForOffset:indexPath.row];

        cell = monthCell;
    } else {
        StatisticCollectionViewCell* statisticCell = (StatisticCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"StatisticCollectionViewCell" forIndexPath:indexPath];
        statisticCell.parentViewDelegate = self;
        statisticCell.currentDate = [super getDateForOffset:indexPath.row];
        statisticCell.currencyFilter = _filter != CurrencyFilter_All ? _filters[_filter] : nil;
        [statisticCell createTableView];
        [statisticCell getData];

        cell = statisticCell;
    }

    return cell;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView*)scrollView
{
    [super ScrollView:scrollView DidScrollForHeaderCollectionView:_collectionViewHeader andCollectionViewContent:_collectionViewStatistics];
}

- (void)scrollViewWillBeginDragging:(UIScrollView*)scrollView
{
    [super ScrollView:scrollView willBeginDraggingForHeaderCollectionView:_collectionViewHeader andCollectionViewContent:_collectionViewStatistics];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView*)scrollView
{
    [self loadNextData];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView*)scrollView
{
    [self loadNextData];
}

#pragma mark - Actions

- (IBAction)goToLeftAction:(id)sender
{
    [super goToLeftForCollectionViewHeader:_collectionViewHeader andContentCollectionView:_collectionViewStatistics];
}

- (IBAction)goToRightAction:(id)sender
{
    if (_collectionViewStatistics.contentOffset.x >= _expansesCollectionViewInitialContentOffset.x) {
        return;
    }

    [super goToRightForCollectionViewHeader:_collectionViewHeader andContentCollectionView:_collectionViewStatistics];
}

- (void)loadNextData
{
    [PRGoogleAnalyticsManager sendEventWithName:kFinancesExpensesMonthChanged parameters:nil];
    _collectionViewHeader.scrollEnabled = YES;

    NSInteger oldOffset = super.monthOffset;
    super.monthOffset = ((_collectionViewHeader.contentOffset.x + 5) / _collectionViewHeader.bounds.size.width);
    NSDate* date = [super getDateForOffset:super.monthOffset - (oldOffset - super.monthOffset)];

    [_lazyManager shouldBeUpdatedWithDate:date
                           relativeToDate:[NSDate new]
                                     then:^{

                                         [PRRequestManager getBalanceWithYear:[date mt_stringFromDateWithFormat:@"yyyy" localized:NO]
                                                            startingWithMonth:[date mt_stringFromDateWithFormat:@"MM" localized:NO]
                                                                   monthCount:1
                                                                         view:self.view
                                                                         mode:PRRequestMode_ShowNothing
                                                                      success:^(NSArray* balances) {
                                                                          MonthsCollectionViewCell* monthCell = [_collectionViewHeader.visibleCells firstObject];
                                                                          if ([monthCell.date mt_isWithinSameMonth:date]) {

                                                                              [_collectionViewStatistics reloadData];
                                                                          }
                                                                      }
                                                                      failure:nil];
                                     }
                                otherwise:nil];
}

#pragma mark - Reachability

- (void)reachabilityChanged:(NSNotification*)note
{
    MonthsCollectionViewCell* monthCell = [_collectionViewHeader.visibleCells firstObject];

    [_lazyManager shouldBeUpdatedIfReachabilityChangedWithNotification:note
                                                                  date:monthCell.date
                                                        relativeToDate:monthCell.date
                                                                  then:^(PRRequestMode mode) {
                                                                      [PRRequestManager getBalanceWithYear:[monthCell.date mt_stringFromDateWithFormat:@"yyyy" localized:NO]
                                                                                         startingWithMonth:[monthCell.date
                                                                                                               mt_stringFromDateWithFormat:@"MM"
                                                                                                                                 localized:NO]
                                                                                                monthCount:7
                                                                                                      view:self.view
                                                                                                      mode:mode
                                                                                                   success:^(NSArray* result) {

                                                                                                   }
                                                                                                   failure:nil];
                                                                  }];
}
@end
