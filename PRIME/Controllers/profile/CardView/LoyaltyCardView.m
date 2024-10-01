//
//  LoyaltyCardView.m
//  PRIME
//
//  Created by Gayane on 7/27/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "LoyaltyCardView.h"

@implementation LoyaltyCardView

- (id)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        UINib* nib = [UINib nibWithNibName:@"LoyaltyCardView" bundle:nil];
        UIView* subview = [[nib instantiateWithOwner:self options:nil] firstObject];
        subview.frame = self.bounds;
        [self addSubview:subview];
    }
    UIImage* btnImage = [UIImage imageNamed:@"card_info"];
    [_informationButton setImage:btnImage forState:UIControlStateNormal];
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    
    return self;


}

@end
