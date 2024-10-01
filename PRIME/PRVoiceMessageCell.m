//
//  PRVoiceMessageCell.m
//  PRIME
//
//  Created by Aram on 12/26/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRVoiceMessageCell.h"
#import "PRAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "PRMessageAlert.h"

typedef NS_ENUM(NSInteger, PRPlayPauseButtonState) {
    PRPlayPauseButtonState_Stopped,
    PRPlayPauseButtonState_Playing
};

@interface PRVoiceMessageCell ()
@property (weak, nonatomic) IBOutlet UIView* wrapperView;
@property (weak, nonatomic) IBOutlet UIButton* playPauseButton;
@property (weak, nonatomic) IBOutlet UILabel* durationLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* timeLabelRightConstraint;
@property (weak, nonatomic) IBOutlet UILabel* guidLabel;

@property (strong, nonatomic) NSString* audioFielName;
@property (strong, nonatomic) PRAudioPlayer* audioPlayer;

@end

static const CGFloat kDurationLabelFontSize = 11.0f;
static const CGFloat kGuidLabelFontSize = 10.0f;
static NSString* const kReceivedVoiceMessageCellIdentifier = @"ReceivedVoiceMessageCell";
static NSString* const kPlayCircleImageName = @"play_circle";
static NSString* const kPauseCircleImageName = @"pause_circle";
static NSString* const kReceivedMessageBackgroundImageName = @"ModernBubbleIncomingFull";
static NSString* const kSentMessageBackgroundImageName = @"ModernBubbleOutgoingFull";

@implementation PRVoiceMessageCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self setupSubviews];
}

- (void)setupSubviews
{
    NSString* imageName = kSentMessageBackgroundImageName;
    UIColor* imageTintCoor = kChatBalloonImageViewColor;
    UIColor* durationLabelTextColor = kRightVoiceMessageDurationLabelTextColor;
    UIColor* timeLabelTextColor = kChatRightTimeLabelTextColor;

    if ([self.reuseIdentifier isEqualToString:kReceivedVoiceMessageCellIdentifier]) {
        imageName = kReceivedMessageBackgroundImageName;
        imageTintCoor = kChatLeftBalloonImageViewColor;
        durationLabelTextColor = kLeftVoiceMessageDurationLabelTextColor;
        timeLabelTextColor = kChatLeftTimeLabelTextColor;
    }

    _durationLabel.text = @"";
    _durationLabel.font = [UIFont systemFontOfSize:kDurationLabelFontSize];
    _durationLabel.textColor = durationLabelTextColor;
    _guidLabel.numberOfLines = 0;
    _guidLabel.font = [UIFont systemFontOfSize:kGuidLabelFontSize];

    self.timeLabel.textAlignment = NSTextAlignmentRight;
    self.timeLabel.textColor = timeLabelTextColor;

    [self.balloonImageView setImage:[UIImage imageNamed:imageName]];
    [self.balloonImageView setTintColor:imageTintCoor];
    [self setPlayPauseButtonImage:kPlayCircleImageName];
}

- (void)setPlayPauseButtonImage:(NSString*)imageName
{
    UIImage* image = [UIImage imageNamed:imageName];
    [_playPauseButton setImage:image forState:UIControlStateNormal];
}

- (IBAction)didPressPlayPauseButton:(UIButton*)sender
{
    if (_playPauseButton.tag == PRPlayPauseButtonState_Stopped) {
        if (_audioFielName) {

            [self setPlayPauseButtonState:PRPlayPauseButtonState_Playing];

            [_audioPlayer play:^{
            }
                failedToPlay:^{
                    [self showFailedMessage];
                }
                didFinishPlaying:^(BOOL successfully) {
                    [self setPlayPauseButtonState:PRPlayPauseButtonState_Stopped];
                }];
        }
    } else {
        [self setPlayPauseButtonState:PRPlayPauseButtonState_Stopped];
        [_audioPlayer pausePlaying];
    }
}

- (void)showFailedMessage
{
    [PRMessageAlert showToastWithMessage:Message_CouldNotPlayAudioFile];
    [self setPlayPauseButtonState:PRPlayPauseButtonState_Stopped];
}

- (PRPlayPauseButtonState)playPauseButtonState
{
    return _playPauseButton.tag;
}

- (void)setPlayPauseButtonState:(PRPlayPauseButtonState)state
{
    NSString* imageName = (state == PRPlayPauseButtonState_Playing) ? kPauseCircleImageName : kPlayCircleImageName;

    [self setPlayPauseButtonImage:imageName];
    _playPauseButton.tag = state;
}

#pragma mark - Public Functions

- (void)setAudioFileName:(NSString*)audioFileName
{
    _audioFielName = audioFileName;
    _audioPlayer = [[PRAudioPlayer alloc] initWithAudioFileName:audioFileName];
    [self setPlayPauseButtonState:PRPlayPauseButtonState_Stopped];
    [_durationLabel setText:[_audioPlayer duration]];
}

- (void)setGuid:(NSString*)guid
{
    if (![PRDatabase isUserProfileFeatureEnabled:ProfileFeature_Chat_Debug]) {
        guid = nil;
    }

    _guidLabel.text = guid;
}

@end
