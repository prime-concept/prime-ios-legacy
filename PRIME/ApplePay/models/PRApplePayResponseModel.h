//
//  PRApplePayResponseModel.h
//  PRIME
//
//  Created by Davit on 1/10/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PRApplePayErrorModel.h"

@interface PRApplePayResponseModel : NSObject

@property (strong, nonatomic) NSNumber* success;
@property (strong, nonatomic) NSNumber* paymentResult;
@property (strong, nonatomic) PRApplePayErrorModel* error;

+ (RKObjectMapping*)mapping;

@end
