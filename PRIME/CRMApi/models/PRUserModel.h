//
//  PRUserModel.h
//  PRIME
//
//  Created by Simon on 3/13/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#ifndef PRIME_PRUserModel_h
#define PRIME_PRUserModel_h

#import "PRModel.h"

@interface PRUserModel : PRModel

@property (nonatomic, strong) NSNumber      *userId;
@property (nonatomic, strong) NSString      *userName;

+ (RKObjectMapping*) mapping;

@end


#endif //PRIME_PRUserModel_h
