//
//  PRAssistantEmailModel.h
//  PRIME
//
//  Created by Artak on 2/26/16.
//  Copyright (c) 2016 XNTrends. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@class PRAssistantEmailTypeModel;

@interface PRAssistantEmailModel : PRModel

@property (nullable, nonatomic, retain) NSString* email;
@property (nullable, nonatomic, retain) NSString* emailId;
@property (nullable, nonatomic, retain) NSNumber* primaryNumber;
@property (nullable, nonatomic, retain) NSNumber* state;
@property (nullable, nonatomic, retain) PRAssistantEmailTypeModel* emailType;

@end
