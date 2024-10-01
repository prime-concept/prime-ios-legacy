//
//  CollectionViewManager.m
//  PRIME
//
//  Created by Nerses Hakobyan on 11/24/15.
//  Copyright © 2015 XNTrends. All rights reserved.
//

#import "CollectionViewManager.h"

@implementation CollectionViewManager

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self constructMonthButtons];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }

    _monthCount = 200;
    _monthOffset = _monthCount - 1;
}

- (void)constructMonthButtons
{
    [_buttonMonthLeft setImage:nil forState:UIControlStateNormal];
    [_buttonMonthRight setImage:nil forState:UIControlStateNormal];
    UIImage* image = [[UIImage imageNamed:@"calendar_arrow_left"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_buttonMonthLeft setImage:image forState:UIControlStateNormal];
    [_buttonMonthLeft setImage:image forState:UIControlStateHighlighted];
    [_buttonMonthLeft setTintColor:kMonthsCollectionViewArrowColor];
    image = [[UIImage imageNamed:@"calendar_arrow_right"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_buttonMonthRight setImage:image forState:UIControlStateNormal];
    [_buttonMonthRight setImage:image forState:UIControlStateHighlighted];
    [_buttonMonthRight setTintColor:kMonthsCollectionViewArrowColor];
}

- (void)goToLeftForCollectionViewHeader:(UICollectionView*)collectionViewHeader andContentCollectionView:(UICollectionView*)collectionViewContent
{
    [collectionViewContent.collectionViewLayout invalidateLayout];
    [collectionViewContent.collectionViewLayout prepareLayout];
    if (!collectionViewHeader.scrollEnabled) {
        return;
    }
    collectionViewHeader.scrollEnabled = NO;
    CGPoint contentOffset = collectionViewContent.contentOffset;
    contentOffset.x -= collectionViewContent.frame.size.width;
    [collectionViewContent scrollRectToVisible:CGRectMake(contentOffset.x, contentOffset.y, collectionViewContent.frame.size.width, collectionViewContent.frame.size.height) animated:YES];
}

- (void)goToRightForCollectionViewHeader:(UICollectionView*)collectionViewHeader andContentCollectionView:(UICollectionView*)collectionViewContent
{
    if (!collectionViewHeader.scrollEnabled) {
        return;
    }
    collectionViewHeader.scrollEnabled = NO;

    CGPoint contentOffset = collectionViewContent.contentOffset;
    contentOffset.x += collectionViewContent.frame.size.width;
    [collectionViewContent scrollRectToVisible:CGRectMake(contentOffset.x, contentOffset.y, collectionViewContent.frame.size.width, collectionViewContent.frame.size.height) animated:YES];
}

- (void)ScrollView:(UIScrollView*)scrollView DidScrollForHeaderCollectionView:(UICollectionView*)collectionViewHeader andCollectionViewContent:(UICollectionView*)collectionViewContent
{
    if (scrollView == collectionViewContent) {
        CGPoint offsetPoint = collectionViewContent.contentOffset;
        NSLog(@"collectionViewHeader.frame.size.width = %f", collectionViewHeader.frame.size.width);
        NSLog(@"collectionViewContent.frame.size.width = %f", collectionViewContent.frame.size.width);
        offsetPoint.x = offsetPoint.x * collectionViewHeader.frame.size.width / collectionViewContent.frame.size.width;
        collectionViewHeader.contentOffset = offsetPoint;
    }

    else if (scrollView == collectionViewHeader) {
        CGPoint offset = collectionViewHeader.contentOffset;
        offset.x = offset.x * collectionViewContent.frame.size.width / collectionViewHeader.frame.size.width;
        collectionViewContent.contentOffset = offset;
    }
}

- (void)ScrollView:(UIScrollView*)scrollView willBeginDraggingForHeaderCollectionView:(UICollectionView*)collectionViewHeader andCollectionViewContent:(UICollectionView*)collectionViewContent
{
    return;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _monthCount;
}

- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView
{
    return 1;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath
{

    NSAssert(false, @"Unimplemented method collectionView:cellForItemAtIndexPath:");
    return nil;
}

- (CGSize)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath*)indexPath
{
    return collectionView.bounds.size;
}

- (NSDate*)getDateForOffset:(NSUInteger)offset
{
    return [[NSDate new] mt_dateMonthsBefore:_monthCount - offset - 1];
}

@end
