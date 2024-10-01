//
//  UINavigationBar+Addition.m
//  PRIME
//
//  Created by Davit on 2/13/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "UINavigationBar+Addition.h"
#if defined(Prime)
#import "_Art_Of_Life_-Swift.h"
#elif defined(PrimeClubConcierge)
#import "PrimeClubConcierge-Swift.h"
#elif defined(Imperia)
#import "IMPERIA-Swift.h"
#elif defined(PondMobile)
#import "Pond Mobile-Swift.h"
#elif defined(Raiffeisen)
#import "Raiffeisen-Swift.h"
#elif defined(VTB24)
#import "PrimeConcierge-Swift.h"
#elif defined(Ginza)
#import "Ginza-Swift.h"
#elif defined(FormulaKino)
#import "Formula Kino-Swift.h"
#elif defined(Platinum)
#import "Platinum-Swift.h"
#elif defined(Skolkovo)
#import "Skolkovo-Swift.h"
#elif defined(PrimeConciergeClub)
#import "Tinkoff-Swift.h"
#elif defined(PrivateBankingPRIMEClub)
#import "PrivateBankingPRIMEClub-Swift.h"
#elif defined(PrimeRRClub)
#import "PRIME RRClub-Swift.h"
#elif defined(Davidoff)
#import "Davidoff-Swift.h"
#endif

@implementation UINavigationBar (Addition)

- (void)hideBottomHairline
{
    // Hide 1px hairline of translucent nav bar
    UIImageView* navBarHairlineImageView = [self findHairlineImageViewUnder:self];
    navBarHairlineImageView.hidden = YES;
}

- (void)showBottomHairline
{
    // Show 1px hairline of translucent nav bar
    UIImageView* navBarHairlineImageView = [self findHairlineImageViewUnder:self];
    navBarHairlineImageView.hidden = NO;
}

- (UIImageView*)findHairlineImageViewUnder:(UIView*)view
{
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView*)view;
    }
    for (UIView* subview in view.subviews) {
        UIImageView* imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

- (void)makeTransparent
{
    [self setTranslucent:YES];
    [self setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.backgroundColor = [UIColor clearColor];
    self.shadowImage = [UIImage new]; // Hides the hairline
    [self hideBottomHairline];
}

- (void)makeDefault
{
    [self setTranslucent:YES];
    [self setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.backgroundColor = nil;
    self.shadowImage = nil; // Hides the hairline
    [self showBottomHairline];
}

+ (void)setStatusBarBackgroundColor:(UIColor*)color
{
    UIView *statusBar = [[UIApplication sharedApplication] statusBarUIView];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}

@end
