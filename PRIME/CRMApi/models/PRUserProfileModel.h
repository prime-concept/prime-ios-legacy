//
//  PRUserProfileModel.h
//  PRIME
//
//  Created by Simon on 15/01/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#ifndef PRIME_PRUserProfileModel_h
#define PRIME_PRUserProfileModel_h

#import "PRAssistantContactModel.h"
#import "PRModel.h"
#import "PRUserProfileFeaturesModel.h"

// Профиль пользователя

@interface PRUserProfileModel : PRModel

@property (nonatomic, strong) NSString* username;
@property (nonatomic, strong) NSString* email;
@property (nonatomic, strong) NSString* phone;
@property (nonatomic, strong) NSString* firstName;
@property (nonatomic, strong) NSString* middleName;
@property (nonatomic, strong) NSString* lastName;
@property (nonatomic, strong) NSString* fullName;
@property (nonatomic, strong) NSNumber* customerTypeId;
@property (nonatomic, strong) NSNumber* projectId;
@property (nonatomic, strong) NSString* clubCard;
@property (nonatomic, strong) NSString* startDate;
@property (nonatomic, strong) NSString* expiryDate;
@property (nonatomic, strong) NSString* calendarLink;
@property (nonatomic, strong) NSString* clubPhone;

@property (nonatomic, strong) PRAssistantContactModel* assistant;
@property (nonatomic, strong) NSOrderedSet<PRUserProfileFeaturesModel*>* features;

@property (nonatomic, assign) BOOL synched;
@property (nonatomic, assign) BOOL enabled;

+ (RKObjectMapping*)mapping;

@end

#endif
