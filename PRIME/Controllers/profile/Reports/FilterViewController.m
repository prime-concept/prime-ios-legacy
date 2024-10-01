//
//  FilterViewController.m
//  PRIME
//
//  Created by Artak on 7/27/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "FilterCell.h"
#import "FilterViewController.h"
#import "PRDatabase.h"

@interface FilterViewController ()

@end

@implementation FilterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = kTableViewBackgroundColor;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    FilterCell* cell = [tableView dequeueReusableCellWithIdentifier:@"FilterCell"];

    if (_selectedFilter == indexPath.row) {

        cell.imageViewCheck.hidden = NO;
        cell.labelCell.textColor = [UIColor blackColor];
    }
    else {

        cell.imageViewCheck.hidden = YES;
        cell.labelCell.textColor = kAppLabelColor;
    }

    cell.labelCell.text = _filters[indexPath.row];

    return cell;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return _filters.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return 70;
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section < _filtersHeader.count) {

        return _filtersHeader[section];
    }
    return nil;
}

- (NSString*)tableView:(UITableView*)tableView titleForFooterInSection:(NSInteger)section
{
    if (section < _filtersHeader.count) {

        return NSLocalizedString(@"Data on transactions made in the last 10 days, can be adjusted", );
    }
    return nil;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSString* eventName = [NSString stringWithFormat:([_filtersHeader[indexPath.section]  isEqual: @"Currency"] ?
                                                      kCurrencyItemSelected : kServiceProviderItemSelected),
                                                      _filters[indexPath.row]];
    [PRGoogleAnalyticsManager sendEventWithName:eventName parameters:nil];
    _selectedFilter = indexPath.row;
    [_tableView reloadData];
}

- (void)didMoveToParentViewController:(UIViewController*)parent
{
    if (![parent isEqual:self.parentViewController]) {

        [_parentViewDelegate setFilterIndex:_selectedFilter];
        [_parentViewDelegate reload];
    }
}
- (void)tableView:(UITableView*)tableView willDisplayFooterView:(UIView*)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView* header = (UITableViewHeaderFooterView*)view;

    header.textLabel.font = [UIFont systemFontOfSize:16.0f];
}
@end
