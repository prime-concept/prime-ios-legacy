//
//  PRWGDocumentMessageCell.m
//  PRIME
//
//  Created by Armen on 6/19/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import "PRWGDocumentMessageCell.h"
#import "PRWGCacheManager.h"
#import "Constants.h"

@interface PRWGDocumentMessageCell()
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UIImageView *balloonImageView;
@property (weak, nonatomic) IBOutlet UIView *cellWrapperView;
@property (weak, nonatomic) IBOutlet UILabel *documentNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *documentInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateLabelBottomConstraint;


@end

static NSInteger const kDateLabelBottomConstraintForHideMode = 0;
static NSInteger const kDateLabelBottomConstraintForShowMode = 6;

@implementation PRWGDocumentMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

-(void)updateCellWithData:(NSDictionary*)data
{
    double timestamp =((NSNumber *)([data valueForKey:kWidgetMessageTimestamp])).doubleValue;
    [self setTimeAndDate:timestamp];
    BOOL isCellLeft = ((NSNumber *)([data valueForKey:kWidgetMessageIsLeft])).boolValue;
    if (isCellLeft) {
        _balloonImageView.image = [_balloonImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _balloonImageView.tintColor = kChatLeftBalloonImageViewColor;;
        _dateLabelBottomConstraint.constant = kDateLabelBottomConstraintForHideMode;
        [_timeLabel setTextColor:kChatLeftTimeLabelTextColor];
        [_documentInfoLabel setTextColor:kChatLeftTimeLabelTextColor];
        [_documentNameLabel setTextColor:kChatLeftMessageTextColor];
        [_cellWrapperView setBackgroundColor:kLeftDocumentMessageWrapperBackgroundColor];
    } else {
        _balloonImageView.image = [_balloonImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _balloonImageView.tintColor = kChatBalloonImageViewColor;
        _timeLabel.textColor = kChatRightTimeLabelTextColor;
        [_documentInfoLabel setTextColor:kChatRightTimeLabelTextColor];
        [_documentNameLabel setTextColor:kChatRightMessageTextColor];
        [_cellWrapperView setBackgroundColor:kRightDocumentMessageWrapperBackgroundColor];
    }
    if ([data valueForKey:kWidgetMessageFormatedDate]) {
        [_dateLabel setText:[data valueForKey:kWidgetMessageFormatedDate]];
        _dateLabelBottomConstraint.constant = kDateLabelBottomConstraintForShowMode;
    } else {
        _dateLabelBottomConstraint.constant = kDateLabelBottomConstraintForHideMode;
        _dateLabel.text = @"";
    }
    NSString *fileName = [[data valueForKey:@"text"] stringByReplacingOccurrencesOfString:@"/chat.private/" withString:@""];
    NSData* documentData = [PRWGCacheManager getFileDataFromCache:fileName];
    NSDictionary* messageDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:documentData];
    if(!messageDictionary)
        return;

    NSString *documentFileName = [messageDictionary valueForKey:kDocumentMessageFileNameKey];
    [_documentNameLabel setText:documentFileName];
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

- (void)setTimeAndDate:(double)timestamp {
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm"];

    _timeLabel.text = [dateFormat stringFromDate:date];
}

@end
