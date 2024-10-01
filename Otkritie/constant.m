//
//  constant.m
//  PRIME
//
//  Created by Mariam on 4/13/17.
//  Copyright © 2017 XNTrends. All rights reserved.
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
NSString* kLoginWithCardText = nil;

NSString* kTabItem1Title = nil;
NSString* kTabItem2Title = nil;
NSString* kTabItem3Title = nil;
NSString* kTabItem4Title = nil;
NSString* kTabItem5Title = nil;
NSString* kCityGuideBaseUrl = nil;
NSString* kCityGuideBaseUtm = nil;
NSString* kUserDefaultsSuiteName = nil;

CGFloat kAssistantCellHeight = 0;
CGFloat kPersonalContactsSectionHeaderHeight = 0;

@interface Brending : NSObject

@end

@implementation Brending

+ (void)load
{
    //Otkritie.
    kClientID = @"451ha55e2ik27lsubjv794o1a";
    kClientSecret = @"bcdrm5lvdjv6gy980rbi4plyb";
    kTargetName = @"open";
    kURLSchemesPrefix = [NSString stringWithFormat:@"%@://", kTargetName];
    kUserDefaultsSuiteName = @"group.com.prime.app.open";
    kClubPhoneNumber = @"+74957750120";
    kMonthsCollectionViewArrowColor = kOpenDarkBlueColor;
    kIconsColor = kOpenLightBlueColor;
    kSegmentedControlTaskStatusColor = kOpenLightBlueColor;
    kTaskSegmentColor = kOpenDarkBlueColor;
    kPayButtonBackgroundColor = kOpenLightBlueColor;
    kReservesOrRequestsSegmentColor = kOpenDarkBlueColor;
    kTabBarBackgroundColor = kOpenDarkBlueColor;
    kTabBarDayLabelUnselectedTextColor = [UIColor colorWithRed:126. / 255 green:135. / 255 blue:144. / 255 alpha:1];
    kCalendarTodayTextColor = kOpenLightBlueColor;
    kNavigationBarTintColor = kOpenDarkBlueColor;
    kDeleteButtonColor = [UIColor redColor];
    kProfileInfoNameColor = [UIColor colorWithRed:211. / 255 green:174. / 255 blue:141. / 255 alpha:1];
    kWelcomeScreenBackgroundColor = kOpenLightBlueColor;
    kWelcomeScreenNextButtonColor = kOpenLightBlueColor;
    kContainerButtonColor = kAppColor;
    kCalendarEventLineColor = kOpenLightBlueColor;
    kCalendarTodayCircleColor = kOpenLightBlueColor;
    kCalendarSelectedDayCircleColor = kOpenLightBlueColor;
    kCalendarTodayButtonColor = kOpenLightBlueColor;
    kCalendarSelectedDayTextColor = [UIColor whiteColor];
    kMonthColor = kOpenDarkBlueColor;
    kTabBarSelectedTextColor = kWhiteColor;
    kTabBarUnselectedTextColor = [UIColor colorWithRed:126. / 255 green:135. / 255 blue:144. / 255 alpha:1];
    kPhoneLabelBackgroundColor = kHeaderBackgroundGrayColor;
    kHeaderViewColor = kHeaderBackgroundGrayColor;
    kChatMessageColor = [UIColor blackColor];
    kDateLabelWrapperViewBackgroundColor = [UIColor colorWithWhite:0.3 alpha:0.4];
    kTypingContainerViewColor = kDarkGrayColor;
    kTaskPriceTextColor = kOpenDarkBlueColor;
    kTableViewBackgroundColor = [UIColor colorWithRed:239. / 255 green:239. / 255 blue:244. / 255 alpha:1];
    kProfileImageTextColor = kWhiteColor;
    kChatTitleColor = kOpenDarkBlueColor;
    kChatTextViewTintColor = kOpenDarkBlueColor;
    kChatBalloonImageViewColor = [UIColor colorWithRed:134. / 255 green:139. / 255 blue:140. / 255 alpha:1];
    kNavigationBarBarTintColor = [UIColor colorWithRed:249. / 255 green:249. / 255 blue:249. / 255 alpha:1];
    kPhoneLabelTextColor = kOpenDarkBlueColor;
    kWeChatImageColor = [UIColor clearColor];
    kNavigationBarTitleColor = [UIColor colorWithRed:131. / 255 green:131. / 255 blue:131. / 255 alpha:1];
    kClubViewLabelBackgroundColor = kHeaderBackgroundGrayColor;
    kClubViewLabelColor = kOpenDarkBlueColor;
    kClubViewButtonColor = kOpenLightBlueColor;
    kChatLeftMessageTextColor = [UIColor blackColor];
    kChatRightMessageTextColor = kWhiteColor;
    kPayButtonTextColor = kWhiteColor;
    kTasksHeaderColor = [UIColor whiteColor];
    kChatLeftBalloonImageViewColor = [UIColor colorWithRed:243. / 255 green:244. / 255 blue:245. / 255 alpha:1];
    kRightVoiceMessageDurationLabelTextColor = [UIColor whiteColor];
    kLeftVoiceMessageDurationLabelTextColor = kChatLeftTimeLabelTextColor;
    kBadgeColor = kOpenLightBlueColor;
    kReceiveVirtualCardBackgroundColor = kOpenDarkBlueColor;
    kReceiveVirtualCardTitleTextColor = kWhiteColor;

    kProfileTableViewBackgroundColor = kWhiteColor;
    kChatSendTextColor = [UIColor colorWithRed:189. / 255 green:201. / 255 blue:201. / 255 alpha:1];
    kChatLeftTimeLabelTextColor = kChatLeftMessageTextColor;
    kChatRightTimeLabelTextColor = kChatRightMessageTextColor;
    kChatTaskIconTextColor = [UIColor colorWithRed:134. / 255 green:139. / 255 blue:140. / 255 alpha:1];
    kChatSendButtonColor = [UIColor colorWithRed:0.71 green:0.61 blue:0.44 alpha:1.0];

    kTabItem2Image = [[UIImage imageNamed:@"tabIcon2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    kTabItem3Image = [[UIImage imageNamed:@"tabIcon3"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    kTabItem4Image = [[UIImage imageNamed:@"tabIcon4"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    kTabItem5Image = [[UIImage imageNamed:@"tabIcon5"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

    kTabItem1Title = @"Calendar";
    kTabItem2Title = @"History";
    kTabItem3Title = @"Requests";
    kTabItem4Title = @"Services";
    kTabItem5Title = @"Profile";
    kCityGuideBaseUrl = @"https://openpb.concierge.ru/lifestyle/";
    kCityGuideBaseUtm = @"";

    kAssistantCellHeight = 40;
    kPersonalContactsSectionHeaderHeight = 25;

    kRequestsBackgroundImage = @"chat_back";
    kChatTypingTextViewPlaceholderText = @"Enter your request";
    kNoRequestsLabelTitle = @"No Requests ";
    kClubInfoVCInfoLabelText = @"";
    kClubInfoVCLine3LabelText = @"Is not found in the client list of program LifeStyle management Открытие PB";
    kLoginWithCardText = @"To use the application please enter your card number of Открытие LifeStyle management";
    kAppMainColor = @"0072BC";
    kInformationBackgroundColor = [UIColor colorWithRed:0. / 255 green:114. / 255 blue:188. / 255 alpha:1];
    kFeatureInfoBackgroundColor = [UIColor colorWithRed:38. / 255 green:60. / 255 blue:78. / 255 alpha:1];
    kFeatureInfoNextButtonColor = [UIColor colorWithRed:198. / 255 green:210. / 255 blue:219. / 255 alpha:1];
    kFeatureInfoTextColor = [UIColor colorWithRed:198. / 255 green:210. / 255 blue:219. / 255 alpha:1];

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
