//
//  PRGoogleAnalyticsManager.m
//  PRIME
//
//  Created by Sargis Terteryan on 9/13/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import "PRGoogleAnalyticsManager.h"
@import Firebase;

@implementation PRGoogleAnalyticsManager

+ (void)sendEventWithName:(NSString*)name parameters:(NSDictionary<NSString* , id>*)parameters
{
    NSString* formattedName = [name stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    [FIRAnalytics logEventWithName:formattedName parameters:parameters];
}

@end
