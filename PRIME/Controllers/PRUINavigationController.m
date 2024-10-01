//
//  PRUINavigationController.m
//  PRIME
//
//  Created by Admin on 3/14/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRUINavigationController.h"
#import "UINavigationBar+Addition.h"

@interface PRUINavigationController ()

@end

@implementation PRUINavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];

	[self.navigationBar setTintColor:kNavigationBarTintColor];

    //- Set bar color
    //[self.navigationBar setBarTintColor:[UIColor colorWithRed:85.0/255.0 green:143.0/255.0 blue:220.0/255.0 alpha:1.0]];

    //- Optional, i don't want my bar to be translucent
    //[self.navigationBar setTranslucent:NO];

#if defined(VTB24) || Raiffeisen || Prime || PrimeClubConcierge || PrimeConciergeClub || Platinum
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *navBarAppearance = [[UINavigationBarAppearance alloc] init];
        [navBarAppearance configureWithOpaqueBackground];
        [navBarAppearance setBackgroundColor:kNavigationBarBarTintColor];
        [UINavigationBar appearance].standardAppearance = navBarAppearance;
        [UINavigationBar appearance].scrollEdgeAppearance = navBarAppearance;
    } else {
        self.navigationBar.translucent = NO;
       [self.navigationBar setBarTintColor:kNavigationBarBarTintColor];
       self.navigationBar.backgroundColor = kNavigationBarBarTintColor;
       self.view.backgroundColor = kNavigationBarBarTintColor;
    }
#endif
//- Set Navigation Bar Title text color

#if defined(PrivateBankingPRIMEClub)
    [self.navigationBar setTitleTextAttributes:
                            @{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
#else
    [self.navigationBar setTitleTextAttributes:
                            @{ NSForegroundColorAttributeName : kNavigationBarTitleTextColor }];
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNavigationBarColor:(UIColor*)barTintColor
{
	[self.navigationBar setBarTintColor:barTintColor];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

#if defined(PrivateBankingPRIMEClub)
    self.navigationBar.translucent = NO;
    [self.navigationBar setBackgroundColor:barTintColor];
#endif

#if defined(VTB24)
	[self.navigationBar setTintColor:kVTBBlackColor];
	self.navigationBar.backgroundColor = kVTBBlackColor;
#endif

#if PrimeClubConcierge || Prime
	self.navigationBar.backgroundColor = UIColor.whiteColor;
#endif
}

@end
