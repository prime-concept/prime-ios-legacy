//
//  PRiPhoneCardsOverviewViewController.m
//  PRIME
//
//  Created by Davit on 8/17/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "PRIPhoneCardsOverviewViewController.h"

@interface PRIPhoneCardsOverviewViewController ()

@property (weak, nonatomic) IBOutlet UILabel* cardsOverviewLabel;
@property (weak, nonatomic) IBOutlet UILabel* inOnePlaceLabel;
@property (weak, nonatomic) IBOutlet UIImageView* iPhoneCardsImageView;

@end

@implementation PRIPhoneCardsOverviewViewController

#pragma mark - Fill Screen

- (void)fillScreenWithData:(NSDictionary*)dataDict
{
    [_cardsOverviewLabel setText:NSLocalizedString(dataDict[kOverviewTitleKey], nil)];
    [_inOnePlaceLabel setText:NSLocalizedString(dataDict[kOverviewOnePlaceKey], nil)];
    [_iPhoneCardsImageView setImage:[UIImage imageNamed:dataDict[kOverviewImageKey]]];
}

@end
