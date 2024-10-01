//
//  PRDocumentModel.m
//  PRIME
//
//  Created by Simon on 15/01/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRDocumentModel.h"

@implementation PRDocumentModel

#ifdef USE_COREDATA
@dynamic documentId, documentType, citizenship, documentNumber, issueDate, expiryDate, birthPlace, authority, countryCode, countryName, visaTypeId, visaTypeName, firstName, lastName, middleName, birthDate, comment, relatedPassport, relatedVisas, domicile, categoryOfVehicleName, insuranceCompany, coverage, issuedAt, authorityId;
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
    
        mapping = [super mapping];
        
        [self addMapingAttributes:mapping];
    
    return mapping;
}

+ (RKObjectMapping*)mappingForDocumentWithVisas
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({
        mapping = [super mapping];

        [self addMapingAttributes:mapping];
        [mapping addRelationshipMappingWithSourceKeyPath:@"relatedVisas"
                                                 mapping:[PRDocumentModel mapping]];
    });

    return mapping;
}

+ (RKObjectMapping*)mappingForDocumentWithPassport
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({
        mapping = [super mapping];

        [self addMapingAttributes:mapping];

        [mapping addRelationshipMappingWithSourceKeyPath:@"relatedPassport"
                                                 mapping:[PRDocumentModel mapping]];
    });

    return mapping;
}

+ (RKObjectMapping*)mappingDocument
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({
        mapping = [super mapping];

        [self addMapingAttributes:mapping];
    });

    return mapping;
}

+ (void)addMapingAttributes:(RKObjectMapping*)mapping
{
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

    mapping.assignsDefaultValueForMissingAttributes = YES;
    mapping.assignsNilForMissingRelationships = YES;

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
