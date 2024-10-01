//
//  PRMediaFileInfoModel.h
//  PRIME
//
//  Created by Armen on 6/19/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@interface PRMediaFileInfoModel : NSObject

@property (nonatomic, assign) NSInteger size;
@property (nonatomic, strong) NSString* name;

+ (RKObjectMapping*)mapping;

@end

NS_ASSUME_NONNULL_END
