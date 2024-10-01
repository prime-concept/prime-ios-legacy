//
//  PRProfileOverviewViewController.m
//  PRIME
//
//  Created by Davit on 8/16/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "PRProfileOverviewViewController.h"

@interface PRProfileOverviewViewController ()

@property (weak, nonatomic) IBOutlet UIView* containerView;
@property (weak, nonatomic) IBOutlet UIImageView* clientImageView;
@property (weak, nonatomic) IBOutlet UILabel* clientNameLabel;
@property (weak, nonatomic) IBOutlet UILabel* clientSurnameLabel;
@property (weak, nonatomic) IBOutlet UITextView* clientNotesTextView;
@property (weak, nonatomic) IBOutlet UIButton* facebookButton;
@property (weak, nonatomic) IBOutlet UIButton* instagramButton;
@property (weak, nonatomic) IBOutlet UIButton* telegramButton;

@end

@implementation PRProfileOverviewViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [_clientNotesTextView setContentInset:UIEdgeInsetsMake(0, 0, 60, 0)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_clientNotesTextView scrollRangeToVisible:NSMakeRange(0, 0)];
}

#pragma mark - Fill Screen

- (void)fillScreenWithData:(NSDictionary*)dataDict
{
    [_clientImageView setImage:[UIImage imageNamed:dataDict[kOverviewImageKey]]];
    [_clientNameLabel setText:NSLocalizedString(dataDict[kOverviewNameKey], nil)];
    [_clientSurnameLabel setText:NSLocalizedString(dataDict[kOverviewSurnameKey], nil)];
    [_clientNotesTextView setText:NSLocalizedString(dataDict[kOverviewContentKey], nil)];
}

#pragma mark - Layout

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    // Apply gradient to text view bottom area.
    [self applyGradientToView:_containerView];

    // Start from the top of the text view at the beginning.
    [_clientNotesTextView setContentOffset:CGPointZero animated:NO];
}

#pragma mark - Actions

- (IBAction)instagramButtonPressed:(id)sender
{
    NSURL* URL = [NSURL URLWithString:@"https://www.instagram.com/prime_art_of_life/"];
    if ([[UIApplication sharedApplication] canOpenURL:URL]) {
        [[UIApplication sharedApplication] openURL:URL];
    }
}

- (IBAction)facebookButtonPressed:(id)sender
{
    NSURL* URL = [NSURL URLWithString:@"https://www.facebook.com/primeartoflife/"];
    if ([[UIApplication sharedApplication] canOpenURL:URL]) {
        [[UIApplication sharedApplication] openURL:URL];
    }
}

- (IBAction)telegramButtonPressed:(id)sender
{
    NSURL* URL = [NSURL URLWithString:@"https://telegram.me/primeconceptbot?utm_source=PrimeConcept&utm_campaign=d84a2adda8-General_PC_010816&utm_medium=email&utm_term=0_52b196c47a-d84a2adda8-9926013"];
    if ([[UIApplication sharedApplication] canOpenURL:URL]) {
        [[UIApplication sharedApplication] openURL:URL];
    }
}

@end
