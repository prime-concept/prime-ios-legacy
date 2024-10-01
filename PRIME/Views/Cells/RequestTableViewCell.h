//
//  RequestTableViewCell.h
//  PRIME
//
//  Created by Admin on 1/30/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRTaskCell.h"
#import "PRPayButtonDelegate.h"
#import "CellWithBadge.h"
#import "PRCellWithCustomSeparator.h"

#import <UIKit/UIKit.h>

@interface RequestTableViewCell : CellWithBadge <PRTaskCell, PRCellWithCustomSeparator>

@property (nonatomic, weak) id<PRPayButtonDelegate> delegate;
@property (strong, nonatomic) NSString* paymentLink;
@property (strong, nonatomic) NSNumber* taskId;
@property (strong, nonatomic) NSDate* requestDate;

@property (weak, nonatomic) IBOutlet UIImageView* imageViewIcon;
@property (weak, nonatomic) IBOutlet UILabel* labelName;
@property (weak, nonatomic) IBOutlet UILabel* labelDescription;
@property (weak, nonatomic) IBOutlet UILabel* labelDueDate;
@property (weak, nonatomic) IBOutlet UIButton* buttonPay;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end
