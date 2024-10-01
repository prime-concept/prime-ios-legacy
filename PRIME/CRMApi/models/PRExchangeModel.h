//
//  PRBalanceModel+CoreDataProperties.h
//  PRIME
//
//  Created by Admin on 9/28/15.
//  Copyright © 2015 XNTrends. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "PRBalanceModel.h"
#import "PRModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PRExchangeModel : PRModel

@property (nullable, nonatomic, retain) NSString *currency;
@property (nullable, nonatomic, retain) NSString *date;
@property (nullable, nonatomic, retain) NSNumber *rate;
@property (nullable, nonatomic, retain) NSNumber *quantity;

@end

NS_ASSUME_NONNULL_END
