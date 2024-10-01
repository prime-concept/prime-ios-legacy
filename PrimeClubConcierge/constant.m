//
//  constant.m
//  PRIME RRClub
//
//  Created by armens on 3/28/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import "Constants.h"
#import <Foundation/Foundation.h>
#import "Config.h"

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
UIColor* kChatStatusReadColor = nil;
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
UIColor* kCalendarSelectedDayTextColor = nil;
UIColor* kTabBarDayLabelSelectedTextColor = nil;
UIColor* kTabBarDayLabelUnselectedTextColor = nil;
UIColor* kInformationBackgroundColor = nil;
UIColor* kFeatureInfoBackgroundColor = nil;
UIColor* kFeatureInfoNextButtonColor = nil;
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
NSString* kNoRequestsLabelTitle = nil;
NSString* kChatTypingTextViewPlaceholderText = nil;
NSString* kRequestsBackgroundImage = nil;
NSString* kClubEmail = nil;

NSString* kTabItem1Title = nil;
NSString* kTabItem2Title = nil;
NSString* kTabItem3Title = nil;
NSString* kTabItem4Title = nil;
NSString* kTabItem5Title = nil;
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
    // Prime Club Concierge
	kClientID = resolve(@"l9E8aAYEecA=", @"gSXr3FxfHc8=");
    kClientSecret = resolve(@"aSyWKxaNOBztuieGHPxq2oupuLXJszZPSaDf4wYdKKg=", @"F7Alt9hglIBE2E/dpeSJ7pxHN1wUzpu3S+oULgmZ/ks=");
    kTargetName = @"primeclubconcierge";
    kURLSchemesPrefix = [NSString stringWithFormat:@"%@://", kTargetName];
    kUserDefaultsSuiteName = @"group.com.prime.app.primeclubconcierge";
    kClubPhoneNumber = @"+79636464500";
    kLoginWithCardText = @"To use the application please enter your card number of Прайм Клуб Консьерж by Prime";
    kMonthsCollectionViewArrowColor = [UIColor colorWithRed:209. / 255 green:200. / 255 blue:203. / 255 alpha:1];
    kIconsColor = kAClubMainColor;
    kBadgeColor = KAClubRed;
    kSegmentedControlTaskStatusColor = kAClubMainColor;
    kTaskSegmentColor = kAClubMainColor;
    kReservesOrRequestsSegmentColor = kAClubMainColor;
    kTabBarBackgroundColor = [UIColor colorWithRed:32. / 255 green:32. / 255 blue:32. / 255 alpha:1];;
    kCalendarTodayTextColor = [UIColor colorWithRed:237. / 255 green:29. / 255 blue:36. / 255 alpha:1];
    kNavigationBarTintColor = [UIColor blackColor];
    kDeleteButtonColor = [UIColor redColor];
    kProfileInfoNameColor = [UIColor colorWithRed:211. / 255 green:174. / 255 blue:141. / 255 alpha:1];
    kWelcomeScreenBackgroundColor = [UIColor colorWithRed:88. / 255 green:65. / 255 blue:75. / 255 alpha:1];
    kWelcomeScreenNextButtonColor = kWhiteColor;
    kContainerButtonColor = kAppColor;
    kCalendarEventLineColor = [UIColor colorWithRed:238. / 255 green:57. / 255 blue:35. / 255 alpha:1];
    kCalendarTodayCircleColor = kAClubMainColor;
    kCalendarSelectedDayCircleColor = [UIColor colorWithRed:238. / 255 green:49. / 255 blue:35. / 255 alpha:1];
    kCalendarTodayButtonColor = kAClubMainColor;
    kCalendarSelectedDayTextColor = [UIColor whiteColor];
    kPayButtonBackgroundColor = KAClubRed;
    kMonthColor = kAppColor;
	kTabBarDayLabelSelectedTextColor = kWhiteColor;
	kTabBarDayLabelUnselectedTextColor = kAClubMainColor;
    kTabBarSelectedTextColor = kWhiteColor;
    kTabBarUnselectedTextColor = [UIColor colorWithRed:90. / 255 green:90. / 255 blue:90. / 255 alpha:1];
    kPhoneLabelBackgroundColor = [UIColor colorWithRed:239. / 255 green:239. / 255 blue:244. / 255 alpha:1];
    kHeaderViewColor = [UIColor colorWithRed:239. / 255 green:239. / 255 blue:244. / 255 alpha:1];
    kChatMessageColor = [UIColor blackColor];
    kDateLabelWrapperViewBackgroundColor = [UIColor clearColor];
    kTypingContainerViewColor = kDarkGrayColor;
    kTaskPriceTextColor = kBrownColor;
    kTableViewBackgroundColor = [UIColor colorWithRed:239. / 255 green:239. / 255 blue:244. / 255 alpha:1];
    kProfileImageTextColor = kWhiteColor;
    kChatTitleColor = [UIColor blackColor];
    kChatTextViewTintColor = kAClubMainColor;
    kChatBalloonImageViewColor = [UIColor colorWithRed:128 / 255.0f green:128. / 255.0f blue:128. / 255.0f alpha:1];
    kNavigationBarBarTintColor = [UIColor colorWithRed:249. / 255 green:249. / 255 blue:249. / 255 alpha:1];
    kPhoneLabelTextColor = [UIColor blackColor];
    kWeChatImageColor = [UIColor clearColor];
    kNavigationBarTitleColor = [UIColor colorWithRed:131. / 255 green:131. / 255 blue:131. / 255 alpha:1];
    kClubViewLabelBackgroundColor = [UIColor colorWithRed:65. / 255 green:45. / 255 blue:45. / 255 alpha:0.1];
    kClubViewLabelColor = [UIColor colorWithRed:65. / 255 green:45. / 255 blue:45. / 255 alpha:1];
    kClubViewButtonColor = [UIColor colorWithRed:200. / 255 green:169. / 255 blue:133. / 255 alpha:1];
    kChatLeftMessageTextColor = [UIColor blackColor];
    kChatRightMessageTextColor = [UIColor whiteColor];
    kChatLeftBalloonImageViewColor = kWhiteColor;
    kProfileTableViewBackgroundColor = kWhiteColor;
    kChatSendTextColor = [UIColor colorWithRed:195. / 255 green:195. / 255 blue:195. / 255 alpha:1];
    kChatLeftTimeLabelTextColor = [UIColor blackColor];
    kChatRightTimeLabelTextColor = [UIColor colorWithWhite:1.0 alpha:0.54];
    kRightVoiceMessageDurationLabelTextColor = [UIColor whiteColor];
    kLeftVoiceMessageDurationLabelTextColor = [UIColor blackColor];
    kPayButtonTextColor = kWhiteColor;
    kTasksHeaderColor = [UIColor whiteColor];
    kChatTaskIconTextColor = [UIColor colorWithRed:138. / 255 green:140. / 255 blue:143. / 255 alpha:1];
    kChatSendButtonColor = kAClubMainColor;
    kChatStatusReadColor = [UIColor whiteColor];
    kReceiveVirtualCardBackgroundColor = kAClubMainColor;
    kReceiveVirtualCardTitleTextColor = kWhiteColor;

    kRequestsBackgroundImage = @"chat_back";

    kTabItem2Image = [[UIImage imageNamed:@"tabIcon2"] imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate];
	kTabItem3Image = [[UIImage imageNamed:@"tabIcon3"] imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate];
	kTabItem4Image = [[UIImage imageNamed:@"tabIcon4"] imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate];
	kTabItem5Image = [[UIImage imageNamed:@"tabIcon5"] imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate];

    kTabItem1Title = @"Calendar";
    kTabItem2Title = @"Requests";
    kTabItem3Title = @"PRIME";
    kTabItem4Title = @"City Guide";
    kTabItem5Title = @"Me";
    kCityGuideBaseUrl = @"https://prime.travel/";
    kCityGuideBaseUtm = @"utm_source=prime_a_club&utm_medium=mobile_application&utm_campaign=prime_travel_user_landing_from_app_integrated";
    kClubEmail = @"A-Club@concierge.ru";

    kAssistantCellHeight = 40;
    kPersonalContactsSectionHeaderHeight = 25;

    kChatTypingTextViewPlaceholderText = @"Type message...";
    kNoRequestsLabelTitle = @"No requests";
    kClubInfoVCInfoLabelText = @"";
    kClubInfoVCLine3LabelText = @"is not recognized by the Concierge-service Прайм Клуб Консьерж by Prime\n";
    kAppMainColor = @"333333";
    kInformationBackgroundColor = kBrownColor;
    kFeatureInfoBackgroundColor = kBrownColor;
    kFeatureInfoNextButtonColor = [UIColor colorWithRed:182. / 255 green:152. / 255 blue:110. / 255 alpha:1];
    kFeatureInfoTextColor = [UIColor colorWithRed:216. / 255 green:204. / 255 blue:202. / 255 alpha:1];

    kAttachMainColor = [UIColor blackColor];
    kAttachCancelColor = kAClubMainColor;
    kLeftContactMessageButtonColor = [UIColor blackColor];
    kRightContactMessageButtonColor = [UIColor whiteColor];
    kLeftContactMessageSeperatorColor = [UIColor colorWithRed:220. / 255 green:220. / 255 blue:220. / 255 alpha:1];
    kRightContactMessageSeperatorColor = [UIColor colorWithRed:215. / 255 green:188. / 255 blue:152. / 255 alpha:1];
    kLeftDocumentMessageWrapperBackgroundColor = [UIColor colorWithRed:244. / 255 green:244. / 255 blue:244. / 255 alpha:1];
    kRightDocumentMessageWrapperBackgroundColor = [UIColor colorWithRed:195. / 255 green:168. / 255 blue:130. / 255 alpha:1];

    kUberActionSheetTopPartColor = [UIColor colorWithRed:182 / 255. green:155 / 255. blue:108 / 255. alpha:1];
}

@end
