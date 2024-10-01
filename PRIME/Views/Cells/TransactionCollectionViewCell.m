//
//  TransactionCollectionViewCell.m
//  PRIME
//
//  Created by Nerses Hakobyan on 11/24/15.
//  Copyright © 2015 XNTrends. All rights reserved.
//

#import "DateTableViewSectionHeader.h"
#import "PRTaskDetailModel.h"
#import "PRTransactionModel.h"
#import "PRTransactionModel.h"
#import "RequestsDetailViewController.h"
#import "SVPullToRefresh.h"
#import "StatisticViewController.h"
#import "TaskIcons.h"
#import "TransactionCollectionViewCell.h"
#import "TransactionHistoryCell.h"
#import "UITableView+HeaderView.h"
#import "ViewForTableViewHeader.h"
#import "XNTLazyManager.h"

@interface TransactionCollectionViewCell ()

@property (strong, nonatomic) NSFetchedResultsController* transactions;
@property (strong, nonatomic) NSArray<PRBalanceModel*>* balances;
@property (strong, nonatomic) NSString* month;
@property (strong, nonatomic) NSString* year;
@property (weak, nonatomic) NSString* currentMonth;
@end

@implementation TransactionCollectionViewCell

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    PRTransactionModel* model = [_transactions objectAtIndexPath:indexPath];
    TransactionHistoryCell* cell = [tableView dequeueReusableCellWithIdentifier:@"TransactionHistoryCell"];
    if (cell == nil) {
        NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"TransactionCell" owner:self options:nil];
        cell = [nib objectAtIndex:3];
    }
    cell.labelPrice.text = [NSString stringWithFormat:@"%0.2f %@", [model.amount doubleValue], model.balance.currency];
    cell.labelPrice.font = [UIFont systemFontOfSize:15];
    cell.labelDescription.text = model.type;
    cell.labelDescription.textColor = kAppLabelColor;
    cell.labelDescription.font = kLabelDescriptionFont;

    PRTaskTypeModel* type = [PRDatabase getTypeForTaskId:model.taskInfoId];
    PRTaskDetailModel* detailModel = [PRDatabase getTaskDetailById:model.taskInfoId];
    cell.imageView.image = [UIImage imageNamed:[TaskIcons imageNameFromTaskTypeId:[type.typeId integerValue]]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.labelName.text = detailModel.taskName;
    cell.labelName.font = kLabelNameFont;
    return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return [_transactions sections].count;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_transactions sections][section] numberOfObjects];
}

- (void)createTableView
{
    _tableView = [UITableView newAutoLayoutView];
    [self.contentView addSubview:_tableView];
    [_tableView autoPinEdgesToSuperviewEdges];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    self.pullToRefreshView = [[SSPullToRefreshView alloc] initWithScrollView:self.tableView
                                                                    delegate:self];
}

- (void)getData
{
    _year = [_currentDate mt_stringFromDateWithFormat:@"YYYY" localized:NO];
    _month = [_currentDate mt_stringFromDateWithFormat:@"MM" localized:NO];

    if (_categoryName) { //From expance page.
        _balances = [PRDatabase getBalanceWithYear:_year month:_month];

        _balances = [_balances sortedArrayUsingComparator:^NSComparisonResult(PRBalanceModel* _Nonnull obj1, PRBalanceModel* _Nonnull obj2) {
            NSArray* currences = [StatisticViewController localizedCurrences];
            return [currences indexOfObject:obj1.currency] < [currences indexOfObject:obj2.currency] ? -1 : 1;
        }];
        _transactions = [PRDatabase getTransactionsWithBalances:_balances andCategory:_categoryName];
    } else {
        [self loadData];
        [self constructData];
    }
    [self swapContentToTop];
    [_tableView reloadData];
    [self createHeaderView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView sizeHeaderToFit];
    });
    ;
}

- (void)swapContentToTop
{
    [self.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
}

- (void)constructData
{

    if (_categoryName) { //From expance page.
        _balances = [PRDatabase getBalanceWithYear:_year month:_month];

        _balances = [_balances sortedArrayUsingComparator:^NSComparisonResult(PRBalanceModel* _Nonnull obj1, PRBalanceModel* _Nonnull obj2) {
            NSArray* currences = [StatisticViewController localizedCurrences];
            return [currences indexOfObject:obj1.currency] < [currences indexOfObject:obj2.currency] ? -1 : 1;
        }];
        _transactions = [PRDatabase getTransactionsWithBalances:_balances andCategory:_categoryName];
    } else {
        [self createHeaderView];
    }
    [_tableView reloadData];
    [_tableView sizeHeaderToFit];
}

- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView*)view
{

    [self.pullToRefreshView startLoading];

    [PRRequestManager getBalanceWithYear:_year
        month:_month
        view:self.tableView
        mode:PRRequestMode_ShowOnlyErrorMessages
        success:^(NSArray<PRBalanceModel*>* balances) {
            [self getData];
            [self.pullToRefreshView finishLoading];
        }
        failure:^{
            [self.pullToRefreshView finishLoading];
        }];
}

- (void)loadData
{
    _balances = [PRDatabase getBalanceWithYear:_year month:_month];
    _transactions = [PRDatabase getTransactionsWithBalances:_balances andFilter:_filter];
    NSMutableArray<PRTransactionModel*>* array = [[NSMutableArray alloc] init];
    for (PRBalanceModel* model in _balances) {
        [array addObjectsFromArray:[model.transactions array]];
    }
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{

    PRTransactionModel* model = [_transactions objectAtIndexPath:indexPath];
    if (!model.taskInfoId) {
        return;
    }
    RequestsDetailViewController* vc = [_parentViewDelegate.storyboard instantiateViewControllerWithIdentifier:@"RequestsDetailViewController"];
    vc.taskId = model.taskInfoId;
    vc.requestDate = model.period;
    [_parentViewDelegate.navigationController pushViewController:vc animated:YES];
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString* sectionTitle = nil;
    NSString* name = [[_transactions sections][section] name];

    sectionTitle = [self stringFromDateString:name].uppercaseString;

    DateTableViewSectionHeader* headerView = [[DateTableViewSectionHeader alloc] init:tableView withSectionTitle:sectionTitle];

    headerView.backgroundColor = kHeaderViewColor;

    return headerView;
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (NSString*)stringFromDateString:(NSString*)name
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZ"];
    NSDate* date = [formatter dateFromString:name];
    [formatter setDateFormat:@"dd MMMM yyyy"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:60 * 60 * DEFAULT_TIME_ZONE_INT]];
    return [formatter stringFromDate:date];
}

- (void)createHeaderView
{

    ViewForTableViewHeader* tableViewHeader = [[ViewForTableViewHeader alloc] initWithNewAutoLayoutView:_balances];
    tableViewHeader.tableView = _tableView;
    _tableView.tableHeaderView = tableViewHeader;
    [tableViewHeader resizeHeadrView];
    _tableView.tableHeaderView = tableViewHeader;
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return 24;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 55;
}

@end
