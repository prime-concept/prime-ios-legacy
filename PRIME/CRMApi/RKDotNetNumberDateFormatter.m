//
//  RKDotNetNumberDateFormatter.m
//  PRIME
//
//  Created by Admin on 2/6/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "RKDotNetNumberDateFormatter.h"

@implementation RKDotNetNumberDateFormatter

- (BOOL)transformValue:(id)inputValue toValue:(id *)outputValue ofClass:(Class)outputValueClass error:(NSError **)error
{
    RKValueTransformerTestInputValueIsKindOfClass(inputValue, (@[ [NSNumber class], [NSDate class] ]), error);
    RKValueTransformerTestOutputValueClassIsSubclassOfClass(outputValueClass, (@[ [NSNumber class], [NSDate class] ]), error);
    
    if ([outputValueClass isSubclassOfClass:[NSDate class]]) {
        if ([inputValue isKindOfClass:[NSNumber class]]) {
            *outputValue = [self dateFromString: [[NSString alloc] initWithFormat: @"/Date(%@)/", [inputValue stringValue]]];
        }
    } else if ([outputValueClass isSubclassOfClass:[NSNumber class]]) {
        NSAssert(0, @"Not implemented");
        
        NSString * outputString = [self stringFromDate: inputValue];
        NSString * extractedString = [NSString extractString: outputString
                                                   toLookFor: @"/Date("
                                           onlyStringBetween: YES
                                                toStopBefore: @"+0000)/"];
        
        *outputValue = @([extractedString intValue]);
    }
    return YES;
}

- (BOOL)validateTransformationFromClass:(Class)sourceClass toClass:(Class)destinationClass
{
    // This transformer handles `NSNumber` <-> `NSDate` transformations
    return (([sourceClass isSubclassOfClass:[NSNumber class]] && [destinationClass isSubclassOfClass:[NSDate class]]) ||
            ([sourceClass isSubclassOfClass:[NSDate class]] && [destinationClass isSubclassOfClass:[NSNumber class]]));
}


@end
