//
//  PRProfileContactEmailModel.h
//  PRIME
//
//  Created by Nerses Hakobyan on 12/29/15.
//  Copyright © 2015 XNTrends. All rights reserved.
//

#import "PREmailTypeModel.h"
#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@class PRProfileContactModel;

@interface PRProfileContactEmailModel : PRModel

@property (nullable, nonatomic, retain) NSString* emailId;
@property (nullable, nonatomic, retain) NSString* email;
@property (nullable, nonatomic, retain) NSString* comment;
@property (nullable, nonatomic, retain) NSNumber* primaryNumber;
@property (nullable, nonatomic, retain) PREmailTypeModel* emailType;
@property (nullable, nonatomic, retain) NSNumber* state;
@property (nullable, nonatomic, retain) PRProfileContactModel* profileContact;
@end
