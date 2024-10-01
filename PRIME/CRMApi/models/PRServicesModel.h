//
//  PRServicesModel.h
//  PRIME
//
//  Created by Gayane on 5/13/16.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRModel.h"

@interface PRServicesModel : PRModel

@property (nonatomic, assign) NSNumber* serviceId;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* serviceDescription;
@property (nonatomic, strong) NSString* icon;
@property (nonatomic, strong) NSString* url;
@property (nonatomic, strong) NSString* nativeUrl;
@property (nonatomic, strong) NSData* image;

+ (RKObjectMapping*)mapping;

@end
