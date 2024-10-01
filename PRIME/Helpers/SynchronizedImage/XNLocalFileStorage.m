//
//  XNLocalFileStorage.m
//  PRIME
//
//  Created by Admin on 6/5/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "XNLocalFileStorage.h"

@implementation XNLocalFileStorage

+ (NSString *) filePathWithName: (NSString *) name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    return [documentsPath stringByAppendingPathComponent: name];
}

+ (UIImage *) loadImage: (NSString *) name
{    
    NSString *filePath = [self.class filePathWithName: name];
    
    NSData *imageData = [NSData dataWithContentsOfFile:filePath];
    UIImage *image = [UIImage imageWithData:imageData];
    
    return image;
}

+ (void) saveImage: (UIImage*) image
          withName: (NSString *) name
{
    NSString *filePath = [self.class filePathWithName: name];
    
    [UIImageJPEGRepresentation(image, 100) writeToFile: filePath
                                            atomically: YES];
}

+ (NSDate*) creationDate: (NSString *) name
{
    NSString *filePath = [self.class filePathWithName: name];
    
    NSFileManager* fm = [NSFileManager defaultManager];
    NSDictionary* attrs = [fm attributesOfItemAtPath:filePath error:nil];
    
    if (attrs != nil) {
        NSDate *date = (NSDate*)[attrs objectForKey: NSFileCreationDate];
        NSLog(@"Date Avatar Image is Created: %@", [date description]);
        return date;
    }
    
    NSLog(@"Avatar Image Date Not found");
    return nil;
}


+ (void) createDirectoryRecursivly:(NSString*) path
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path = [[paths objectAtIndex:0] stringByAppendingPathComponent:path];
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        if (![[NSFileManager defaultManager] createDirectoryAtPath:path
                                       withIntermediateDirectories:YES
                                                        attributes:nil
                                                             error:&error])
        {
            NSLog(@"Create directory error: %@", error);
        }
    }
}

+ (NSArray*) filesListForPath:(NSString*) path 
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path = [[paths objectAtIndex:0] stringByAppendingPathComponent:path];
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];

    return directoryContent;
}

+(void) deleteFileFromPath:(NSString*) path
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path = [[paths objectAtIndex:0] stringByAppendingPathComponent:path];

    NSError *error;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error])
        {
            NSLog(@"Delete file error: %@", error);
        }
    }
}

+(void) deleteDirectoryWithName:(NSString*) path
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path = [[paths objectAtIndex:0] stringByAppendingPathComponent:path];
    
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

+(void) moveFileFromSource:(NSString*) source toDestination:(NSString*) destination
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentRootPath = [paths objectAtIndex:0];
    
    NSString *destinationDictionary = [destination stringByDeletingLastPathComponent];
    [self.class createDirectoryRecursivly:destinationDictionary];
    
    [[NSFileManager defaultManager] moveItemAtPath:[documentRootPath stringByAppendingPathComponent:source] toPath:[documentRootPath stringByAppendingPathComponent:destination] error:nil];
}

@end
