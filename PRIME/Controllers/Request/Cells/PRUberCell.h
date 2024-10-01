//
//  PRUberCell.h
//  PRIME
//
//  Created by Nerses Hakobyan on 4/6/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PRUberCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView* surgeImageView;
@property (weak, nonatomic) IBOutlet UIImageView* carImageView;
@property (weak, nonatomic) IBOutlet UILabel* uberServiceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel* servicePriceLabel;
@property (weak, nonatomic) IBOutlet UILabel* estimatedPickupTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel* currencyLabel;
@property (assign, nonatomic) BOOL shouldShowSurge;

- (void)willAppear;

@end
