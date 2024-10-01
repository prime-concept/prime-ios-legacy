//
//  PRPrimeTravelOverviewViewController.m
//  PRIME
//
//  Created by Davit on 8/22/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "PRPrimeTravelOverviewViewController.h"

@interface PRPrimeTravelOverviewViewController ()

@property (weak, nonatomic) IBOutlet UILabel* travelPrivillegesLabel;
@property (weak, nonatomic) IBOutlet UILabel* totalPartnersLabel;
@property (weak, nonatomic) IBOutlet UILabel* aviaLabel;
@property (weak, nonatomic) IBOutlet UILabel* aviaDetailsLabel;
@property (weak, nonatomic) IBOutlet UIImageView* aviaPartnersImageView;
@property (weak, nonatomic) IBOutlet UILabel* hotelCollectionLabel;
@property (weak, nonatomic) IBOutlet UILabel* hotelDetailsLabel;
@property (weak, nonatomic) IBOutlet UIImageView* hotelPartnersImageView;

@end

@implementation PRPrimeTravelOverviewViewController

#pragma mark - Fill Screen

- (void)fillScreenWithData:(NSDictionary*)dataDict
{
    [_travelPrivillegesLabel setText:NSLocalizedString(dataDict[kOverviewTitleKey], nil)];
    [_totalPartnersLabel setText:NSLocalizedString(dataDict[kOverviewPartnersCountKey], nil)];

    NSArray<NSDictionary*>* itemsArray = dataDict[kOverviewItemsKey][kOverviewItemKey];

    NSDictionary* aviaDictionary = itemsArray[0];
    [_aviaLabel setText:NSLocalizedString(aviaDictionary[kOverviewTitleKey], nil)];
    [_aviaDetailsLabel setText:NSLocalizedString(aviaDictionary[kOverviewContentKey], nil)];
    [_aviaPartnersImageView setImage:[UIImage imageNamed:aviaDictionary[kOverviewImageKey]]];

    NSDictionary* hotelDictionary = itemsArray[1];
    [_hotelCollectionLabel setText:NSLocalizedString(hotelDictionary[kOverviewTitleKey], nil)];
    [_hotelDetailsLabel setText:NSLocalizedString(hotelDictionary[kOverviewContentKey], nil)];
    [_hotelPartnersImageView setImage:[UIImage imageNamed:hotelDictionary[kOverviewImageKey]]];
}

@end
