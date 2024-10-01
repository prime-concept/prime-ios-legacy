//
//  PRMediaMessageModel.h
//  PRIME
//
//  Created by armens on 4/10/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import "PRModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PRMediaMessageModel : PRModel

@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* path;
@property (nonatomic, strong) NSString* privacy;
@property (nonatomic, strong) NSString* uuid;
@property (nonatomic, strong) NSString* checksum;

+ (RKObjectMapping*)mapping;

@end

NS_ASSUME_NONNULL_END
