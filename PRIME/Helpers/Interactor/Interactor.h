//
//  Interactor.h
//  PRIME
//
//  Created by Admin on 2/11/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WelcomeViewController.h"


@interface Interactor : UIPercentDrivenInteractiveTransition<WelcomeViewControllerPanTarget>

-(instancetype)initWithParentViewController:(UIViewController *)viewController NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly) UIViewController *parentViewController;

@end
