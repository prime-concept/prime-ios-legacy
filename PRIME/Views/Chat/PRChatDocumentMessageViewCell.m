//
//  PRChatDocumentMessageViewCell.m
//  PRIME
//
//  Created by Armen on 6/13/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import "PRChatDocumentMessageViewCell.h"

@interface PRChatDocumentMessageViewCell()

@property (weak, nonatomic) IBOutlet UILabel *documentNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *documentInfoLabel;
@property (weak, nonatomic) IBOutlet UIView *cellWrapperView;

@end

static NSString* const kReceivedDocumentMessageCellIdentifier = @"PRChatReceiveDocumentMessageViewCell";

@implementation PRChatDocumentMessageViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setUpBalloonImageView];
}

- (void)setUpBalloonImageView
{
    NSString* balloonImageName = @"ModernBubbleOutgoingFull";
    UIColor* balloonImageTintColor = kChatBalloonImageViewColor;
    UIColor* timeLabelTextColor = kChatRightTimeLabelTextColor;
    _documentInfoLabel.font = [UIFont systemFontOfSize:9];
    [_documentNameLabel setTextColor:kChatRightMessageTextColor];
    [_documentInfoLabel setTextColor:kChatRightTimeLabelTextColor];
    [_cellWrapperView setBackgroundColor:kRightDocumentMessageWrapperBackgroundColor];

    if ([self.reuseIdentifier isEqualToString:kReceivedDocumentMessageCellIdentifier]) {
        balloonImageName = @"ModernBubbleIncomingFull";
        balloonImageTintColor = kChatLeftBalloonImageViewColor;
        timeLabelTextColor = kChatLeftTimeLabelTextColor;
        [_documentNameLabel setTextColor:kChatLeftMessageTextColor];
        [_documentInfoLabel setTextColor:kChatLeftTimeLabelTextColor];
        [_cellWrapperView setBackgroundColor:kLeftDocumentMessageWrapperBackgroundColor];
    }
    [self.balloonImageView setImage:[UIImage imageNamed:balloonImageName]];
    [self.balloonImageView setTintColor:balloonImageTintColor];
}

- (void)setMessageFileInfoWithPath:(NSString*)messageFileInfoPath
{
    NSURL* directory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                               inDomains:NSUserDomainMask] lastObject];
    NSString* docDirPath = [directory path];
    NSString* filePath = [NSString stringWithFormat:@"%@/%@", docDirPath, messageFileInfoPath];

    NSData* data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary* messageDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if(!messageDictionary)
        return;

    NSString *fileName = [messageDictionary valueForKey:kDocumentMessageFileNameKey];
    [_documentNameLabel setText:fileName];
    NSString *fileSize = [NSByteCountFormatter stringFromByteCount:[[messageDictionary valueForKey:kDocumentMessageFileSizeKey] integerValue] countStyle:NSByteCountFormatterCountStyleMemory];
    NSString *fileExtension = [messageDictionary valueForKey:kDocumentMessageFileExtensionKey];
    if([fileExtension isEqualToString:@""])
    {
        [_documentInfoLabel setText:fileSize];
    }
    else
    {
        [_documentInfoLabel setText:[NSString stringWithFormat:@"%@ · %@", fileSize, fileExtension]];
    }
}

@end
