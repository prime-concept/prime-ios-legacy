//
//  PRWGCacheManager.m
//  PRIME
//
//  Created by Armen on 5/22/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import "PRWGCacheManager.h"

@implementation PRWGCacheManager

+ (void)addFileToCache:(NSData*)fileData fileName:(NSString*)fileName
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* filePath = [self.class pathOfFileWithName:fileName];

    if (![fileManager fileExistsAtPath:filePath])
    {
        [fileData writeToFile:filePath atomically:YES];
    }
}

+ (void)removeFileFromCache:(NSString*)fileName
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* filePath = [self.class pathOfFileWithName:fileName];

    [fileManager removeItemAtPath:filePath error:nil];
}

+ (NSData*)getFileDataFromCache:(NSString*)fileName
{
    NSString* filePath = [self.class pathOfFileWithName:fileName];

    return [NSData dataWithContentsOfFile:filePath];
}

+ (BOOL)isFileExistInCache:(NSString*)fileName
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* filePath = [self.class pathOfFileWithName:fileName];

    return [fileManager fileExistsAtPath:filePath] ? YES : NO;
}

+ (NSString*)pathOfFileWithName:(NSString*)fileName
{
    NSString* docDirPath = [[self.class applicationDocumentsDirectory] path];
    NSString* filePath = [NSString stringWithFormat:@"%@/%@", docDirPath, fileName];

    return filePath;
}

+ (NSURL*)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

@end
