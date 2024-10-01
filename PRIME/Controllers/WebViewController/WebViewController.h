//
//  WebViewController.h
//  PRIME
//
//  Created by Artak on 1/31/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "CustomActionSheetViewController.h"
#import "PaymentCardPicker.h"
#import "BaseViewController.h"

#import <SSPullToRefresh/SSPullToRefreshView.h>
#import <UIKit/UIKit.h>

@import WebKit;

@interface WebViewController : BaseViewController <UIScrollViewDelegate, WKNavigationDelegate, WKUIDelegate, SSPullToRefreshViewDelegate, PaymentCardPickerDelegate, SelectionViewControllerDelegate>

@property (strong, nonatomic) NSString* url;
@property (strong, nonatomic) WKWebView* webView;
@property (assign, nonatomic) BOOL hideProgressHUD;

- (void)initializeWebView;
- (BOOL)isNavigationBarNeeded;

@end
