//
//  XNLocalFileStorage.h
//  PRIME
//
//  Created by Admin on 6/5/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XNLocalFileStorage : NSObject

+ (UIImage *) loadImage: (NSString *) name;

+ (void) saveImage: (UIImage*) image
          withName: (NSString *) name;

+ (NSDate*) creationDate: (NSString *) name;

+ (void) createDirectoryRecursivly:(NSString*) path;

+ (NSArray*) filesListForPath:(NSString*) path;

+(void) deleteFileFromPath:(NSString*) path;

+(void) deleteDirectoryWithName:(NSString*) name;

+(void) moveFileFromSource:(NSString*) source toDestination:(NSString*) destination;
@end
