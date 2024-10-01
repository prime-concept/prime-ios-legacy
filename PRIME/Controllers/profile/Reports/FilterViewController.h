//
//  FilterViewController.h
//  PRIME
//
//  Created by Artak Tsatinyan on 7/27/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "BaseViewController.h"

@class FilterViewController;
@protocol FilterViewControllerDelegate <NSObject>

@optional
- (void)reload;
- (void)setFilterIndex:(NSInteger)filters;
- (FilterViewController*)getFilterViewController;
@end

@interface FilterViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView* tableView;

@property (strong, nonatomic) NSArray* filters;
@property (strong, nonatomic) NSArray* filtersHeader;
@property (nonatomic) NSInteger selectedFilter;

@property (weak, nonatomic) id<FilterViewControllerDelegate> parentViewDelegate;
@end
