//
//  LoyaltyCardView.h
//  PRIME
//
//  Created by Gayane on 7/27/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoyaltyCardView : UIView

@property (weak, nonatomic) IBOutlet UIImageView* loyaltyCardLogoImageView;
@property (weak, nonatomic) IBOutlet UILabel* loyaltyCardExpirationDate;
@property (weak, nonatomic) IBOutlet UILabel* loyaltyCardNumber;
@property (weak, nonatomic) IBOutlet UIButton* informationButton;
@property (weak, nonatomic) IBOutlet UILabel* loyaltyCardName;

@property (strong, nonatomic) NSNumber* cardId;

@end
