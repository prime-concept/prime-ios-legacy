//
//  CategoriesViewController.h
//  PRIME
//
//  Created by Artak on 1/30/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "BaseViewController.h"
#import "CategoriesDataSource.h"

@interface CategoriesViewController : BaseViewController <UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView* tableViewCategories;
@property (strong, nonatomic) CategoriesDataSource* categoriesDataSource;

@end
