//
//  PRInitialOverviewViewController.h
//  PRIME
//
//  Created by Davit on 8/16/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "PROverviewBaseViewController.h"

@protocol InitialOverviewViewControllerDelegate <NSObject>

@optional
- (void)registerPrimeSegmentDidSelect;

@end

@interface PRInitialOverviewViewController : PROverviewBaseViewController

@property (weak, nonatomic) id<InitialOverviewViewControllerDelegate> delegate;

@end
