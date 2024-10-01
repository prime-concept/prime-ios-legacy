//
//  ContainerViewController.h
//  PRIME
//
//  Created by Artak Tsatinyan on 3/19/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "BaseViewController.h"
#import "FilterViewController.h"
#import <UIKit/UIKit.h>

#define SegueTransactionView @"transactionViewSegue"
#define SegueStatistics @"statisticsSegue"

@interface ContainerViewController : BaseViewController

- (void)swapToViewControllers:(NSString*)segueName;

@property (nonatomic, strong) UIViewController<FilterViewControllerDelegate>* currentViewController;

@end
