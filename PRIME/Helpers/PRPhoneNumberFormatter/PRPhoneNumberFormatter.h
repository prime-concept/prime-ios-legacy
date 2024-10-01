//
//  PRPhoneNumberFormatter.h
//  PRIME
//
//  Created by Mariam on 5/10/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHSPhoneTextField+DeleteBackward.h"

@interface PRPhoneNumberFormatter : NSObject

// Returns pattern/format for given phone number.
+ (NSString*)formatForPhoneNumber:(NSString*)phoneNumber;

// Returns pattern/format for given phone number with prefix '+'.
+ (NSString*)formatWithPrefixForPhoneNumber:(NSString*)phoneNumber;

// Returns the right formatted string for given phone number.
+ (NSString*)formatedStringForPhone:(NSString*)phone;

// Returns pattern/format for given country code.
+ (NSString*)formatForCountryCode:(NSInteger)code;

@end
