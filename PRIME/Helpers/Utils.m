//
//  Utils.m
//  PRIME
//
//  Created by Admin on 6/22/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRCreditCardValidator.h"
#import "Utils.h"
#import <CountryPicker/CountryPicker.h>

@implementation Utils

+ (UIImage*)getImageForCardNumber:(NSString*)cardNumber
{
    UIImage* image = nil;

    CreditCardType cardType = [PRCreditCardValidator checkWithCardNumber:cardNumber];

    switch (cardType) {
    case CreditCardType_Mastercard:
        image = [UIImage imageNamed:@"mastercard"];
        break;
    case CreditCardType_Visa:
        image = [UIImage imageNamed:@"visa"];
        break;
    default:
        break;
    }

    return image;
}

+ (NSString*)stringFromDateString:(NSString*)name
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZ"];
    NSDate* date = [formatter dateFromString:name];
    [formatter setDateFormat:DEFAULT_TIME_FORMAT];

    return [formatter stringFromDate:date];
}

+ (NSDate*)dateWithComponentsFromDate:(NSDate*)date units:(NSCalendarUnit)units
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:units fromDate:date];

    return [calendar dateFromComponents:components];
}

+ (NSString*)changeDateStringFormat:(NSString*)dateString toFormat:(NSString*)dateFormat;
{
    if (!dateString || !dateFormat) {
        return dateString;
    }

    NSDate* date = [NSDate mt_dateFromISOString:dateString];
    return [date mt_stringFromDateWithFormat:dateFormat localized:NO];
}

+ (NSString*)countryNameFromCode:(NSString*)countryCode
{
    return [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] displayNameForKey:NSLocaleCountryCode value:countryCode];
}

+ (UIImage*)countryFlagFromCode:(NSString*)countryCode
{
    NSString* imagePath = [NSString stringWithFormat:@"CountryPicker.bundle/%@", countryCode];

    if ([[UIImage class] respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]) {
        return [UIImage imageNamed:imagePath inBundle:[NSBundle bundleForClass:[CountryPicker class]] compatibleWithTraitCollection:nil];
    }

    return [UIImage imageNamed:imagePath];
}

+ (NSArray*)removeDuplicateItemsFromArray:(NSArray*)array
{
    NSOrderedSet* orderedSet = [NSOrderedSet orderedSetWithArray:array];

    return [orderedSet array];
}

+ (UIStoryboard*)mainStoryboard
{
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    return mainStoryboard;
}

+ (CGFloat)statusBarHight
{
    static CGFloat statusBarHight = CGFLOAT_MIN;
    if (statusBarHight == CGFLOAT_MIN) {
        CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
        statusBarHight = CGRectGetHeight(statusBarFrame);
    }

    return statusBarHight;
}

+ (NSString *)applyFormatForFormattedString:(NSString *)formattedDigits
{
    NSMutableString *result = [[NSMutableString alloc] init];

    NSInteger charIndex = 0;
    for (NSInteger i = 0; i < [DEFAULT_PHONE_FORMAT length] && charIndex < [formattedDigits length]; i++) {

        unichar ch = [DEFAULT_PHONE_FORMAT characterAtIndex:i];
        if ( ch == '#')
        {
            unichar sp = [formattedDigits characterAtIndex:charIndex++];
            [result appendString:[NSString stringWithCharacters:&sp length:1]];
        }
        else
        {
            [result appendString:[NSString stringWithCharacters:&ch length:1]];
        }
    }
    return [NSString stringWithFormat:@"%@", result];
}

+ (NSString*)removeAllSeparatorsInString:(NSString*)string
{
    string = [string stringByReplacingOccurrencesOfString:@"+" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"-" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"(" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@")" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];

    return string;
}

+ (NSString*)fromMillisecondsToFormattedDate:(NSString*)milliseconds
{
    NSDateFormatter* dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:DATE_DAY_FORMAT];
    NSDate* formatedDate = [dateFormatter dateFromString:milliseconds];
    if (formatedDate) {
        return milliseconds;
    }

    NSTimeInterval timeInterval = [milliseconds doubleValue];
    formatedDate = [NSDate dateWithTimeIntervalSince1970:(timeInterval / 1000.0)];
    NSString* formattedDateString = [formatedDate mt_stringFromDateWithFormat:DATE_DAY_FORMAT localized:NO];

    return formattedDateString;
}

+ (NSDate*)dateWithOffsetFromNow:(NSInteger)offset
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* monthOffsetFromNowComponents = [[NSDateComponents alloc] init];
    monthOffsetFromNowComponents.month = -offset;

    NSDate* offsetMonthsAgo = [calendar dateByAddingComponents:monthOffsetFromNowComponents
                                                        toDate:[NSDate date]
                                                       options:0];
    return offsetMonthsAgo;
}

+ (void)delay:(NSInteger)seconds block:(dispatch_block_t)block {
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC), dispatch_get_main_queue(), block);
}

@end
