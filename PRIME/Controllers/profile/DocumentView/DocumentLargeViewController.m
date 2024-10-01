//
//  DocumentLargeViewController.m
//  PRIME
//
//  Created by Admin on 6/5/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "DocumentLargeViewController.h"
#import "PRMessageProcessingManager.h"
#import "PRAudioPlayer.h"
#import "InformationAlertController.h"

@interface DocumentLargeViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *imageLoadingView;

@end

@implementation DocumentLargeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _imageView.image = _image;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;

    _scrollView.minimumZoomScale = 1.0;
    _scrollView.maximumZoomScale = 6.0;

    UIBarButtonItem* shareButton = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                             target:self
                             action:@selector(shareAction)];
    self.navigationItem.rightBarButtonItem = shareButton;
    if(_model)
    {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    }
    else
    {
        [_imageLoadingView stopAnimating];
    }
#ifdef Platinum
    [self.navigationController.navigationBar setTintColor:kNavigationBarTintColor];
#else
//    [self.navigationController.navigationBar setTintColor:kIconsColor];
#endif
}

- (void)shareAction
{
    UIActivityViewController* activityController = [[UIActivityViewController alloc] initWithActivityItems:@[ _image ] applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(!_model)
    {
        return;
    }
    [_imageLoadingView startAnimating];
    __weak DocumentLargeViewController* weakSelf = self;
    [PRMessageProcessingManager getMediaFileFromPath:_model.text
                                             success:^(NSData* mediaFile) {
                                                 DocumentLargeViewController* strongSelf = weakSelf;
                                                 [PRAudioPlayer saveAudioDataInFile:mediaFile withIdentifier:_model.guid];
                                                 if(!strongSelf)
                                                 {
                                                     return;
                                                 }
                                                 [strongSelf.imageLoadingView stopAnimating];
                                                 [strongSelf setImage:[UIImage imageWithData:mediaFile]];
                                                 [strongSelf.imageView setImage:[UIImage imageWithData:mediaFile]];
                                                 [strongSelf.navigationItem.rightBarButtonItem setEnabled:YES];
                                             }
                                             failure:^(NSInteger statusCode, NSError* error){
                                                 DocumentLargeViewController* strongSelf = weakSelf;
                                                 if(!strongSelf)
                                                 {
                                                     return;
                                                 }
                                                 [strongSelf.imageLoadingView stopAnimating];
                                                 [InformationAlertController presentAlert:strongSelf
                                                                               alertTitle:NSLocalizedString(@"Download photo failed", nil)
                                                                                  message:@""
                                                                                 okAction:nil];
                                             }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (self.isMovingFromParentViewController) {
        //        [UIView animateWithDuration:0.3 animations:^{
        //            _imageView.alpha = 0.0;
        //        } completion:^(BOOL finished) {
        //            _imageView.hidden = YES;
        //        }];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

@end
