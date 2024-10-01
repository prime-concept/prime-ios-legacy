//
//  UINavigationBar+Addition.h
//  PRIME
//
//  Created by Davit on 2/13/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationBar (Addition)

// Hides 1px hairline of the nav bar.
- (void)hideBottomHairline;

// Shows 1px hairline of the nav bar.
- (void)showBottomHairline;

// Makes the navigation bar background transparent.
- (void)makeTransparent;

// Restores the default navigation bar appeareance.
- (void)makeDefault;

+ (void)setStatusBarBackgroundColor:(UIColor*)color;

@end
