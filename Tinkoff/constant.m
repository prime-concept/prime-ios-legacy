//
//  constant.m
//  Prime Concierge Club
//
//  Created by Aram on 1/19/18.
//  Copyright © 2018 XNTrends. All rights reserved.
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
UIColor* kLeftVoiceMessageDurationLabelTextColor = nil;
UIColor* kRightVoiceMessageDurationLabelTextColor = nil;
UIColor* kChatLeftBalloonImageViewColor = nil;
UIColor* kProfileTableViewBackgroundColor = nil;
UIColor* kChatSendTextColor = nil;
UIColor* kChatSendButtonColor = nil;
UIColor* kChatStatusReadColor = nil;
UIColor* kChatTextViewTintColor = nil;
UIColor* kUberActionSheetTopPartColor = nil;
UIColor* kChatLeftTimeLabelTextColor = nil;
UIColor* kChatRightTimeLabelTextColor = nil;
UIColor* kChatTaskIconTextColor = nil;
UIColor* kTasksHeaderColor = nil;
UIColor* kCalendarTodayCircleColor = nil;
UIColor* kBadgeColor = nil;
UIColor* kCalendarSelectedDayCircleColor = nil;
UIColor* kPayButtonBackgroundColor = nil;
UIColor* kPayButtonTextColor = nil;
UIColor* kCalendarTodayButtonColor = nil;
UIColor* kChatPhoneButtonColor = nil;
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
NSString* kClubEmail = nil;

NSString* kTabItem1Title = nil;
NSString* kTabItem2Title = nil;
NSString* kTabItem3Title = nil;
NSString* kTabItem4Title = nil;
NSString* kTabItem5Title = nil;
NSString* kUserDefaultsSuiteName = nil;
NSString* kLoginWithCardText = nil;

NSString* kCityGuideBaseUrl = nil;
NSString* kCityGuideBaseUtm = nil;

CGFloat kAssistantCellHeight = 0;
CGFloat kPersonalContactsSectionHeaderHeight = 0;

@interface Brending : NSObject

@end

@implementation Brending

