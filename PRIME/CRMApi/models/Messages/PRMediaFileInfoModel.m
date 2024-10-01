//
//  PRMediaFileInfoModel.m
//  PRIME
//
//  Created by Armen on 6/19/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import "PRMediaFileInfoModel.h"

@implementation PRMediaFileInfoModel

+ (RKObjectMapping*)mapping
{
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:self.class];

    [mapping addAttributeMappingsFromArray:
     @[
       @"name",
       @"size",
       ]];

    return mapping;
}

@end
