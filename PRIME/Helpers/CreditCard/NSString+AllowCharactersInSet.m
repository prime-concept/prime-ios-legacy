//
//  NSString+AllowCharactersInSet.m
//  PRIME
//
//  Created by Admin on 2/6/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "NSString+AllowCharactersInSet.h"

@implementation NSString (AllowCharactersInSet)

- (NSString *)stringByAllowingOnlyCharactersInSet:(NSCharacterSet *)characterSet {
    NSMutableString *strippedString = [NSMutableString
                                       stringWithCapacity:self.length];
    
    NSScanner *scanner = [NSScanner scannerWithString:self];
    
    while (!scanner.isAtEnd) {
        NSString *buffer = nil;
        
        if ([scanner scanCharactersFromSet:characterSet intoString:&buffer]) {
            [strippedString appendString:buffer];
        } else {
            scanner.scanLocation = scanner.scanLocation + 1;
        }
    }
    
    return strippedString;
}

@end
