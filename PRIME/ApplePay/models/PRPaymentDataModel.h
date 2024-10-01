//
//  PRPaymentDataModel.h
//  PRIME
//
//  Created by Davit on 1/16/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PRApplePayInfoModel.h"

@interface PRPaymentDataModel : NSObject

@property (strong, nonatomic) NSNumber* success;
@property (strong, nonatomic) NSString* status;
@property (strong, nonatomic) PRApplePayInfoModel* data;

+ (RKObjectMapping*)mapping;

@end
