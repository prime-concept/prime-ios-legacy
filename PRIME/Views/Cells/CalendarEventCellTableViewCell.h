//
//  CalendarEventCellTableViewCell.h
//  PRIME
//
//  Created by Artak on 1/29/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRTaskCell.h"
#import <UIKit/UIKit.h>

@interface CalendarEventCellTableViewCell : UITableViewCell <PRTaskCell>

@property (weak, nonatomic) IBOutlet UILabel* labelStartDate;
@property (weak, nonatomic) IBOutlet UILabel* labelEndDate;
@property (weak, nonatomic) IBOutlet UILabel* labelName;
@property (weak, nonatomic) IBOutlet UILabel* labelNote;
@property (weak, nonatomic) IBOutlet UILabel* labelWholeDay;
@property (weak, nonatomic) IBOutlet UIView* dateView;
@property (strong, nonatomic) NSNumber* taskId;
@property (strong, nonatomic) NSDate* requestDate;

- (void)setUberWithTime:(NSString*)uberTime;
- (void)hideUber:(BOOL)hidden;

@end
