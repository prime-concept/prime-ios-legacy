//
//  PRBalanceModel.h
//  PRIME
//
//  Created by Admin on 7/29/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PRTransactionModel;

@interface PRBalanceModel : PRModel

@property (nonatomic, retain) NSNumber * openingBalance;
@property (nonatomic, retain) NSNumber * closingBalance;
@property (nonatomic, retain) NSString * currency;
@property (nonatomic, retain) NSOrderedSet *transactions;

@property (nonatomic, retain) NSString * month;
@property (nonatomic, retain) NSString * year;

@end

@interface PRBalanceModel (CoreDataGeneratedAccessors)

- (void)addTransactionsObject:(PRTransactionModel *)value;
- (void)removeTransactionsObject:(PRTransactionModel *)value;
- (void)addTransactions:(NSSet *)values;
- (void)removeTransactions:(NSSet *)values;

@end
