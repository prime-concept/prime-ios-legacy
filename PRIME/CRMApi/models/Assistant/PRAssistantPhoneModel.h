//
//  PRAssistantPhoneModel.h
//  PRIME
//
//  Created by Artak on 2/26/16.
//  Copyright (c) 2016 XNTrends. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@class PRPAssistantPhoneTypeModel;

NS_ASSUME_NONNULL_BEGIN

@interface PRAssistantPhoneModel : PRModel

@property (nullable, nonatomic, retain) NSString* phone;
@property (nullable, nonatomic, retain) NSString* phoneId;
@property (nullable, nonatomic, retain) NSNumber* primaryNumber;
@property (nullable, nonatomic, retain) NSNumber* state;
@property (nullable, nonatomic, retain) PRPAssistantPhoneTypeModel* phoneType;

@end

NS_ASSUME_NONNULL_END
