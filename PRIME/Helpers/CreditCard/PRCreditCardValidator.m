//
//  PRCreditCardValidator.m
//  PRIME
//
//  Created by Artak on 2/6/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRCreditCardValidator.h"
#import "NSString+AllowCharactersInSet.h"
#import "PRCardData.h"

@implementation PRCreditCardValidator

#pragma mark - Card Checkings

+ (CreditCardType)checkWithCardNumber:(NSString*)cardNumber
{
    NSCharacterSet* numbers = [NSCharacterSet
        characterSetWithCharactersInString:@"0123456789"];

    NSString* numericCardNumber = [cardNumber stringByAllowingOnlyCharactersInSet:numbers];

    NSUInteger length = [numericCardNumber length];

    if (length < 13) {
        return CreditCardType_Invalid;
    }

    CreditCardType type = CreditCardType_Invalid;

// MasterCard
#if defined(Imperia)
    if ([PRCreditCardValidator isImperiaCardValid:numericCardNumber]) {
#elif defined(Otkritie)
    if ([PRCreditCardValidator isOtkritieCardValid:numericCardNumber]) {
#else
    if ([numericCardNumber hasPrefix:@"5"]) {
#endif
        if (length != 16) {
            return CreditCardType_Invalid;
        }
        type = CreditCardType_Mastercard;
    }

// Visa
#if defined(Imperia)
    else if ([PRCreditCardValidator isImperiaCardValid:numericCardNumber]) {
#elif defined(Otkritie)
    else if ([PRCreditCardValidator isOtkritieCardValid:numericCardNumber]) {
#else
    else if ([numericCardNumber hasPrefix:@"4"]) {
#endif
        if (length != 16 && length != 13) {
            return CreditCardType_Invalid;
        }
        type = CreditCardType_Visa;
    }

    // Amex.
    else if ([numericCardNumber hasPrefix:@"34"] ||
        [numericCardNumber hasPrefix:@"37"]) {
        if (length != 15) {
            return CreditCardType_Invalid;
        }
        type = CreditCardType_Amex;
    }

    // Diners.
    else if ([numericCardNumber hasPrefix:@"36"] ||
        [numericCardNumber hasPrefix:@"38"] ||
        [numericCardNumber hasPrefix:@"300"] ||
        [numericCardNumber hasPrefix:@"301"] ||
        [numericCardNumber hasPrefix:@"302"] ||
        [numericCardNumber hasPrefix:@"303"] ||
        [numericCardNumber hasPrefix:@"304"] ||
        [numericCardNumber hasPrefix:@"305"]) {
        if (length != 14) {
            return CreditCardType_Invalid;
        }
        type = CreditCardType_DinersClub;
    }

    // Discover.
    else if ([numericCardNumber hasPrefix:@"6011"]) {
        if (length != 15 && length != 16) {
            return CreditCardType_Invalid;
        }
        type = CreditCardType_Discover;
    }

    // EnRoute.
    else if ([numericCardNumber hasPrefix:@"2014"] ||
        [numericCardNumber hasPrefix:@"2149"]) {
        if (length != 15 && length != 16) {
            return CreditCardType_Invalid;
        }
        // Any digit check.
        type = CreditCardType_enRoute;
    }

    // Jcb.
    else if ([numericCardNumber hasPrefix:@"3"]) {
        if (length != 16) {
            return CreditCardType_Invalid;
        }
        type = CreditCardType_jcb;
    }

    // Jcb.
    else if ([numericCardNumber hasPrefix:@"2131"] ||
        [numericCardNumber hasPrefix:@"1800"]) {
        if (length != 15) {
            return CreditCardType_Invalid;
        }
        type = CreditCardType_jcb;
    } else {
        return CreditCardType_Invalid;
    }

    // The Luhn algorithm or Luhn formula,also known as the "modulus 10" or "mod 10" algorithm.
    NSUInteger sum = 0;
    NSUInteger i = (length % 2);
    for (; i < length; i += 2) {
        NSUInteger s = ([numericCardNumber characterAtIndex:i] - '0') * 2;
        if (s > 9) {
            s -= 9;
        }
        sum += s;
    }

    i = (length + 1) % 2;

    for (; i < length; i += 2)
        sum += ([numericCardNumber characterAtIndex:i] - '0');

    // Must be %10.
    if (sum % 10 != 0) {
        return CreditCardType_Invalid;
    }

    return type;
}

+ (BOOL)isCardExist:(NSString*)cardNumber expDate:(NSString*)expDate;
{
    NSArray* cards = [NSMutableArray objectFromKeychainWithKey:kCardDataKeyPath forClass:PRCardData.class];

    NSCharacterSet* numbers = [NSCharacterSet
        characterSetWithCharactersInString:@"0123456789"];

    for (PRCardData* card in cards) {
        if ([[card.cardNumber stringByAllowingOnlyCharactersInSet:numbers]
                isEqualToString:[cardNumber stringByAllowingOnlyCharactersInSet:numbers]]
            &&
            [card.expDate isEqualToString:expDate]) {
            return YES;
        }
    }

    return NO;
}

#pragma mark - Card Info

+ (NSString*)getHiddenCardNumber:(NSString*)cardNumber
{
    NSString* trimmedString = [cardNumber substringFromIndex:MAX((int)[cardNumber length] - 4, 0)];

    return [[NSMutableString alloc] initWithFormat:@".... %@", trimmedString];
}

+ (NSString*)getLongHiddenCardNumberWithStars:(NSString*)cardNumber
{
    NSString* edString = [cardNumber substringFromIndex:MAX((int)[cardNumber length] - 4, 0)];
    NSString* startString = [cardNumber substringToIndex:4];

    return [[NSMutableString alloc] initWithFormat:@"%@ **** **** %@", startString, edString];
}

+ (NSString*)getLongHiddenCardNumber:(NSString*)cardNumber
{
    NSString* trimmedString = [cardNumber substringFromIndex:MAX((int)[cardNumber length] - 4, 0)];

    return [[NSMutableString alloc] initWithFormat:@"XXXX XXXX XXXX %@", trimmedString];
}

+ (NSDate*)getExpDateFromString:(NSString*)expDate
{
    return [self isDatePassed:expDate] ? nil : [NSDate mt_dateFromString:expDate usingFormat:@"MM/yy"];
}

+ (NSString*)getTypeForCardNumber:(NSString*)cardNumber
{
    NSString* typeString = nil;

    CreditCardType cardType = [PRCreditCardValidator checkWithCardNumber:cardNumber];

    switch (cardType) {
    case CreditCardType_Mastercard:
        typeString = @"MasterCard";
        break;
    case CreditCardType_Visa:
        typeString = @"Visa";
        break;
    default:
        break;
    }

    return typeString;
}

#pragma mark - Date Validation

+ (BOOL)isDatePassed:(NSString*)string
{
    NSArray* arrayWithDate = [string componentsSeparatedByString:@"/"];
    NSInteger month = [arrayWithDate[0] integerValue];
    NSInteger year = [arrayWithDate[1] integerValue];

    NSDate* currDate = [NSDate date];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/YY"];
    NSString* dateString = [dateFormatter stringFromDate:currDate];

    NSArray* arrayWithCurrDate = [dateString componentsSeparatedByString:@"/"];
    NSInteger currMonth = [arrayWithCurrDate[0] integerValue];
    NSInteger currYear = [arrayWithCurrDate[1] integerValue];

    if ((year > currYear) || (year == currYear && month <= 12 && month >= currMonth)) {
        return NO;
    }

    return YES;
}

+ (BOOL)isValidExpDate:(NSString*)expDate
{
    return ([self getExpDateFromString:expDate] != nil);
}

#pragma mark - Imperia Card Validation

+ (BOOL)isImperiaCardValid:(NSString*)paymentCard
{
    NSArray<NSString*>* validImperiaCardsWithPrefix = @[
        @"545160324",
        @"545160331",
        @"545160337",
        @"545160340",
        @"545160182",
        @"545160071",
        @"545160217",
        @"545160263",
        @"545160401"
    ];

    for (NSUInteger i = 0; i < validImperiaCardsWithPrefix.count; i++) {
        if ([paymentCard hasPrefix:validImperiaCardsWithPrefix[i]]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Otkritie Card Validation

+ (BOOL)isOtkritieCardValid:(NSString*)paymentCard
{
    NSArray<NSString*>* validOtkritieCardsWithPrefix = @[
        @"404586",
        @"405870",
        @"406790",
        @"406791",
        @"407178",
        @"409701",
        @"409755",
        @"409756",
        @"413307",
        @"416038",
        @"420574",
        @"425181",
        @"425182",
        @"425183",
        @"425184",
        @"425185",
        @"425656",
        @"426896",
        @"427856",
        @"428165",
        @"428166",
        @"429037",
        @"429038",
        @"429040",
        @"430291",
        @"434146",
        @"434147",
        @"434148",
        @"437351",
        @"446065",
        @"458493",
        @"464843",
        @"467487",
        @"472840",
        @"472841",
        @"472842",
        @"472843",
        @"479302",
        @"479715",
        @"479716",
        @"479718",
        @"479777",
        @"484800",
        @"485649",
        @"514017",
        @"515243",
        @"515668",
        @"515758",
        @"518796",
        @"518803",
        @"520324",
        @"520349",
        @"520634",
        @"522459",
        @"529260",
        @"530183",
        @"530403",
        @"531674",
        @"532130",
        @"532301",
        @"532837",
        @"535108",
        @"539896",
        @"539714",
        @"544218",
        @"544499",
        @"544573",
        @"544962",
        @"547449",
        @"548764",
        @"548106",
        @"549848",
        @"552219",
        @"552671",
        @"552681",
        @"558620",
        @"670518",
        @"670587",
        @"676231",
        @"676968",
        @"676697",
        @"676951",
        @"750054",
        @"750824"
    ];

    for (NSUInteger i = 0; i < validOtkritieCardsWithPrefix.count; i++) {
        if ([paymentCard hasPrefix:validOtkritieCardsWithPrefix[i]]) {
            return YES;
        }
    }
    return NO;
}

@end
