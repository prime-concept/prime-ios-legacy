//
//  StatisticViewController.h
//  PRIME
//
//  Created by Admin on 3/15/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterViewController.h"
#import "CollectionViewManager.h"

@interface StatisticViewController : CollectionViewManager

@property (weak, nonatomic) IBOutlet UICollectionView* collectionViewHeader;
@property (weak, nonatomic) IBOutlet UICollectionView* collectionViewStatistics;

@property (strong, nonatomic) NSIndexPath* selectedIndexPath;

- (IBAction)goToLeftAction:(id)sender;
- (IBAction)goToRightAction:(id)sender;

+ (NSArray*)localizedCurrences;
+ (NSString*)currenctyForFilter:(enum CurrencyFilter)filter;

@end
