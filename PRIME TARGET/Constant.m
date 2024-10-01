//
//  Constant.m
//  PRIME
//
//  Created by Gayane on 3/11/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "Constants.h"
#import <Foundation/Foundation.h>

UIColor* kMonthsCollectionViewArrowColor = nil;
UIColor* kIconsColor = nil;
UIColor* kSegmentedControlTaskStatusColor;
UIColor* kTaskSegmentColor = nil;
UIColor* kTabBarBackgroundColor = nil;
UIColor* kReservsOrRequestsSegment = nil;
UIColor* kCalendarDayTextColorToday = nil;
UIColor* kNavigationBarTintColor = nil;
UIColor* kDeleteButtonColor = nil;
UIColor* kProfileInfoNameColor = nil;
UIColor* kWelcomeScreenBackgroundColor = nil;
UIColor* kWelcomeScreenNextButtonColor = nil;
UIColor* kContainerButtonColor = nil;
UIColor* kCalendarEventLineColor = nil;
UIColor* kMonthColor = nil;
UIColor* kTabBarSelectedTextColor = nil;
UIColor* kTabBarUnselectedTextColor = nil;
UIColor* kPhoneLabelBackground = nil;
UIColor* kHeaderViewColor = nil;
UIColor* kChatMessageColor = nil;
UIColor* kDateLabelWrapperViewBackground = nil;
UIColor* kTypingContainerView = nil;
UIColor* kTaskPriceTextColor = nil;
UIColor* kTableViewBackgroundColor = nil;
UIColor* kProfileImageTextColor = nil;

UIImage* kTabItem1 = nil;
UIImage* kTabItem2 = nil;
UIImage* kTabItem3 = nil;
UIImage* kTabItem4 = nil;
UIImage* kTabItem5 = nil;

NSString* kChatTitleName = nil;
NSString* kChatIconName = nil;
NSString* clubInfoVCInfoLabelText = nil;
NSString* clubInfoVCLine3LabelText = nil;

CGFloat kAssistantCellHeight = 0;
CGFloat kPersonalContactsSectionHeaderHeight = 0;

@interface Brending : NSObject

@end

@implementation Brending

+ (void)load
{
    //Prime.
    kMonthsCollectionViewArrowColor = [UIColor colorWithRed:209. / 255 green:200. / 255 blue:203. / 255 alpha:1];
    kIconsColor = kGold;
    kSegmentedControlTaskStatusColor = kLightBrown;
    kTaskSegmentColor = kLightBrown;
    kReservsOrRequestsSegment = kBrown;
    kTabBarBackgroundColor = kBrown;
    kCalendarDayTextColorToday = [UIColor colorWithRed:237. / 255 green:29. / 255 blue:36. / 255 alpha:1];
    kNavigationBarTintColor = kBrown;
    kDeleteButtonColor = [UIColor redColor];
    kProfileInfoNameColor = [UIColor colorWithRed:211. / 255 green:174. / 255 blue:141. / 255 alpha:1];
    kWelcomeScreenBackgroundColor = [UIColor colorWithRed:88. / 255 green:65. / 255 blue:75. / 255 alpha:1];
    kWelcomeScreenNextButtonColor = kWhite;
    kContainerButtonColor = kAppColor;
    kCalendarEventLineColor = [UIColor colorWithRed:238. / 255 green:57. / 255 blue:35. / 255 alpha:1];
    kMonthColor = kAppColor;
    kTabBarSelectedTextColor = kWhite;
    kTabBarUnselectedTextColor = [UIColor colorWithRed:142. / 255 green:117. / 255 blue:127. / 255 alpha:1];
    kPhoneLabelBackground = [UIColor colorWithRed:239. / 255 green:239. / 255 blue:244. / 255 alpha:1];
    kHeaderViewColor = [UIColor colorWithRed:239. / 255 green:239. / 255 blue:244. / 255 alpha:1];
    kChatMessageColor = [UIColor blackColor];
    kDateLabelWrapperViewBackground = [UIColor colorWithWhite:0.3 alpha:0.4];
    kTypingContainerView = kDarkGray;
    kTaskPriceTextColor = kBrown;
    kTableViewBackgroundColor = [UIColor colorWithRed:239. / 255 green:239. / 255 blue:244. / 255 alpha:1];
    kProfileImageTextColor = kWhite;

    kTabItem1 = [[UIImage imageNamed:@"tabIcon1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    kTabItem2 = [[UIImage imageNamed:@"tabIcon2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    kTabItem3 = [[UIImage imageNamed:@"tabIcon3"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    kTabItem4 = [[UIImage imageNamed:@"tabIcon4"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    kTabItem5 = [[UIImage imageNamed:@"tabIcon5"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

    kAssistantCellHeight = 40;
    kPersonalContactsSectionHeaderHeight = 25;

    kChatTitleName = @"PRIME";
    kChatIconName = kChatTitleName;
    clubInfoVCInfoLabelText = @"Private closed club. The number of members is limited to 300 persons.\n\nJoin the Club PRIMECONCEPT possible only on the recommendation of one of the members or at the invitation of shareholders and leadership Club.";
    clubInfoVCLine3LabelText = @"is not found in the list of members\n";
}

@end