//
//  AppWindow.m
//  PRIME
//
//  Created by Андрей Соловьев on 01.03.2023.
//  Copyright © 2023 XNTrends. All rights reserved.
//

#import "AppWindow.h"
#import "DebugMenuViewController.h"
#import "UIViewController+Convenience.h"
#import "Config.h"

@implementation AppWindow

-(void)motionEnded:(UIEventSubtype)motion withEvent:(nullable UIEvent *)event {
	if (motion == UIEventSubtypeMotionShake && Config.isDebugEnabled) {
		[[DebugMenuViewController new] present];
	}
}

@end
