//
//  CategoriesDataSource.h
//  PRIME
//
//  Created by Admin on 1/29/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestDataSource.h"

@class CategoriesViewController;
@interface CategoriesDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray* allCategories;
@property (strong, nonatomic) NSArray* categoriesToShow;

@property (weak, nonatomic) CategoriesViewController* parentView;

@property PRRequestSegment selectedSegment;
    @end