+ (void)load
{
    //Prime Concierge Club.
	kClientID = resolve(@"5ov5kp11f6d9w3a9fggkw6fiz", @"dGlua29mZl9ib3Q=");
	kClientSecret = resolve(@"08z2viw6mr3ydum663vxuprl8", @"dGlua29mZl9ib3RfcGFzcw==");
    kTargetName = @"primeconciergeclub";
    kURLSchemesPrefix = [NSString stringWithFormat:@"%@://", kTargetName];
    kUserDefaultsSuiteName = @"group.com.prime.app.primeconciergeclub";
    kClubPhoneNumber = @"+74952879990";
    kMonthsCollectionViewArrowColor = [UIColor colorWithRed:209. / 255 green:200. / 255 blue:203. / 255 alpha:1];
    kIconsColor = kTinkoffMainColor;
    kBadgeColor = kTinkoffYellowColor;
    kSegmentedControlTaskStatusColor = kTinkoffLightGrayColor;
    kTaskSegmentColor = kTinkoffMainColor;
    kReservesOrRequestsSegmentColor = kTinkoffMainColor;
    kTabBarBackgroundColor = kTinkoffMainColor;
    kCalendarTodayTextColor = [UIColor colorWithRed:237. / 255 green:29. / 255 blue:36. / 255 alpha:1];
    kNavigationBarTintColor = kTinkoffMainColor;
    kDeleteButtonColor = [UIColor redColor];
    kProfileInfoNameColor = [UIColor colorWithRed:211. / 255 green:174. / 255 blue:141. / 255 alpha:1];
    kWelcomeScreenBackgroundColor = [UIColor colorWithRed:88. / 255 green:65. / 255 blue:75. / 255 alpha:1];
    kWelcomeScreenNextButtonColor = kWhiteColor;
    kContainerButtonColor = kTinkoffYellowColor;
    kCalendarEventLineColor = [UIColor colorWithRed:238. / 255 green:57. / 255 blue:35. / 255 alpha:1];
    kCalendarTodayCircleColor = [UIColor redColor];
    kCalendarTodayButtonColor = kTinkoffMainColor;
    kCalendarSelectedDayCircleColor = kTinkoffYellowColor;
    kCalendarSelectedDayTextColor = [UIColor blackColor];
    kPayButtonBackgroundColor = kTinkoffYellowColor;
    kMonthColor = kAppColor;
    kTabBarSelectedTextColor = kWhiteColor;
    kTabBarUnselectedTextColor = kTinkoffLightGrayColor;
    kTabBarDayLabelUnselectedTextColor = kTinkoffMainColor;
    kPhoneLabelBackgroundColor = [UIColor colorWithRed:239. / 255 green:239. / 255 blue:244. / 255 alpha:1];
    kHeaderViewColor = [UIColor colorWithRed:239. / 255 green:239. / 255 blue:244. / 255 alpha:1];
    kChatMessageColor = [UIColor blackColor];
    kDateLabelWrapperViewBackgroundColor = [UIColor colorWithWhite:0.3 alpha:0.4];
    kTypingContainerViewColor = kDarkGrayColor;
    kTaskPriceTextColor = kBrownColor;
    kTableViewBackgroundColor = [UIColor colorWithRed:239. / 255 green:239. / 255 blue:244. / 255 alpha:1];
    kProfileImageTextColor = kWhiteColor;
    kChatTitleColor = kTinkoffMainColor;
    kChatTextViewTintColor = kTinkoffMainColor;
    kChatBalloonImageViewColor = kTinkoffMainColor;
    kNavigationBarBarTintColor = [UIColor colorWithRed:249. / 255 green:249. / 255 blue:249. / 255 alpha:1];
    kPhoneLabelTextColor = [UIColor blackColor];
    kWeChatImageColor = [UIColor clearColor];
    kNavigationBarTitleColor = [UIColor colorWithRed:131. / 255 green:131. / 255 blue:131. / 255 alpha:1];
    kClubViewLabelBackgroundColor = kTinkoffWhiteColor;
    kClubViewLabelColor = kTinkoffMainColor;
    kClubViewButtonColor = kTinkoffMainColor;
    kChatLeftMessageTextColor = [UIColor blackColor];
    kChatRightMessageTextColor = kTinkoffWhiteColor;
    kRightVoiceMessageDurationLabelTextColor = kTinkoffWhiteColor;
    kLeftVoiceMessageDurationLabelTextColor = [UIColor blackColor];
    kChatLeftBalloonImageViewColor = kTinkoffWhiteColor;
    kProfileTableViewBackgroundColor = kWhiteColor;
    kPayButtonTextColor = [UIColor blackColor];
    kChatSendTextColor = [UIColor colorWithRed:195. / 255 green:195. / 255 blue:195. / 255 alpha:1];
    kChatSendButtonColor = [UIColor colorWithRed:0.27 green:0.62 blue:0.84 alpha:1.0];
    kChatStatusReadColor = [UIColor whiteColor];
    kChatLeftTimeLabelTextColor = kAppLabelColor;
    kChatRightTimeLabelTextColor = kTinkoffWhiteColor;
    kTasksHeaderColor = kTinkoffWhiteColor;
    kChatTaskIconTextColor = kTinkoffLightGrayColor;
    kReceiveVirtualCardBackgroundColor = kTinkoffMainColor;
    kReceiveVirtualCardTitleTextColor = kWhiteColor;

    kTabItem2Image = [[UIImage imageNamed:@"tabIcon2"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    kTabItem3Image = [[UIImage imageNamed:@"tabIcon3"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    kTabItem4Image = [[UIImage imageNamed:@"tabIcon4"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    kTabItem5Image = [[UIImage imageNamed:@"tabIcon5"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    kTabItem1Title = @"Calendar";
    kTabItem2Title = @"Requests";
    kTabItem3Title = @"Concierge";
    kTabItem4Title = @"City Guide";
    kTabItem5Title = @"Me";
    kCityGuideBaseUrl = @"https://prime.travel/";
    kCityGuideBaseUtm = @"utm_source=prime_tinkoff&utm_medium=mobile_application&utm_campaign=prime_travel_user_landing_from_app_integrated";
    kClubEmail = @"Tinkoff@concierge.ru";
    
    kAssistantCellHeight = 40;
    kPersonalContactsSectionHeaderHeight = 25;

    kChatTypingTextViewPlaceholderText = @"Type message...";
    kNoRequestsLabelTitle = @"No requests";
    kClubInfoVCInfoLabelText = @"";
    kClubInfoVCLine3LabelText = @"is not found in the list of concierge-service.\nTo activate the application and register, please contact the concierge-service \n+74952879990";
    kAppMainColor = @"3e4758";
    kInformationBackgroundColor = [UIColor colorWithRed:62. / 255 green:71. / 255 blue:88. / 255 alpha:1];

    kUberActionSheetTopPartColor = [UIColor colorWithRed:182 / 255. green:155 / 255. blue:108 / 255. alpha:1];
    kFeatureInfoBackgroundColor = [UIColor colorWithRed:62. / 255 green:71. / 255 blue:88. / 255 alpha:1];
    kFeatureInfoNextButtonColor = [UIColor colorWithRed:191. / 255 green:201. / 255 blue:216. / 255 alpha:1];
    kFeatureInfoTextColor = [UIColor colorWithRed:191. / 255 green:201. / 255 blue:216. / 255 alpha:1];

    kAttachMainColor = [UIColor blackColor];
    kAttachCancelColor = kGoldColor;
    kLeftContactMessageButtonColor = [UIColor blackColor];
    kRightContactMessageButtonColor = [UIColor whiteColor];
    kLeftContactMessageSeperatorColor = [UIColor colorWithRed:220. / 255 green:220. / 255 blue:220. / 255 alpha:1];
    kRightContactMessageSeperatorColor = [UIColor colorWithRed:215. / 255 green:188. / 255 blue:152. / 255 alpha:1];
    kLeftDocumentMessageWrapperBackgroundColor = [UIColor colorWithRed:244. / 255 green:244. / 255 blue:244. / 255 alpha:1];
    kRightDocumentMessageWrapperBackgroundColor = [UIColor colorWithRed:195. / 255 green:168. / 255 blue:130. / 255 alpha:1];

    //Appearance
    [[UITextField appearance] setTintColor:kTinkoffMainColor];
    [[UITextView appearance] setTintColor:kTinkoffMainColor];
}

@end
