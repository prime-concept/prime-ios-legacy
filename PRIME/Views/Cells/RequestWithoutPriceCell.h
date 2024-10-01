//
//  RequestWithoutLriceCell.h
//  PRIME
//
//  Created by Admin on 2/9/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRTaskCell.h"
#import "CellWithBadge.h"
#import "PRCellWithCustomSeparator.h"

#import <UIKit/UIKit.h>

@interface RequestWithoutPriceCell : CellWithBadge <PRTaskCell, PRCellWithCustomSeparator>

@property (strong, nonatomic) NSNumber* taskId;
@property (strong, nonatomic) NSDate* requestDate;

@property (weak, nonatomic) IBOutlet UIImageView *imageViewIcon;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelDescription;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end
