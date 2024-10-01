//
//  PRProfileContactDocumentModel.m
//  PRIME
//
//  Created by Mariam on 2/15/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRProfileContactDocumentModel.h"

@implementation PRProfileContactDocumentModel

#ifdef USE_COREDATA
@dynamic documentId, documentType, citizenship, documentNumber, issueDate, expiryDate, birthPlace, authority, countryCode, countryName, visaTypeId, visaTypeName, firstName, lastName, middleName, birthDate, profileContact, state, comment, imagesData, domicile, categoryOfVehicleName, insuranceCompany, coverage, issuedAt, authorityId, relatedPassport, relatedVisas;
#endif

+ (RKDynamicMapping*)mapping
{
    static RKDynamicMapping* dynamicMapping = nil;

    pr_dispatch_once({
        dynamicMapping = [RKDynamicMapping new];

        [dynamicMapping setObjectMappingForRepresentationBlock:^RKObjectMapping *(id representation) {
            id relatedPassport = [representation valueForKey:@"relatedPassport"];
            id relatedVisas = [representation valueForKey:@"relatedVisas"];
            if (relatedPassport) {
                return [self.class mappingForDocumentWithPassport];
            } else if (relatedVisas) {
                return [self.class mappingForDocumentWithVisas];
            } else {
                return [self.class mappingDocument];
            }
        }];

    });

    return dynamicMapping;
}

+ (RKObjectMapping*)mappingForCreateDocument
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({
    mapping = [super mapping];

    [self addMapingAttributes:mapping];
    });

    return mapping;
}

+ (RKObjectMapping*)mappingForDocumentWithVisas
{
    static RKObjectMapping* mapping = nil;

    mapping = [super mapping];

    [self addMapingAttributes:mapping];
    [mapping addRelationshipMappingWithSourceKeyPath:@"relatedVisas"
                                             mapping:[PRDocumentModel mapping]];

    return mapping;
}

+ (RKObjectMapping*)mappingForDocumentWithPassport
{
    static RKObjectMapping* mapping = nil;

    mapping = [super mapping];

    [self addMapingAttributes:mapping];

    [mapping addRelationshipMappingWithSourceKeyPath:@"relatedPassport"
                                             mapping:[PRDocumentModel mapping]];

    return mapping;
}

+ (RKObjectMapping*)mappingDocument
{
    static RKObjectMapping* mapping = nil;

    mapping = [super mapping];

    [self addMapingAttributes:mapping];

    return mapping;
}

+ (void)addMapingAttributes:(RKObjectMapping*)mapping
{
    mapping.assignsDefaultValueForMissingAttributes = YES;
    mapping.assignsNilForMissingRelationships = YES;

    [mapping addAttributeMappingsFromDictionary:
     @{
       @"id" : @"documentId"
       }];

    [mapping addAttributeMappingsFromArray:
     @[
       @"documentType",
       @"citizenship",
       @"documentNumber",
       @"issueDate",
       @"expiryDate",
       @"birthPlace",
       @"authority",
       @"countryCode",
       @"countryName",
       @"visaTypeId",
       @"visaTypeName",
       @"firstName",
       @"lastName",
       @"birthDate",
       @"middleName",
       @"comment",
       @"domicile",
       @"categoryOfVehicleName",
       @"insuranceCompany",
       @"coverage",
       @"issuedAt",
       @"authorityId"
       ]];

    [[self class] setIdentificationAttributes:@[ @"documentId" ]
                                      mapping:mapping];
}

+ (RKObjectMapping*)inverseMapping
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({
        mapping = [super mapping];

        [self addMapingAttributes:mapping];

    });

    return [mapping inverseMapping];
}

@end
