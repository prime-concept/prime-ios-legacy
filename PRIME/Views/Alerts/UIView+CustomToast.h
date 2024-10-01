//
//  UIView+CustomToast.h
//  PRIME
//
//  Created by Admin on 4/7/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <Toast/UIView+Toast.h>

@interface  UIView (CustomToast)

- (void)makeCustomToast:(NSString *)message duration:(NSTimeInterval)interval position:(id)position;

@end
