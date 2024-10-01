//
//  ChatTaskCell.h
//  PRIME
//
//  Created by Taron on 3/15/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface TaskView : UIView
@property (nonatomic, assign) BOOL needSeparator;

@end

@interface ChatTaskCell : UITableViewCell

@property (strong, nonatomic) NSNumber* taskId;
@property (strong, nonatomic) NSDate* requestDate;
@property (strong, nonatomic) UIImageView* imageViewIcon;
@property (strong, nonatomic) UILabel* nameLabel;
@property (strong, nonatomic) UILabel* descriptionLabel;
@property (assign, nonatomic) CGSize estimatedCellSize;
@property (assign, nonatomic) BOOL needToShowHeaderView;

/** In debug mode, on cell will also be presented message "guid" */
- (void)setGuid:(NSString*)guid;

/** Set task last message info for cell */
- (void)setTaskLastMessageInfo:(PRMessageModel*)taskLastMessage;

/** Set message creation date into cell */
- (void)setDate:(double)timestamp;

- (void)setTaskInformation:(PRTasklinkTask*)task;

- (CGFloat)taskCellEstimatedHeightForTask:(PRTasklinkTask*)task andMessage:(PRMessageModel*)message;

@end
