//
//  TransactionCollectionViewCell.h
//  PRIME
//
//  Created by Nerses Hakobyan on 11/24/15.
//  Copyright © 2015 XNTrends. All rights reserved.
//

#import "TransactionHistoryViewController.h"
#import <Foundation/Foundation.h>

@interface TransactionCollectionViewCell : UICollectionViewCell <UITableViewDelegate, UITableViewDataSource, FilterViewControllerDelegate, SSPullToRefreshViewDelegate>
@property (strong, nonatomic) UITableView* tableView;
@property (weak, nonatomic) IBOutlet UIView* tableViewHeader;
@property (weak, nonatomic) IBOutlet UILabel* informationLabel;
@property (weak, nonatomic) IBOutlet UILabel* labelInformation;
@property (weak, nonatomic) IBOutlet UIButton* buttonClose;
@property (weak, nonatomic) IBOutlet UILabel* labelHeaderRemaining;
@property (weak, nonatomic) IBOutlet UIView* viewHeaderContainer;
@property (weak, nonatomic) TransactionHistoryViewController* parentViewDelegate;
@property (strong, nonatomic) SSPullToRefreshView* pullToRefreshView;
@property (strong, nonatomic) NSDate* currentDate;
@property (strong, nonatomic) NSString* categoryName;
@property (nonatomic) enum TransactionFilter filter;

- (void)getData;
- (void)createHeaderView;
- (void)createTableView;
@end
