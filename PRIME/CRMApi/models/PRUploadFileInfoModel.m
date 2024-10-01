//
//  PRFileInfoModel.m
//  PRIME
//
//  Created by Admin on 4/2/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRUploadFileInfoModel.h"

@implementation PRUploadFileInfoModel

#ifdef USE_COREDATA
@dynamic uid, documentId, fileName, size, createdAt, contentType, fileDescription, height, width;
#endif

+ (RKObjectMapping*) mapping
{
    static RKObjectMapping *mapping = nil;
    
    pr_dispatch_once({
        
        mapping = [super mapping];
        
        [mapping addAttributeMappingsFromDictionary:
         @{
           @"description" : @"fileDescription"
           }];
        
        [mapping addAttributeMappingsFromArray:
         @[
           @"uid",
           @"fileName",
           @"size",
           @"createdAt",
           @"contentType",
           @"height",
           @"width"
           ]];
        
    });
    
    return mapping;
}

+ (PRUploadFileInfoModel*) entityFromFileInfo: (PRListFileInfoModel *) fileInfo
{
    PRUploadFileInfoModel *uFileInfo = [PRUploadFileInfoModel MR_createEntity];
    
    uFileInfo.uid = fileInfo.uid;
    uFileInfo.documentId = fileInfo.documentId;
    uFileInfo.fileName = fileInfo.fileName;
    uFileInfo.size = fileInfo.size;
    uFileInfo.createdAt = fileInfo.createdAt;
    uFileInfo.contentType = fileInfo.contentType;
    uFileInfo.fileDescription = fileInfo.fileDescription;
    uFileInfo.width = fileInfo.width;
    uFileInfo.height = fileInfo.height;
    
    return uFileInfo;
}

@end
