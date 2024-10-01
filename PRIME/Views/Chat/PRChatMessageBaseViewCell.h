//
//  PRChatMessageBaseViewCell.h
//  PRIME
//
//  Created by Mariam on 3/10/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@interface PRChatMessageBaseViewCell : UITableViewCell <TTTAttributedLabelDelegate>

@property (nonatomic, weak) IBOutlet TTTAttributedLabel* messageLabel;
@property (nonatomic, weak) IBOutlet UILabel* timeLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* balloonRightConstraint;
@property (nonatomic, weak) IBOutlet UIImageView* balloonImageView;

@property (nonatomic, strong) id<UIActionSheetDelegate> viewDelegate;
@property (nonatomic, assign) NSInteger resendMessageButtonTag;
@property (nonatomic) BOOL needToShowHeaderView;
@property (nonatomic) CGSize estimatedCellSize;

- (void)setDate:(double)timestamp;

/** In debug mode, on cell will also be presented message "guid" */
- (void)setMessageText:(NSString*)text messageGuid:(NSString*)guid;

- (void)statusSendingGrayIndicator;
- (void)statusSendingRedIndicator;
- (void)statusSent;
- (void)statusReserved;
- (void)statusRead;

- (void)createResendButton;
- (void)deleteResendButton;

@end
