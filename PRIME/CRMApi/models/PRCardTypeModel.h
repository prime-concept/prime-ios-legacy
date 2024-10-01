//
//  PRCardTypeModel.h
//  PRIME
//
//  Created by Admin on 7/16/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRModel.h"

@interface PRCardTypeModel : PRModel

@property (nonatomic, strong) NSNumber* typeId;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSNumber* position;
@property (nonatomic, strong) NSString* color;
@property (nonatomic, strong) NSString* logoUrl;

+ (RKObjectMapping*)mapping;

@end
