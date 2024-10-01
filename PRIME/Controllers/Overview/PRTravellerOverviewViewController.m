//
//  PRTravellerOverviewViewController.m
//  PRIME
//
//  Created by Davit on 8/17/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "PRTravellerOverviewViewController.h"

@interface PRTravellerOverviewViewController ()

@property (weak, nonatomic) IBOutlet UIButton* readOnlineButton;
@property (weak, nonatomic) IBOutlet UILabel* primeTravellerLabel;
@property (weak, nonatomic) IBOutlet UILabel* travellerJournalLabel;
@property (weak, nonatomic) IBOutlet UIImageView* usersFacesImageView;
@property (weak, nonatomic) IBOutlet UILabel* travellerDetailsLabel;

@end

@implementation PRTravellerOverviewViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [_readOnlineButton.layer setBorderWidth:1.0f];
    [_readOnlineButton.layer setBorderColor:[UIColor colorWithRed:230.0 / 255.0 green:226.0 / 255.0 blue:217.0 / 255.0 alpha:1.0].CGColor];
    [_readOnlineButton.layer setCornerRadius:10.0f];
    [_readOnlineButton.layer setMasksToBounds:YES];
}

#pragma mark - Fill Screen

- (void)fillScreenWithData:(NSDictionary*)dataDict
{
    [_primeTravellerLabel setText:NSLocalizedString(dataDict[kOverviewTitleKey], nil)];
    [_travellerJournalLabel setText:NSLocalizedString(dataDict[kOverviewDetailsKey], nil)];
    [_travellerDetailsLabel setText:NSLocalizedString(dataDict[kOverviewContentKey], nil)];
    [_readOnlineButton setTitle:NSLocalizedString(dataDict[kOverviewButtonTextKey], nil) forState:UIControlStateNormal];
    [_usersFacesImageView setImage:[UIImage imageNamed:dataDict[kOverviewImageKey]]];
}

#pragma mark - Actions

- (IBAction)readOnlineButtonPressed:(id)sender
{
    NSURL* URL = [NSURL URLWithString:@"https://www.primeconcept.co.uk/prime-traveller/"];
    if ([[UIApplication sharedApplication] canOpenURL:URL]) {
        [[UIApplication sharedApplication] openURL:URL];
    }
}

@end
