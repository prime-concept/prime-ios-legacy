//
//  PhotoPreSendViewController.m
//  PRIME
//
//  Created by armens on 4/16/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import "PhotoPreSendViewController.h"
#import "PRMessageProcessingManager.h"
#import "Constants.h"
#import "InformationAlertController.h"

@interface PhotoPreSendViewController ()

@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *backToGaleryButton;
@property (weak, nonatomic) IBOutlet UIView *sendingView;
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@end

@implementation PhotoPreSendViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [_sendButton setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];
    [_backToGaleryButton setTitle:NSLocalizedString(@"Back", nil) forState:UIControlStateNormal];
    [_statusLabel setText:NSLocalizedString(@"Sending", nil)];
    [_loadingIndicator stopAnimating];
    [_photoBackground setHidden:YES];
    [_previewPhotoView setImage:_selectedPhoto];
    if(_picker.sourceType == UIImagePickerControllerSourceTypeCamera || _isVideoMode)
    {
        [_previewView setHidden:YES];
        [_sendingView setHidden:NO];
        [self.view setBackgroundColor:[UIColor clearColor]];
    }
    else
    {
        [_previewView setHidden:NO];
        [_sendingView setHidden:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGSize imageSize = [_previewPhotoView.image size];
    UIImage* background = [UIImage imageNamed:@"transparencyBackground"];
    CGSize backgroundRawSize = [background size];
    CGFloat scale = MAX(imageSize.width/backgroundRawSize.width, imageSize.height/backgroundRawSize.width);
    CGFloat scaledWidth = backgroundRawSize.width * scale;
    CGFloat scaledHeight = backgroundRawSize.height * scale;

    CGRect backgroundRect = CGRectMake(0.f, 0.f, scaledWidth, scaledHeight);
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(scaledWidth, scaledHeight), NO, 0);
    [background drawInRect:backgroundRect];
    UIImage *scaledBackground = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGRect cropRect = CGRectMake(0.f, 0.f, imageSize.width, imageSize.height);
    CGImageRef imageRef = CGImageCreateWithImageInRect([scaledBackground CGImage], cropRect);
    UIImage *croppedBackground = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);

    [_photoBackground setImage:croppedBackground];
    [_photoBackground setHidden:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [_photoBackground setHidden:YES];
    [super viewDidDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if(_picker.sourceType == UIImagePickerControllerSourceTypeCamera || _isVideoMode)
    {
        [self sendAcion:self];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (IBAction)sendAcion:(id)sender
{
    if ([PRRequestManager connectionRequired] && [PRDatabase isUserProfileFeatureEnabled:ProfileFeature_SMS_Messages]) {
        [InformationAlertController presentAlert:self
                                      alertTitle:NSLocalizedString(@"No connection to the Internet", nil)
                                         message:@""
                                        okAction:^{
                                            [self dismissModalViewControllerAnimated:NO];
                                            [_picker dismissViewControllerAnimated:NO completion:nil];
                                        }];
        return;
    }
    [_sendingView setHidden:NO];
    [_loadingIndicator startAnimating];

    NSData* uploadData = nil;
    NSString* messageType = nil;
    NSString* mimeType = nil;
    if(_isVideoMode)
    {
        uploadData = [NSData dataWithContentsOfURL:_selectedVideoURL options:NSDataReadingMappedIfSafe error:nil];
        messageType = kMessageType_Video;
        mimeType = kVideoMessageMimeType;
    }
    else
    {
        uploadData = UIImageJPEGRepresentation(_previewPhotoView.image, 1.0);
        messageType = kMessageType_Image;
        mimeType = kPhotoMessageMimeType;
    }

    __weak PhotoPreSendViewController* weakSelf = self;
    PRMessageModel* messageModel = [PRMessageProcessingManager sendMediaMessage:uploadData
                                                                       mimeType:mimeType
                                                                    messageType:messageType
                                                                toChannelWithID:[_chatViewController currentChatIdWithPrefix]
                                                                        success:^(PRMediaMessageModel *mediaMessageModel) {
        PhotoPreSendViewController* strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        [strongSelf setSentStatus];
        [strongSelf dismissModalViewControllerAnimated:NO];
        [strongSelf.picker dismissViewControllerAnimated:NO completion:nil];
    } failure:^(NSInteger statusCode, NSError *error) {
        PhotoPreSendViewController* strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        [strongSelf setFailureStatus];
        [strongSelf dismissModalViewControllerAnimated:NO];
        [strongSelf.picker dismissViewControllerAnimated:NO completion:nil];
    }];
    messageModel = [messageModel MR_inThreadContext];
    [_chatViewController.messages addObject:messageModel];
}

- (IBAction)backToGaleryAction:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)setSentStatus {
    [_statusLabel setText:NSLocalizedString(@"Sent", nil)];
    [_loadingIndicator stopAnimating];
}

- (void)setFailureStatus {
    [_statusLabel setText:NSLocalizedString(@"Sending fail", nil)];
    [_loadingIndicator stopAnimating];
}

@end
