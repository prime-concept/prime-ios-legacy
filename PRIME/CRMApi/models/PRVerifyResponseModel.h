//
//  PRVerifyResponseModel.h
//  PRIME
//
//  Created by Artak on 30/05/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PRVerifyResponseModel : NSObject

@property (nonatomic, strong) NSString* username;

+ (RKObjectMapping*) mapping;

@end
