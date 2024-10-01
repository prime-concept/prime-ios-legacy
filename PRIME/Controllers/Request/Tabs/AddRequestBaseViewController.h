//
//  AddRequestBaseViewController.h
//  PRIME
//
//  Created by Artak on 3/23/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "BaseViewController.h"
#import "Option.h"
#import <UIKit/UIKit.h>

@interface AddRequestBaseViewController : BaseViewController

- (CGRect)createAdditionalOptions:(NSArray*)items startPosition:(CGRect)frame forView:(UIView*)superView;

@end
