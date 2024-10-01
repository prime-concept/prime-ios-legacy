//
//  Constants.h
//  PRIME
//
//  Created by Simon on 12/01/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#ifndef PRIME_Constants_h
#define PRIME_Constants_h

#import <Foundation/NSString.h>
@import UIKit;

#pragma mark functionality

//#define NEW_IMPLEMENTATION
#define TRANSACTION_FUNC
#define EXPENSES_FUNC

#if defined(TRANSACTION_FUNC) || defined(EXPENSES_FUNC)
#define REPORTS_FUNC
#endif

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define IS_IPHONE_4 (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double)480) < DBL_EPSILON)
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_IPHONE_6P (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double)736) < DBL_EPSILON)
#define IS_IPHONE_X (IS_IPHONE && SCREEN_MAX_LENGTH == 812.0)
#define IS_IPHONE_XR (IS_IPHONE && SCREEN_MAX_LENGTH == 896.0)
#define IS_IPHONE_XS (IS_IPHONE && SCREEN_MAX_LENGTH == 812.0)
#define IS_IPHONE_XS_MAX (IS_IPHONE && SCREEN_MAX_LENGTH == 896.0)
#define IS_IPHONE_X_SERIES (IS_IPHONE_XR || IS_IPHONE_XS || IS_IPHONE_X || IS_IPHONE_XS_MAX)

#define CHAT_BASE64_ENCODING_FUNC
#define CHAT_FUNC
#define NOTIFICATION_FUNC
#define REQUEST_SHARING_FUNC
#define ENABLE_INITIATION_REQUEST_BUTTONS_IN_CHAT
//#define ENABLE_TEST_MESSAGES_SENDER
//#define ENABLE_PROFILE_NAME_EDITING

#pragma mark constants

#ifdef DEBUG_MODE
#define DLog(s, ...) NSLog(@"<%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])
#else
#define DLog(s, ...)
#endif

#if !USE_PRODUCTION_SERVER && !USE_XNTEST_SERVER && !USE_DEVELOPMENT_SERVER && !USE_XNCITEST_SERVER
#define USE_PRODUCTION_SERVER 1
#endif

#if USE_PRODUCTION_SERVER
#if USE_XNTEST_SERVER || USE_DEVELOPMENT_SERVER || USE_XNCITEST_SERVER
#error Only one of USE_PRODUCTION_SERVER, USE_XNTEST_SERVER, USE_DEVELOPMENT_SERVER, USE_XNCITEST_SERVER can be enabled !
#endif
#define BASE_URL_ROOT @"v3"
#define kServerBaseUrl2 @"https://api.primeconcept.co.uk/" BASE_URL_ROOT
#endif

#if USE_XNTEST_SERVER
#if USE_PRODUCTION_SERVER || USE_DEVELOPMENT_SERVER || USE_XNCITEST_SERVER
#error Only one of USE_PRODUCTION_SERVER, USE_XNTEST_SERVER, USE_DEVELOPMENT_SERVER, USE_XNCITEST_SERVER can be enabled !
#endif
#define BASE_URL_ROOT @"prime"
#define kServerBaseUrl2 @"http://test.xntrends.com/" BASE_URL_ROOT
#endif

#define double_str(s) str(s)
#define str(s) #s

#define _XNCITEST_SERVER_URL XNCITEST_SERVER_URL
#define XNCITEST_SERVER_BASE_URL double_str(_XNCITEST_SERVER_URL)

#if USE_XNCITEST_SERVER
#if USE_PRODUCTION_SERVER || USE_DEVELOPMENT_SERVER || USE_XNTEST_SERVER
#error Only one of USE_PRODUCTION_SERVER, USE_XNTEST_SERVER, USE_DEVELOPMENT_SERVER, USE_XNCITEST_SERVER can be enabled !
#endif
#define BASE_URL_ROOT @"prime_ci"
#define kServerBaseUrl2 @"http://" XNCITEST_SERVER_BASE_URL @"/" BASE_URL_ROOT
#endif

#if USE_DEVELOPMENT_SERVER
#if USE_PRODUCTION_SERVER || USE_XNTEST_SERVER || USE_XNCITEST_SERVER
#error Only one of USE_PRODUCTION_SERVER, USE_XNTEST_SERVER, USE_DEVELOPMENT_SERVER, USE_XNCITEST_SERVER can be enabled !
#endif
#define BASE_URL_ROOT @"service"
#define kServerBaseUrl2 @"https://test.primeconcept.co.uk/" BASE_URL_ROOT
#endif

#define kManageSubscriptionsUrl @"https://www.primeconcept.co.uk/subscriptions?access_token=&color="
#define kClubRulesUrl @"https://www.primeconcept.co.uk/rules.html"
#define kClubUrl @"http://www.primeconcept.co.uk"
#define kPondMobileRatesUrl @"https://pondmobile.com/rates"

extern NSString* kClubPhoneNumber;
extern NSString* kClubEmail;

#define kParseAppId @"86tfzA2yOPBYD1IZlnjzfDNuE0r083Z9KdRPVdky"
#define KParseClientKey @"6KsPmZHHkvdNzmxaX4DbqlSverP2KQq4GYHHKtKn"

// Chat server settings

#if !USE_CHAT_PRODUCTION_SERVER && !USE_XNCICHAT_SERVER
#define USE_CHAT_PRODUCTION_SERVER 1
#endif

#if USE_CHAT_PRODUCTION_SERVER
#if USE_XNCICHAT_SERVER
#error Only one of USE_CHAT_PRODUCTION_SERVER, USE_XNCICHAT_SERVER can be enabled !
#endif
#define kWebsocketRegistrationUrl2 @"wss://chat.primeconcept.co.uk/chat-server/v3_1/messages?access_token=%@&X-Client-Id=%@&X-Device-Id=%@"
#define kChatBaseUrl2 @"https://chat.primeconcept.co.uk/chat-server/v3_1/"
//#define kChatUrl @"ws://test.primeconcept.co.uk:8080/chat/chat"
#endif

#if USE_XNCICHAT_SERVER
#if USE_CHAT_PRODUCTION_SERVER
#error Only one of USE_CHAT_PRODUCTION_SERVER, USE_XNCICHAT_SERVER can be enabled !
#endif

