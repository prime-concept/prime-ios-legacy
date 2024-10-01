//
//  SelectCardViewController.h
//  PRIME
//
//  Created by Artak on 1/31/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "BaseViewController.h"
#import "CardDataSource.h"
#import <UIKit/UIKit.h>

@interface SelectCardViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UITableView* tableView;
@property (strong, nonatomic) CardDataSource* dataSource;

@end
