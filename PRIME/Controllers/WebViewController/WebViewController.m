//
//  WebViewController.m
//  PRIME
//
//  Created by Simon on 1/31/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "CustomActionSheetViewController.h"
#import "NSString+AllowCharactersInSet.h"
#import "PRCardData.h"
#import "PRCreditCardValidator.h"
#import "PRDatabase.h"
#import "PaymentCardPicker.h"
#import "SelectCardViewController.h"
#import "Utils.h"
#import "WebViewController.h"
#import "PRTaskDocumentManager.h"

static NSString* const kPrimeBaseURL = @"cityguide.primeconcept.co.uk";

/**
 *  Payment gateways.
 */
typedef NS_ENUM(NSInteger, PaymentGateway) {
    PaymentGateway_Unknown,
    PaymentGateway_Ruru,
    PaymentGateway_Sberbank,
    PaymentGateway_Alfabank,
    PaymentGateway_Rsb,
    PaymentGateway_SbKnhd
};

@interface WebViewController () {
    BOOL _isAuthenticated;
    NSUInteger _selectedCardIndex;
    BOOL _isPaymentFormFound;
    BOOL _needToLayoutSubviews;
}

@property (nonatomic, strong) NSString* mime;
@property (nonatomic, strong) NSURLConnection* urlConnection;
@property (nonatomic, strong) NSMutableURLRequest* request;
@property (nonatomic, strong) UIScrollView* webScrollView;
@property (nonatomic, strong) SSPullToRefreshView* pullToRefreshView;
@end

@implementation WebViewController

static NSString* kinohodWidgetURL = @"http://kinohod.ru/widget/";
static const NSInteger kStatusBarHeight = 20;
static const NSInteger kTabBarHeight = 49;

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _needToLayoutSubviews = YES;

    [self prepareNavigationLeftButton];
    [self initializeWebView];

    if (!_hideProgressHUD) {
        [MBProgressHUD showHUDAddedTo:_webView
                             animated:YES];
    }

    [self loadWebView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!_isPaymentFormFound) {
        return;
    }
    NSArray<PRCardData*>* cards = [NSMutableArray objectFromKeychainWithKey:kCardDataKeyPath
                                                                   forClass:PRCardData.class];
    NSInteger cards_count = [cards count];
    if (cards_count) {
        [self prepareNavigationRightButton];
        return;
    }
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    if (_needToLayoutSubviews) {
        [_webView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
        [_webView autoPinEdgeToSuperviewSafeArea:ALEdgeTop withInset:0 relation:NSLayoutRelationEqual];
        _needToLayoutSubviews = NO;
    }
}

- (BOOL)shouldHideNavigationBar
{
    return ![self isNavigationBarNeeded];
}

- (void)initializeWebView
{
    if (!_webView) {
        _webView = [WKWebView newAutoLayoutView];
        _webView.frame = CGRectMake(0, kStatusBarHeight, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - (kStatusBarHeight + kTabBarHeight));

        [self.view addSubview:_webView];
    }
}

#pragma mark - Actions

- (void)initPullToRefresh
{
    for (UIView* subView in _webView.subviews) {
        if (![subView isKindOfClass:[UIScrollView class]]) {
            continue;
        }
        _webScrollView = (UIScrollView*)subView;
        _webScrollView.delegate = self;
    }

    _pullToRefreshView = [[SSPullToRefreshView alloc] initWithScrollView:_webScrollView
                                                                delegate:self];
}

- (void)setUrl:(NSString*)url
{
    _url = url;

    if (![self isViewLoaded]) {
        return;
    }

    if (![MBProgressHUD HUDForView:_webView] && !_hideProgressHUD) {
        [MBProgressHUD showHUDAddedTo:_webView
                             animated:YES];
    }
    [self loadWebView];
}

