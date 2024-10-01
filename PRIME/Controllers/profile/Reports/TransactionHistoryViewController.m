//
//  TransactionHistoryViewController.m
//  PRIME
//
//  Created by Artak Tsatinyan on 7/27/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "MonthsCollectionViewCell.h"
#import "PRBalanceModel.h"
#import "PRDatabase.h"
#import "PRRequestManager.h"
#import "PRTaskTypeModel.h"
#import "PRTransactionModel.h"
#import "RequestsDetailViewController.h"
#import "SVPullToRefresh.h"
#import "StatisticViewController.h"
#import "TaskIcons.h"
#import "TransactionCollectionViewCell.h"
#import "TransactionHistoryCell.h"
#import "TransactionHistoryViewController.h"
#import "UITableView+HeaderView.h"
#import "XNTLazyManager.h"

@interface TransactionHistoryViewController () {
    BOOL _isFirstTime;
    CGPoint _historyCollectionViewInitialContentOffset;
}

@property (strong, nonatomic) XNTLazyManager* lazyManager;

@property (strong, nonatomic) NSString* month;
@property (strong, nonatomic) NSString* year;

@property (strong, nonatomic) NSArray<NSString*>* filters;
@property (strong, nonatomic) NSArray<NSString*>* filtersHeader;

@property (nonatomic, assign) TransactionFilter filter;

@end

@implementation TransactionHistoryViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _isFirstTime = YES;
    _collectionViewHeader.backgroundColor = kTableViewHeaderColor;

    self.view.backgroundColor = kTableViewHeaderColor;
    _collectionViewTransactions.backgroundColor = [UIColor whiteColor];
    if (!_categoryName) {
        _lazyManager = [[XNTLazyManager alloc] initWithObserver:self
                                                       selector:@selector(reachabilityChanged:)];

        _filters = @[ NSLocalizedString(@"All", ), NSLocalizedString(@"PRIME", ), NSLocalizedString(@"Partners", ) ];
        _filtersHeader = @[ NSLocalizedString(@"Service provider", ) ];

        _filter = TransactionFilter_All;
    } else {
        self.title = _categoryName;
    }

    if (!_currentDate) {
        _currentDate = [NSDate new];
    }

    _year = [_currentDate mt_stringFromDateWithFormat:@"yyyy" localized:NO];
    _month = [_currentDate mt_stringFromDateWithFormat:@"MM" localized:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    __weak id weakSelf = self;
    [_lazyManager shouldBeUpdatedIfViewDidAppearWithDate:[NSDate new]
        relativeToDate:[NSDate new]
        then:^(PRRequestMode mode) {

            TransactionHistoryViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            [PRRequestManager getBalanceWithYear:[[NSDate new] mt_stringFromDateWithFormat:@"yyyy" localized:NO]
                               startingWithMonth:[[NSDate new] mt_stringFromDateWithFormat:@"MM" localized:NO]
                                      monthCount:7
                                            view:strongSelf.view
                                            mode:PRRequestMode_ShowErrorMessagesAndProgress
                                         success:^(NSArray* result) {
                                             TransactionHistoryViewController* strongSelf = weakSelf;
                                             if (!strongSelf) {
                                                 return;
                                             }
                                             [strongSelf.collectionViewTransactions reloadItemsAtIndexPaths:@[ [NSIndexPath indexPathForRow:super.monthOffset inSection:0] ]];
                                         }
                                         failure:^{

                                         }];

        }
        otherwiseIfFirstTime:^{

        }
        otherwise:^{

        }];
}

#pragma mark - Layout

