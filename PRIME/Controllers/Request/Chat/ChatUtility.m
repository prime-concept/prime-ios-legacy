//
//  ChatUtility.m
//  PRIME
//
//  Created by Simon on 1/23/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import <ChatUtility.h>
#import "PRUserDefaultsManager.h"

@implementation ChatUtility

+ (NSString*)clientIdWithPrefix
{
    PRUserProfileModel* profile = [[PRUserProfileModel MR_findAllInContext:[NSManagedObjectContext MR_rootSavingContext]] firstObject];
    if (profile.username) {
        NSString* clientID = [NSString stringWithFormat:@"%@%@", kClientPrefix, profile.username];
        return clientID;
    }

    return nil;
}

+ (NSString*)mainChatIdWithPrefix
{
    PRUserProfileModel* profile = [[PRUserProfileModel MR_findAllInContext:[NSManagedObjectContext MR_rootSavingContext]] firstObject];
    if (profile.username) {
        NSString* mainChatId = [NSString stringWithFormat:@"%@%@", kMainChatPrefix, profile.username];
        return mainChatId;
    }

    return nil;
}

+ (NSString*)chatIdWithPrefix:(NSString*)chatId
{
    if (chatId) {
        return [NSString stringWithFormat:@"%@%@", kChatPrefix, chatId];
    }

    return nil;
}

+ (BOOL)isYesterday:(NSDate*)date
{
    return [date mt_isWithinSameDay:[[NSDate date] mt_dateDaysBefore:1]];
}

+ (NSString*)formatedDate:(NSDate*)date
{
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];

    if ([date mt_isWithinSameDay:[NSDate date]]) {
        return NSLocalizedString(@"Today", );
    }

    if ([self isYesterday:date]) {
        return NSLocalizedString(@"Yesterday", );
    }

    if ([date mt_isWithinSameYear:[NSDate date]]) {
        [dateFormat setDateFormat:@"EEE, d MMMM"];
        return [dateFormat stringFromDate:date];
    }

    [dateFormat setDateFormat:@"dd MMMM yyyy"];
    return [dateFormat stringFromDate:date];
}

+ (NSString*)formatedTime:(NSDate*)date
{

    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm"];

    return [dateFormat stringFromDate:date];
}

@end