- (void)loadWebView
{
    if (!_url || [_url isEqualToString:@""]) {
        return;
    }
    _webView.navigationDelegate = self;
    _webView.scrollView.delegate = self;
    _webView.UIDelegate = self;

    // Check if local files under the documents directory are going to be loaded on the webview or web pages.
    if ([self isUrlFromDocumentsDirectory]) {

        /*
         If webview responds to selector loadFileURL:allowingReadAccessToURL: then open using this method.
         Note, that this method is available iOS9.0 and later. For below iOS9.0 file under documents directory
         will be copied to temp directory (it is accessible for reading) and the copied file will be loaded on the webview.
         */
        NSURL* fileURL = [NSURL fileURLWithPath:_url];

        if ([_webView respondsToSelector:@selector(loadFileURL:allowingReadAccessToURL:)]) {
            [_webView loadFileURL:fileURL allowingReadAccessToURL:fileURL];
        } else {
            fileURL = [NSURL fileURLWithPath:[PRTaskDocumentManager getTempFileUrlFromUrl:_url]];
            _request = [NSMutableURLRequest requestWithURL:fileURL];
            [_webView loadRequest:_request];
        }

        return;
    }

    _request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_url]
                                       cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                   timeoutInterval:30.0f];

    [_request setHTTPShouldHandleCookies:YES];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    [_request setAllHTTPHeaderFields:[NSHTTPCookie requestHeaderFieldsWithCookies:[NSHTTPCookieStorage sharedHTTPCookieStorage].cookies]];

    [_webView loadRequest:_request];
}

- (BOOL)isUrlFromDocumentsDirectory
{
    return [_url hasPrefix:@"/var/"] || [_url hasPrefix:@"/Users/"];
}

- (void)scrollViewWillBeginZooming:(UIScrollView*)scrollView withView:(nullable UIView*)view
{
    if (![self isDisplayingPDF]) {
        scrollView.maximumZoomScale = 1;
    }
}

- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView*)view
{
    [_pullToRefreshView startLoading];
    [self loadWebView];
}

#pragma mark - Button Action

- (void)goBack:(id)sender
{
    if ([_webView canGoBack]) {
        [_webView goBack];
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kRestoreCurrentShakeIndex object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Webview delegate

- (void)webView:(WKWebView*)webView didFinishNavigation:(WKNavigation*)navigation
{
    if ([self isNavigationBarNeeded]) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }

    if ([MBProgressHUD HUDForView:_webView]) {
        [MBProgressHUD hideHUDForView:_webView
                             animated:YES];
    }
    [_pullToRefreshView finishLoading];

    if (webView.isLoading) {
        return;
    }

    _isAuthenticated = NO;

    if ([webView.URL.absoluteString containsString:kinohodWidgetURL]) {
        [self initJavaScriptWithFileName:@"kinohod"
                               withBlock:^(id _Nullable result, NSError* _Nullable error) {
                                   if (!error) {
                                       [_webView evaluateJavaScript:@"document.getElementById(\"email\")!==null"
                                                  completionHandler:^(id result2, NSError* _Nullable error) {
                                                      if (!error) {
                                                          NSString* resultString = [NSString stringWithFormat:@"%@", result2];
                                                          NSString* email = [PRDatabase getUserProfile].email;
                                                          if (([resultString isEqualToString:@"true"] || [result2 integerValue] == 1) && email.length) {
                                                              [self setEmail:email];
                                                          }
                                                      }
                                                  }];
                                   }

                               }];
    }

    [self initJavaScriptWithFileName:@"payment"
                           withBlock:^(id _Nullable result, NSError* _Nullable error) {
                               if (!error) {
                                   if ([NSString stringWithFormat:@"%@", result]) {

                                       NSDictionary<NSString*, NSNumber*>* functionNameDictionary = @{
                                           @"isValidRuruForm()" : @(PaymentGateway_Ruru),
                                           @"isValidSberbankForm()" : @(PaymentGateway_Sberbank),
                                           @"isValidAlfabankForm()" : @(PaymentGateway_Alfabank),
                                           @"isValidRsbForm()" : @(PaymentGateway_Rsb),
                                           @"isValidSberbankKnhdForm()" : @(PaymentGateway_SbKnhd)
                                       };

                                       [functionNameDictionary enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL* _Nonnull stop) {
                                           [_webView evaluateJavaScript:key
                                                      completionHandler:^(id result, NSError* error) {
                                                          if (!error && result) {
                                                              NSString* resultString = [NSString stringWithFormat:@"%@", result];
                                                              if ([resultString isEqualToString:@"true"] || [result integerValue] == 1) {
                                                                  [self initJavaScriptForPaymentGatway:[obj integerValue]];
                                                              }
                                                          }
                                                      }];
                                       }];
                                   }

                                   if (!_isPaymentFormFound) {
                                       self.navigationItem.rightBarButtonItem = nil;
                                   }
                               }
                           }];
}

