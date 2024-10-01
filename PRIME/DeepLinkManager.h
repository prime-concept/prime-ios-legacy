//
//  DeepLinkManager.h
//  PRIME
//
//  Created by Aram on 3/23/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

// Common
static NSString* const kDeepLinkURLKey = @"url";

static NSString* const kDeepLinkKey = @"deepLink";

// Chat
static NSString* const kServiceIDKey = @"service_id";

static NSString* const kDeepLinkPath = @"$deeplink_path";

// City Guide
static NSString* const kDeepLinkCustomURL = @"$custom_url";

static NSString* const kDeepLinkCanonicalURL = @"$canonical_url";

static NSString* const kDeepLinkCanonicalIdentifier = @"$canonical_identifier";

@interface DeepLinkManager : NSObject

+ (void)handleDeepLinkForServices:(NSDictionary*)serviceInfo tabBarController:(UITabBarController*)tabBarController;

@end
