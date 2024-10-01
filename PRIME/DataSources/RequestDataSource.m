//
//  RequestDataSource.m
//  PRIME
//
//  Created by Artak Tsatinyan on 1/30/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "CommandBuilder.h"
#import "PROrderModel.h"
#import "RequestDataSource.h"
#import "RequestTableViewCell.h"
#import "RequestWithoutPriceCell.h"
#import "TaskIcons.h"
#import "ChatUtility.h"

@implementation RequestDataSource

- (instancetype)initWithFetchedResultsForRequest:(NSArray<NSFetchedResultsController*>*)fetchedResultsControllers

                               payButtonDelegate:(id<PRPayButtonDelegate>)delegate;
{
    self = [super init];
    if (self) {
        _delegate = delegate;
        _fetchedResultsControllers = fetchedResultsControllers;
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return [self sectionsCount];
}

- (NSArray*)modelsForSection:(NSInteger)section
{
    return [[self sectionInfo:section] objects];
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self sectionInfo:section] numberOfObjects];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    PRTaskDetailModel* info = nil;
    PROrderModel* order = nil;

    UITableViewCell* cell = nil;

    if ([self sectionsCount]) {
        info = [self modelsForSection:indexPath.section][indexPath.row];
    }

    NSString* channelId = [ChatUtility chatIdWithPrefix:info.chatId.stringValue];
    NSInteger unseenMessagesCount = [PRDatabase requestsUnseenMessagesCountFromSubscriptionsForChannelId: channelId];

    if ([info.orders count] > 0 && info.completed.integerValue == 0) {

        order = [info.orders firstObject];

        RequestTableViewCell* requestTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"RequestTableViewCell"];
        NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"TransactionCell" owner:self options:nil];
        requestTableViewCell = [nib objectAtIndex:2];
        requestTableViewCell.labelName.text = info.taskName;
        [requestTableViewCell.labelName setFont:kLabelNameFont];
        requestTableViewCell.labelDescription.text = info.taskDescription;
        [requestTableViewCell.labelDescription setFont:kLabelDescriptionFont];
        requestTableViewCell.taskId = info.taskId;
        requestTableViewCell.paymentLink = order.paymentLink;
        requestTableViewCell.delegate = _delegate;
        requestTableViewCell.requestDate = info.requestDate;
        [requestTableViewCell.buttonPay setTitle:[[NSString alloc] initWithFormat:@"%@ %@", [order amount], NSLocalizedString([order getCurrency], nil)] forState:UIControlStateNormal];
        requestTableViewCell.imageView.image = [UIImage imageNamed:[TaskIcons imageNameFromTaskTypeId:info.taskType.typeId.integerValue]];
        requestTableViewCell.labelDueDate.text = ![order dueDate] ? @"" : [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"due", nil), [order dueDate]];
        if(!info.completed.boolValue) {
            [requestTableViewCell createBadgeWithValue:unseenMessagesCount];
        }

        cell = requestTableViewCell;
    } else {
        RequestWithoutPriceCell* requestWithoutPriceCell = [tableView dequeueReusableCellWithIdentifier:@"RequestWithoutPriceCell"];
        NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"TransactionCell" owner:self options:nil];
        requestWithoutPriceCell = [nib objectAtIndex:1];
        requestWithoutPriceCell.labelName.text = info.taskName;
        [requestWithoutPriceCell.labelName setFont:kLabelNameFont];
        requestWithoutPriceCell.labelDescription.text = info.taskDescription;
        [requestWithoutPriceCell.labelDescription setFont:kLabelDescriptionFont];
        requestWithoutPriceCell.taskId = info.taskId;
        requestWithoutPriceCell.requestDate = info.requestDate;
        requestWithoutPriceCell.imageView.image = [UIImage imageNamed:[TaskIcons imageNameFromTaskTypeId:info.taskType.typeId.integerValue]];
        if(!info.completed.boolValue) {
            [requestWithoutPriceCell createBadgeWithValue:unseenMessagesCount];
        }

        requestWithoutPriceCell.imageView.image = [UIImage imageNamed:[TaskIcons imageNameFromTaskTypeId:info.taskType.typeId.integerValue]];
        cell = requestWithoutPriceCell;
    }

    [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];

    return cell;
}

- (NSArray<NSIndexPath*>*)extraLinesPosition
{
    NSMutableArray<NSIndexPath*>* objects = [NSMutableArray new];

    if ([_fetchedResultsControllers count] < 2) { // Currently "count" equals to 2 only when selected 'InProgress' tab.
        return objects;
    }

    id obj = [[[[[_fetchedResultsControllers firstObject] sections] lastObject] objects] lastObject];
    NSIndexPath* indexPath = [[_fetchedResultsControllers firstObject] indexPathForObject:obj];

    if (indexPath) {
        [objects addObject:indexPath];
    }

    return objects;
}

- (NSUInteger)rowsCount
{
    return [self sectionsCount];
}

- (NSInteger)sectionsCount
{
    NSInteger sectionsCount = 0;

    for (NSFetchedResultsController* fetchedResultsController in _fetchedResultsControllers) {
        sectionsCount += fetchedResultsController.sections.count;
    }

    return sectionsCount;
}

- (id<NSFetchedResultsSectionInfo>)sectionInfo:(NSInteger)section
{
    NSFetchedResultsController* fetchedResultsController;

    for (NSFetchedResultsController* obj in _fetchedResultsControllers) {

        NSInteger sectionsCount = obj.sections.count;

        if (section < sectionsCount) {
            fetchedResultsController = obj;
            break;
        }

        section -= sectionsCount;
    }

    return [fetchedResultsController sections][section];
}

@end
