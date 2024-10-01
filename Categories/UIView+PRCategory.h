//
//  UIView+PRCategory.h
//  PRIME
//
//  Created by Sargis Terteryan on 5/24/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (PRCategory)

+ (void)addSubviewToViewWithConstraints:(UIView*)view subview:(UIView*)subView top:(NSInteger)top bottom:(NSInteger)bottom leading:(NSInteger)leading trailing:(NSInteger)trailing;

@end
