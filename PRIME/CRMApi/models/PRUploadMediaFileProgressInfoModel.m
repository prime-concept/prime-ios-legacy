//
//  PRUploadMediaFileProgressInfoModel.m
//  PRIME
//
//  Created by armens on 4/19/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import "PRUploadMediaFileProgressInfoModel.h"

@implementation PRUploadMediaFileProgressInfoModel

+ (RKObjectMapping*)mapping
{
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:self.class];

    [mapping addAttributeMappingsFromArray:
     @[
       @"percentTransfered",
       @"bytesTransfered",
       @"size",
       @"uuid",
       @"state"
       ]];

    return mapping;
}

@end
