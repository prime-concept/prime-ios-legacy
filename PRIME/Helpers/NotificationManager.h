//
//  ParseManager.h
//  PRIME
//
//  Created by Admin on 9/4/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const kParseTaskPage;


@interface NotificationManager : NSObject

+ (void) proccessNotificationWithTabBarController:(UITabBarController*) tabBarController;

@end