#define double_str(s) str(s)
#define str(s) #s

#define _XNCICHAT_SERVER_URL XNCICHAT_SERVER_URL
#define XNCICHAT_SERVER_BASE_URL double_str(_XNCICHAT_SERVER_URL)

#define kWebsocketRegistrationUrl @"ws://" XNCICHAT_SERVER_BASE_URL
#define kChatBaseUrl @"http://" XNCICHAT_SERVER_BASE_URL
#endif

///////////////////////

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] floatValue] >= v)
#define kLocationFilteringMaxDelta 0.5

extern NSString* kClientID;
extern NSString* kClientSecret;
extern NSString* kAppMainColor;
extern NSString* kTargetName;

#define kUberServerUrl @"https://api.uber.com"
#define kUberClientID @"lM5cZ5SLvDrow7PfqTvC3FuXBFgpsp9a"
#define kUberClientSecret @"Dr5-LEgzx-ZYWrpplTeHJZKspW1XU6MzJuGInz_U"
#define kUberServerToken @"bFYbE18-jOAaFy-kbaH0g2ivPYWMOMnmhiH_IcBS"
#define kUberAppId @"lM5cZ5SLvDrow7PfqTvC3FuXBFgpsp9a"

#define kMinPhoneNumberLength (1)
#define kMaxPhoneNumberLength (20)
#define kMinSMSCodeLength (4)
#define kMaxSMSCodeLength (4)
#define kMinTransactionHistory (20)

#define kTopTenPage @"%@?%@client_id=%@&open_city=%@&prefix=%@&phone=%@&token=%@"
#define kTopTenFlowers @"?client_id=%@&longitude=%@&latitude=%@&phone=%@&prefix=%@&user_token=%@&env=webview"

#define kUserRegistered @"userLogined"
#define kCoreDataDidSetup @"coreDataDidSetup"
#define kCoreDataDidSetupKey @"coreDataSetup"
#define kSendUUIDKey @"sendUUID"
#define kIsAfterRegistration @"isAfterRegistration"
#define kUserPhoneNumber @"kUserPhoneNumber"
#define kCustomerId @"kCustomerId"
#define kCardDataKeyPath @"cards"
#define kCredentialKeyPath @"credential"
#define kUserNameKey @"userNameKey"
#define kUserPasscode @"passcodeKey"

#define COUNTRY_CODE_RUSSIA @"RU"
#define DEFAULT_TIME_ZONE @"3"
#define DEFAULT_TIME_ZONE_ISO8601 (@"+0" DEFAULT_TIME_ZONE @"00")
#define DEFAULT_TIME_ZONE_INT ([DEFAULT_TIME_ZONE intValue])
#define DEFAULT_TIME_FORMAT @"dd MMMM yyyy"
#define DATE_DAY_FORMAT @"yyyy-MM-dd"
#define DATE_MONTH_FORMAT @"yyyy-MM"
#define DATE_FORMAT_ddMMyyyy @"dd-MM-yyyy"

#define DEFAULT_PHONE_FORMAT @"# (###) ###-##-##-##-##-##-##"

#if PrimeRRClub
#define DEFAULT_CARD_FORMAT @"#########"
#elif PrimeClubConcierge
#define DEFAULT_CARD_FORMAT @"### ### ###"
#else
#define DEFAULT_CARD_FORMAT @"#### #### #### ####"
#endif

#define EXPIRY_DATE_FORMAT @"MM/yy"

#pragma mark apperance
/**
 * URLSchemes
 */
extern NSString* kURLSchemesPrefix;

/**
 * Information Background Color
 */
extern UIColor* kInformationBackgroundColor;

/**
 * Base colors
 */
//PRIME
#define kWhiteColor [UIColor whiteColor]
#define kBrownColor [UIColor colorWithRed:63. / 255 green:36. / 255 blue:27. / 255 alpha:1]
#define kGoldColor [UIColor colorWithRed:200. / 255 green:169. / 255 blue:133. / 255 alpha:1]
#define kLightBrownColor [UIColor colorWithRed:181. / 255 green:156. / 255 blue:115. / 255 alpha:1]
#define kTextGreyColor [UIColor colorWithRed:148. / 255 green:148. / 255 blue:148. / 255 alpha:1]

//IMPERIA
#define kDarkPinkColor [UIColor colorWithRed:171. / 255 green:22. / 255 blue:43. / 255 alpha:1]
#define kLightBlackColor [UIColor colorWithRed:35. / 255 green:31. / 255 blue:32. / 255 alpha:1]
#define kDarkGreyColor [UIColor colorWithRed:64. / 255 green:64. / 255 blue:65. / 255 alpha:1]
#define kGreyColor [UIColor colorWithRed:146. / 255 green:146. / 255 blue:146. / 255 alpha:1]
#define kLightGreyColor [UIColor colorWithRed:219. / 255 green:220. / 255 blue:222. / 255 alpha:1]
#define kMilkColor [UIColor colorWithRed:246. / 255 green:248. / 255 blue:247. / 255 alpha:1]

//Raiffeisen
#define kAquamarineColor [UIColor colorWithRed:116. / 255 green:198. / 255 blue:199. / 255 alpha:1]
#define kRDarkGreyColor [UIColor colorWithRed:146. / 255 green:146. / 255 blue:146. / 255 alpha:1]
#define kRLightGreyColor [UIColor colorWithRed:178. / 255 green:178. / 255 blue:178. / 255 alpha:1]
#define kRWhiteColor [UIColor colorWithRed:246. / 255 green:246. / 255 blue:246. / 255 alpha:1]
#define kRBlackColor [UIColor colorWithRed:29. / 255 green:26. / 255 blue:23. / 255 alpha:1]
#define kBecomeClientEnabledColor [UIColor colorWithRed:85. / 255 green:198. / 255 blue:186. / 255 alpha:1]

