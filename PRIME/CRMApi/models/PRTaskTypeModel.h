//
//  PRTaskTypeModel.h
//  PRIME
//
//  Created by Simon on 15/01/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#ifndef PRIME_PRTaskTypeModel_h
#define PRIME_PRTaskTypeModel_h

#import "PRModel.h"

@interface PRTaskTypeModel : PRModel

@property (nonatomic, strong) NSNumber* typeId;
@property (nonatomic, strong) NSString* typeName;

+ (RKObjectMapping*)mapping;

@end

#endif
