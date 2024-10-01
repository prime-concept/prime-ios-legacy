//
//  ClubInformationViewController.m
//  PRIME
//
//  Created by Artak on 20/08/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "ClubInformationViewController.h"
#import "PRRequestManager.h"
#import "PRUINavigationController.h"

@interface ClubInformationViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* callBackButtonHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* callBackDividerViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* openSiteButtonHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* openSiteButtonBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* openSiteDividerViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* phoneNumberBackgroundHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* line1LabelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* line2LabelHeightConstraint;

@end

static const CGFloat kSkolkovoTextHeight = 80.0f;

@implementation ClubInformationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self setStyles];
    [self setValues];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
#ifdef Raiffeisen
    [(PRUINavigationController*)self.navigationController setNavigationBarColor:kClubViewLabelBackgroundColor];
#endif
}

- (void)setStyles
{
    [_buttonCall setTitleColor:kClubViewButtonColor forState:UIControlStateNormal];
    [_buttonCallBack setTitleColor:kClubViewButtonColor forState:UIControlStateNormal];
    [_buttonOpenSite setTitleColor:kClubViewButtonColor forState:UIControlStateNormal];

    [_phoneNumberBackground setBackgroundColor:kClubViewLabelBackgroundColor];
    _line1Label.textColor = kClubViewLabelColor;
    _line1Label.font = [UIFont systemFontOfSize:15];

    _line2Label.textColor = kClubViewLabelColor;
    [_line2Label setFont:[UIFont fontWithName:@"OCRA" size:21]];

#if defined(PrivateBankingPRIMEClub)
    _line2Label.textColor = [UIColor blackColor];
    _line2Label.font = [UIFont systemFontOfSize:21];
#endif

    _line3Label.textColor = kClubViewLabelColor;
    _line3Label.font = [UIFont systemFontOfSize:15];
    _line3Label.textAlignment = NSTextAlignmentCenter;

#ifdef Raiffeisen
    _callBackButtonHeightConstraint.constant = 0;
    _callBackDividerViewHeight.constant = 0;
    _buttonCallBack.hidden = YES;

    [_phoneNumberBackground setBackgroundColor:kClubViewLabelBackgroundColor];
    UIColor* labelColor = [UIColor colorWithRed:86. / 255 green:88. / 255 blue:87. / 255 alpha:1];

    _line1Label.textColor = labelColor;
    _line2Label.textColor = [UIColor blackColor];
    _line3Label.textColor = labelColor;

#endif

#ifdef Imperia
    _callBackButtonHeightConstraint.constant = 0;
    _openSiteButtonHeightConstraint.constant = 0;
    _callBackDividerViewHeight.constant = 0;
    _openSiteDividerViewHeight.constant = 0;
    _buttonCallBack.hidden = YES;
    _buttonOpenSite.hidden = YES;
#endif

#ifdef FormulaKino
    if (IS_IPHONE_4) {
        _openSiteButtonBottomConstraint.constant = 10;
    }
    _phoneNumberBackgroundHeightConstraint.constant = 270;
#endif

    _informatinoLabel.textColor = kClubViewLabelColor;
    _informatinoLabel.font = [UIFont systemFontOfSize:14];
    _informatinoLabel.textAlignment = NSTextAlignmentLeft;

    _view1.backgroundColor = kDarkGrayColor;
    _view2.backgroundColor = kDarkGrayColor;
    _view3.backgroundColor = kDarkGrayColor;
}

- (void)setValues
{
    NSString* line1Text;
    NSString* line2Text;

    if (_cardNumber) {
        line1Text = NSLocalizedString(@"Card number", nil);
        line2Text = _cardNumber;
    } else {
#ifdef FormulaKino
        line1Text = NSLocalizedString(@"Telephone number", nil);
#else
        line1Text = NSLocalizedString(@"Phone number", nil);
#endif

        line2Text = [@"+" stringByAppendingString:_phoneNumber];
    }

    _line1Label.text = line1Text;
    _line2Label.text = line2Text;
    _line3Label.text = NSLocalizedString(kClubInfoVCLine3LabelText, nil);

#ifdef Skolkovo
    _line1Label.text = NSLocalizedString(kClubInfoVCLine3LabelText, nil);
    _line1Label.lineBreakMode = NSLineBreakByWordWrapping;
    _line1LabelHeightConstraint.constant = kSkolkovoTextHeight;
    _line2LabelHeightConstraint.constant = 0;
    _line1Label.numberOfLines = 0;
    _line2Label.text = nil;
    _line3Label.text = nil;
#endif

    _informatinoLabel.text = NSLocalizedString(kClubInfoVCInfoLabelText, nil);

    [_buttonCall setTitle:NSLocalizedString(@"Call", nil)
                 forState:UIControlStateNormal];

    [_buttonCallBack setTitle:NSLocalizedString(@"Call back", nil)
                     forState:UIControlStateNormal];

    [_buttonOpenSite setTitle:NSLocalizedString(@"Open site", nil)
                     forState:UIControlStateNormal];
}

- (IBAction)callAction:(UIButton*)sender
{
    NSString* phoneNumber = [@"telprompt://" stringByAppendingString:kClubPhoneNumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

- (IBAction)callBackAction:(UIButton*)sender
{
    [PRRequestManager callBackToClient:_cardNumber ?: _phoneNumber
                                  view:self.view
                                  mode:PRRequestMode_ShowErrorMessagesAndProgress
                               success:^{
                                   UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Your request is accepted. We will contact you within 24 hours.", nil)
                                                                                       message:nil
                                                                                      delegate:nil
                                                                             cancelButtonTitle:@"OK"
                                                                             otherButtonTitles:nil, nil];
                                   [alertView show];
                               }
                               failure:^{

                               }];
}

- (IBAction)opeenSiteAction:(UIButton*)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kClubUrl]];
}
@end
