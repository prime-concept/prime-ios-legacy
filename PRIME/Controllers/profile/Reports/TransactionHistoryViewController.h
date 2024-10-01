//
//  TransactionHistoryViewController.h
//  PRIME
//
//  Created by Admin on 7/27/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SSPullToRefresh/SSPullToRefreshView.h>
#import "FilterViewController.h"
#import "CollectionViewManager.h"

@interface TransactionHistoryViewController : CollectionViewManager

@property (weak, nonatomic) IBOutlet UICollectionView* collectionViewHeader;
@property (weak, nonatomic) IBOutlet UICollectionView* collectionViewTransactions;
@property NSInteger monthOffsetFromCategory;
@property (strong, nonatomic) NSDate* currentDate;
@property (strong, nonatomic) NSString* categoryName;
@property BOOL showAllCategories;

- (FilterViewController*)getFilterViewController;
@end
