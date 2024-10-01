//
//  NSString+extended.h
//  PRIME
//
//  Created by Admin on 6/4/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (extended)

- (BOOL)isAllDigits;

- (NSString*)extractStringToLookFor:(NSString*)lookFor
                  onlyStringBetween:(BOOL)onlyStringBetween
                       toStopBefore:(NSString*)stopBefore;

+ (BOOL)isAllDigits:(NSString*)string;

+ (NSString*)extractString:(NSString*)fullString
                 toLookFor:(NSString*)lookFor
         onlyStringBetween:(BOOL)onlyStringBetween
              toStopBefore:(NSString*)stopBefore;

-(BOOL)isValidEmail;

@end

