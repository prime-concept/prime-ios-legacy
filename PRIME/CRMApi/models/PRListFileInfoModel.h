//
//  PRListFileInfoModel.h
//  PRIME
//
//  Created by Admin on 6/5/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRFileInfoInterface.h"

@interface PRListFileInfoModel : NSObject <PRFileInfoInterface> //IMPORTANT!!! Should not be in Core Data

@property (nonatomic, strong) NSString      *uid;
@property (nonatomic, strong) NSNumber      *documentId; // nil is Avatar
@property (nonatomic, strong) NSString      *fileName;
@property (nonatomic, strong) NSNumber      *size;
@property (nonatomic, strong) NSDate        *createdAt;
@property (nonatomic, strong) NSString      *contentType;
@property (nonatomic, strong) NSString      *fileDescription;
@property (nonatomic, strong) NSNumber      *width;
@property (nonatomic, strong) NSNumber      *height;

+ (RKObjectMapping*) mapping;

@end
