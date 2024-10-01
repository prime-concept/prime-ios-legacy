//
//  PRApplePayErrorModel.h
//  PRIME
//
//  Created by Davit on 1/10/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PRApplePayErrorModel : NSObject

@property (strong, nonatomic) NSString* errorCode;
@property (strong, nonatomic) NSString* errorDescription;

+ (RKObjectMapping*)mapping;

@end
