//
//  Option.m
//  PRIME
//
//  Created by Admin on 3/26/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "Option.h"

@implementation Option

+(instancetype) aviaOption
{
    Option *option = [[Option alloc] init];
    option.imageName = @"avia";
    option.optionName = NSLocalizedString(@"Avia", nil);
    option.optionId = OPTION_Avia;

    return option;
}

+(instancetype) viphallOption
{
    Option *option = [[Option alloc] init];
    option.imageName = @"vip_hall_tab_active";
    option.optionName = NSLocalizedString(@"Vip hall", nil);
    option.optionId = OPTION_VIPHall;

    return option;
}

+(instancetype) transferOption
{
    Option *option = [[Option alloc] init];
    option.imageName = @"transfer_tab_active";
    option.optionName = NSLocalizedString(@"Transfer", nil);
    option.optionId = OPTION_Transfer;

    return option;
}

+(instancetype) hotelOption
{
    Option *option = [[Option alloc] init];
    option.imageName = @"hotel_tab_active";
    option.optionName = NSLocalizedString(@"Hotel", nil);
    option.optionId = OPTION_Hotel;

    return option;
}

+(instancetype) restoranOption
{
    Option *option = [[Option alloc] init];
    option.imageName = @"restaurant_tab_active";
    option.optionName = NSLocalizedString(@"Restaurant", nil);
    option.optionId = OPTION_Avia;

    return option;
}

+(instancetype) otherOption
{
    Option *option = [[Option alloc] init];
    option.imageName = @"other_tab_active";
    option.optionName = NSLocalizedString(@"Other", nil);
    option.optionId = OPTION_Other;

    return option;
}

@end
