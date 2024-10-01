//
//  NSString+extended.m
//  PRIME
//
//  Created by Admin on 6/4/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "NSString+extended.h"

static NSCharacterSet* _notDigits = nil;

@implementation NSString (extended)

+ (void)initialize
{
    if (self == [NSString class]) {
        _notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    }
}

- (BOOL)isAllDigits
{
    return [self.class isAllDigits:self];
}

- (NSString*)extractStringToLookFor:(NSString*)lookFor
                  onlyStringBetween:(BOOL)onlyStringBetween
                       toStopBefore:(NSString*)stopBefore
{
    return [self.class extractString:self
                           toLookFor:lookFor
                   onlyStringBetween:onlyStringBetween
                        toStopBefore:stopBefore];
}

+ (BOOL)isAllDigits:(NSString*)string
{
    if ([string rangeOfCharacterFromSet:_notDigits].location == NSNotFound) {
        // date doesn't consist only of the digits 0 through 9
        return TRUE;
    }

    return FALSE;
}

+ (NSString*)extractString:(NSString*)fullString
                 toLookFor:(NSString*)lookFor
         onlyStringBetween:(BOOL)onlyStringBetween
              toStopBefore:(NSString*)stopBefore
{
    NSInteger lookForLength = 0;
    NSInteger stopBeforeLength = [stopBefore length];
    if (onlyStringBetween) {
        lookForLength = [lookFor length];
        stopBeforeLength = 0;
    }
    NSRange firstRange = [fullString rangeOfString:lookFor];

    if (firstRange.length == 0) {
        return nil; //substring not found
    }

    NSRange finalRange;

    if (stopBefore == nil) {
        finalRange = NSMakeRange(firstRange.location + lookForLength, [fullString length] - (firstRange.location + lookForLength));
    } else {
        NSRange secondRange = [[fullString substringFromIndex:firstRange.location + lookForLength] rangeOfString:stopBefore];

        if (secondRange.length == 0) {
            return nil; //substring not found
        }

        finalRange = NSMakeRange(firstRange.location + lookForLength, secondRange.location + stopBeforeLength);
    }

    return [fullString substringWithRange:finalRange];
}

- (BOOL)isValidEmail
{
    if (![self length]) {
        return NO;
    }

    NSString* regExPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";

    NSRegularExpression* regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:self options:0 range:NSMakeRange(0, [self length])];

    return regExMatches;
}

@end
