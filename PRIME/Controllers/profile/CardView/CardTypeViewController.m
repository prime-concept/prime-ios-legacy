//
//  CardTypeViewController.m
//  PRIME
//
//  Created by Artak on 7/16/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "AddCardViewController.h"
#import "CardTypeViewController.h"
#import "DiscountCardViewController.h"
#import "PRCardTypeModel.h"
#import "PRRequestManager.h"

@interface CardTypeViewController ()

@property (strong, nonatomic) NSArray* cardTypes;
@property (weak, nonatomic) IBOutlet UITableView* tableView;

@end

static const CGFloat kTableViewHeaderHeight = 56.0f;
static const CGFloat kTableViewHeaderFontSize = 16.0f;
static NSString* const kHeaderFooterViewIdentifier = @"HeaderFooterView";

@implementation CardTypeViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = kTableViewBackgroundColor;

    self.title = NSLocalizedString(@"Cards", nil);

    _cardTypes = [PRDatabase getDiscountTypes];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    BOOL isDataExist = _cardTypes && _cardTypes.count > 0;

    [self.lazyManager shouldBeUpdatedIfViewDidAppearWithDate:[NSDate date]
        relativeToDate:nil
        then:^(PRRequestMode mode) {
            [PRRequestManager getDiscountTypesWithView:self.view
                                                  mode:isDataExist ? PRRequestMode_ShowNothing : PRRequestMode_ShowErrorMessagesAndProgress
                                               success:^(NSArray* result) {

                                                   [self reload];

                                               }
                                               failure:^{

                                               }];
        }
        otherwiseIfFirstTime:^{

            [_tableView reloadData];

        }
        otherwise:^{

        }];
}

#pragma mark - Helpers

- (void)reload
{
    _cardTypes = [PRDatabase getDiscountTypes];
    [_tableView reloadData];

    [_dataSource reload];
}

- (UITableViewHeaderFooterView*)headerFooterViewForTableView:(UITableView*)tableView
{
    UITableViewHeaderFooterView* headerFooterView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kHeaderFooterViewIdentifier];
    if (!headerFooterView) {
        headerFooterView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:kHeaderFooterViewIdentifier];
    }

    return headerFooterView;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return _cardTypes.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{

    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cardTypeCell"];
    NSString* typeName = nil;

    typeName = ((PRCardTypeModel*)_cardTypes[indexPath.row]).name;
    NSLog(@"Card id %@  --- name %@", ((PRCardTypeModel*)_cardTypes[indexPath.row]).typeId,
        ((PRCardTypeModel*)_cardTypes[indexPath.row]).name);

    cell.textLabel.text = typeName;

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableViewHeaderHeight;
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    DiscountCardViewController* discountCardVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DiscountCardViewController"];
    discountCardVC.type = _cardTypes[indexPath.row];
    discountCardVC.dataSource = _dataSource;
    [self.navigationController pushViewController:discountCardVC animated:YES];
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self headerFooterViewForTableView:tableView];
}

- (void)tableView:(UITableView*)tableView willDisplayHeaderView:(UIView*)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView* headerView = (UITableViewHeaderFooterView*)view;

    headerView.textLabel.font = [UIFont systemFontOfSize:kTableViewHeaderFontSize];
    [headerView.textLabel setText:[NSLocalizedString(@"Card types", ) uppercaseString]];
}

@end
