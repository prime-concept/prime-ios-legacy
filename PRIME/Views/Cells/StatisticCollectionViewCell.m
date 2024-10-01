//
//  StatisticCollectionViewCell.m
//  PRIME
//
//  Created by Admin on 3/16/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "StatisticCollectionViewCell.h"
#import "StatisticTableViewCell.h"
#import "StatisticHeader.h"
#import "PRTransactionModel.h"
#import "PRBalanceModel.h"
#import "TransactionHistoryViewController.h"
#import "StatisticViewController.h"

@interface TransactionCategoryInformation : NSObject

@property (strong, nonatomic) NSString* category;
@property (nonatomic) double percent;
@property (strong, nonatomic) NSMutableDictionary* currencySpend;

@end

@implementation TransactionCategoryInformation

@end

@implementation StatisticCollectionViewCell

+ (UIColor*)flatColorForCategoryName:(NSString*)categoryName
{
    static NSMutableDictionary* colors = nil;
    CGFloat hue;
    CGFloat saturation;
    CGFloat brightness;
    CGFloat alpha;
    const CGFloat kSaturationPercent = 0.40;
    const CGFloat kBrightnessPercent = 0.75;
    pr_dispatch_once({
        colors = [NSMutableDictionary dictionary];
    });
    NSArray* darkColors = @[ FlatBlackDark, FlatBlueDark, FlatCoffeeDark, FlatGrayDark, FlatGreenDark, FlatLimeDark, FlatMagentaDark, FlatMaroonDark, FlatMintDark, FlatNavyBlueDark, FlatOrangeDark, FlatPinkDark, FlatPlumDark, FlatPowderBlueDark, FlatPurpleDark, FlatRedDark, FlatSandDark, FlatSkyBlueDark, FlatTealDark, FlatWatermelonDark, FlatWhiteDark, FlatYellowDark ];
    UIColor* color = colors[categoryName];
    static long currentIndex = 0;
    if (!color) {

        if (colors.count < darkColors.count) {
            color = darkColors[colors.count];
        }
        else if (currentIndex >= darkColors.count) {
            currentIndex = 0;
            color = darkColors[currentIndex];
        }
        else {
            color = darkColors[currentIndex];
            currentIndex++;
        }

        colors[categoryName] = color;
    }
    [color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    color = [UIColor colorWithHue:hue saturation:kSaturationPercent brightness:kBrightnessPercent alpha:alpha];
    return color;
}

- (void)createTableView
{
    _tableViewStatistics = [UITableView newAutoLayoutView];
    [self.contentView addSubview:_tableViewStatistics];
    [_tableViewStatistics autoPinEdgesToSuperviewEdges];
    _tableViewStatistics.dataSource = self;
    _tableViewStatistics.delegate = self;
    [_tableViewStatistics reloadData];
}

- (void)getData
{
    NSString* year = [_currentDate mt_stringFromDateWithFormat:@"YYYY" localized:NO];
    NSString* month = [_currentDate mt_stringFromDateWithFormat:@"MM" localized:NO];

    _balances = [PRDatabase getBalanceWithYear:year month:month];
    _transactions = [PRDatabase getTransactionsGroupedWithCategoryForBalances:_balances];

    BOOL noData = YES;
    _tableViewStatistics.dataSource = self;
    if (_balances.count) {

        [self constructData];
        noData = NO;
    }

    [_tableViewStatistics reloadData];
}

- (void)constructData
{
    NSMutableDictionary* transactionsByCategory = [NSMutableDictionary dictionary];

    TransactionCategoryInformation* allCategory = [TransactionCategoryInformation new];
    allCategory.currencySpend = [NSMutableDictionary dictionary];
    allCategory.category = NSLocalizedString(@"All expenses", nil);
    _allSpend = 0;

    for (PRTransactionModel* model in _transactions) {

        NSLog(@"%@ %@, %@, %d", model.amount, model.currency, model.category, model.expense);
        if (!model.expense || [model.amount doubleValue] >= 0)
            continue;

        NSString* stringDate = [model.period mt_stringFromDateWithFormat:@"yyyy-MM-dd" localized:NO];

        double currentSpend = [model.amount doubleValue];

        if (_currencyFilter != CurrencyFilter_All) {
            _lastCurrencyDate = stringDate;
            NSLog(@"%f", [model.amount doubleValue]);
            if ([model.currency isEqualToString:_currencyFilter] && [model.amount doubleValue] < 0) {
                currentSpend = [model.amount doubleValue];
            }
            else {
                currentSpend = 0;
            }
            if (isnan(currentSpend) || isinf(currentSpend)) {
                continue;
            }
        }

        TransactionCategoryInformation* categoryInformation = transactionsByCategory[model.category];
        if (!categoryInformation) {
            categoryInformation = [TransactionCategoryInformation new];
            categoryInformation.category = model.category;
            categoryInformation.currencySpend = [NSMutableDictionary dictionary];
            transactionsByCategory[model.category] = categoryInformation;
        }

        NSString* currentCurrency = _currencyFilter ? _currencyFilter : model.currency;
        NSNumber* spendForCurrency = categoryInformation.currencySpend[currentCurrency];
        if (!spendForCurrency) {
            spendForCurrency = @0;
        }

        spendForCurrency = @([spendForCurrency doubleValue] + currentSpend);

        categoryInformation.currencySpend[currentCurrency] = spendForCurrency;

        NSNumber* allSpendForCurrency = allCategory.currencySpend[currentCurrency];
        if (!allSpendForCurrency) {
            allSpendForCurrency = @0;
        }
        allSpendForCurrency = @([allSpendForCurrency doubleValue] + currentSpend);
        allCategory.currencySpend[currentCurrency] = allSpendForCurrency;

        if (_currencyFilter == CurrencyFilter_All) {
            double spend = [model.amount doubleValue] * [model.exchangeRate doubleValue];
            _allSpend += spend;

            categoryInformation.percent += spend;
        }
        else {

            _allSpend += currentSpend;
            categoryInformation.percent += currentSpend;
        }
    }
    NSMutableArray* tmp = [NSMutableArray arrayWithArray:[transactionsByCategory allValues]];
    NSPredicate* modelWithNoSpend = [NSPredicate predicateWithBlock:^BOOL(TransactionCategoryInformation* obj, NSDictionary* bind) {
        return obj.percent != 0;
    }];

    tmp = [[tmp filteredArrayUsingPredicate:modelWithNoSpend] mutableCopy];

    NSSortDescriptor* descriptor =
        [[NSSortDescriptor alloc] initWithKey:@"percent"
                                    ascending:YES];
    [tmp sortUsingDescriptors:[NSArray arrayWithObjects:descriptor, nil]];

    if (tmp.count) {
        [tmp insertObject:allCategory atIndex:0];
    }

    _transactions = tmp;
}

const CGFloat leftMargin = 9;

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{

    NSString* identifier = indexPath.row == 0 ? @"StatisticTableViewCellWithoutProgress" : @"StatisticTableViewCell";

    StatisticTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    TransactionCategoryInformation* model = self.transactions[indexPath.row];
    NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"StatisticCell" owner:self options:nil];
    if (indexPath.row == 0) {

        cell = [nib objectAtIndex:1];
    }
    else {
        cell = [nib objectAtIndex:0];
    }
    cell.labelType.text = model.category;

    __block NSString* spend = @"";
    for (NSString* cur in [StatisticViewController localizedCurrences]) {
        NSNumber* amount = model.currencySpend[cur];
        if (amount != nil && amount.floatValue < 0) {
            spend = [NSString stringWithFormat:@"%@ %0.1f %@\n", spend, [amount doubleValue], cur];
        }
    }

    [model.currencySpend enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSNumber* obj, BOOL* stop) {

        if (![[StatisticViewController localizedCurrences] containsObject:key]) {
            spend = [NSString stringWithFormat:@"%@ %0.1f %@\n", spend, [obj doubleValue], key];
        }
    }];

    CGFloat percent = model.percent / _allSpend * 100;
    cell.labelPercent.text = [NSString stringWithFormat:@"%0.1f %%", percent];
    cell.needToDrawProgerss = !(indexPath.row == 0);
    cell.progressSize = percent / 100;
    cell.labelPercent.textColor = kAppLabelColor;
    cell.labelCurrencies.text = spend.length > 0 ? [spend substringToIndex:spend.length - 1] : @"";
    cell.accessoryType = indexPath.row == 0 ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.leftMargin = leftMargin;

    cell.progressBarColor = [self.class flatColorForCategoryName:model.category];
    [cell.labelCurrencies sizeToFit];
    [cell.contentView layoutSubviews];
    [cell setNeedsDisplay];

    return cell;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    TransactionCategoryInformation* model = self.transactions[indexPath.row];
    CGFloat height = 80 + (model.currencySpend.count - 1) * 20;

    if (indexPath.row == 0) {
        height -= 10;
    }

    return height;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return _transactions.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    TransactionHistoryViewController* vc;
    TransactionCategoryInformation* model = self.transactions[indexPath.row];
    vc = [_parentViewDelegate.storyboard instantiateViewControllerWithIdentifier:@"TransactionHistoryViewController"];

    vc.currentDate = _currentDate;
    if (indexPath.row == 0) {
        vc.categoryName = nil;
        vc.showAllCategories = YES;
    }
    else {
        vc.categoryName = model.category;
    }
    vc.monthOffsetFromCategory = _parentViewDelegate.monthOffset;
    [_parentViewDelegate.navigationController pushViewController:vc animated:YES];
}

- (void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsMake(0, leftMargin, 0, 0)];
    }

    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsMake(0, leftMargin, 0, 0)];
    }

    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, leftMargin, 0, 0)];
    }
}

@end