//VTB
#define kVTBGoldColor [UIColor colorWithRed:0.73 green:0.59 blue:0.35 alpha:1.0]
#define kVTBBlackColor [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0]
#define kVTBMilkColor [UIColor colorWithRed:247. / 255 green:245. / 255 blue:246. / 255 alpha:1]
#define kVTBLightGreyColor [UIColor colorWithRed:241. / 255 green:241. / 255 blue:241. / 255 alpha:1]
#define kVTBGreyColor [UIColor colorWithRed:158. / 255 green:158. / 255 blue:158. / 255 alpha:1]
#define kVTBDarkGreyColor [UIColor colorWithRed:83. / 255 green:83. / 255 blue:83. / 255 alpha:1]

//Otkritie
#define kOpenDarkBlueColor [UIColor colorWithRed:32. / 255 green:58. / 255 blue:77. / 255 alpha:1]
#define kOpenLightBlueColor [UIColor colorWithRed:24. / 255 green:116. / 255 blue:191. / 255 alpha:1]
#define kOpenDarkGrayColor [UIColor colorWithRed:60. / 255 green:77. / 255 blue:91. / 255 alpha:1]
#define kHeaderBackgroundGrayColor [UIColor colorWithRed:239. / 255 green:239. / 255 blue:244. / 255 alpha:1]

//Aeroflot
#define kAeroflotBlackColor [UIColor colorWithRed:0. / 255 green:0. / 255 blue:0. / 255 alpha:1]
#define kAeroflotDarkGrayColor [UIColor colorWithRed:153. / 255 green:153. / 255 blue:153. / 255 alpha:1]
#define kAeroflotGrayColor [UIColor colorWithRed:205. / 255 green:204. / 255 blue:204. / 255 alpha:1]
#define kAeroflotWhiteColor [UIColor colorWithRed:248. / 255 green:248. / 255 blue:248. / 255 alpha:1]
#define kAeroflotRedColor [UIColor colorWithRed:205. / 255 green:51. / 255 blue:51. / 255 alpha:1]

//Skolkovo
#define kSkolkovoMainColor [UIColor colorWithRed:23. / 255 green:53. / 255 blue:30. / 255 alpha:1]
#define kSkolkovoLightGreenColor [UIColor colorWithRed:0. green:85. / 255 blue:64. / 255 alpha:1]
#define kSkolkovoWhiteColor [UIColor colorWithRed:231. / 255 green:242. / 255 blue:229. / 255 alpha:1]

//Prime Concierge Club
#define kTinkoffMainColor [UIColor colorWithRed:62. / 255 green:71. / 255 blue:88. / 255 alpha:1]
#define kTinkoffLightGrayColor [UIColor colorWithRed:199. / 255 green:201. / 255 blue:204. / 255 alpha:1]
#define kTinkoffWhiteColor [UIColor colorWithRed:239. / 255 green:239. / 255 blue:239. / 255 alpha:1]
#define kTinkoffYellowColor [UIColor colorWithRed:255. / 255 green:221. / 255 blue:45. / 255 alpha:1]

// PrivateBankingPRIMEClub
#define kGazprombankMainColor [UIColor colorWithRed:45. / 255 green:47. / 255 blue:54. / 255 alpha:1];
#define KGazprombankGrayColor [UIColor colorWithRed:216. / 255 green:216. / 255 blue:216. / 255 alpha:1];

//RRClub
#define kRRClubMainColor [UIColor colorWithRed:27. / 255 green:28. / 255 blue:29. / 255 alpha:1];

// Davidoff
#define kDavidoffMainColor [UIColor colorWithRed:184. / 255 green:145. / 255 blue:74. / 255 alpha:1];

// Prime Club Concierge
#define kAClubMainColor [UIColor colorWithRed:51. / 255 green:51. / 255 blue:51. / 255 alpha:1];
#define KAClubRed [UIColor colorWithRed:239. / 255 green:49. / 255 blue:35. / 255 alpha:1]

extern UIColor* kIconsColor;
extern UIColor* kTaskSegmentColor;

extern UIImage* kTabItem2Image;
extern UIImage* kTabItem3Image;
extern UIImage* kTabItem4Image;
extern UIImage* kTabItem5Image;
/**
 * Themes
 */

#define kAppColor kBrownColor
extern UIColor* kSegmentedControlTaskStatusColor;
extern UIColor* kReservesOrRequestsSegmentColor;
extern UIColor* kContainerButtonColor;
extern UIColor* kWeChatImageColor;
extern UIColor* kChatTaskIconTextColor;
extern UIColor* kTasksHeaderColor;
extern UIColor* kBadgeColor;

/**
 * Requests Tab
 */
#define kLabelNameFont [UIFont systemFontOfSize:16]
#define kLabelDescriptionFont [UIFont systemFontOfSize:12 weight:0]

#define kUberLabelTextColor [UIColor colorWithRed:180. / 255 green:156. / 255 blue:108. / 255 alpha:1]
#define kUberSurgeColor [UIColor colorWithRed:139 / 255.f green:214 / 255.f blue:228 / 255.f alpha:1]
#define kUberEstimatedArriveTimeLabelColor [UIColor colorWithRed:205 / 255. green:187 / 255. blue:162 / 255. alpha:1]
#define kToPayRequestBackgroundColor [UIColor colorWithRed:251 / 255. green:249 / 255. blue:244 / 255. alpha:1]
#define kToPayRequestTransparentBackgroundColor [UIColor colorWithRed:251 / 255. green:249 / 255. blue:244 / 255. alpha:0.5]
#define kLineColor [UIColor colorWithRed:188. / 255 green:189. / 255 blue:192. / 255 alpha:1]

extern NSString* kNoRequestsLabelTitle;
extern NSString* kRequestsBackgroundImage;

/**
 * MonthCollectionViewColors
 */
extern UIColor* kMonthsCollectionViewArrowColor;

/**
 * Welcome Screen
 */
#define kWelcomeScreenTextColor [UIColor colorWithRed:183. / 255 green:170. / 255 blue:177. / 255 alpha:1]
extern UIColor* kWelcomeScreenBackgroundColor;
extern UIColor* kWelcomeScreenNextButtonColor;

/**
 * Navigation Bar
 */

static const CGFloat kNavBarHeight = 44.0f;
#ifdef PrimeRRClub
#define kNavigationBarTitleTextColor [UIColor blackColor]
#else
#define kNavigationBarTitleTextColor [UIColor colorWithRed:132. / 255 green:132. / 255 blue:132. / 255 alpha:1]
#endif

