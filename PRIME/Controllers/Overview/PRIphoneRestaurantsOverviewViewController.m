//
//  PRIphoneRestaurantsViewController.m
//  PRIME
//
//  Created by Davit on 8/19/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "PRIphoneRestaurantsOverviewViewController.h"

@interface PRIphoneRestaurantsOverviewViewController ()

@property (weak, nonatomic) IBOutlet UILabel* cityGuideLabel;
@property (weak, nonatomic) IBOutlet UILabel* bestPlacesGuideLabel;
@property (weak, nonatomic) IBOutlet UILabel* restaurantsDetailsLabel;
@property (weak, nonatomic) IBOutlet UIImageView* iPhoneRestaurantsImageView;

@end

@implementation PRIphoneRestaurantsOverviewViewController

#pragma mark - Fill Screen

- (void)fillScreenWithData:(NSDictionary*)dataDict
{
    [_cityGuideLabel setText:NSLocalizedString(dataDict[kOverviewTitleKey], nil)];
    [_bestPlacesGuideLabel setText:NSLocalizedString(dataDict[kOverviewDetailsKey], nil)];
    [_restaurantsDetailsLabel setText:NSLocalizedString(dataDict[kOverviewContentKey], nil)];
    [_iPhoneRestaurantsImageView setImage:[UIImage imageNamed:dataDict[kOverviewImageKey]]];
}

@end
