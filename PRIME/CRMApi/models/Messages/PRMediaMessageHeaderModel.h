//
//  PRMediaHeaderMessageModel.h
//  PRIME
//
//  Created by armens on 4/10/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import "PRModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PRMediaMessageHeaderModel : PRModel

@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* path;
@property (nonatomic, strong) NSString* privacy;
@property (nonatomic, strong) NSString* uuid;

+ (RKObjectMapping*)mapping;

@end

NS_ASSUME_NONNULL_END
