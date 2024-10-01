//
//  UIView+PRCategory.m
//  PRIME
//
//  Created by Sargis Terteryan on 5/24/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import "UIView+PRCategory.h"

@implementation UIView (PRCategory)

+ (void)addSubviewToViewWithConstraints:(UIView*)parentView subview:(UIView*)subView top:(NSInteger)top bottom:(NSInteger)bottom leading:(NSInteger)leading trailing:(NSInteger)trailing;
{
    [parentView addSubview:subView];

    subView.translatesAutoresizingMaskIntoConstraints = NO;

    // Trailing
    NSLayoutConstraint* trailingConstraint = [NSLayoutConstraint
        constraintWithItem:subView
                 attribute:NSLayoutAttributeTrailing
                 relatedBy:NSLayoutRelationEqual
                    toItem:parentView
                 attribute:NSLayoutAttributeTrailing
                multiplier:1.0f
                  constant:trailing];

    // Leading
    NSLayoutConstraint* leadingConstraint = [NSLayoutConstraint
        constraintWithItem:subView
                 attribute:NSLayoutAttributeLeading
                 relatedBy:NSLayoutRelationEqual
                    toItem:parentView
                 attribute:NSLayoutAttributeLeading
                multiplier:1.0f
                  constant:leading];

    // Top
    NSLayoutConstraint* topConstraint = [NSLayoutConstraint
        constraintWithItem:subView
                 attribute:NSLayoutAttributeTop
                 relatedBy:NSLayoutRelationEqual
                    toItem:parentView
                 attribute:NSLayoutAttributeTop
                multiplier:1.0f
                  constant:top];

    // Bottom
    NSLayoutConstraint* bottomConstraint = [NSLayoutConstraint
        constraintWithItem:subView
                 attribute:NSLayoutAttributeBottom
                 relatedBy:NSLayoutRelationEqual
                    toItem:parentView
                 attribute:NSLayoutAttributeBottom
                multiplier:1.0f
                  constant:bottom];

    [parentView addConstraint:trailingConstraint];
    [parentView addConstraint:bottomConstraint];
    [parentView addConstraint:leadingConstraint];
    [parentView addConstraint:topConstraint];
}

@end
