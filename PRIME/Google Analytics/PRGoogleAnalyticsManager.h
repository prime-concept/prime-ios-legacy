//
//  PRGoogleAnalyticsManager.h
//  PRIME
//
//  Created by Sargis Terteryan on 9/13/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PRGoogleAnalyticsManager : NSObject

+ (void)sendEventWithName:(NSString*)name parameters:(NSDictionary<NSString* , id>*)parameters;

@end
