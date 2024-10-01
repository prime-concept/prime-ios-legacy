//
//  CollectionViewManager.h
//  PRIME
//
//  Created by Nerses Hakobyan on 11/24/15.
//  Copyright © 2015 XNTrends. All rights reserved.
//

#import "FilterViewController.h"
#import <Foundation/Foundation.h>
#import <SSPullToRefresh/SSPullToRefreshView.h>

@interface CollectionViewManager : UIViewController <SSPullToRefreshViewDelegate, FilterViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic) NSUInteger monthCount;
@property NSInteger monthOffset;
@property (weak, nonatomic) IBOutlet UIButton* buttonMonthLeft;
@property (weak, nonatomic) IBOutlet UIButton* buttonMonthRight;

- (void)goToLeftForCollectionViewHeader:(UICollectionView*)collectionViewHeader andContentCollectionView:(UICollectionView*)collectionViewContent;

- (void)goToRightForCollectionViewHeader:(UICollectionView*)collectionViewHeader andContentCollectionView:(UICollectionView*)collectionViewContent;

- (void)ScrollView:(UIScrollView*)scrollView DidScrollForHeaderCollectionView:(UICollectionView*)collectionViewHeader andCollectionViewContent:(UICollectionView*)collectionViewContent;

- (void)ScrollView:(UIScrollView*)scrollView willBeginDraggingForHeaderCollectionView:(UICollectionView*)collectionViewHeader andCollectionViewContent:(UICollectionView*)collectionViewContent;

- (NSDate*)getDateForOffset:(NSUInteger)offset;
@end
