//
//  UploadViewController.m
//  PRIME
//
//  Created by Armen on 6/14/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import "UploadViewController.h"
#import "PRMessageProcessingManager.h"
#import "Constants.h"

@interface UploadViewController ()
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;

@property (assign, nonatomic) NSInteger progressValue;

@end

@implementation UploadViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getProgress:) name:kSendUUIDKey object:nil];
    _progressValue = 0;

    [_statusLabel setText:NSLocalizedString(@"Sending", nil)];
    [_progressLabel setText:[NSString stringWithFormat:@"%ld%%", (long)_progressValue]];
}

- (void)setSentStatus {
    [_progressLabel setText:@""];
    [_statusLabel setText:NSLocalizedString(@"Sent", nil)];
}

- (void)setFailureStatus {
    [_progressLabel setText:@""];
    [_statusLabel setText:NSLocalizedString(@"Sending fail", nil)];
}

- (void)getProgress:(NSNotification*)notification
{
    if([notification.name isEqualToString:kSendUUIDKey])
    {
        NSString* uuid = (NSString*)notification.userInfo[@"uuid"];
        [NSTimer scheduledTimerWithTimeInterval:0.2
                                         target:self
                                       selector:@selector(onTick:)
                                       userInfo:uuid repeats:YES];
    }
}

- (void)onTick:(NSTimer *)timer {
    [PRMessageProcessingManager getMediaUploadProgress:[timer userInfo] currentPercent:^(NSNumber *percent) {
        if(percent.integerValue >= 0)
        {
            [self setProgressValue:percent.integerValue];
        }
        else
        {
            [self setFailureStatus];
            [timer invalidate];
            [self dismissModalViewControllerAnimated:NO];
            [_presenter dismissViewControllerAnimated:NO completion:nil];
        }
        if(percent.integerValue == 100)
        {
            [self setSentStatus];
            [timer invalidate];
            [self dismissModalViewControllerAnimated:NO];
            [_presenter dismissViewControllerAnimated:NO completion:nil];
        }
    }];
}

- (void)setProgressValue:(NSInteger)value {
    if(value != _progressValue)
    {
        [_progressLabel setText:[NSString stringWithFormat:@"%ld%%", (long)_progressValue]];
        _progressValue = value;
    }
}

@end
