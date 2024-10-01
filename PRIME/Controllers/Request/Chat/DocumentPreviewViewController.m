//
//  DocumentPreviewViewController.m
//  PRIME
//
//  Created by Armen on 6/13/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import "DocumentPreviewViewController.h"
#import "PRMessageProcessingManager.h"
#import "UploadViewController.h"
#import "PRAudioPlayer.h"
#import "InformationAlertController.h"
@import WebKit;

@interface DocumentPreviewViewController ()<WKNavigationDelegate>

@property (strong, nonatomic) WKWebView *webView;
@property (strong, nonatomic) UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property (strong, nonatomic) NSString *localFileName;
@property(strong, nonatomic) NSString* filePath;

@end

@implementation DocumentPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [_cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [_sendButton setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];

    _webView = [WKWebView new];
    _loadingIndicator = [UIActivityIndicatorView new];
    [_loadingIndicator setCenter:self.view.center];
    [_loadingIndicator setHidesWhenStopped:YES];
    [_loadingIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [_webView setNavigationDelegate:self];
    if(!_isSendingMode)
    {
        [_cancelButton setHidden:YES];
        [_sendButton setHidden:YES];
        UIBarButtonItem* shareButton = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                        target:self
                                        action:@selector(shareAction)];
        self.navigationItem.rightBarButtonItem = shareButton;
    }
    [self.view addSubview:_webView];
    [self.view addSubview:_loadingIndicator];

    if(_fileURL)
    {
        [_webView loadFileURL:_fileURL allowingReadAccessToURL:_fileURL];
    }
    else
    {
        if([[NSFileManager defaultManager] fileExistsAtPath:_filePath])
        {
            NSURL *url = [NSURL fileURLWithPath:_filePath];
            [_webView loadFileURL:url allowingReadAccessToURL:url];
        }
        else
        {
            [self.navigationItem.rightBarButtonItem setEnabled:NO];
            [_loadingIndicator startAnimating];
        }
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    CGFloat topOffset;
    if (@available(iOS 11.0, *))
    {
        topOffset = self.view.safeAreaInsets.top;
    }
    else
    {
        topOffset = self.topLayoutGuide.length;
    }

    if(_isSendingMode)
    {
		CGFloat buttonsTop = self.cancelButton.frame.origin.y;

        [_webView setFrame:CGRectMake(0, topOffset, self.view.bounds.size.width, buttonsTop - 4 - topOffset)];
    }
    else
    {
        [_webView setFrame:CGRectMake(0, topOffset, self.view.bounds.size.width, self.view.bounds.size.height - topOffset)];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(![[NSFileManager defaultManager] fileExistsAtPath:_filePath])
    {
        __weak DocumentPreviewViewController* weakSelf = self;
        [PRMessageProcessingManager getMediaFileFromPath:_documentDownloadingPath
                                                 success:^(NSData* mediaFile) {
                                                     DocumentPreviewViewController* strongSelf = weakSelf;
                                                     [PRAudioPlayer saveAudioDataInFile:mediaFile withIdentifier:_localFileName];
                                                     if(!strongSelf)
                                                     {
                                                         return;
                                                     }
                                                     [strongSelf.loadingIndicator stopAnimating];
                                                     NSURL *url = [NSURL fileURLWithPath:_filePath];
                                                     [strongSelf.webView loadFileURL:url allowingReadAccessToURL:url];
                                                     [strongSelf.navigationItem.rightBarButtonItem setEnabled:YES];
                                                 }
                                                 failure:^(NSInteger statusCode, NSError* error){
                                                     DocumentPreviewViewController* strongSelf = weakSelf;
                                                     if(!strongSelf)
                                                     {
                                                         return;
                                                     }
                                                     [InformationAlertController presentAlert:strongSelf
                                                                                   alertTitle:NSLocalizedString(@"Download document failed", nil)
                                                                                      message:@""
                                                                                     okAction:nil];
                                                 }];
    }
}

- (IBAction)cancelAction:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)sendAction:(id)sender
{
    if(_chatViewControllerProtocolResponder && [_chatViewControllerProtocolResponder respondsToSelector:@selector(currentChatIdWithPrefix)] && [_chatViewControllerProtocolResponder respondsToSelector:@selector(addMessage:)])
    {
        UploadViewController *uploadViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"UploadViewController"];
        [uploadViewController setPresenter:self];
        uploadViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:uploadViewController animated:NO completion:nil];

        NSData *uploadData = [NSData dataWithContentsOfURL:_fileURL options:NSDataReadingMappedIfSafe error:nil];
        NSString *fileName = [_fileURL lastPathComponent];
        PRMessageModel* messageModel = [PRMessageProcessingManager sendMediaMessage:uploadData
                                                                           mimeType:fileName
                                                                        messageType:kMessageType_Document
                                                                    toChannelWithID:[_chatViewControllerProtocolResponder currentChatIdWithPrefix]
                                                                            success:^(PRMediaMessageModel *mediaMessageModel) {}
                                                                            failure:^(NSInteger statusCode, NSError *error) {}];
        messageModel = [messageModel MR_inThreadContext];
        [_chatViewControllerProtocolResponder addMessage:messageModel];
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSString *message = NSLocalizedString(@"Unsupported file", nil);
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"DocImage" ofType:@"png"];
    imagePath = [[NSURL fileURLWithPath:imagePath] absoluteString];
    NSString *htmlString1 = @"<style>\
    body {\
    width: 100%;\
    height: 100%;\
    margin: 0;\
    padding: 0;\
    display: flex;\
        justify-content:center;\
        align-items:center;\
    }\
    .block {\
    display: inline-block;\
        text-align: center;\
    }\
    img {\
    width: 80%;\
    }\
    .text {\
    display: flex;\
        justify-content:center;\
        align-items:center;\
    padding: 10px 5px;\
        font-size: 50px;\
    color: blue;\
    }\
    </style>\
    <div class='container'>\
    <div class='block'>";
    NSString *htmlString2 = [NSString stringWithFormat:@"%@<img src='%@'>\
    <div class='text'>%@</div>\
    </div>\
    </div>", htmlString1, imagePath, message];
    [_webView loadHTMLString:htmlString2 baseURL:[NSBundle mainBundle].resourceURL];
}

- (void)setFilePathWithGuid:(NSString*)guid fileName:(NSString*)fileName
{
    _localFileName = [NSString stringWithFormat:@"%@/%@", guid, fileName];
    NSURL* directory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                               inDomains:NSUserDomainMask] lastObject];
    NSString* docDirPath = [directory path];
    _filePath = [NSString stringWithFormat:@"%@/%@", docDirPath, _localFileName];
}

- (void)shareAction
{
    UIActivityViewController* activityController = [[UIActivityViewController alloc] initWithActivityItems:@[ [NSURL fileURLWithPath:_filePath] ] applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}

@end