extern UIColor* kNavigationBarTintColor;
extern UIColor* kNavigationBarBarTintColor;
extern UIColor* kNavigationBarTitleColor;

/**
 * Tab Bar
 */
extern UIColor* kTabBarSelectedTextColor;
extern UIColor* kTabBarUnselectedTextColor;
extern UIColor* kTabBarDayLabelSelectedTextColor;
extern UIColor* kTabBarDayLabelUnselectedTextColor;
#define kTabBarSelectedIconColor kTabBarSelectedTextColor
extern UIColor* kTabBarBackgroundColor;

#define kBadgeTextColor kWhiteColor
#define kBadgeBackgroundColor kBadgeColor
#define kBadgeFontSize 13

/**
 * Calendar themes
 */
#define kCalendarDotColor [UIColor colorWithRed:194. / 255 green:193. / 255 blue:193. / 255 alpha:1]
#define kCalendarLineColor [UIColor colorWithRed:188. / 255 green:189. / 255 blue:192. / 255 alpha:1]

#define kCalendarDayCircleColorSelected [UIColor blackColor]
#define kCalendarDayCircleColorSelectedOtherMonth kNavigationBarTitleTextColor

extern UIColor* kCalendarTodayTextColor;
extern UIColor* kCalendarEventLineColor;
extern UIColor* kCalendarTodayCircleColor;
extern UIColor* kCalendarSelectedDayTextColor;
extern UIColor* kCalendarSelectedDayCircleColor;
extern UIColor* kCalendarTodayButtonColor;

#define kCalendarTodayTextColorSelected [UIColor whiteColor]
#define kCalendarTodayTextColorSelectedOtherMonth kCalendarTodayTextColorSelected
#define kCalendarTodayTextColorOtherMonth kCalendarTodayTextColor

#define kCalendarDayCircleColorToday kCalendarTodayTextColorSelected
#define kCalendarDayCircleColorTodaySelected kCalendarTodayTextColor
#define kCalendarDayCircleColorTodayOtherMonth kCalendarDayCircleColorToday
#define kCalendarDayCircleColorTodaySelectedOtherMonth kCalendarDayCircleColorTodaySelected

#define kCalendarWeekDayBackgroundColor [UIColor whiteColor]

/**
 * Profile themes
 */
extern UIColor* kProfileInfoNameColor;
extern UIColor* kProfileImageTextColor;
extern UIColor* kReceiveVirtualCardBackgroundColor;
extern UIColor* kReceiveVirtualCardTitleTextColor;
#define kProfileInfoValueColor [UIColor colorWithRed:75. / 255 green:75. / 255 blue:77. / 255 alpha:1]

extern CGFloat kAssistantCellHeight;
extern CGFloat kPersonalContactsSectionHeaderHeight;

/**
 * City Guide
 */
extern NSString* kCityGuideBaseUrl;
extern NSString* kCityGuideBaseUtm;

/**
 * User Defaults Suite Name
 */

extern NSString* kUserDefaultsSuiteName;

/**
 * Document
 */
#define kDocumentDetailViewCellPlaceholderColor [UIColor colorWithRed:216.0 / 255.0 green:217.0 / 255.0 blue:218.0 / 255.0 alpha:1]
#define kDocumentDetailViewCellTextColor [UIColor colorWithRed:151.0 / 255.0 green:152.0 / 255.0 blue:153.0 / 255.0 alpha:1]

/**
 * Tasks themes
 */
#define kTaskTitleColor [UIColor colorWithRed:35. / 255 green:31. / 255 blue:32. / 255 alpha:1]
#define kTaskDescriptionColor [UIColor colorWithRed:167. / 255 green:169. / 255 blue:172. / 255 alpha:1]

extern UIColor* kTaskPriceTextColor;
extern UIColor* kPayButtonTextColor;
extern UIColor* kPayButtonBackgroundColor;

//Delete button color.
extern UIColor* kDeleteButtonColor;

/**
 * Prime Card
 */
#define kPrimeCardGoodThruColor [UIColor colorWithRed:135. / 255 green:115. / 255 blue:105. / 255 alpha:0.9]

/**
 * Cards
 */
#define kScanButtonColor [UIColor colorWithRed:80. / 255 green:138. / 255 blue:202. / 255 alpha:1]

//-
#define kDarkGrayColor [UIColor colorWithRed:240. / 255 green:240. / 255 blue:240. / 255 alpha:1]
#define klightGrayColor [UIColor colorWithRed:250. / 255 green:250. / 255 blue:250. / 255 alpha:1]
#define kAppTintColor [UIColor colorWithRed:183. / 255 green:170. / 255 blue:177. / 255 alpha:0.9]

#define kAppLabelColor [UIColor colorWithRed:150. / 255 green:150. / 255 blue:150. / 255 alpha:1]
#if defined(PrimeClubConcierge)
#define kAppPassCodeColor [UIColor colorWithRed: 0xEE / 255. green: 0x31 / 255. blue: 0x23 / 255. alpha:1]
#else
#define kAppPassCodeColor [UIColor colorWithRed:110. / 255 green:110. / 255 blue:110. / 255 alpha:1]
#endif
#define kBlueTextColor [UIColor colorWithRed:25. / 255 green:117. / 255 blue:150. / 255 alpha:1]
#define kTableViewHeaderColor kTableViewBackgroundColor

/**
 * TransactionsPage
 */
#define kSegmentedControlColor [UIColor colorWithRed:98. / 255 green:79. / 255 blue:85. / 255 alpha:1]
#define kExpenseBackgroundColor [UIColor colorWithRed:246. / 255 green:246. / 255 blue:246. / 255 alpha:1]
extern UIColor* kMonthColor;

/**
 * Registration Page
 */
extern UIColor* kPhoneLabelBackgroundColor;
extern UIColor* kPhoneLabelTextColor;

/**
 * Table View Background Color
 */
extern UIColor* kTableViewBackgroundColor;

/**
 * Header views color
 */
extern UIColor* kHeaderViewColor;
extern UIColor* kProfileTableViewBackgroundColor;

/**
 * Club Information view
 */
