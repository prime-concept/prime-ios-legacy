//
//  PRModel.m
//  PRIME
//
//  Created by Simon on 21/01/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRModel.h"

@interface PRModel ()

+ (NSString*)className;

@end

@implementation PRModel

+ (NSString*)className
{
    return NSStringFromClass([self class]);
}

+ (RKObjectMapping*)mapping
{
    RKObjectMapping* mapping = nil;
#ifdef USE_COREDATA
    mapping = [RKEntityMapping mappingForEntityForName:[self className]
                                  inManagedObjectStore:[RKManagedObjectStore defaultStore]];

#else
    mapping = [RKObjectMapping mappingForClass:[self class]];
#endif

    return mapping;
}

+ (void)setIdentificationAttributes:(NSArray*)attributes
                            mapping:(RKObjectMapping*)mapping
{
#ifdef USE_COREDATA
    NSAssert([mapping isKindOfClass:[RKEntityMapping class]],
        @"mapping should be instance of RKEntityMapping class");

    ((RKEntityMapping*)mapping).identificationAttributes = attributes;
#endif
}

- (void)save
{
    [self.managedObjectContext refreshObject:self
                                mergeChanges:YES];

    NSError* error = nil;
    [self.managedObjectContext saveToPersistentStore:&error];
}

@end