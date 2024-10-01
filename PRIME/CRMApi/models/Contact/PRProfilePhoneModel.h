//
//  PRProfilePhoneModel.h
//  PRIME
//
//  Created by Nerses Hakobyan on 12/28/15.
//  Copyright © 2015 XNTrends. All rights reserved.
//

#import "PRPhoneTypeModel.h"
#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@interface PRProfilePhoneModel : PRModel

@property (nullable, nonatomic, retain) NSString* phoneId;
@property (nullable, nonatomic, retain) NSString* phone;
@property (nullable, nonatomic, retain) NSString* comment;
@property (nullable, nonatomic, retain) NSNumber* primaryNumber;
@property (nullable, nonatomic, retain) PRPhoneTypeModel* phoneType;
@property (nullable, nonatomic, retain) NSNumber* state;

@end