extern UIColor* kClubViewButtonColor;
extern UIColor* kClubViewLabelColor;
extern UIColor* kClubViewLabelBackgroundColor;

extern NSString* kClubInfoVCInfoLabelText;
extern NSString* kClubInfoVCLine3LabelText;

/**
 * Review star view
 */
#define kStarFillColor [UIColor colorWithRed:230. / 255 green:230. / 255 blue:230. / 255 alpha:1]
#define kStarStrokeColor [UIColor colorWithRed:200. / 255 green:200. / 255 blue:200. / 255 alpha:1]
#define kReviewBackgroundColor [UIColor colorWithRed:73. / 255 green:73. / 255 blue:73. / 255 alpha:1]
#define kButtonNotNowColor [UIColor colorWithRed:161. / 255 green:161. / 255 blue:161. / 255 alpha:1]
#define kButtonSendColor [UIColor colorWithRed:118. / 255 green:118. / 255 blue:118. / 255 alpha:1]
#define kButtonNotNowTextColor [UIColor colorWithRed:81. / 255 green:81. / 255 blue:81. / 255 alpha:1]
#define kButtonSendTextColor [UIColor colorWithRed:73. / 255 green:73. / 255 blue:73. / 255 alpha:1]
#define kTextFieldColor [UIColor colorWithRed:41. / 255 green:41. / 255 blue:41. / 255 alpha:1]

/**
 * Chat
 */
#define kResendMessagesTimerInterval (3)
#define kTimeoutToShowRedButton (300)
#define kServicesOrder @"ServicesOrder"
#define kServiceIconsUrl @"https://www.primeconcept.co.uk/icons/%@/ios/%@.png"

#define kTaskLinkMessageTextColor [UIColor colorWithRed:68. / 255 green:69. / 255 blue:67. / 255 alpha:1]
#define kRecordingCancelLabelTextColor [UIColor colorWithRed:128. / 255 green:129. / 255 blue:133. / 255 alpha:1]
#define kHelpScreenBackButtonColor [UIColor colorWithRed:128. / 255 green:132. / 255 blue:135. / 255 alpha:1]

#define kMessageStatusReadIconName @"message_state_read"
#define kMessageStatusSentIconName @"message_state_sent"
#define kMessageStatusNotSentIconName @"message_state_notSent"
#define kMessageStatusInSendingIconName @"message_state_inSending"
#define kMessageStatusDeliveredIconName @"message_state_delivered"

extern UIColor* kChatMessageColor;
extern UIColor* kDateLabelWrapperViewBackgroundColor;
extern UIColor* kTypingContainerViewColor;
extern UIColor* kChatTitleColor;
extern UIColor* kChatBalloonImageViewColor;
extern UIColor* kChatLeftBalloonImageViewColor;
extern UIColor* kChatSendTextColor;
extern UIColor* kChatSendButtonColor;
extern UIColor* kChatTextViewTintColor;
extern UIColor* kChatStatusReadColor;

extern UIColor* kChatLeftMessageTextColor;
extern UIColor* kChatRightMessageTextColor;
extern UIColor* kChatLeftTimeLabelTextColor;
extern UIColor* kChatRightTimeLabelTextColor;
extern UIColor* kLeftVoiceMessageDurationLabelTextColor;
extern UIColor* kRightVoiceMessageDurationLabelTextColor;
extern UIColor* kFeatureInfoBackgroundColor;
extern UIColor* kFeatureInfoNextButtonColor;
extern UIColor* kFeatureInfoTextColor;

extern UIColor* kAttachMainColor;
extern UIColor* kAttachCancelColor;
extern UIColor* kLeftContactMessageButtonColor;
extern UIColor* kRightContactMessageButtonColor;
extern UIColor* kLeftContactMessageSeperatorColor;
extern UIColor* kRightContactMessageSeperatorColor;
extern UIColor* kLeftDocumentMessageWrapperBackgroundColor;
extern UIColor* kRightDocumentMessageWrapperBackgroundColor;

extern NSString* kTabItem1Title;
extern NSString* kTabItem2Title;
extern NSString* kTabItem3Title;
extern NSString* kTabItem4Title;
extern NSString* kTabItem5Title;

extern NSString* kChatTypingTextViewPlaceholderText;

/**
 * Login Screen
 */
extern NSString* kLoginWithCardText;

#define kMessageStatus_Sent @"SENT"
#define kMessageStatus_Delivered @"RESERVED"
#define kMessageStatus_Seen @"SEEN"
#define kMessageStatus_Deleted @"DELETED"

#define kMessageType_Text @"TEXT"
#define kMessageType_VoiceMessage @"VOICEMESSAGE"
#define kMessageType_TaskLink @"TASK_LINK"
#define kMessageType_Image @"IMAGE"
#define kMessageType_Location @"LOCATION"
#define kMessageType_Video @"VIDEO"
#define kMessageType_Document @"DOC"
#define kMessageType_Contact @"CONTACT"

#define kPhotoMessageMimeType @"image/jpeg"
#define kContactMessageMimeType @"text/x-vcard"
#define kLocationMessageMimeType @"application/json"
#define kVideoMessageMimeType @"video/mp4"

typedef NS_ENUM(NSInteger, MessageStatus) {
    MessageStatus_Sent = 1,
    MessageStatus_Reserved,
    MessageStatus_Seen,
    MessageStatus_Deleted
};

typedef NS_ENUM(NSInteger, MessageState) {
    MessageState_Sending,
    MessageState_FinishedSending,
    MessageState_Initial,
    MessageState_Aborted
};

typedef NS_ENUM(NSInteger, ChatMessageType) {
    ChatMessageType_Text,
    ChatMessageType_Image,
    ChatMessageType_Voice,
    ChatMessageType_Video,
    ChatMessageType_Tasklink,
    ChatMessageType_Document,
    ChatMessageType_Location,
    ChatMessageType_Contact
};

/**
 * ApplePay Constants
 */
#define kOrganizationName NSLocalizedString(@"PRIME CLUB", nil)

/**
 * UberActionSheet Colors
 */

extern UIColor* kUberActionSheetTopPartColor;
/**
 * Profile Notification Constants
 */
#define kProfileHasBeenLoaded @"ProfileHasBeenLoaded"

