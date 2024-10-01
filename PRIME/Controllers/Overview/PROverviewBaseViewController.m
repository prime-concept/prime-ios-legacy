//
//  PROverviewBaseViewController.m
//  PRIME
//
//  Created by Davit on 8/24/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "PROverviewBaseViewController.h"

@implementation PROverviewBaseViewController

#pragma mark - Gradient

- (void)applyGradientToView:(UIView*)view
{
    CAGradientLayer* gradient = [CAGradientLayer layer];

    gradient.frame = view.bounds;
    gradient.colors = @[ (id)[UIColor blackColor].CGColor, (id)[UIColor blackColor].CGColor, (id)[UIColor blackColor].CGColor, (id)[UIColor clearColor].CGColor ];

    view.layer.mask = gradient;
}

@end
