//
//  PRChatVideoMessageViewCell.m
//  PRIME
//
//  Created by Armen on 6/7/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import "PRChatVideoMessageViewCell.h"

@interface PRChatVideoMessageViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *videoPreviewImageView;
@property (weak, nonatomic) IBOutlet UIImageView *defaultVideoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *videoIconImageView;

@end

static NSString* const kReceivedVideoMessageCellIdentifier = @"PRChatReceiveVideoMessageViewCell";

@implementation PRChatVideoMessageViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setUpBalloonImageView];
}

- (void)setUpBalloonImageView
{
    NSString* balloonImageName = @"ModernBubbleOutgoingFull";
    UIColor* balloonImageTintColor = kChatBalloonImageViewColor;
    UIColor* timeLabelTextColor = kChatRightTimeLabelTextColor;

    if ([self.reuseIdentifier isEqualToString:kReceivedVideoMessageCellIdentifier]) {
        balloonImageName = @"ModernBubbleIncomingFull";
        balloonImageTintColor = kChatLeftBalloonImageViewColor;
        timeLabelTextColor = kChatLeftTimeLabelTextColor;
    }
    [self.balloonImageView setImage:[UIImage imageNamed:balloonImageName]];
    [self.balloonImageView setTintColor:balloonImageTintColor];
    [_videoIconImageView setHidden:YES];
    [_defaultVideoImageView setTintColor:timeLabelTextColor];
}

- (UIImage*)getMessageImage
{
    return _videoPreviewImageView.image;
}

- (void)setMessageImageWithPath:(NSString*)messageImagePath
{
    [_defaultVideoImageView setHidden:NO];
    NSURL* directory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                               inDomains:NSUserDomainMask] lastObject];
    NSString* docDirPath = [directory path];
    NSString* filePath = [NSString stringWithFormat:@"%@/%@_min", docDirPath, messageImagePath];

    UIImage* image = [UIImage imageNamed:filePath];
    _hasImage = NO;
    if(image)
    {
        _hasImage = YES;
        [_defaultVideoImageView setHidden:YES];
        [_videoIconImageView setHidden:NO];
    }
    else
    {
        [_videoIconImageView setHidden:YES];
    }
    [_videoPreviewImageView setImage:image];
}

@end