#define kAppWillEnterForegroundAfterTimeout @"AppWillEnterForegroundAfterTimeout"

/**
 * Shake Notification Constants
 */
#define kRestoreCurrentShakeIndex @"RestoreCurrentShakeIndex"

/**
 * Badge Notification Constants
 */
#define kInvalidMessagesDeletionDidComplete @"InvalidMessagesDeletionDidComplete"

/**
 * TouchID Notification Constants
 */
#define kRefreshTouchIDButton @"RefreshTouchIDButton"

/**
 * Login Notification Constants
 */
#define kOpenLoginViewController @"OpenLoginViewController"

/**
 * Widget Display Mode Changes Notification Constants
 */
#define kShowMoreOrLessNotification @"ShowMoreOrLessNotification"

// FCM refreshed token notification key.
#define kFCMRefreshedToken @"FCMRefreshedToken"

// Widget Constants
#define kMessagesForWidget @"lastMessages"
#define kWidgetMessageType @"type"
#define kWidgetMessageTimestamp @"timestamp"
#define kWidgetMessageText @"text"
#define kWidgetMessageAudioFileName @"audioFileName"
#define kWidgetMessageMediaFileName @"mediaFileName"
#define kWidgetMessageImageName @"imageName"
#define kWidgetMessageTaskName @"taskName"
#define kWidgetMessageTaskDescription @"taskDescription"
#define kWidgetMessage @"message"
#define kWidgetMessageTaskLink @"taskLink"
#define kWidgetMessageFormatedDate @"formatedDate"
#define kWidgetMessageIsLeft @"isLeftCell"
#define kWidgetEventTypeNeedToPay @"needToPay"
#define kWidgetEventTypeInProgress @"inProgress"
#define kWidgetRequests @"eventsRequests"
#define kWidgetEvents @"eventsCalendar"
#define kWidgetMessageDuration @"duration"
#define kWidgetServiceIconName @"icon"
#define kWidgetServiceName @"name"
#define kWidgetServiceId @"serviceId"
#define kWidgetServices @"services"
#define kWidgetCityguideData @"dataCityGuide"
#define kWidgetCityguideDescription @"bottom_str"
#define kWidgetCityguideName @"name"
#define kWidgetCityguideImage @"image"
#define kWidgetCityguideInner_link @"inner_link"
#define kWidgetRequestDate @"requestDate"
#define kWidgetEventType @"eventType"
#define kWidgetRequestID @"taskId"
#define kWidgetRequestPayText @"payText"
#define kWidgetRequestPayDate @"payDate"
#define kWidgetCityguideImageSrc @"src"
#define kDisplayMode @"DisplayMode"
#define kUserName @"userName"
#define kTasksUpdateTimeout 1800.0 // 30 minutes
#define kMessagesUpdateTimeout 600.0 // 10 min
#define kCityGuideUpdateTimeout 36000.0 // 10 hour

/**
 * Location message Dictionary keys
 */
#define kLocationMessageLatitudeKey @"latitude"
#define kLocationMessageLongitudeKey @"longitude"
#define kLocationMessageSnapshotKey @"snapshot"

/**
 * Location message Dictionary keys
 */
#define kDocumentMessageFileNameKey @"fileName"
#define kDocumentMessageFileSizeKey @"size"
#define kDocumentMessageFileExtensionKey @"extension"

/**
 * Features Keys
 */
#define kInfoIsRequested @"%@InfoIsRequested"
#define kInformationItems @"items"
#define kInformationType @"type"
#define kInformationHeader @"header"
#define kInformationImage @"image"
#define kInformationValue @"value"
#define kInformationUrl @"url"
#define kInformationItemName @"name"
#define kInformationIcon @"icon"
#define kInformationListItem @"list_item"

/**
 * Request Status Codes
 */
#define kErrorNotFound 404
#define kStatusCodeSuccess 200

/**
 * Profile registration keys
 */
#define kCardNumber @"card_number"
#define kFirstName @"first_name"
#define kLastName @"last_name"
#define kMiddleName @"middle_name"
#define kBirthday @"birthday"
#define kPhone @"phone"
#define kEmail @"email"


/**
 * Google Analytics Events texts
 */
// Tabs
#define kChatTabOpened @"chat_tab_opened"
#define kCalendarTabOpened @"calendar_tab_opened"
#define kRequestTabOpened @"requests_tab_opened"
#define kCityGuideTabOpened @"city_guide_tab_opened"
#define kMeTabOpened @"me_tab_opened"

#define kCallButtonClicked @"call_button_clicked"
#define kAssistantViewOpened @"assistant_view_opened"
#define kCallToAssistantClicked @"call_to_assistant_clicked"
#define kMailToAssistantClicked @"mail_to_assistant_clicked"
#define kTaskLinkClicked @"chat_task_link_clicked"
#define kTaskPayButtonClicked @"task_pay_button_clicked"
#define kMessageSendAction @"message_send_button_clicked"
#define kMessageSendInOfflineModeDialog @"message_send_offline_mode_dialog_shown"
#define kMicrophonePressed @"microphone_button_pressed"
#define kMoreButtonClicked @"service_more_button_clicked"
#define kResendMessageButtonClicked @"resend_message_button_clicked"
#define kLongPressedOnChatTab @"long_pressed_on_chat_tab"
#define kServiceIconClicked @"%@_service_opened"

// Calendar
#define kCalendarDaySelected @"calendar_day_selected"
#define kCalendarSwiped @"calendar_swiped"
#define kNavigationBarDateLabelClicked @"calendar_nav_bar_date_label_clicked"
#define kTodayButtonClicked @"calendar_today_button_clicked"
#define kEventIsClicked @"calendar_event_clicked"

// Requests
#define kRequestDetailsPageOpened @"request_details_page_opened"
#define kRequestChatOpened @"details_screen_chat_clicked"
#define kCategoriesMenuButtonClicked @"categories_menu_button_clicked"
#define kRequestSegmentInProgressClicked @"requests_in_progress_clicked"
#define kRequestSegmentCompletedClicked @"requests_completed_clicked"
#define kRequestCategorySelected @"request_category_selected"
#define kRequestAllCategorySelected @"request_all_category_selected"

// My Profile
#define kMyProfileButtonClicked @"my_profile_page_opened"