- (void)webView:(WKWebView*)webView decidePolicyForNavigationAction:(WKNavigationAction*)navigationAction
                    decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    if (![self isNavigationBarNeeded]) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    NSMutableURLRequest* nsRequest = [NSMutableURLRequest requestWithURL:webView.URL];

    NSString* url = [webView.URL absoluteString];
    NSLog(@"Did start loading: %@ auth:%d", url, _isAuthenticated);

    NSString* scheme = navigationAction.request.URL.scheme;
    if (![scheme isEqual:@"http"] && ![scheme isEqual:@"https"] && ![scheme isEqual:@"file"]) {
        if ([[UIApplication sharedApplication] canOpenURL:navigationAction.request.URL]) {
            [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }

    // Added to fix the blank issue in google.map.
    if ([url isEqualToString:@"about:blank"]) {
        return;
    }

    [_webView evaluateJavaScript:@"if (typeof formAction == 'function') {formAction();}"
               completionHandler:^(id result, NSError* error) {
                   if (!error && result) {
                       NSString* possibleAction = [webView.URL absoluteString];
                       NSString* formAction = [[NSURL URLWithString:[NSString stringWithFormat:@"%@", result] relativeToURL:webView.URL] absoluteString];
                       if (![possibleAction isEqualToString:formAction]) {
                           return;
                       }
                       if (navigationAction.navigationType == WKNavigationTypeFormSubmitted && _isPaymentFormFound) {
                           do {
                               __block NSString* cardNumber = nil;
                               [_webView evaluateJavaScript:@"cardNumber()"
                                          completionHandler:^(id result, NSError* error) {
                                              if (!error && result) {
                                                  cardNumber = [NSString stringWithFormat:@"%@", result];
                                                  CreditCardType creditCardType = [PRCreditCardValidator checkWithCardNumber:cardNumber];
                                                  if (creditCardType != CreditCardType_Mastercard && creditCardType != CreditCardType_Visa) {
                                                      return;
                                                  }
                                              }
                                          }];

                               [_webView evaluateJavaScript:@"expirationMonth() + '/' + expirationYear()"
                                          completionHandler:^(id result, NSError* error) {
                                              if (!error && result) {
                                                  NSString* resultString = [NSString stringWithFormat:@"%@", result];

                                                  NSString* dateString = resultString;

                                                  NSDate* date = [NSDate mt_dateFromString:dateString usingFormat:@"MM/yyyy"];

                                                  if (date == nil) {
                                                      return;
                                                  }

                                                  NSString* expDate = [date mt_stringFromDateWithFormat:@"MM/yy" localized:NO];

                                                  // Find in existing Payment Cards.

                                                  if ([PRCreditCardValidator isCardExist:cardNumber expDate:expDate]) {
                                                      return;
                                                  }

                                                  [PRMessageAlert showMessage:Message_SaveCardData
                                                                          yes:^{
                                                                              NSMutableArray<PRCardData*>* cards = [NSMutableArray objectFromKeychainWithKey:kCardDataKeyPath
                                                                                                                                                    forClass:PRCardData.class];
                                                                              PRCardData* cardData = [[PRCardData alloc] init];

                                                                              cardData.cardNumber = cardNumber;
                                                                              cardData.expDate = expDate;

                                                                              [cards addObject:cardData];

                                                                              [cards storeToKeychainWithKey:kCardDataKeyPath];

                                                                          }
                                                                           no:^{
                                                                           }];
                                              }
                                          }];
                           } while (NO);
                       }
                   }
               }];

    _request = nsRequest;

    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView*)webView didFailNavigation:(WKNavigation*)navigation withError:(NSError*)error
{

    if (_isAuthenticated) {
        return;
    }
    if (![[error domain] isEqualToString:NSURLErrorDomain]) {
        return;
    }
    switch ([error code]) {
    case NSURLErrorSecureConnectionFailed:
    case NSURLErrorServerCertificateHasBadDate:
    case NSURLErrorServerCertificateUntrusted:
    case NSURLErrorServerCertificateHasUnknownRoot:
    case NSURLErrorServerCertificateNotYetValid:
    case NSURLErrorClientCertificateRejected:
    case NSURLErrorClientCertificateRequired:
        NSLog(@"WebView did fail load with SSL error code:%ld", [error code]);
        break;
    default:
        NSLog(@"WebView did fail load with error code:%ld", [error code]);
        return;
    }
    _urlConnection = [[NSURLConnection alloc] initWithRequest:_request
                                                     delegate:self];

    [_urlConnection start];
}

- (WKWebView*)webView:(WKWebView*)webView createWebViewWithConfiguration:(WKWebViewConfiguration*)configuration forNavigationAction:(WKNavigationAction*)navigationAction windowFeatures:(WKWindowFeatures*)windowFeatures
{
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }

    return nil;
}

