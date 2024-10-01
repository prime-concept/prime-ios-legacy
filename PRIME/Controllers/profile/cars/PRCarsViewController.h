//
//  PRCarsViewController.h
//  PRIME
//
//  Created by Mariam on 6/16/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileBaseViewController.h"

@interface PRCarsViewController : ProfileBaseViewController

@property (assign, nonatomic) BOOL isSynchedFromOffline;

- (void)reloadData;

@end
