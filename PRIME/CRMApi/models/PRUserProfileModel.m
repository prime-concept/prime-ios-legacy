//
//  PRUserProfileModel.m
//  PRIME
//
//  Created by Simon on 11/01/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRAssistantContactModel.h"
#import "PRUserProfileModel.h"

@implementation PRUserProfileModel

#ifdef USE_COREDATA
@dynamic username;
@dynamic enabled;
@dynamic email;
@dynamic phone;
@dynamic firstName;
@dynamic middleName;
@dynamic lastName;
@dynamic fullName;
@dynamic customerTypeId;
@dynamic projectId;
@dynamic clubCard;
@dynamic startDate;
@dynamic expiryDate;
@dynamic calendarLink;
@dynamic synched;
@dynamic clubPhone;
@dynamic assistant;
@dynamic features;
#endif

+ (RKObjectMapping*)mapping
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({

        mapping = [super mapping];

        [mapping addAttributeMappingsFromArray:
                     @[
                        @"username",
                        @"enabled",
                        @"email",
                        @"phone",
                        @"firstName",
                        @"middleName",
                        @"lastName",
                        @"fullName",
                        @"customerTypeId",
                        @"projectId",
                        @"clubCard",
                        @"startDate",
                        @"expiryDate",
                        @"calendarLink",
                        @"clubPhone"
                     ]];

        mapping.assignsNilForMissingRelationships = YES;

        [mapping addRelationshipMappingWithSourceKeyPath:@"assistant"
                                                 mapping:[PRAssistantContactModel mapping]];

        [mapping addRelationshipMappingWithSourceKeyPath:@"features"
                                                 mapping:[PRUserProfileFeaturesModel mapping]];

        [PRUserProfileModel setIdentificationAttributes:@[ @"username" ]
                                                mapping:mapping];

    });

    return mapping;
}

@end
