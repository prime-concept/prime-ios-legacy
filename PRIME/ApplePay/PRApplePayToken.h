//
//  PRApplePayToken.h
//  PRIME
//
//  Created by Davit on 1/17/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PRApplePayToken : NSObject

@property (strong, nonatomic) NSString* paymentToken;
@property (strong, nonatomic) NSString* paymentUid;

+ (RKObjectMapping*)mapping;

@end