// Segments
#define kMyProfileSegmentContactsClicked @"my_profile_contacts_clicked"
#define kMyProfileSegmentDocumentsClicked @"my_profile_documents_clicked"
#define kMyProfileSegmentFamilyPartnersClicked @"my_profile_family_partners_clicked"

// Profile Segment
#define kMyProfileAddPhoneButtonClicked @"my_profile_add_phone_clicked"
#define kMyProfileEditPhoneButtonClicked @"my_profile_edit_phone_clicked"
#define kMyProfileAddEmailButtonClicked @"my_profile_add_email_clicked"
#define kMyProfileEditEmailButtonClicked @"my_profile_edit_email_clicked"
#define kMyProfileImageCorrectionButtonClicked @"my_profile_correction_button_clicked"
#define kMyProfileDeletePhoneButtonClicked @"my_profile_delete_phone_clicked"
#define kMyProfileDeleteEmailButtonClicked @"my_profile_delete_email_clicked"
#define kMyProfileSaveEmailButtonClicked @"my_profile_save_email_button_clicked"
#define kMyProfileSavePhoneButtonClicked @"my_profile_save_phone_button_clicked"

// Passports/Visas Segment
#define kMyProfileAddPassportButtonClicked @"my_profile_add_passport_clicked"
#define kMyProfileEditPassportButtonClicked @"my_profile_edit_passport_clicked"
#define kMyProfileAddVisaButtonClicked @"my_profile_add_visa_clicked"
#define kMyProfileEditVisaButtonClicked @"my_profile_edit_visa_clicked"
#define kMyProfileDeletePassportButtonClicked @"my_profile_delete_passport_clicked"
#define kMyProfileDeleteVisaButtonClicked @"my_profile_delete_visa_clicked"
#define kMyProfileDeleteDocumentButtonClicked @"my_profile_delete_document_clicked"
#define kMyProfileAddPassportPhotoButtonClicked @"my_profile_add_passport_photo_clicked"
#define kMyProfileAddVisaPhotoButtonClicked @"my_profile_add_visa_photo_clicked"
#define kMyProfileAddDocumentPhotoButtonClicked @"my_profile_add_document_photo_clicked"
#define kMyProfileDeletePassportPhotoPressed @"my_profile_delete_passport_photo_pressed"
#define kMyProfileDeleteVisaPhotoPressed @"my_profile_delete_visa_photo_pressed"
#define kMyProfileDeleteDocumentPhotoPressed @"my_profile_delete_document_photo_pressed"
#define kMyProfileSavePassportButtonClicked @"my_profile_save_passport_button_clicked"
#define kMyProfileSaveVisaButtonClicked @"%@_visa_saved"
#define kMyProfileSaveDocumentButtonClicked @"%@_saved"
#define kMyProfileBirthDateFieldClicked @"birth_date_field_of_document_clicked"

// Family/Partner Segment
#define kMyProfileAddFamilyButtonClicked @"my_profile_family_doc_created"
#define kMyProfileEditFamilyButtonClicked @"my_profile_family_doc_edited"
#define kMyProfileAddPartnerButtonClicked @"my_profile_partner_doc_created"
#define kMyProfileEditPartnerButtonClicked @"my_profile_partner_doc_edited"
#define kMyProfileSaveFamilyButtonClicked @"my_profile_save_family_clicked"
#define kMyProfileSavePartnerButtonClicked @"my_profile_save_partner_clicked"
#define kMyProfileDeleteFamilyPartnerButtonClicked @"my_profile_delete_family_partner_clicked"
#define kPersonalDataBirthDateClicked @"personal_data_birthday_clicked"
#define kPersonalDataAddPhoneClicked @"personal_data_add_phone_clicked"
#define kPersonalDataAddEmailClicked @"personal_data_add_email_clicked"

// My Cards
#define kMyCardsButtonClicked @"my_cards_page_opened"

// Segments
#define kMyCardsPaymentCardsSegmentClicked @"my_cards_payment_cards_clicked"
#define kMyCardsLoyaltyCardsSegmentClicked @"my_cards_loyalty_cards_clicked"

// Payment Cards Segment
#define kMyCardsAddPaymentCardButtonClicked @"add_payment_card_clicked"
#define kMyCardsEditPaymentCardButtonClicked @"edit_payment_card_clicked"
#define kMyCardsScanPaymentCardButtonClicked @"scan_payment_card_clicked"
#define kMyCardsDeletePaymentCardButtonClicked @"delete_payment_card_clicked"
#define kMyCardsSaveNewPaymentCardButtonClicked @"new_payment_card_save_clicked"
#define kMyCardsSaveEditedPaymentCardButtonClicked @"edit_payment_card_save_button_clicked"

// Bonus Cards Segment
#define kMyCardsAddLoyaltyCardButtonClicked @"add_loyalty_card_clicked"
#define kMyCardsEditLoyaltyCardButtonClicked @"edit_loyalty_card_clicked"
#define kMyCardsSaveLoyaltyCard @"new_loyalty_card_save_clicked"
#define kMyCardsDeleteLoyaltyCardButtonClicked @"delete_loyalty_card_clicked"
#define kMyCardsLoyaltyCardIssueDateClicked @"loyalty_card_issue_date_clicked"
#define kMyCardsLoyaltyCardExpirationDateClicked @"loyalty_card_expiration_date_clicked"

// My Cars
#define kMyCarsButtonClicked @"my_cars_page_opened"
#define kMyCarsAddCarButtonClicked @"add_car_clicked"
#define kMyCarsEditCarButtonClicked @"edit_car_clicked"
#define kMyCarsSaveCarButtonClicked @"save_car_clicked"
#define kMyCarsDeleteCarButtonClicked @"delete_car_clicked"

// Finances
#define kFinancesButtonClicked @"finances_page_opened"
#define kFinancesCloseButtonClicked @"finances_close_button_clicked"

#define kFinancesHistoryMonthChanged @"finances_history_date_changed"
#define kFinancesExpensesMonthChanged @"expenses_date_changed"

// Segments
#define kFinancesHistorySegmentClicked @"finances_history_clicked"
#define kFinancesExpensesSegmentClicked @"finances_expenses_clicked"

