//
//  PRApplePayItemModel.h
//  PRIME
//
//  Created by Davit on 1/10/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PRApplePayItemModel : NSObject

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* amount;

+ (RKObjectMapping*)mapping;

@end
