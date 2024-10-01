//
//  CardDataSource.m
//  PRIME
//
//  Created by Admin on 1/31/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "CardDataSource.h"
#import "PRCardData.h"
#import "PRCreditCardValidator.h"
#import "PaymentCardTableViewCell.h"

#define SECTION_COUNT 1

#define PROFILE_TABLE_VIEW_CELL_HEIGTH 45

@implementation CardDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_cardSection count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PaymentCardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PaymentCardTableViewCell"];
    cell.labelCardType.textColor = kAppLabelColor;
    cell.labelCardNumber.textColor = kAppLabelColor;
    cell.labelCardExpDate.textColor = kAppLabelColor;

    PRCardData *cardData = _cardSection[indexPath.row];
    
    cell.labelCardType.text = [PRCreditCardValidator getTypeForCardNumber: cardData.cardNumber];
    
    cell.labelCardNumber.text = [PRCreditCardValidator getHiddenCardNumber: cardData.cardNumber];
    
    cell.labelCardExpDate.text = cardData.expDate;

    [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return PROFILE_TABLE_VIEW_CELL_HEIGTH;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

#pragma mark delete action

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