#pragma mark - NURLConnection delegate

- (void)connection:(NSURLConnection*)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge*)challenge;
{
    NSLog(@"WebController Got auth challange via NSURLConnection");

    if ([challenge previousFailureCount] != 0) {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
        return;
    }
    _isAuthenticated = YES;

    NSURLCredential* credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];

    [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
}

- (void)webView:(WKWebView*)webView decidePolicyForNavigationResponse:(WKNavigationResponse*)navigationResponse
                      decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{

    _mime = [navigationResponse.response MIMEType];

    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse *)navigationResponse.response;
    NSArray* cookies = [ NSHTTPCookie cookiesWithResponseHeaderFields:[ httpResponse allHeaderFields ] forURL:[NSURL fileURLWithPath:_url]];
    [[ NSHTTPCookieStorage sharedHTTPCookieStorage ] setCookies: cookies forURL: [NSURL fileURLWithPath:_url] mainDocumentURL: nil ];

    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (BOOL)isDisplayingPDF
{
    NSString* extension = [[_mime substringFromIndex:([_mime length] - 3)] lowercaseString];

    return ([[[_webView.URL pathExtension] lowercaseString] isEqualToString:@"pdf"] || [extension isEqualToString:@"pdf"]);
}

// We use this method is to accept an untrusted site which unfortunately we need to do, as our PVM servers are self signed.
- (BOOL)connection:(NSURLConnection*)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace*)protectionSpace
{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

#pragma mark - Java Script

- (void)initJavaScriptWithFileName:(NSString*)fileName withBlock:(void (^__nullable)(__nullable id, NSError* __nullable error))completionHandler
{

    NSString* path = [[NSBundle mainBundle] pathForResource:fileName
                                                     ofType:@"js"];

    if (!path.length) {
        return;
    }

    NSError* error = nil;
    NSString* script = [NSString stringWithContentsOfFile:path
                                                 encoding:NSUTF8StringEncoding
                                                    error:&error];

    if (error && !script.length) {
        return;
    }

    [_webView evaluateJavaScript:script
               completionHandler:^(id result, NSError* error) {

                   completionHandler(result, error);

               }];
}

- (void)initJavaScriptForPaymentGatway:(PaymentGateway)paymentGateway
{
    NSString* paymentGatewayStr = nil;
    switch (paymentGateway) {
    case PaymentGateway_Ruru:
        paymentGatewayStr = @"ruru";
        break;
    case PaymentGateway_Sberbank:
        paymentGatewayStr = @"sberbank";
        break;
    case PaymentGateway_Alfabank:
        paymentGatewayStr = @"alfabank";
        break;
    case PaymentGateway_Rsb:
        paymentGatewayStr = @"rsb";
        break;
    case PaymentGateway_SbKnhd:
        paymentGatewayStr = @"kinohod";
        break;
    default:
        break;
    }
    if (!paymentGatewayStr) {
        return;
    }
    [self initJavaScriptWithFileName:paymentGatewayStr
                           withBlock:^(id _Nullable result, NSError* _Nullable error) {
                               [self autofillPaymentCardDataIfNeeded];
                           }];
}

- (void)selectCardFromCards:(NSArray<PRCardData*>*)cards
{
    PaymentCardPicker* picker = [[PaymentCardPicker alloc] init];
    picker.delegate = self;

    PaymentCardPickerItems* items = [[PaymentCardPickerItems alloc] init];

    for (PRCardData* card in cards) {
        NSString* cardNumber = [PRCreditCardValidator getLongHiddenCardNumber:card.cardNumber];
        NSString* expDate = card.expDate;

        NSString* text = [NSString stringWithFormat:@"%@ %@", cardNumber, expDate];
        UIImage* image = [Utils getImageForCardNumber:card.cardNumber];

        [items addItemWithText:text image:image];
    }

    [picker setItems:items];

    _selectedCardIndex = 0;
    [picker setSelectedCardIndex:_selectedCardIndex animated:YES];

    CustomActionSheetViewController* paymentCardPickerSheet = [[CustomActionSheetViewController alloc] init];
    paymentCardPickerSheet.delegate = self;
    paymentCardPickerSheet.picker = picker;

    [paymentCardPickerSheet show];
}

- (void)paymentCardPicker:(PaymentCardPicker*)picker didSelectCardWithIndex:(NSInteger)index
{
    _selectedCardIndex = index;
}

- (void)selectionViewControllerDidDoneFor:(CustomActionSheetViewController*)sheet
{
    NSArray<PRCardData*>* cards = [NSMutableArray objectFromKeychainWithKey:kCardDataKeyPath
                                                                   forClass:PRCardData.class];

    if (_selectedCardIndex < [cards count]) {
        [self autofillPaymentCardData:cards[_selectedCardIndex]];
    }
}

- (void)autofillPaymentCardData:(PRCardData*)card
{
    [self setCardNumber:[card cardNumber]];

    NSDate* expDate = [PRCreditCardValidator getExpDateFromString:[card expDate]];

    [self setExpirationYear:[expDate mt_stringFromDateWithFormat:@"20yy"
                                                       localized:NO]];
    [self setExpirationMonth:[expDate mt_stringFromDateWithFormat:@"MM"
                                                        localized:NO]];

    [self focusCVVField];
}

- (void)autofillPaymentCardDataIfNeeded
{
    NSArray<PRCardData*>* cards = [NSMutableArray objectFromKeychainWithKey:kCardDataKeyPath
                                                                   forClass:PRCardData.class];

    NSInteger cards_count = [cards count];
    if (!cards_count) {
        self.navigationItem.rightBarButtonItem = nil;
        return;
    }

    if (cards_count == 1) {
        [self autofillPaymentCardData:cards[0]];
    } else {
        [self selectCardFromCards:cards];
    }

    [self prepareNavigationRightButton];
}

- (void)showCards
{
    NSArray<PRCardData*>* cards = [NSMutableArray objectFromKeychainWithKey:kCardDataKeyPath
                                                                   forClass:PRCardData.class];

    NSInteger cards_count = [cards count];

    if (cards_count != 1) {
        [self selectCardFromCards:cards];
        return;
    }
    [PRMessageAlert showMessage:Message_AutofillCardData
                            yes:^{
                                [self autofillPaymentCardData:cards[0]];
                            }
                             no:^{
                             }];
}

#pragma mark - Navigation Bar

- (BOOL)isNavigationBarNeeded
{
    NSString* url = nil;
    if (_webView) {
        url = _webView.URL.absoluteString;
    } else if (self.url) {
        url = self.url;
    } else {
        return NO;
    }
    if ([url containsString:kPrimeBaseURL]) {
        return NO;
    } else if ([url containsString:[kCityGuideBaseUrl substringFromIndex:8]]) {
        return NO;
    }
    return YES;
}

- (void)prepareNavigationRightButton
{
    UIImage* imageSettings = [UIImage imageNamed:@"menu"];
    CGRect frame = CGRectMake(0, 0, imageSettings.size.width, imageSettings.size.height);

    UIButton* buttonSettings = [[UIButton alloc] initWithFrame:frame];
    [buttonSettings setBackgroundImage:imageSettings
                              forState:UIControlStateNormal];
    [buttonSettings setShowsTouchWhenHighlighted:NO];

    [buttonSettings addTarget:self
                       action:@selector(showCards)
             forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* barButtonItemSettings = [[UIBarButtonItem alloc] initWithCustomView:buttonSettings];

    self.navigationItem.rightBarButtonItem = barButtonItemSettings;
}

- (void)prepareNavigationLeftButton
{
    UIButton* backButtonInternal = [UIButton buttonWithType:UIButtonTypeSystem];
    backButtonInternal.backgroundColor = [UIColor clearColor];
    UIImage* backImageWithColor = [[UIImage imageNamed:@"topbar_btn_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [backButtonInternal setImage:backImageWithColor forState:UIControlStateNormal];
    [backButtonInternal setTitle:NSLocalizedString(@"Back", nil) forState:UIControlStateNormal];
#if defined (PrivateBankingPRIMEClub)
    [self.navigationController.navigationBar setBarTintColor:kTabBarBackgroundColor];
#endif
    [backButtonInternal setTitleColor:kNavigationBarTintColor forState:UIControlStateNormal];
    [backButtonInternal addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];

    backButtonInternal.titleLabel.font = [UIFont systemFontOfSize:17.0]; // 17 is font size of native back button title
    [backButtonInternal setTitleEdgeInsets:UIEdgeInsetsMake(1.0, -2.5, 0.0, 0.0)]; // Magic number gives right result
    [backButtonInternal setImageEdgeInsets:UIEdgeInsetsMake(0.0, -15.0, -1.0, 0.0)];
    [backButtonInternal sizeToFit];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonInternal];
}

#pragma mark JavaScript calls for fields

- (void)setCardNumber:(NSString*)cardNumber
{

    NSCharacterSet* numbers = [NSCharacterSet
        characterSetWithCharactersInString:@"0123456789"];

    NSString* numericCardNumber = [cardNumber stringByAllowingOnlyCharactersInSet:numbers];

    [_webView evaluateJavaScript:[NSString stringWithFormat:@"setCardNumber('%@')", numericCardNumber]
               completionHandler:^(id result, NSError* error){

               }];
}

- (void)setHolderName:(NSString*)holderName
{

    [_webView evaluateJavaScript:[NSString stringWithFormat:@"setHolderName('%@')", holderName]
               completionHandler:^(id result, NSError* error){

               }];
}

- (void)setEmail:(NSString*)email
{
    [_webView evaluateJavaScript:[NSString stringWithFormat:@"setEmail('%@')", email]
               completionHandler:^(id result, NSError* error){

               }];
}

- (void)setExpirationYear:(NSString*)expirationYear
{
    [_webView evaluateJavaScript:[NSString stringWithFormat:@"setExpirationYear('%@')", expirationYear]
               completionHandler:^(id result, NSError* error){
               }];
}

- (void)setExpirationMonth:(NSString*)expirationMonth
{

    [_webView evaluateJavaScript:[NSString stringWithFormat:@"setExpirationMonth('%@')", expirationMonth]
               completionHandler:^(id result, NSError* error){
               }];
}

- (void)focusCVVField
{

    NSString* jscode = @"document.getElementsByName('cvc_mko')[0].focus();";

    [_webView evaluateJavaScript:jscode
               completionHandler:^(id result, NSError* error){
               }];
}

#pragma mark - Dealloc

- (void)dealloc
{
    _webView.scrollView.delegate = nil;
}

@end
