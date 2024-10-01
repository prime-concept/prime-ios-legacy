//
//  UIView+CustomToast.m
//  PRIME
//
//  Created by Admin on 4/7/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "UIView+CustomToast.h"

@interface UIView (ToastPrivate)

- (UIView *)viewForMessage:(NSString *)message title:(NSString *)title image:(UIImage *)image;
- (void)hideToast:(UIView *)toast;

@end

static UIView *toast = nil;

@implementation UIView (CustomToast)

- (void)makeCustomToast:(NSString *)message duration:(NSTimeInterval)interval position:(id)position
{
    if (toast != nil && toast.superview != nil) {
        [self hideToast:toast];
    }
    toast = [self viewForMessage:message title:nil image:nil];
    [self showToast:toast duration:interval position:position];
}
@end

