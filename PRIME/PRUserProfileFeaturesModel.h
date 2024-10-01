//
//  PRUserProfileFeaturesModel.h
//  PRIME
//
//  Created by Davit on 7/29/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "PRModel.h"

@interface PRUserProfileFeaturesModel : PRModel

@property (nonatomic, strong) NSString* feature;

+ (RKObjectMapping*)mapping;

@end
