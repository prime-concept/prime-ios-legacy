//
//  PRTransactionModel.h
//  PRIME
//
//  Created by Admin on 7/29/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@class PRBalanceModel;
@interface PRTransactionModel : PRModel

@property (nonatomic, retain) NSNumber * transactionId;
@property (nonatomic, retain) NSDate * period;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * toReport;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * balanceBefore;
@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) NSNumber * balanceAfter;
@property (nonatomic, retain) NSString * currency;
@property (nonatomic, retain) NSNumber * directPayment;
@property (nonatomic, retain) NSNumber * exchangeRate;
@property (nonatomic, retain) NSNumber * taskInfoId;
@property (nonatomic) BOOL expense;

@property (nonatomic, retain) PRBalanceModel *balance;

@property (nonatomic, strong) NSDate            *day; // Used for Grouping
@end
