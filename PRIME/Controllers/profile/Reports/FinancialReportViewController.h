//
//  FinancialReportViewController.h
//  PRIME
//
//  Created by Nerses Hakobyan on 11/20/15.
//  Copyright © 2015 XNTrends. All rights reserved.
//

#import "FilterViewController.h"
#import "BaseViewController.h"
#import <SSPullToRefresh/SSPullToRefreshView.h>
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, Segment) {
    Segment_History,
    Segment_Expenses
};

@interface FinancialReportViewController : BaseViewController <FilterViewControllerDelegate>

@end
