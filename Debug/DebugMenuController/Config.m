//
//  Config.m
//  PRIME
//
//  Created by Андрей Соловьев on 01.03.2023.
//  Copyright © 2023 XNTrends. All rights reserved.
//

#import "Config.h"

NSString *isProdEnabledKey = @"isProdEnabled";

NSString *resolve(NSString * prod, NSString *dev) {
   if (Config.isProdEnabled) {
	   return prod;
   }
   return dev;
}

@implementation Config

@dynamic isProdEnabled;
@dynamic isDebugEnabled;

+ (BOOL)isProdEnabled {
	NSObject *object = [NSUserDefaults.standardUserDefaults objectForKey:isProdEnabledKey];
	if (object == nil) {
		[self setProdEnabled:true];
		return true;
	}
	return [NSUserDefaults.standardUserDefaults boolForKey:isProdEnabledKey];
}

+ (void)setProdEnabled:(BOOL)isProdEnabled {
	[NSUserDefaults.standardUserDefaults setBool:isProdEnabled forKey:isProdEnabledKey];
}

+ (BOOL)isDebugPossible {
	NSString *lastPathComponent = NSBundle.mainBundle.appStoreReceiptURL.lastPathComponent;
	if (lastPathComponent == nil) {
		return YES;
	}

	return [lastPathComponent containsString:@"sandboxReceipt"];
}

+ (BOOL)isDebugEnabled {
	BOOL isDebugEnabled = [NSUserDefaults.standardUserDefaults boolForKey:@"isDebugEnabled"];
	return isDebugEnabled && self.isDebugPossible;
}

+ (void)setDebugEnabled:(BOOL)isDebugEnabled {
	[NSUserDefaults.standardUserDefaults setBool:isDebugEnabled forKey:@"isDebugEnabled"];
}

+ (NSString *)crmEndpoint {
	if ([self isProdEnabled]) {
		return @"https://api.primeconcept.co.uk/v3/";
	}

	return @"https://demo.primeconcept.co.uk/v3/";
}

+ (NSString *)chatEndpoint {
	if ([self isProdEnabled]) {
		return @"https://chat.primeconcept.co.uk/";
	}

	return @"https://demo.primeconcept.co.uk/";
}

@end
