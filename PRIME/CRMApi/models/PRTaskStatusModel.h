//
//  PRTaskStatusModel.h
//  PRIME
//
//  Created by Simon on 15/01/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#ifndef PRIME_PRTaskStatusModel_h
#define PRIME_PRTaskStatusModel_h

#import "PRModel.h"

@interface PRTaskStatusModel : PRModel

@property (nonatomic, strong) NSNumber      *statusId;
@property (nonatomic, strong) NSString      *statusName;

+ (RKObjectMapping*) mapping;

@end

#endif
