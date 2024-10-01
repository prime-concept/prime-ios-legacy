//
//  PRUploadMediaFileProgressInfoModel.h
//  PRIME
//
//  Created by armens on 4/19/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import "PRModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PRUploadMediaFileProgressInfoModel : NSObject

@property (nonatomic, strong) NSNumber* percentTransfered;
@property (nonatomic, assign) NSInteger bytesTransfered;
@property (nonatomic, assign) NSInteger size;
@property (nonatomic, strong) NSString* uuid;
@property (nonatomic, strong) NSString* state;

+ (RKObjectMapping*)mapping;

@end

NS_ASSUME_NONNULL_END
