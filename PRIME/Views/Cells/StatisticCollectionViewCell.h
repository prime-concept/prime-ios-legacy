//
//  StatisticCollectionViewCell.h
//  PRIME
//
//  Created by Admin on 3/16/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StatisticViewController.h"

@interface StatisticCollectionViewCell : UICollectionViewCell <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView* tableViewStatistics;
@property (strong, nonatomic) NSDate* currentDate;

@property (strong, nonatomic) NSArray* transactions;
@property (strong, nonatomic) NSArray* balances;

@property (strong, nonatomic) NSString* currencyFilter;

@property (nonatomic) double allSpend;
@property (strong, nonatomic) NSString *lastCurrencyDate;

@property (weak, nonatomic) StatisticViewController *parentViewDelegate;
- (void)getData;
-(void)createTableView;
@end