// History Segment
#define kFinancesHistoryServiceProviderOpened @"service_provider_screen_opened"
#define kServiceProviderItemSelected @"%@_service_provider_selected"

// Expenses Segment
#define kFinancesExpensesCurrencyOpened @"currency_screen_opened"
#define kCurrencyItemSelected @"%@_currency_selected"

// My Preferences
#define kMyPreferencesButtonClicked @"my_preferences_page_opened"

// Club Rules
#define kClubRulesButtonClicked @"club_rules_page_opened"

// Change Password
#define kChangePasswordButtonClicked @"change_password_page_opened"
#define kChangePasswordCurrentPasswordEntered @"current_password_entered"
#define kChangePasswordNewPasswordEntered @"new_password_entered"
#define kChangePasswordNewPasswordRepeated @"new_password_repeated"

// Reference
#define kReferenceButtonClicked @"information_page_opened"
#define kReferenceCloseOrContinueButtonClicked @"information_page_closed"
#define kReferenceChildPageOpened @"information_child_page_opened"

// New Version Available Alert
#define kNewVersionAvailableYesButtonClicked @"download_new_version_yes_clicked"
#define kNewVersionAvailableNoButtonClicked @"download_new_version_no_clicked"

// Location Permission
#define kLocationAllowButtonClicked @"location_permission_allowed"
#define kLocationDoNotAllowButtonClicked @"location_permission_denied"

// Photo Library Permission
#define kPhotoLibraryPermissionAllowButtonClicked @"photo_library_permission_allowed"
#define kPhotoLibraryPermissionDoNotAllowButtonClicked @"photo_library_permission_denied"

// Camera Permission
#define kCameraPermissionAllowButtonClicked @"camera_permission_allowed"
#define kCameraPermissionDoNotAllowButtonClicked @"camera_permission_denied"

// Notification Permission
#define kNotificationPermissionAllowButtonClicked @"notification_permission_allowed"
#define kNotificationPermissionDoNotAllowButtonClicked @"notification_permission_denied"

// Calendar Permission
#define kCalendarPermissionAllowButtonClicked @"calendar_permission_allowed"
#define kCalendarPermissionDoNotAllowButtonClicked @"calendar_permission_denied"

// Remote Notification
#define kRemoteNotificationOpenedButtonClicked @"remote_notification_opened"

// Login Screen
#define kLoginScreenPasswordEntered @"log_in_screen_password_entered"
#define kLoginScreenForgotPasswordButtonClicked @"log_in_screen_forgot_password_clicked"

// Touch Id
#define kFingerTouchButtonClicked @"finger_touch_button_clicked"

// Registration Screen
#define kCountriesScreenOpened @"registration_choose_country_opened"
#define kCountrySelected @"%@_selected"
#define kRegistrationScreenOpened @"registration_screen_opened"
#define kPhoneNumberEntered @"registration_phone_number_entered"
#define kRegistrationCodeConfirmed @"registration_code_confirm_entered"
#define kPasswordCreated @"registration_password_created"
#define kPasswordReapeted @"registration_password_repeated"

// Overview Screen
#define kOverviewScreenIAmPrimeButtonClicked @"i_am_prime_clicked"
#define kOverviewScreenOpened @"intro_screen_opened"
#define kOverviewScreenSwiped @"intro_screen_swiped"

// Features Screen
#define kFeaturesScreenNextButtonClicked @"features_screen_next_clicked"
#define kFeaturesScreenCloseButtonClicked @"features_screen_close_clicked"
#define kFeaturesScreenSwiped @"features_screen_swiped"
#define kFeaturesScreenOpened @"features_page_opened"

// Date Picker
#define kPhoneTypePickerSelectButtonClicked @"phone_type_picker_select_clicked"
#define kPhoneTypePickerCancelButtonClicked @"phone_type_picker_cancel_clicked"

#define kEmailTypePickerSelectButtonClicked @"email_type_picker_select_clicked"
#define kEmailTypePickerCancelButtonClicked @"email_type_picker_cancel_clicked"

#define kDatePickerSelectButtonClicked @"date_picker_select_clicked"
#define kDatePickerCancelButtonClicked @"date_picker_cancel_clicked"

#define kCountryPickerSelectButtonClicked @"country_picker_select_clicked"
#define kCountryPickerCancelButtonClicked @"country_picker_cancel_clicked"

#define kFamilyTypePickerSelectButtonClicked @"family_type_picker_select_clicked"
#define kFamilyTypePickerCancelButtonClicked @"family_type_picker_cancel_clicked"

#define kPartnerTypePickerSelectButtonClicked @"partner_type_picker_select_clicked"
#define kPartnerTypePickerCancelButtonClicked @"partner_type_picker_cancel_clicked"

#define kLoyaltyCardTypePickerSelectButtonClicked @"loyalty_card_type_picker_select_clicked"
#define kLoyaltyCardTypePickerCancelButtonClicked @"loyalty_card_type_picker_cancel_clicked"

#define kVisaTypePickerSelectButtonClicked @"visa_type_picker_select_clicked"
#define kVisaTypePickerCancelButtonClicked @"visa_type_picker_cancel_clicked"

// Chat
#define kChatDeeplinkTextOpened @"chat_deeplink_text_opened"

// SiriKit Constants
#define kKeyForMessagesFromSiri @"messages_from_siri"
#define kServiceNameForExtensions @"com.prime.app.PRIME.SiriKit"
#define kAccessTokenKey @"accessTokenKey"
#define kSiriUserDefaultsSuiteName @"group.com.prime.app.Siri.PRIME"

// CRM
#define kAuthorizationPath @"oauth/token"  // Should not be '/' at the end.

#define kPasscodeKey @"passcode_for_touch_id"
#define kOwnerIdentifier @"owner"

#define kCityGuideUrl @"https://cityguide.primeconcept.co.uk/api/get_collection?col=list&lang=ru&limit=10&splat=/msk/2/w/f&lng=%f&lat=%f"
#define kMessageSendPath @"messages?access_token=%@&t=%@&X-Client-Id=%@&X-Device-Id=%@"
#define kDataExpirationMonthOffset 3
#define kMessagesFetchLimit 20

#endif
