//
//  PRCreditCardValidator.h
//  PRIME
//
//  Created by Admin on 2/6/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CreditCardType) {
    CreditCardType_Invalid,
    CreditCardType_Mastercard,
    CreditCardType_Visa,
    CreditCardType_Amex,
    CreditCardType_DinersClub,
    CreditCardType_Discover,
    CreditCardType_enRoute,
    CreditCardType_jcb

};

@interface PRCreditCardValidator : NSObject

// Checks a given string for a valid credit card
+ (CreditCardType) checkWithCardNumber: (NSString *) cardNumber;

// Returns card number as ".... 1234"
+ (NSString*) getHiddenCardNumber: (NSString*) cardNumber;

// Returns card number as "1234 **** **** 1234"
+ (NSString*) getLongHiddenCardNumberWithStars: (NSString*) cardNumber;

// Returns card number as "XXXX XXXX XXXX 1234"
+ (NSString*) getLongHiddenCardNumber: (NSString*) cardNumber;

+ (BOOL) isValidExpDate: (NSString*) expDate;

+ (NSDate *) getExpDateFromString: (NSString*) expDate;

+ (NSString*) getTypeForCardNumber: (NSString*) cardNumber;

+ (BOOL) isCardExist: (NSString*) cardNumber expDate: (NSString*)expDate;

@end
