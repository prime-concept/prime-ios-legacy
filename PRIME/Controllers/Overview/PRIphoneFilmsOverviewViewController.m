//
//  PRIphoneFilmsOverviewViewController.m
//  PRIME
//
//  Created by Davit on 8/19/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "PRIphoneFilmsOverviewViewController.h"

@interface PRIphoneFilmsOverviewViewController ()

@property (weak, nonatomic) IBOutlet UILabel* cityGuideLabel;
@property (weak, nonatomic) IBOutlet UILabel* purchaseTicketsLabel;
@property (weak, nonatomic) IBOutlet UILabel* ticketsDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView* cinemaPartnersImageView;
@property (weak, nonatomic) IBOutlet UIImageView* iPhoneFilmsImageView;

@end

@implementation PRIphoneFilmsOverviewViewController

#pragma mark - Fill Screen

- (void)fillScreenWithData:(NSDictionary*)dataDict
{
    [_cityGuideLabel setText:NSLocalizedString(dataDict[kOverviewTitleKey], nil)];
    [_purchaseTicketsLabel setText:NSLocalizedString(dataDict[kOverviewDetailsKey], nil)];
    [_ticketsDescriptionLabel setText:NSLocalizedString(dataDict[kOverviewContentKey], nil)];
    [_cinemaPartnersImageView setImage:[UIImage imageNamed:dataDict[kOverviewImagePartnersKey]]];
    [_iPhoneFilmsImageView setImage:[UIImage imageNamed:dataDict[kOverviewImageIPhoneKey]]];
}

@end
