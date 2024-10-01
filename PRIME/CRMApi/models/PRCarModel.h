//
//  PRCarModel.h
//  PRIME
//
//  Created by Mariam on 6/19/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRModel.h"

@class PRCarModel;

@interface PRCarModelResponse : PRModel

@property (nonatomic, strong) NSMutableOrderedSet<PRCarModel*>* data;

+ (RKObjectMapping*)mapping;

@end

@interface PRCarModel : PRModel

@property (nonatomic, strong) NSNumber* carId;
@property (nonatomic, strong) NSString* vin;
@property (nonatomic, strong) NSString* registrationPlate;
@property (nonatomic, strong) NSString* brand;
@property (nonatomic, strong) NSString* model;
@property (nonatomic, strong) NSString* releaseDate;
@property (nonatomic, strong) NSString* color;

@property (nonatomic, strong) NSNumber* state;

+ (RKObjectMapping*)mapping;

@end