- (void)viewDidLayoutSubviews
{
    if (_isFirstTime) {
        if (_categoryName || _showAllCategories) {
            [_collectionViewTransactions scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_monthOffsetFromCategory inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        } else {
            [_collectionViewTransactions scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:super.monthOffset inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        }
        _isFirstTime = NO;
        _historyCollectionViewInitialContentOffset = _collectionViewTransactions.contentOffset;
    }

    [super viewWillLayoutSubviews];
}

#pragma mark - Transaction Filter

- (void)setFilterIndex:(NSInteger)filter
{
    if (filter == 0) {
        [PRDatabase setSelectedFilterForTransaction:TransactionFilter_All];
    } else if (filter == 1) {
        [PRDatabase setSelectedFilterForTransaction:TransactionFilter_Prime];
    } else {
        [PRDatabase setSelectedFilterForTransaction:TransactionFilter_Partner];
    }
}

- (FilterViewController*)getFilterViewController
{
    [PRGoogleAnalyticsManager sendEventWithName:kFinancesHistoryServiceProviderOpened parameters:nil];
    FilterViewController* filterVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FilterViewController"];

    filterVC.filters = _filters;
    filterVC.filtersHeader = _filtersHeader;
    filterVC.parentViewDelegate = self;
    filterVC.selectedFilter = _filter;

    return filterVC;
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath
{

    NSLog(@"%@", indexPath);
    UICollectionViewCell* cell = nil;

    if ([collectionView isEqual:_collectionViewHeader]) {

        MonthsCollectionViewCell* monthCell = (MonthsCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"MonthsCollectionViewCell" forIndexPath:indexPath];

        monthCell.date = [super getDateForOffset:indexPath.row];
        monthCell.backgroundColor = kTableViewBackgroundColor;

        cell = monthCell;
    } else {
        TransactionCollectionViewCell* transactionCell = (TransactionCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"TransactionCollectionViewCell" forIndexPath:indexPath];
        transactionCell.parentViewDelegate = self;
        transactionCell.currentDate = [super getDateForOffset:indexPath.row];
        transactionCell.filter = _filter;
        transactionCell.categoryName = _categoryName;
        [transactionCell createTableView];
        [transactionCell getData];
        cell = transactionCell;
    }
    return cell;
}

#pragma mark - Reachability

- (void)reachabilityChanged:(NSNotification*)note
{
    [self.lazyManager shouldBeUpdatedIfReachabilityChangedWithNotification:note
                                                                      date:[NSDate date]
                                                            relativeToDate:nil
                                                                      then:^(PRRequestMode mode) {
                                                                          [PRRequestManager getBalanceWithYear:_year
                                                                                                         month:_month
                                                                                                          view:self.view
                                                                                                          mode:PRRequestMode_ShowErrorMessagesAndProgress
                                                                                                       success:^(NSArray<PRBalanceModel*>* balances) {

                                                                                                           [_collectionViewTransactions reloadData];

                                                                                                       }
                                                                                                       failure:^{

                                                                                                       }];

                                                                      }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView*)scrollView
{
    [super ScrollView:scrollView DidScrollForHeaderCollectionView:_collectionViewHeader andCollectionViewContent:_collectionViewTransactions];
}

- (void)scrollViewWillBeginDragging:(UIScrollView*)scrollView
{
    [super ScrollView:scrollView willBeginDraggingForHeaderCollectionView:_collectionViewHeader andCollectionViewContent:_collectionViewTransactions];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView*)scrollView
{
    [self loadNextData];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView*)scrollView
{
    [self loadNextData];
}

#pragma mark - Actions

- (void)loadNextData
{
    [PRGoogleAnalyticsManager sendEventWithName:kFinancesHistoryMonthChanged parameters:nil];
    static const CGFloat kOffset = 50;

    NSInteger oldOffset = super.monthOffset;
    super.monthOffset = ((_collectionViewHeader.contentOffset.x + kOffset) / _collectionViewHeader.bounds.size.width);
    NSDate* date = [self getDateForOffset:super.monthOffset - (oldOffset - super.monthOffset)];

    [_lazyManager shouldBeUpdatedWithDate:date
                           relativeToDate:[NSDate new]
                                     then:^{

                                         [PRRequestManager getBalanceWithYear:[date mt_stringFromDateWithFormat:@"yyyy" localized:NO]
                                                            startingWithMonth:[date mt_stringFromDateWithFormat:@"MM" localized:NO]
                                                                   monthCount:1
                                                                         view:self.view
                                                                         mode:PRRequestMode_ShowOnlyErrorMessages
                                                                      success:^(NSArray* balances) {

                                                                          MonthsCollectionViewCell* monthCell = [_collectionViewHeader.visibleCells firstObject];
                                                                          if ([monthCell.date mt_isWithinSameMonth:date]) {
                                                                              [_collectionViewTransactions reloadData];
                                                                          }

                                                                      }
                                                                      failure:nil];
                                     }
                                otherwise:nil];

    _collectionViewHeader.scrollEnabled = YES;
}

- (IBAction)goToLeftAction:(id)sender
{
    [super goToLeftForCollectionViewHeader:_collectionViewHeader andContentCollectionView:_collectionViewTransactions];
}

- (IBAction)goToRightAction:(id)sender
{
    if (_collectionViewTransactions.contentOffset.x >= _historyCollectionViewInitialContentOffset.x) {
        return;
    }

    [super goToRightForCollectionViewHeader:_collectionViewHeader andContentCollectionView:_collectionViewTransactions];
}

- (void)reload
{
    _filter = [PRDatabase getSelectedFilterForTransaction];
    [_collectionViewTransactions reloadData];
}

@end
