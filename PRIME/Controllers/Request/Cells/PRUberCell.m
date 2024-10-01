//
//  PRUberCell.m
//  PRIME
//
//  Created by Nerses Hakobyan on 4/6/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "PRUberCell.h"
#import <UIKit/UIKit.h>

@implementation PRUberCell

- (void)willAppear
{
    [_uberServiceNameLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:18]];
    [_currencyLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:11]];
    [_servicePriceLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:11]];
    [_estimatedPickupTimeLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:10]];
    [_estimatedPickupTimeLabel setTextColor:kTextGreyColor];
    [_servicePriceLabel setTextColor:kTextGreyColor];
    if (_shouldShowSurge) {
        _servicePriceLabel.textColor = kUberSurgeColor;

        [_surgeImageView setImage:[UIImage imageNamed:@"uberSurgeIcon"]];
        return;
    }
    _surgeImageView.hidden = YES;
}

@end
