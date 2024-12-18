//
//  UIAlertController+PRNewWindow.m
//  PRIME
//
//  Created by Aram on 10/9/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "UIAlertController+PRNewWindow.h"
#import <objc/runtime.h>

@interface UIAlertController (PRPrivateWindow)
@property (strong, nonatomic) UIWindow* alertWindow;

@end

@implementation UIAlertController (PRPrivateWindow)
@dynamic alertWindow;

- (void)setAlertWindow:(UIWindow*)alertWindow
{
    objc_setAssociatedObject(self, @selector(alertWindow), alertWindow, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIWindow*)alertWindow
{
    return objc_getAssociatedObject(self, @selector(alertWindow));
}

@end

@implementation UIAlertController (PRNewWindow)

- (void)pr_show
{
    [self pr_show:YES];
}

- (void)pr_show:(BOOL)animated
{
    self.alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.alertWindow.rootViewController = [[UIViewController alloc] init];

    id<UIApplicationDelegate> delegate = [UIApplication sharedApplication].delegate;
    // Applications that does not load with UIMainStoryboardFile might not have a window property.
    if ([delegate respondsToSelector:@selector(window)]) {
        // We inherit the main window's tintColor.
        self.alertWindow.tintColor = delegate.window.tintColor;
    }

    // Window level is above the top window (this makes the alert, if it's a sheet, show over the keyboard).
    UIWindow* topWindow = [UIApplication sharedApplication].windows.lastObject;
    self.alertWindow.windowLevel = topWindow.windowLevel + 1;

    [self.alertWindow makeKeyAndVisible];
    [self.alertWindow.rootViewController presentViewController:self animated:animated completion:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    // Precaution to insure window gets destroyed.
    self.alertWindow.hidden = YES;
    self.alertWindow = nil;
}

@end
