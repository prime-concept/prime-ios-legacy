//
//  PRPhoneNumberFormatter.m
//  PRIME
//
//  Created by Mariam on 5/10/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRPhoneNumberFormatter.h"

@implementation PRPhoneNumberFormatter

#pragma mark - Public Methods

+ (NSString*)formatForPhoneNumber:(NSString*)phoneNumber
{
    NSString* code = @"";
    for (int i = 0; i < phoneNumber.length; i++) {
        code = [code stringByAppendingString:[phoneNumber substringWithRange:NSMakeRange(i, 1)]];
        if ([self formatForCountryCode:[code integerValue]].length > 0) {
            return [self formatForCountryCode:[code integerValue]];
        }
    }
    return DEFAULT_PHONE_FORMAT;
}

+ (NSString*)formatWithPrefixForPhoneNumber:(NSString*)phoneNumber
{
    return [@"+" stringByAppendingString:[PRPhoneNumberFormatter formatForPhoneNumber:phoneNumber]];
}

+ (NSString*)formatedStringForPhone:(NSString*)phone
{
    if (!phone || !phone.length) {
        return @"";
    }

    SHSPhoneTextField* textFieldForFormat = [[SHSPhoneTextField alloc] init];
    textFieldForFormat.text = phone;
    [textFieldForFormat.formatter setDefaultOutputPattern:[PRPhoneNumberFormatter formatForPhoneNumber:phone]];
    [textFieldForFormat.formatter setPrefix:@"+"];
    return textFieldForFormat.text;
}

+ (NSString*)formatForCountryCode:(NSInteger)code
{
    switch (code) {
    case 7: // Russia
        return @"# (###) ###-##-##-##-##-##-##";

    case 1: // US, Canada
        return @"# (###) ###-####-####-####";

    case 33: // France
        return @"## (#) ##-##-##-##-##-##-##-##";

    case 46: // Sweden
        return @"## (##) ###-##-##-##-##-##-##";

    case 32: // Belgium
    case 34: // Spain
    case 49: // Germany
        return @"## (###) ##-##-##-##-##-##-##";

    case 30: // Greece
    case 39: // Italy
        return @"## (###) ###-####-###-####";

    case 44: // UK
        return @"## (####) ###-###-###-####";

    case 374: // Armenia
        return @"### (##) ##-##-##-##-##-##-##";

    case 375: // Belarus
    case 380: // Ukraine
        return @"### (##) ###-####-####-###";

    default:
        return @"";
    }
}

@end
