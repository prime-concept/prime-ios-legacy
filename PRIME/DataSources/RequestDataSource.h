//
//  RequestDataSource.h
//  PRIME
//
//  Created by Artak on 1/30/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRPayButtonDelegate.h"

typedef NS_ENUM(NSInteger, PRRequestSegment) {
    PRRequestSegment_InProgress,
    PRRequestSegment_Completed,
    PRRequestSegment_Unknown
};

@interface RequestDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<PRPayButtonDelegate> delegate;

@property (strong, nonatomic) NSArray<NSFetchedResultsController*>* fetchedResultsControllers;

- (id<NSFetchedResultsSectionInfo>)sectionInfo:(NSInteger)section;
- (NSArray<NSIndexPath*>*)extraLinesPosition;
- (instancetype)initWithFetchedResultsForRequest:(NSArray<NSFetchedResultsController*>*)fetchedResultsControllers
                               payButtonDelegate:(id<PRPayButtonDelegate>)delegate NS_DESIGNATED_INITIALIZER;

@property (NS_NONATOMIC_IOSONLY, readonly) NSUInteger rowsCount;

@end
