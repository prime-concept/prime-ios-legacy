//
//  Constant.m
//  PRIME
//
//  Created by Gayane on 3/11/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

UIColor* kMonthsCollectionViewArrowColor = nil;
UIColor* kIconsColor = nil;
UIColor* kSegmentedControlTaskStatusColor;
UIColor* kTaskSegmentColor = nil;
UIColor* kTabBarBackgroundColor = nil;
UIColor* kReservesOrRequestsSegmentColor = nil;
UIColor* kCalendarTodayTextColor = nil;
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
UIColor* kPhoneLabelBackgroundColor = nil;
UIColor* kHeaderViewColor = nil;
UIColor* kChatMessageColor = nil;
UIColor* kDateLabelWrapperViewBackgroundColor = nil;
UIColor* kTypingContainerViewColor = nil;
UIColor* kTaskPriceTextColor = nil;
UIColor* kTableViewBackgroundColor = nil;
UIColor* kProfileImageTextColor = nil;
UIColor* kChatTitleColor = nil;
UIColor* kChatBalloonImageViewColor = nil;
UIColor* kNavigationBarBarTintColor = nil;
UIColor* kPhoneLabelTextColor = nil;
UIColor* kWeChatImageColor = nil;
UIColor* kNavigationBarTitleColor = nil;
UIColor* kClubViewLabelBackgroundColor = nil;
UIColor* kClubViewLabelColor = nil;
UIColor* kClubViewButtonColor = nil;
UIColor* kChatLeftMessageTextColor = nil;
UIColor* kChatRightMessageTextColor = nil;
UIColor* kChatLeftBalloonImageViewColor = nil;
UIColor* kProfileTableViewBackgroundColor = nil;
UIColor* kChatSendTextColor = nil;
UIColor* kChatTextViewTintColor = nil;
UIColor* kChatSendButtonColor = nil;
UIColor* kUberActionSheetTopPartColor = nil;
UIColor* kChatLeftTimeLabelTextColor = nil;
UIColor* kChatRightTimeLabelTextColor = nil;
UIColor* kLeftVoiceMessageDurationLabelTextColor = nil;
UIColor* kRightVoiceMessageDurationLabelTextColor = nil;
UIColor* kChatTaskIconTextColor = nil;
UIColor* kTasksHeaderColor = nil;
UIColor* kCalendarTodayCircleColor = nil;
UIColor* kCalendarSelectedDayCircleColor = nil;
UIColor* kPayButtonBackgroundColor = nil;
UIColor* kPayButtonTextColor = nil;
UIColor* kBadgeColor = nil;
UIColor* kCalendarTodayButtonColor = nil;
UIColor* kTabBarDayLabelUnselectedTextColor = nil;
UIColor* kFeatureInfoTextColor = nil;
UIColor* kReceiveVirtualCardBackgroundColor = nil;
UIColor* kReceiveVirtualCardTitleTextColor = nil;

UIColor* kAttachMainColor = nil;
UIColor* kAttachCancelColor = nil;
UIColor* kLeftContactMessageButtonColor = nil;
UIColor* kRightContactMessageButtonColor = nil;
UIColor* kLeftContactMessageSeperatorColor = nil;
UIColor* kRightContactMessageSeperatorColor = nil;
UIColor* kLeftDocumentMessageWrapperBackgroundColor = nil;
UIColor* kRightDocumentMessageWrapperBackgroundColor = nil;

UIImage* kTabItem2Image = nil;
UIImage* kTabItem3Image = nil;
UIImage* kTabItem4Image = nil;
UIImage* kTabItem5Image = nil;

NSString* kClientID = nil;
NSString* kClientSecret = nil;
NSString* kURLSchemesPrefix = nil;
NSString* kClubInfoVCInfoLabelText = nil;
NSString* kClubInfoVCLine3LabelText = nil;
NSString* kAppMainColor = nil;
NSString* kTargetName = nil;
NSString* kClubPhoneNumber = nil;
NSString* kCityGuideBaseUrl = nil;
NSString* kCityGuideBaseUtm = nil;
NSString* kUserDefaultsSuiteName = nil;
NSString* kLoginWithCardText = nil;

CGFloat kAssistantCellHeight = 0;
CGFloat kPersonalContactsSectionHeaderHeight = 0;

@interface Brending : NSObject

@end

@implementation Brending

