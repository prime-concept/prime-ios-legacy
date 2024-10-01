//
//  RKObjectParameterization+NumberDateFormatter.m
//  PRIME
//
//  Created by Admin on 3/17/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "RKObjectParameterization+NumberDateFormatter.h"

@implementation RKObjectParameterization (NumberDateFormatter)

- (void)mappingOperation:(RKMappingOperation *)operation didSetValue:(id)value forKeyPath:(NSString *)keyPath usingMapping:(RKAttributeMapping *)mapping
{
    id transformedValue = nil;
    if ([value isKindOfClass:[NSDate class]]) {
        [mapping.valueTransformer transformValue:value toValue:&transformedValue ofClass:[NSNumber class] error:nil];
    } else if ([value isKindOfClass:[NSDecimalNumber class]]) {
        // Precision numbers are serialized as strings to work around Javascript notation limits
        transformedValue = [(NSDecimalNumber *)value stringValue];
    } else if ([value isKindOfClass:[NSSet class]]) {
        // NSSets are not natively serializable, so let's just turn it into an NSArray
        transformedValue = [value allObjects];
    } else if ([value isKindOfClass:[NSOrderedSet class]]) {
        // NSOrderedSets are not natively serializable, so let's just turn it into an NSArray
        transformedValue = [value array];
    } else if (value == nil) {
        // Serialize nil values as null
        transformedValue = [NSNull null];
    } else {
        Class propertyClass = RKPropertyInspectorGetClassForPropertyAtKeyPathOfObject(mapping.sourceKeyPath, operation.sourceObject);
        if ([propertyClass isSubclassOfClass:NSClassFromString(@"__NSCFBoolean")] || [propertyClass isSubclassOfClass:NSClassFromString(@"NSCFBoolean")]) {
            transformedValue = @([value boolValue]);
        }
    }
    
    if (transformedValue) {
        RKLogDebug(@"Serialized %@ value at keyPath to %@ (%@)", NSStringFromClass([value class]), NSStringFromClass([transformedValue class]), value);
        [operation.destinationObject setValue:transformedValue forKeyPath:keyPath];
    }
}

@end
