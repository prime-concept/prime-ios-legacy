//
//  PRStatusModel.h
//  PRIME
//
//  Created by Admin on 2/1/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PRStatusModel : NSObject

@property (nonatomic, strong) NSString* error;
@property (nonatomic, strong) NSString* errorDescription;

+ (RKObjectMapping*) mapping;

@end
