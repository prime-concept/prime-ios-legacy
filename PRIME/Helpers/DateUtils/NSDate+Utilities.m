//
//  NSDate+Utilities.m
//  PRIME
//
//  Created by Sargis Terteryan on 7/23/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import "NSDate+Utilities.h"

static const unsigned componentFlags = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekOfYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal);

@implementation NSDate (Utilities)

+ (NSCalendar*)currentCalendar
{
    static NSCalendar* sharedCalendar = nil;
    if (!sharedCalendar)
        sharedCalendar = [NSCalendar autoupdatingCurrentCalendar];
    return sharedCalendar;
}

#pragma mark - Relative Dates

+ (NSDate*)dateWithDaysFromNow:(NSInteger)days
{
    return [[NSDate date] dateByAddingDays:days];
}

+ (NSDate*)dateWithDaysBeforeNow:(NSInteger)days
{
    return [[NSDate date] dateBySubtractingDays:days];
}

+ (NSDate*)dateYesterday
{
    return [NSDate dateWithDaysBeforeNow:1];
}

#pragma mark - Comparing Dates

- (BOOL)isEqualToDateIgnoringTime:(NSDate*)aDate
{
    NSDateComponents* components1 = [[NSDate currentCalendar] components:componentFlags fromDate:self];
    NSDateComponents* components2 = [[NSDate currentCalendar] components:componentFlags fromDate:aDate];
    return ((components1.year == components2.year) && (components1.month == components2.month) && (components1.day == components2.day));
}

- (BOOL)isToday:(NSDate*)date
{
    return [date isEqualToDateIgnoringTime:[NSDate date]];
}

- (BOOL)isYesterday
{
    return [self isEqualToDateIgnoringTime:[NSDate dateYesterday]];
}

- (BOOL)isSameYearAsDate:(NSDate*)aDate
{
    NSDateComponents* components1 = [[NSDate currentCalendar] components:NSCalendarUnitYear fromDate:self];
    NSDateComponents* components2 = [[NSDate currentCalendar] components:NSCalendarUnitYear fromDate:aDate];
    return (components1.year == components2.year);
}

- (BOOL)isThisYear
{
    return [self isSameYearAsDate:[NSDate date]];
}

#pragma mark - Adjusting Dates

- (NSDate*)dateByAddingYears:(NSInteger)dYears
{
    NSDateComponents* dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setYear:dYears];
    NSDate* newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
    return newDate;
}

- (NSDate*)dateByAddingMonths:(NSInteger)dMonths
{
    NSDateComponents* dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setMonth:dMonths];
    NSDate* newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
    return newDate;
}

- (NSDate*)dateByAddingDays:(NSInteger)dDays
{
    NSDateComponents* dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:dDays];
    NSDate* newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
    return newDate;
}

- (NSDate*)dateBySubtractingDays:(NSInteger)dDays
{
    return [self dateByAddingDays:(dDays * -1)];
}

@end
