//
//  PaymentCardTableViewCell.h
//  PRIME
//
//  Created by Admin on 1/31/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaymentCardTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageViewIcon;
@property (weak, nonatomic) IBOutlet UILabel *labelCardType;
@property (weak, nonatomic) IBOutlet UILabel *labelCardNumber;
@property (weak, nonatomic) IBOutlet UILabel *labelCardExpDate;
@end
