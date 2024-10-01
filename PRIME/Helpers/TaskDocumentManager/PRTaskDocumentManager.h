//
//  PRTaskDocumentManager.h
//  PRIME
//
//  Created by Mariam on 3/15/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PRTaskDetailModel.h"

@interface PRTaskDocumentManager : NSObject

// Saves items PDF documents for given task.
+ (void)saveDocumentsForTask:(PRTaskDetailModel*)task withView:(UIView*)view;

// Gets PDF document with given taskID and item name.
+ (NSString*)getDocumentWithTaskId:(NSNumber*)taskId name:(NSString*)name;

// Copies file from Documents Directory to TempDirectory and returns the url.
+ (NSString*)getTempFileUrlFromUrl:(NSString*)url;

// Gets cached PDF documents' paths.
+ (NSArray<NSString*>*)getPDFDocumentsPaths;

// Finds the task Id from given path.
+ (NSNumber*)taskIdFromPath:(NSString*)path;

@end
