//
//  PRLoyalCardModel.h
//  PRIME
//
//  Created by Admin on 7/16/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRModel.h"
#import "PRCardTypeModel.h"

@interface PRLoyalCardModel : PRModel

@property (nonatomic, strong) NSNumber* cardId;
@property (nonatomic, strong) PRCardTypeModel* type;
@property (nonatomic, strong) NSString* cardNumber;
@property (nonatomic, strong) NSString* issueDate;
@property (nonatomic, strong) NSString* expiryDate;
@property (nonatomic, strong) NSString* cardDescription;
@property (nonatomic, strong) NSString* password;

@property (nonatomic, strong) NSNumber* syncStatus; //0 norm, -1 deleted, 1 added
+ (RKObjectMapping*)mapping;

@end
