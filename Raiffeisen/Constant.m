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
UIColor* kUberActionSheetTopPartColor = nil;
UIColor* kChatTextViewTintColor = nil;
UIColor* kChatSendButtonColor = nil;
UIColor* kChatStatusReadColor = nil;
UIColor* kChatLeftTimeLabelTextColor = nil;
UIColor* kChatRightTimeLabelTextColor = nil;
UIColor* kLeftVoiceMessageDurationLabelTextColor = nil;
UIColor* kRightVoiceMessageDurationLabelTextColor = nil;
UIColor* kChatTaskIconTextColor = nil;
UIColor* kTasksHeaderColor = nil;
UIColor* kCalendarTodayCircleColor = nil;
UIColor* kCalendarSelectedDayCircleColor = nil;
UIColor* kPayButtonTextColor = nil;
UIColor* kBadgeColor = nil;
UIColor* kCalendarTodayButtonColor = nil;
UIColor* kPayButtonBackgroundColor = nil;
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
NSString* kClubEmail = nil;

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
    //Raiffeisen.
    kClientID = @"3vep6u6z78nwcaqmgzexpkltd";
    kClientSecret = @"7dcujbgtdrc2qy1wvmkvxalhi";
    kTargetName = @"raiffeisen";
    kURLSchemesPrefix = [NSString stringWithFormat:@"%@://", kTargetName];
    kUserDefaultsSuiteName = @"group.com.prime.app.Raiffeisen";
    kClubPhoneNumber = @"+74957755219";
    kMonthsCollectionViewArrowColor = kRLightGreyColor;
    kIconsColor = kAquamarineColor;
    kSegmentedControlTaskStatusColor = kAquamarineColor;
    kTaskSegmentColor = kAquamarineColor;
    kReservesOrRequestsSegmentColor = kWhiteColor;
    kTabBarBackgroundColor = [UIColor colorWithRed:250. / 255 green:250. / 255 blue:250. / 255 alpha:1];
    kCalendarTodayTextColor = kAquamarineColor;
    kCalendarTodayCircleColor = kAquamarineColor;
    kCalendarSelectedDayCircleColor = kAquamarineColor;
    kCalendarTodayButtonColor = kAquamarineColor;
    kCalendarSelectedDayTextColor = [UIColor whiteColor];
    kNavigationBarTintColor = kAquamarineColor;
    kDeleteButtonColor = kAquamarineColor;
    kProfileInfoNameColor = kAquamarineColor;
    kWelcomeScreenBackgroundColor = [UIColor colorWithRed:47. / 255 green:46. / 255 blue:46. / 255 alpha:1];
    kWelcomeScreenNextButtonColor = kWhiteColor;
    kContainerButtonColor = kAquamarineColor;
    kCalendarEventLineColor = kAquamarineColor;
    kMonthColor = [UIColor colorWithRed:83. / 255 green:83. / 255 blue:90. / 255 alpha:1];
    kTabBarDayLabelUnselectedTextColor = kRDarkGreyColor;
    kTabBarSelectedTextColor = kAquamarineColor;
    kTabBarUnselectedTextColor = kRDarkGreyColor;
    kPhoneLabelBackgroundColor = [UIColor colorWithRed:37. / 255 green:37. / 255 blue:37. / 255 alpha:1];
    kHeaderViewColor = kRWhiteColor;
    kChatMessageColor = [UIColor blackColor];
    kDateLabelWrapperViewBackgroundColor = [UIColor colorWithWhite:0.3 alpha:0.4];
    kTypingContainerViewColor = kRWhiteColor;
    kTaskPriceTextColor = kBrownColor;
    kTableViewBackgroundColor = [UIColor colorWithRed:250. / 255 green:250. / 255 blue:250. / 255 alpha:1];
    kProfileImageTextColor = kWhiteColor;
    kChatTitleColor = kWhiteColor;
    kChatBalloonImageViewColor = kAquamarineColor;
    kChatLeftBalloonImageViewColor = kRWhiteColor;
    kNavigationBarBarTintColor = [UIColor colorWithRed:00. / 255 green:00. / 255 blue:00. / 255 alpha:1];
    kPhoneLabelTextColor = kWhiteColor;
    kWeChatImageColor = kAquamarineColor;
    kNavigationBarTitleColor = kWhiteColor;
    kClubViewLabelBackgroundColor = [UIColor colorWithRed:247. / 255 green:249. / 255 blue:248. / 255 alpha:1];
    kClubViewLabelColor = kWhiteColor;
    kClubViewButtonColor = kAquamarineColor;
    kChatLeftMessageTextColor = [UIColor blackColor];
    kChatRightMessageTextColor = kWhiteColor;
    kProfileTableViewBackgroundColor = kHeaderViewColor;
    kChatSendTextColor = kRDarkGreyColor;
    kPayButtonBackgroundColor = kAquamarineColor;
    kChatTextViewTintColor = kAquamarineColor;
    kChatLeftTimeLabelTextColor = kAppLabelColor;
    kBadgeColor = kAquamarineColor;
    kPayButtonTextColor = kWhiteColor;
    kChatRightTimeLabelTextColor = kChatRightMessageTextColor;
    kRightVoiceMessageDurationLabelTextColor = [UIColor whiteColor];
    kLeftVoiceMessageDurationLabelTextColor = kChatLeftTimeLabelTextColor;
    kTasksHeaderColor = [UIColor whiteColor];
    kChatTaskIconTextColor = [UIColor colorWithRed:138. / 255 green:140. / 255 blue:143. / 255 alpha:1];
    kChatSendButtonColor = [UIColor colorWithRed:0.71 green:0.61 blue:0.44 alpha:1.0];
    kChatStatusReadColor = [UIColor whiteColor];
    kReceiveVirtualCardBackgroundColor = [UIColor colorWithRed:250. / 255 green:250. / 255 blue:250. / 255 alpha:1];;
    kReceiveVirtualCardTitleTextColor = kWhiteColor;

    kTabItem2Image = [UIImage imageNamed:@"tabIcon2"];
    kTabItem3Image = [UIImage imageNamed:@"tabIcon3"];
    kTabItem4Image = [UIImage imageNamed:@"tabIcon4"];
    kTabItem5Image = [UIImage imageNamed:@"tabIcon5"];

    kTabItem1Title = @"Calendar";
    kTabItem2Title = @"Requests";
    kTabItem3Title = @"Concierge";
    kTabItem4Title = @"City Guide";
    kTabItem5Title = @"Me";
    kCityGuideBaseUrl = @"https://prime.travel/";
    kCityGuideBaseUtm = @"utm_source=prime_raiffeisen&utm_medium=mobile_application&utm_campaign=prime_travel_user_landing_from_app_integrated";

    kAssistantCellHeight = CGFLOAT_MIN;
    kPersonalContactsSectionHeaderHeight = CGFLOAT_MIN;

    kChatTypingTextViewPlaceholderText = @"Type message...";
    kNoRequestsLabelTitle = @"No requests";
    kClubInfoVCInfoLabelText = @"";
    kClubInfoVCLine3LabelText = @"Is not found in the client list of concierge service Raiffeisen Premium Banking";
    kLoginWithCardText = @"To use the application please enter your card number of Raiffeisen Premium Banking";
    kAppMainColor = @"74C6C7";
    kInformationBackgroundColor = [UIColor colorWithRed:3. / 255 green:7. / 255 blue:8. / 255 alpha:1];
    kFeatureInfoBackgroundColor = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1];
    kFeatureInfoNextButtonColor = [UIColor colorWithRed:201. / 255 green:201. / 255 blue:201. / 255 alpha:1];
    kFeatureInfoTextColor = [UIColor colorWithRed:201. / 255 green:201. / 255 blue:201. / 255 alpha:1];

    kAttachMainColor = [UIColor blackColor];
    kAttachCancelColor = kGoldColor;
    kLeftContactMessageButtonColor = [UIColor blackColor];
    kRightContactMessageButtonColor = [UIColor whiteColor];
    kLeftContactMessageSeperatorColor = [UIColor colorWithRed:220. / 255 green:220. / 255 blue:220. / 255 alpha:1];
    kRightContactMessageSeperatorColor = [UIColor colorWithRed:215. / 255 green:188. / 255 blue:152. / 255 alpha:1];
    kLeftDocumentMessageWrapperBackgroundColor = [UIColor colorWithRed:244. / 255 green:244. / 255 blue:244. / 255 alpha:1];
    kRightDocumentMessageWrapperBackgroundColor = [UIColor colorWithRed:195. / 255 green:168. / 255 blue:130. / 255 alpha:1];

    kUberActionSheetTopPartColor = kAquamarineColor;
    //Appearance
    [[UITextField appearance] setTintColor:kAquamarineColor];
    [[UITextView appearance] setTintColor:kAquamarineColor];
}

@end
