//
//  Utils.h
//  PRIME
//
//  Created by Admin on 6/22/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+ (UIImage*)getImageForCardNumber:(NSString*)cardNumber;
+ (NSString*)stringFromDateString:(NSString*)name;
+ (NSDate*)dateWithComponentsFromDate:(NSDate*)date units:(NSCalendarUnit)units;
+ (NSString*)changeDateStringFormat:(NSString*)dateString toFormat:(NSString*)dateFormat;
+ (NSString*)countryNameFromCode:(NSString*)countryCode;
+ (UIImage*)countryFlagFromCode:(NSString*)countryCode;
+ (NSArray*)removeDuplicateItemsFromArray:(NSArray*)array;
+ (UIStoryboard*)mainStoryboard;
+ (CGFloat)statusBarHight;
+ (NSString *)applyFormatForFormattedString:(NSString *)formattedDigits;
+ (NSString*)removeAllSeparatorsInString:(NSString*)string;
+ (NSString*)fromMillisecondsToFormattedDate:(NSString*)milliseconds;
+ (NSDate*)dateWithOffsetFromNow:(NSInteger)offset;

+ (void)delay:(NSInteger)seconds block:(dispatch_block_t)block;

@end
