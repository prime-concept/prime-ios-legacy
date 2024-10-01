//
//  TransactionHistoryCell.h
//  PRIME
//
//  Created by Admin on 7/27/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransactionHistoryCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelDescription;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewType;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@end
