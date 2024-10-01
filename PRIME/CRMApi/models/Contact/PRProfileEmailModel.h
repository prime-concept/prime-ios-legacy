//
//  PRProfileEmailModel.h
//  PRIME
//
//  Created by Nerses Hakobyan on 12/28/15.
//  Copyright © 2015 XNTrends. All rights reserved.
//

#import "PREmailTypeModel.h"
#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@interface PRProfileEmailModel : PRModel

@property (nullable, nonatomic, retain) NSString* email;
@property (nullable, nonatomic, retain) NSString* emailId;
@property (nullable, nonatomic, retain) NSString* comment;
@property (nonatomic, assign) BOOL primaryNumber;
@property (nullable, nonatomic, retain) PREmailTypeModel* emailType;
@property (nullable, nonatomic, retain) NSNumber* state;

@end
