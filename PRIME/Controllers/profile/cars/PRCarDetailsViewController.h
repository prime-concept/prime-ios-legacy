//
//  PRCarDetailsViewController.h
//  PRIME
//
//  Created by Mariam on 6/16/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PRCarModel.h"
#import "PRCarsViewController.h"

@interface PRCarDetailsViewController : UIViewController

- (void)setCurrentCar:(PRCarModel*)car
                 context:(NSManagedObjectContext*)context
    parentViewController:(PRCarsViewController*)parentViewController;

@end
