//
//  VideoPlayer.m
//  PRIME
//
//  Created by Armen on 6/11/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import "VideoPlayer.h"
#import "PRMessageProcessingManager.h"
#import "PRAudioPlayer.h"
#import "InformationAlertController.h"
#import "ImageProcessing.h"
@import AVKit;

@interface VideoPlayer ()

@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *videoLoadingIndicator;

@property (strong, nonatomic) AVPlayerViewController *playerViewController;
@property(strong, nonatomic) NSString* filePath;
@property(strong, nonatomic) NSString* localFileName;

@end

@implementation VideoPlayer

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem* shareButton = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                    target:self
                                    action:@selector(shareAction)];
    self.navigationItem.rightBarButtonItem = shareButton;
    _playerViewController = [AVPlayerViewController new];
    if( [[NSFileManager defaultManager] fileExistsAtPath:_filePath])
    {
        [_videoLoadingIndicator stopAnimating];
        [_previewImageView setHidden:YES];
        AVPlayer *player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:_filePath]];
        _playerViewController.player = player;
        [[_playerViewController player] play];
        [self.view addSubview:_playerViewController.view];
    }
    else
    {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
        [_previewImageView setImage:_previewImage];
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
    [_playerViewController.view setFrame:CGRectMake(0, topOffset, self.view.bounds.size.width, self.view.bounds.size.height - topOffset)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if(![[NSFileManager defaultManager] fileExistsAtPath:_filePath])
    {
        __weak VideoPlayer* weakSelf = self;
        [PRMessageProcessingManager getMediaFileFromPath:_videoDownloadingPath
                                                 success:^(NSData* mediaFile) {
                                                     VideoPlayer* strongSelf = weakSelf;
                                                     if(!strongSelf)
                                                     {
                                                         return;
                                                     }
                                                     [PRAudioPlayer saveAudioDataInFile:mediaFile withIdentifier:strongSelf.localFileName];
                                                     if(![strongSelf.previewImageView image])
                                                     {
                                                         UIImage *previewImage = [ImageProcessing previewFromVideoWithFilePath:strongSelf.filePath];
                                                         UIImage *minImage = [ImageProcessing miniImageFromOriginal:previewImage sideMaxSize:200];
                                                         [PRAudioPlayer saveAudioDataInFile:UIImageJPEGRepresentation(minImage, 0.5) withIdentifier:[strongSelf.localFileName stringByReplacingOccurrencesOfString:@".mp4" withString:@"_min"]];
                                                     }
                                                     [strongSelf.videoLoadingIndicator stopAnimating];
                                                     [strongSelf.previewImageView setHidden:YES];
                                                     AVPlayer *player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:strongSelf.filePath]];
                                                     strongSelf.playerViewController.player = player;
                                                     [[strongSelf.playerViewController player] play];
                                                     [strongSelf.view addSubview:strongSelf.playerViewController.view];
                                                     [strongSelf.navigationItem.rightBarButtonItem setEnabled:YES];
                                                 }
                                                 failure:^(NSInteger statusCode, NSError* error){
                                                     VideoPlayer* strongSelf = weakSelf;
                                                     if(!strongSelf)
                                                     {
                                                         return;
                                                     }
                                                     [strongSelf.videoLoadingIndicator stopAnimating];
                                                     [InformationAlertController presentAlert:strongSelf
                                                                                   alertTitle:NSLocalizedString(@"Download video failed", nil)
                                                                                      message:@""
                                                                                     okAction:nil];
                                                 }];
    }
}

- (void)setFilePathWithGuid:(NSString*)guid
{
    _localFileName = [NSString stringWithFormat:@"%@.mp4",  guid];
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
