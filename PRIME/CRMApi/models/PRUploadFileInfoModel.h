//
//  PRFileInfoModel.h
//  PRIME
//
//  Created by Admin on 4/2/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRModel.h"
#import "PRListFileInfoModel.h"

@interface PRUploadFileInfoModel : PRModel <PRFileInfoInterface>

@property (nonatomic, strong) NSString      *uid;
@property (nonatomic, strong) NSNumber      *documentId; // nil is Avatar
@property (nonatomic, strong) NSString      *fileName;
@property (nonatomic, strong) NSNumber      *size;
@property (nonatomic, strong) NSDate        *createdAt;
@property (nonatomic, strong) NSString      *contentType;
@property (nonatomic, strong) NSString      *fileDescription;
@property (nonatomic, strong) NSNumber      *width;
@property (nonatomic, strong) NSNumber      *height;

+ (PRUploadFileInfoModel*) entityFromFileInfo: (PRListFileInfoModel *) fileInfo;

@end
