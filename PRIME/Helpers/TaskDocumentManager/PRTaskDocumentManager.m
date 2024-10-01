//
//  PRTaskDocumentManager.m
//  PRIME
//
//  Created by Mariam on 3/15/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRTaskDocumentManager.h"

@implementation PRTaskDocumentManager

#pragma mark - Public Methods

+ (void)saveDocumentsForTask:(PRTaskDetailModel*)task withView:(UIView*)view
{
    for (PRTaskItemModel* item in [[task.items array] filteredArrayUsingPredicate:[self.class predicateForDocumentWithPDFNameAndLinkType]]) {

        NSString* uid = [self.class uidForTaskDocumentFromValuePath:item.itemValue];

        if (!uid) {
            return;
        }

        [PRRequestManager downloadTaskDocumentByUID:uid
                                               view:view
                                               mode:PRRequestMode_ShowNothing
                                            success:^(NSData* itemDocumentData) {

                                                NSString* pdfPath = [self.class documentsDirectoryPathWithComponent:[self.class stringWithTaskId:task.taskId name:item.itemName]];
                                                [itemDocumentData writeToFile:pdfPath atomically:YES];
                                            }
                                            failure:^{

                                            }];
    }
}

+ (NSString*)getDocumentWithTaskId:(NSNumber*)taskId name:(NSString*)name
{
    return [self.class documentsDirectoryPathWithComponent:[self.class stringWithTaskId:taskId name:name]];
}

+ (NSString*)getTempFileUrlFromUrl:(NSString*)url
{
    NSString* tempFileURLPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.pdf"];

    // Check if file "temp.pdf" exists at temp directory, remove it then make a new copy.
    if ([[NSFileManager defaultManager] fileExistsAtPath:tempFileURLPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:tempFileURLPath error:nil];
    }

    if ([[NSFileManager defaultManager] copyItemAtPath:url toPath:tempFileURLPath error:nil]) {
        return tempFileURLPath;
    }

    return url;
}

+ (NSNumber*)taskIdFromPath:(NSString*)path
{
    NSString* taskId = [[path componentsSeparatedByString:@"Documents/"] lastObject];
    NSRange range = [taskId rangeOfString:@"_"];
    if (range.location != NSNotFound) {
        taskId = [taskId substringToIndex:range.location];
    }
    return @([taskId intValue]) ?: @(0);
}

+ (NSArray<NSString*>*)getPDFDocumentsPaths
{
    NSMutableArray<NSString*>* pathsArray = [NSMutableArray array];

    for (PRTaskDetailModel* task in [PRDatabase getTasksForTodayAndTomorrowWithPDFDocuments]) {
        for (PRTaskItemModel* item in [[task.items array] filteredArrayUsingPredicate:[self.class predicateForDocumentWithPDFNameAndLinkType]]) {
            NSString* PDFDocumentPath = [PRTaskDocumentManager getDocumentWithTaskId:task.taskId name:item.itemName];
            if ([[NSFileManager defaultManager] fileExistsAtPath:PDFDocumentPath]) {
                [pathsArray addObject:PDFDocumentPath];
            }
        }
    }

    return pathsArray;
}

#pragma mark - Private Methods

+ (NSString*)documentsDirectoryPathWithComponent:(NSString*)component
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:component];
    return path;
}

+ (NSString*)stringWithTaskId:(NSNumber*)taskId name:(NSString*)name
{
    return [NSString stringWithFormat:@"%@_%@", taskId, name];
}

+ (NSString*)uidForTaskDocumentFromValuePath:(NSString*)path
{
    NSString* uid = [[path componentsSeparatedByString:@"download/"] lastObject];
    NSRange range = [uid rangeOfString:@"?access_token"];
    if (range.location != NSNotFound) {
        uid = [uid substringToIndex:range.location];
    }
    return uid;
}

+ (NSPredicate*)predicateForDocumentWithPDFNameAndLinkType
{
    return [NSPredicate predicateWithFormat:@"(itemName CONTAINS[cd] %@) AND (itemType == %@)", @".pdf", @"link"];
}

@end
