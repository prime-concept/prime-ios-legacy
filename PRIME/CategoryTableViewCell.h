//
//  CategoryTableViewCell.h
//  PRIME
//
//  Created by Gayane on 12/7/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoryTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel* requestCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView* requestIconImageView;
@property (weak, nonatomic) IBOutlet UILabel* requestNameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* requestNameLabelLeadingConstraint;

@end
