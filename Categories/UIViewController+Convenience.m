//
//  UIViewController+Convenience.m
//  PRIME
//
//  Created by Андрей Соловьев on 01.03.2023.
//  Copyright © 2023 XNTrends. All rights reserved.
//

#import "UIViewController+Convenience.h"

@implementation UIViewController (Convenience)

- (instancetype)topmostPresentedOrSelf {
	UIViewController *result = self;
	while (result.presentedViewController != nil) {
		result = result.presentedViewController;
	}

	return result;
}

+ (instancetype)topmostPresentedOrRoot {
	return UIApplication.sharedApplication
		.keyWindow
		.rootViewController
		.topmostPresentedOrSelf;
}

- (void)present {
	[UIViewController.topmostPresentedOrRoot presentViewController:self animated:true completion:nil];
}

- (void)alert:(NSString *)title action:(void (^)())action cancel:(nonnull void (^)())cancel {
	[UIViewController alert:title action:action cancel: cancel];
}

+ (void)alert:(NSString *)title action:(void (^)())action cancel:(nonnull void (^)())cancel {
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
	alert.title = title;

	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:cancel];
	UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"ОК" style:UIAlertActionStyleDefault handler:action];
	[alert addAction:okAction];
	[alert addAction:cancelAction];
	[alert present];
}

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
