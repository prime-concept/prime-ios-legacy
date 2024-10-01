//
//  PRActionModel.h
//  PRIME
//
//  Created by Simon on 3/13/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#ifndef PRIME_PRActionModel_h
#define PRIME_PRActionModel_h

#import "PRModel.h"
#import "PRUserModel.h"

@interface PRActionModel : PRModel

@property (nonatomic, strong) NSNumber      *actionId;
@property (nonatomic, strong) NSString      *actionName;
@property (nonatomic, strong) NSDate        *date;
@property (nonatomic, strong) NSString      *code;
@property (nonatomic, strong) NSString      *actionDescription;
@property (nonatomic, strong) PRUserModel   *user;

+ (RKObjectMapping*) mapping;

@end

#endif //PRIME_PRActionModel_h
