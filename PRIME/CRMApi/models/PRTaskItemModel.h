//
//  PRTaskItemModel.h
//  PRIME
//
//  Created by Simon on 15/01/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#ifndef PRIME_PRTaskItemModel_h
#define PRIME_PRTaskItemModel_h

#import "PRModel.h"

@interface PRTaskItemModel : PRModel

@property (nonatomic, strong) NSString* itemName;
@property (nonatomic, strong) NSString* itemType;
@property (nonatomic, strong) NSString* itemValue;
@property (nonatomic, strong) NSString* itemIcon;
@property (nonatomic, strong) NSNumber* latitude;
@property (nonatomic, strong) NSNumber* longitude;

@property (nonatomic) BOOL shareable;

+ (RKObjectMapping*)mapping;

@end

#endif
