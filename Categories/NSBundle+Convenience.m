//
//  NSBundle+Convenience.m
//  PRIME
//
//  Created by Андрей Соловьев on 03.03.2023.
//  Copyright © 2023 XNTrends. All rights reserved.
//

#import "NSBundle+Convenience.h"

@implementation NSBundle (Convenience)

- (BOOL)doesMatchURLScheme:(NSString *)scheme {
	if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"]) {
		NSArray *urlTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
		for(NSDictionary *urlType in urlTypes)
		{
			if(urlType[@"CFBundleURLSchemes"])
			{
				NSArray *urlSchemes = urlType[@"CFBundleURLSchemes"];
				for(NSString *urlScheme in urlSchemes)
					if([urlScheme caseInsensitiveCompare:scheme] == NSOrderedSame)
						return YES;
			}
			
		}
	}
	return NO;
}

@end
