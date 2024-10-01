//
//  UIViewController+Convenience.h
//  PRIME
//
//  Created by Андрей Соловьев on 01.03.2023.
//  Copyright © 2023 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Convenience)

- (instancetype)topmostPresentedOrSelf;
+ (instancetype)topmostPresentedOrRoot;

- (void)present;

- (void)alert:(NSString *)title action:(void (^)())action cancel:(void (^)())cancel;
//+ (void)alert:(NSString *)title action:(void (^)())action cancel:(void (^)())cancel;

@end

NS_ASSUME_NONNULL_END