+ (void)load
{
    //Imperia.
    kClientID = @"ewd9xnq1trxp1zm1plr2fvsyb";
    kClientSecret = @"3fzh1nu6fspi290324k80bwuo";
    kTargetName = @"imperia";
    kURLSchemesPrefix = [NSString stringWithFormat:@"%@://", kTargetName];
    kUserDefaultsSuiteName = @"group.com.prime.app.imperia";
    kClubPhoneNumber = @"+74956440644";
    kMonthsCollectionViewArrowColor = kLightGreyColor;
    kIconsColor = kDarkPinkColor;
    kSegmentedControlTaskStatusColor = kDarkPinkColor;
    kTaskSegmentColor = kDarkPinkColor;
    kPayButtonBackgroundColor = kDarkPinkColor;
    kReservesOrRequestsSegmentColor = kDarkPinkColor;
    kTabBarBackgroundColor = kMilkColor;
    kCalendarTodayTextColor = kDarkPinkColor;
    kNavigationBarTintColor = kDarkPinkColor;
    kDeleteButtonColor = kDarkPinkColor;
    kProfileInfoNameColor = kDarkPinkColor;
    kWelcomeScreenBackgroundColor = kWhiteColor;
    kWelcomeScreenNextButtonColor = kLightBlackColor;
    kContainerButtonColor = kLightBlackColor;
    kCalendarEventLineColor = kDarkPinkColor;
    kCalendarTodayCircleColor = kDarkPinkColor;
    kCalendarSelectedDayCircleColor = kDarkPinkColor;
    kCalendarTodayButtonColor = kDarkPinkColor;
    kMonthColor = kLightBlackColor;
    kTabBarSelectedTextColor = kDarkPinkColor;
    kTabBarUnselectedTextColor = kGreyColor;
    kTabBarDayLabelUnselectedTextColor = kGreyColor;
    kPhoneLabelBackgroundColor = kLightGreyColor;
    kHeaderViewColor = kLightGreyColor;
    kChatMessageColor = kDarkGreyColor;
    kDateLabelWrapperViewBackgroundColor = kDarkGreyColor;
    kTypingContainerViewColor = kWhiteColor;
    kTaskPriceTextColor = kDarkPinkColor;
    kTableViewBackgroundColor = [UIColor colorWithRed:236. / 255 green:237. / 255 blue:238. / 255 alpha:1];
    kProfileImageTextColor = kLightBlackColor;
    kChatTitleColor = kIconsColor;
    kChatBalloonImageViewColor = [UIColor colorWithRed:226. / 255 green:255. / 255 blue:199. / 255 alpha:1];
    kNavigationBarBarTintColor = [UIColor colorWithRed:249. / 255 green:249. / 255 blue:249. / 255 alpha:1];
    kPhoneLabelTextColor = [UIColor blackColor];
    kWeChatImageColor = kDarkPinkColor;
    kNavigationBarTitleColor = [UIColor colorWithRed:131. / 255 green:131. / 255 blue:131. / 255 alpha:1];
    kClubViewLabelBackgroundColor = [UIColor colorWithRed:65. / 255 green:45. / 255 blue:45. / 255 alpha:0.1];
    kClubViewLabelColor = [UIColor colorWithRed:65. / 255 green:45. / 255 blue:45. / 255 alpha:1];
    kClubViewButtonColor = kDarkPinkColor;
    kChatLeftMessageTextColor = [UIColor blackColor];
    kChatRightMessageTextColor = [UIColor blackColor];
    kChatLeftBalloonImageViewColor = kWhiteColor;
    kChatTextViewTintColor = kDarkPinkColor;
    kProfileTableViewBackgroundColor = kLightGreyColor;
    kChatSendTextColor = [UIColor colorWithRed:195. / 255 green:195. / 255 blue:195. / 255 alpha:1];
    kChatLeftTimeLabelTextColor = kAppLabelColor;
    kBadgeColor = kDarkPinkColor;
    kPayButtonTextColor = kWhiteColor;
    kChatRightTimeLabelTextColor = kChatRightMessageTextColor;
    kRightVoiceMessageDurationLabelTextColor = kChatRightTimeLabelTextColor;
    kLeftVoiceMessageDurationLabelTextColor = kChatLeftTimeLabelTextColor;
    kTasksHeaderColor = [UIColor whiteColor];
    kChatTaskIconTextColor = [UIColor colorWithRed:138. / 255 green:140. / 255 blue:143. / 255 alpha:1];
    kChatSendButtonColor = [UIColor colorWithRed:0.71 green:0.61 blue:0.44 alpha:1.0];
    kReceiveVirtualCardBackgroundColor = kMilkColor;
    kReceiveVirtualCardTitleTextColor = kWhiteColor;

    kTabItem2Image = [UIImage imageNamed:@"tabIcon2"];
    kTabItem3Image = [UIImage imageNamed:@"tabIcon3"];
    kTabItem4Image = [UIImage imageNamed:@"tabIcon4"];
    kTabItem5Image = [UIImage imageNamed:@"tabIcon5"];

    kAttachMainColor = [UIColor blackColor];
    kAttachCancelColor = kGoldColor;
    kLeftContactMessageButtonColor = [UIColor blackColor];
    kRightContactMessageButtonColor = [UIColor whiteColor];
    kLeftContactMessageSeperatorColor = [UIColor colorWithRed:220. / 255 green:220. / 255 blue:220. / 255 alpha:1];
    kRightContactMessageSeperatorColor = [UIColor colorWithRed:215. / 255 green:188. / 255 blue:152. / 255 alpha:1];
    kLeftDocumentMessageWrapperBackgroundColor = [UIColor colorWithRed:244. / 255 green:244. / 255 blue:244. / 255 alpha:1];
    kRightDocumentMessageWrapperBackgroundColor = [UIColor colorWithRed:195. / 255 green:168. / 255 blue:130. / 255 alpha:1];

    kUberActionSheetTopPartColor = [UIColor colorWithRed:182 / 255. green:155 / 255. blue:108 / 255. alpha:1];

    kAssistantCellHeight = CGFLOAT_MIN;
    kPersonalContactsSectionHeaderHeight = CGFLOAT_MIN;
    kClubInfoVCInfoLabelText = @"Your contact number is not listed in\n\"Imperia Private Banking\" Concierge Service.\nTo activate Mobile App please provide us your current telephone number.\n";
    kClubInfoVCLine3LabelText = @"is not found in the list of members\n";
    kAppMainColor = @"AB162B";
    kCityGuideBaseUrl = @"https://cityguide.primeconcept.co.uk/";
    kCityGuideBaseUtm = @"";
}

@end