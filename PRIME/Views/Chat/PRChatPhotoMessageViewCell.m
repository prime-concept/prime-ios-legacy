//
//  PRChatPhotoMessageViewCell.m
//  PRIME
//
//  Created by armens on 4/11/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import "PRChatPhotoMessageViewCell.h"

@interface PRChatPhotoMessageViewCell()

@property (weak, nonatomic) IBOutlet UIImageView* messageImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *imageLoadingIndicatorView;

@end

static NSString* const kReceivedPhotoMessageCellIdentifier = @"PRChatReceivePhotoMessageViewCell";
static NSString* const kReceivedLocationMessageCellIdentifier = @"PRChatReceiveLocationMessageViewCell";

@implementation PRChatPhotoMessageViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setUpBalloonImageView];
}

- (void)setUpBalloonImageView
{
    NSString* balloonImageName = @"ModernBubbleOutgoingFull";
    UIColor* balloonImageTintColor = kChatBalloonImageViewColor;
    UIColor* timeLabelTextColor = kChatRightTimeLabelTextColor;

    if ([self.reuseIdentifier isEqualToString:kReceivedPhotoMessageCellIdentifier] || [self.reuseIdentifier isEqualToString:kReceivedLocationMessageCellIdentifier]) {
        balloonImageName = @"ModernBubbleIncomingFull";
        balloonImageTintColor = kChatLeftBalloonImageViewColor;
        timeLabelTextColor = kChatLeftTimeLabelTextColor;
    }
    [self.balloonImageView setImage:[UIImage imageNamed:balloonImageName]];
    [self.balloonImageView setTintColor:balloonImageTintColor];
}

- (UIImage*)getMessageImage
{
    return _messageImageView.image;
}

- (void)setMessageImageWithPath:(NSString*)messageImagePath isLocation:(BOOL)isLocation
{
    [_imageLoadingIndicatorView startAnimating];
    NSURL* directory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                              inDomains:NSUserDomainMask] lastObject];
    NSString* docDirPath = [directory path];
    NSString* filePath = [NSString stringWithFormat:@"%@/%@", docDirPath, messageImagePath];

    if(isLocation)
    {
        _isLocation = YES;
        NSData* data = [NSData dataWithContentsOfFile:filePath];
        NSDictionary* messageDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if(!messageDictionary)
            return;
        UIImage *image = [UIImage imageWithData:[messageDictionary valueForKey:kLocationMessageSnapshotKey]];
        if(image)
        {
            [_imageLoadingIndicatorView stopAnimating];
        }
        [_messageImageView setImage:image];

        _coordinate.longitude = [[messageDictionary valueForKey:kLocationMessageLongitudeKey] doubleValue];
        _coordinate.latitude = [[messageDictionary valueForKey:kLocationMessageLatitudeKey] doubleValue];
    }
    else
    {
        _isLocation = NO;
        UIImage* image = [UIImage imageNamed:filePath];
        _hasImage = NO;
        if(image)
        {
            _hasImage = YES;
            [_imageLoadingIndicatorView stopAnimating];
        }
        [self.messageImageView setImage:image];
    }
}

@end
