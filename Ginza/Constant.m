//
//  Constant.m
//  PRIME
//
//  Created by Gayane on 11/1/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "Constants.h"
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
UIColor* kCalendarSelectedDayTextColor = nil;
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
    //Ginza.
    kClientID = @"6yqbo5wn8edvgc802jdm7r8z4";
    kClientSecret = @"2y9wzi3owq3dmyc097uy4q0wu";
    kTargetName = @"ginza";
    kURLSchemesPrefix = [NSString stringWithFormat:@"%@://", kTargetName];
    kUserDefaultsSuiteName = @"group.com.prime.app.Ginza";
    kClubPhoneNumber = @"+78124587735";
    kMonthsCollectionViewArrowColor = [UIColor colorWithRed:209. / 255 green:200. / 255 blue:203. / 255 alpha:1];
    kIconsColor = kGoldColor;
    kSegmentedControlTaskStatusColor = kLightBrownColor;
    kTaskSegmentColor = kLightBrownColor;
    kReservesOrRequestsSegmentColor = kBrownColor;
    kTabBarBackgroundColor = kBrownColor;
    kPayButtonBackgroundColor = kGoldColor;
    kCalendarTodayTextColor = [UIColor colorWithRed:237. / 255 green:29. / 255 blue:36. / 255 alpha:1];
    kCalendarTodayCircleColor = kLightBrownColor;
    kCalendarSelectedDayCircleColor = kLightBrownColor;
    kCalendarSelectedDayTextColor = [UIColor whiteColor];
    kNavigationBarTintColor = kBrownColor;
    kDeleteButtonColor = [UIColor redColor];
    kProfileInfoNameColor = [UIColor colorWithRed:211. / 255 green:174. / 255 blue:141. / 255 alpha:1];
    kWelcomeScreenBackgroundColor = [UIColor colorWithRed:62. / 255 green:36. / 255 blue:26. / 255 alpha:1];
    kWelcomeScreenNextButtonColor = kWhiteColor;
    kContainerButtonColor = kAppColor;
    kCalendarEventLineColor = [UIColor colorWithRed:238. / 255 green:57. / 255 blue:35. / 255 alpha:1];
    kCalendarTodayButtonColor = kLightBrownColor;
    kMonthColor = kAppColor;
    kTabBarDayLabelUnselectedTextColor = [UIColor colorWithRed:142. / 255 green:117. / 255 blue:127. / 255 alpha:1];
    kTabBarSelectedTextColor = kWhiteColor;
    kTabBarUnselectedTextColor = [UIColor colorWithRed:142. / 255 green:117. / 255 blue:127. / 255 alpha:1];
    kPhoneLabelBackgroundColor = [UIColor colorWithRed:239. / 255 green:239. / 255 blue:244. / 255 alpha:1];
    kHeaderViewColor = [UIColor colorWithRed:239. / 255 green:239. / 255 blue:244. / 255 alpha:1];
    kChatMessageColor = [UIColor blackColor];
    kDateLabelWrapperViewBackgroundColor = [UIColor colorWithWhite:0.3 alpha:0.4];
    kTypingContainerViewColor = kDarkGrayColor;
    kTaskPriceTextColor = kBrownColor;
    kTableViewBackgroundColor = [UIColor colorWithRed:239. / 255 green:239. / 255 blue:244. / 255 alpha:1];
    kProfileImageTextColor = kWhiteColor;
    kChatTitleColor = kGoldColor;
    kChatTextViewTintColor = kGoldColor;
    kChatBalloonImageViewColor = [UIColor colorWithRed:226. / 255 green:255. / 255 blue:199. / 255 alpha:1];
    kNavigationBarBarTintColor = [UIColor colorWithRed:249. / 255 green:249. / 255 blue:249. / 255 alpha:1];
    kPhoneLabelTextColor = [UIColor blackColor];
    kWeChatImageColor = [UIColor clearColor];
    kNavigationBarTitleColor = [UIColor colorWithRed:131. / 255 green:131. / 255 blue:131. / 255 alpha:1];
    kClubViewLabelBackgroundColor = [UIColor colorWithRed:65. / 255 green:45. / 255 blue:45. / 255 alpha:0.1];
    kClubViewLabelColor = [UIColor colorWithRed:65. / 255 green:45. / 255 blue:45. / 255 alpha:1];
    kClubViewButtonColor = [UIColor colorWithRed:200. / 255 green:169. / 255 blue:133. / 255 alpha:1];
    kChatLeftMessageTextColor = [UIColor blackColor];
    kChatRightMessageTextColor = [UIColor blackColor];
    kChatLeftBalloonImageViewColor = kWhiteColor;
    kProfileTableViewBackgroundColor = kWhiteColor;
    kChatSendTextColor = [UIColor colorWithRed:195. / 255 green:195. / 255 blue:195. / 255 alpha:1];
    kChatLeftTimeLabelTextColor = kAppLabelColor;
    kBadgeColor = kGoldColor;
    kPayButtonTextColor = kWhiteColor;
    kChatRightTimeLabelTextColor = kChatRightMessageTextColor;
    kRightVoiceMessageDurationLabelTextColor = kChatRightTimeLabelTextColor;
    kLeftVoiceMessageDurationLabelTextColor = kChatLeftTimeLabelTextColor;
    kTasksHeaderColor = [UIColor whiteColor];
    kChatTaskIconTextColor = [UIColor colorWithRed:180. / 255 green:157. / 255 blue:113. / 255 alpha:1];
    kChatSendButtonColor = [UIColor colorWithRed:0.71 green:0.61 blue:0.44 alpha:1.0];
    kReceiveVirtualCardBackgroundColor = kBrownColor;
    kReceiveVirtualCardTitleTextColor = kWhiteColor;

    kTabItem2Image = [[UIImage imageNamed:@"tabIcon2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    kTabItem3Image = [[UIImage imageNamed:@"tabIcon3"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    kTabItem4Image = [[UIImage imageNamed:@"tabIcon4"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    kTabItem5Image = [[UIImage imageNamed:@"tabIcon5"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

    kAssistantCellHeight = 40;
    kPersonalContactsSectionHeaderHeight = 25;

    kTabItem1Title = @"Calendar";
    kTabItem2Title = @"Requests";
    kTabItem3Title = @"Concierge";
    kTabItem4Title = @"City Guide";
    kTabItem5Title = @"Me";
    kCityGuideBaseUrl = @"https://cityguide.primeconcept.co.uk/";
    kCityGuideBaseUtm = @"";

    kChatTypingTextViewPlaceholderText = @"Type message...";
    kNoRequestsLabelTitle = @"No requests";
    kClubInfoVCInfoLabelText = @"";
    kClubInfoVCLine3LabelText = @"is not found in the list of Ginza concierge-service\n";
    kAppMainColor = @"3F241B";
    kInformationBackgroundColor = [UIColor colorWithRed:63. / 255 green:36. / 255 blue:27. / 255 alpha:1];
    kFeatureInfoBackgroundColor = kBrownColor;
    kFeatureInfoNextButtonColor = [UIColor colorWithRed:182. / 255 green:152. / 255 blue:110. / 255 alpha:1];
    kFeatureInfoTextColor = [UIColor colorWithRed:216. / 255 green:204. / 255 blue:202. / 255 alpha:1];

    kAttachMainColor = [UIColor blackColor];
    kAttachCancelColor = kGoldColor;
    kLeftContactMessageButtonColor = [UIColor blackColor];
    kRightContactMessageButtonColor = [UIColor whiteColor];
    kLeftContactMessageSeperatorColor = [UIColor colorWithRed:220. / 255 green:220. / 255 blue:220. / 255 alpha:1];
    kRightContactMessageSeperatorColor = [UIColor colorWithRed:215. / 255 green:188. / 255 blue:152. / 255 alpha:1];
    kLeftDocumentMessageWrapperBackgroundColor = [UIColor colorWithRed:244. / 255 green:244. / 255 blue:244. / 255 alpha:1];
    kRightDocumentMessageWrapperBackgroundColor = [UIColor colorWithRed:195. / 255 green:168. / 255 blue:130. / 255 alpha:1];

    kUberActionSheetTopPartColor = [UIColor colorWithRed:182 / 255. green:155 / 255. blue:108 / 255. alpha:1];
}

@end
