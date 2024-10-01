//
//  PRTasksTypesModel.h
//  PRIME
//
//  Created by Admin on 2/17/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#ifndef PRIME_PRTasksTypesModel_h
#define PRIME_PRTasksTypesModel_h

#import "PRModel.h"

@interface PRTasksTypesModel : PRModel

@property (nonatomic, strong) NSNumber* typeId;
@property (nonatomic, strong) NSString* typeName;
@property (nonatomic, strong) NSNumber* count;

+ (RKObjectMapping*)mapping;

@end

#endif
