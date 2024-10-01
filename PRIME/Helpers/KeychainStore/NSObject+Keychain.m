//
//  NSObject+Keychain.m
//  XNTrends
//
//  Created by Simon Simonyan on 2/9/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "NSObject+Keychain.h"
#import "XNTKeychainStore.h"
#import <objc/runtime.h>
#import "NSObject+Motis.h"
#import "NSDate+MTDates.h"

// Extension added by XNTrends
@implementation NSObject (Motis)

- (id)mts_value
{
    NSArray * keys = [[self.class mts_mapping] allKeys];

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:keys.count];

    for (NSString *key in keys)
    {
        id value = [self mts_valueForKey:key];

        if (!value) {
            value = [NSNull null];
        } else if ([[value class]isSubclassOfClass:[NSObject class]]) {
            value = [value mts_value];
        }

        dictionary[key] = value;
    }

    return [dictionary copy];
}

@end

// Extension added by XNTrends
@implementation NSString (Motis)

- (id)mts_value
{
    return self;
}

@end

// Extension added by XNTrends
@implementation NSDate (Motis)

- (id)mts_value
{
    return [self mt_stringFromDateWithISODateTime];
}

@end

// Extension added by XNTrends
@implementation NSArray (Motis)

- (id)mts_value
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity: [self count]];

    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

        id value = obj;

        if (!value) {
            value = [NSNull null];
        } else if ([[value class]isSubclassOfClass:[NSObject class]]) {
            value = [value mts_value];
        }

        [array addObject: value];
    }];

    return array;
}

@end

// Extension added by XNTrends
@implementation NSDictionary (Motis)

- (id)mts_value
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity: [self count]];

    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id value = obj;

        if (!value) {
            value = [NSNull null];
        } else if ([[value class]isSubclassOfClass:[NSObject class]]) {
            value = [value mts_value];
        }

        dict[key] = value;
    }];

    return dict;
}

@end

//////////////////////////////////////////

@implementation NSObject (Keychain)

-(BOOL) storeToKeychainWithKey:(NSString *)key
{
    NSError *error = nil;

    id object = [self mts_value];

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: object
                                                       options: 0
                                                         error: &error];

    if ( !error ) {
        return [XNTKeychainStore setData: jsonData
                                  forKey: key];
    }

    return NO;
}

+(id) dictFromKeychainWithKey:(NSString *)key
{
    NSError *error = nil;

    NSData *jsonData = [XNTKeychainStore dataForKey: key];

    if ( !jsonData ) {
        return nil;
    }

    id dict = [NSJSONSerialization JSONObjectWithData: jsonData
                                              options: NSJSONReadingMutableLeaves | NSJSONReadingMutableContainers
                                                error: &error];
    if (error) {
        return nil;
    }

    return dict;
}


+(instancetype) objectFromKeychainWithKey:(NSString *)key
{
    id dict = [self.class dictFromKeychainWithKey: key];

    if ( !dict) {
        return nil;
    }

    id object = [[self.class alloc] init];

    [NSObject.class initDateFormatter];

    [object mts_setValuesForKeysWithDictionary: dict];

    return object;
}

+ (NSDateFormatter*)dateFormatter
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

    return formatter;
}

+(void) initDateFormatter
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];

        SEL originalSelector = @selector(mts_validationDateFormatter);
        SEL swizzledSelector = @selector(dateFormatter);

        Method originalMethod = class_getClassMethod(class, originalSelector);
        Method swizzledMethod = class_getClassMethod(class, swizzledSelector);

        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

@end
