//
//  PRLifeStyleTableViewCell.h
//  PRIME
//
//  Created by Davit on 8/23/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PRLifeStyleTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView* logoImageView;
@property (weak, nonatomic) IBOutlet UILabel* groupNameLabel;
@property (weak, nonatomic) IBOutlet UILabel* groupDescriptionLabel;

@end
