//
//  PROrderModel.h
//  PRIME
//
//  Created by Admin on 2/18/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#ifndef PRIME_PROrderModel_h
#define PRIME_PROrderModel_h

#import "PRModel.h"

@interface PROrderModel : PRModel

@property (nonatomic, strong) NSNumber* orderStatus;
@property (nonatomic, strong) NSString* amount;
@property (nonatomic, strong) NSString* paymentLink;
@property (nonatomic, strong) NSString* paymentUid;
@property (nonatomic, strong) NSString* dueDate;
@property (nonatomic, strong) NSString* currency;

+ (RKObjectMapping*)mapping;
- (NSString*)getCurrency;

@end

#endif //PRIME_PROrderModel_h
