//
//  PRProfileContactModel.m
//  PRIME
//
//  Created by Nerses Hakobyan on 12/28/15.
//  Copyright © 2015 XNTrends. All rights reserved.
//

#import "PRProfileContactEmailModel.h"
#import "PRProfileContactModel.h"
#import "PRProfileContactPhoneModel.h"

@implementation PRProfileContactModel

@dynamic firstName;
@dynamic contactId;
@dynamic lastName;
@dynamic middleName;
@dynamic contactType;
@dynamic phones;
@dynamic emails;
@dynamic birthDate;
@dynamic documents;
@dynamic state;

+ (RKObjectMapping*)mapping
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({

        mapping = [super mapping];

        [mapping addAttributeMappingsFromDictionary:
                     @{
                         @"id" : @"contactId"
                     }];

        [mapping addAttributeMappingsFromArray:
                     @[
                        @"firstName",
                        @"middleName",
                        @"lastName",
                        @"birthDate"
                     ]];

        [mapping addRelationshipMappingWithSourceKeyPath:@"contactType"
                                                 mapping:[PRContactTypeModel mapping]];
        [mapping addRelationshipMappingWithSourceKeyPath:@"phones"
                                                 mapping:[PRProfileContactPhoneModel mapping]];
        [mapping addRelationshipMappingWithSourceKeyPath:@"emails"
                                                 mapping:[PRProfileContactEmailModel mapping]];
        [mapping addRelationshipMappingWithSourceKeyPath:@"documents"
                                                 mapping:[PRProfileContactDocumentModel mapping]];

        mapping.assignsDefaultValueForMissingAttributes = YES;
        mapping.assignsNilForMissingRelationships = YES;

        [self setIdentificationAttributes:@[ @"contactId" ]
                                  mapping:mapping];
    });

    return mapping;
}

- (NSOrderedSet<PRProfileContactPhoneModel*>*)nonDeletedPhones
{
    NSMutableOrderedSet<PRProfileContactPhoneModel*>* phones = [NSMutableOrderedSet orderedSet];

    for (PRProfileContactPhoneModel* phone in self.phones) {
        if (![phone.state isEqualToNumber:@(ModelStatus_Deleted)]) {
            [phones addObject:phone];
        }
    }

    return [phones copy];
}

- (NSOrderedSet<PRProfileContactEmailModel*>*)nonDeletedEmails
{
    NSMutableOrderedSet<PRProfileContactEmailModel*>* emails = [NSMutableOrderedSet orderedSet];

    for (PRProfileContactEmailModel* email in self.emails) {
        if (![email.state isEqualToNumber:@(ModelStatus_Deleted)]) {
            [emails addObject:email];
        }
    }

    return [emails copy];
}

- (NSOrderedSet<PRProfileContactDocumentModel*>*)nonDeletedDocuments
{
    NSMutableOrderedSet<PRProfileContactDocumentModel*>* documents = [NSMutableOrderedSet orderedSet];

    for (PRProfileContactDocumentModel* document in self.documents) {
        if (![document.state isEqualToNumber:@(ModelStatus_Deleted)]) {
            [documents addObject:document];
        }
    }

    return [documents copy];
}

- (NSUInteger)nonDeletedPhonesCount
{
    NSUInteger count = 0;
    for (PRProfileContactPhoneModel* phone in self.phones) {
        if (![phone.state isEqualToNumber:@(ModelStatus_Deleted)]) {
            ++count;
        }
    }

    return count;
}

- (NSUInteger)nonDeletedEmailsCount
{
    NSUInteger count = 0;
    for (PRProfileContactEmailModel* email in self.emails) {
        if (![email.state isEqualToNumber:@(ModelStatus_Deleted)]) {
            ++count;
        }
    }

    return count;
}

- (NSUInteger)nonDeletedDocumentsCount
{
    NSUInteger count = 0;
    for (PRProfileContactDocumentModel* document in self.documents) {
        if (![document.state isEqualToNumber:@(ModelStatus_Deleted)]) {
            ++count;
        }
    }

    return count;
}

@end
