//
//  CategoriesDataSource.m
//  PRIME
//
//  Created by Artak Tsatinyan on 1/29/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "CategoriesDataSource.h"
#import "CategoriesViewController.h"
#import "PRTasksTypesModel.h"
#import "RequestsViewController.h"
#import "StatisticViewController.h"
#import "TaskIcons.h"
#import "CategoryTableViewCell.h"
#import "TransactionHistoryViewController.h"

#define MAX_CATEGORIES_TO_SHOW (5)
const CGFloat nameLabelLeadingConstraint = 67.5;
const CGFloat withoutLogoNameLabelLeadingConstraint = 15;

@interface CategoriesDataSource () {
    BOOL _doesShowAllButton;
}

@end

@implementation CategoriesDataSource

- (instancetype)init
{
    self = [super init];
    if (self) {
        _doesShowAllButton = YES;
    }
    return self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return _doesShowAllButton ? (MIN([_categoriesToShow count], MAX_CATEGORIES_TO_SHOW) + 1) : [_categoriesToShow count];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    CategoryTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryTableViewCell"];

    NSInteger count = _doesShowAllButton ? MIN([_categoriesToShow count], MAX_CATEGORIES_TO_SHOW) : [_categoriesToShow count];

    if (indexPath.row == count) {
        cell.requestNameLabel.text = NSLocalizedString(@"All categories...", );
#if defined(Platinum) || defined(VTB24)
        cell.requestNameLabel.textColor = kIconsColor;
#else
        cell.requestNameLabel.textColor = kSegmentedControlTaskStatusColor;
#endif
        cell.requestNameLabelLeadingConstraint.constant = withoutLogoNameLabelLeadingConstraint;
        cell.requestIconImageView.image = nil;
        cell.requestCountLabel.hidden = YES;
        cell.accessoryType = UITableViewCellAccessoryNone;

        return cell;
    }

    PRTasksTypesModel* model = _categoriesToShow[indexPath.row];
    cell.requestIconImageView.image = [UIImage imageNamed:[TaskIcons imageNameFromTaskTypeId:model.typeId.integerValue]];
    cell.requestNameLabel.text = model.typeName;
    cell.requestNameLabel.font = kLabelNameFont;
    cell.requestNameLabel.textColor = [UIColor blackColor];
    cell.requestNameLabelLeadingConstraint.constant = nameLabelLeadingConstraint;
    cell.requestCountLabel.hidden = NO;
    cell.requestCountLabel.textColor = kAppLabelColor;
    cell.requestCountLabel.text = [NSString stringWithFormat:@"%@", model.count];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSInteger count = 0;

    if (_doesShowAllButton) {
        count = MIN([_categoriesToShow count], MAX_CATEGORIES_TO_SHOW);
        if (count == indexPath.row) {
            [PRGoogleAnalyticsManager sendEventWithName:kRequestAllCategorySelected parameters:nil];
            [self showAllCategories];
            return;
        }
    }

    [PRGoogleAnalyticsManager sendEventWithName:kRequestCategorySelected parameters:nil];
    PRTasksTypesModel* info = [_categoriesToShow objectAtIndex:indexPath.row];
    [self openRequestPageForFilter:info.typeId
                       andFilterBy:RequestsFilter_CategoryId
                             title:info.typeName];
}

- (void)showAllCategories
{
    _doesShowAllButton = NO;

    _categoriesToShow = [_allCategories mutableCopy];
    [_parentView.tableViewCategories reloadData];
}

#pragma mark - Navigation

- (void)openRequestPageForFilter:(NSNumber*)filterId andFilterBy:(RequestFilter)filterBy title:(NSString*)title
{
    RequestsViewController* viewController = (RequestsViewController*)[_parentView.storyboard instantiateViewControllerWithIdentifier:@"RequestsViewController"];
    viewController.filterById = filterId;
    viewController.filterForKey = filterBy;
    viewController.title = NSLocalizedString(title, );
    viewController.reservesOrRequestsSegmentedControl.selectedSegmentIndex = PRRequestSegment_InProgress;

    [_parentView.navigationController pushViewController:viewController
                                                animated:YES];
}

@end
