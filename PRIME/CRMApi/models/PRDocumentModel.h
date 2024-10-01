//
//  PRDocumentModel.h
//  PRIME
//
//  Created by Simon on 15/01/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#ifndef PRIME_PRDocumentModel_h
#define PRIME_PRDocumentModel_h

#import "PRModel.h"

@interface PRDocumentModel : PRModel

@property (nullable, nonatomic, retain) NSNumber* documentId;
@property (nullable, nonatomic, retain) NSNumber* documentType;
@property (nullable, nonatomic, retain) NSString* citizenship;
@property (nullable, nonatomic, retain) NSString* documentNumber;
@property (nullable, nonatomic, retain) NSString* issueDate;
@property (nullable, nonatomic, retain) NSString* expiryDate;
@property (nullable, nonatomic, retain) NSString* birthPlace;
@property (nullable, nonatomic, retain) NSString* authority;
@property (nullable, nonatomic, retain) NSString* countryCode;
@property (nullable, nonatomic, retain) NSString* countryName;
@property (nullable, nonatomic, retain) NSNumber* visaTypeId;
@property (nullable, nonatomic, retain) NSString* visaTypeName;
@property (nullable, nonatomic, retain) NSString* firstName;
@property (nullable, nonatomic, retain) NSString* lastName;
@property (nullable, nonatomic, retain) NSString* middleName;
@property (nullable, nonatomic, retain) NSString* birthDate;
@property (nullable, nonatomic, retain) NSString* comment;
@property (nullable, nonatomic, retain) NSString* domicile;
@property (nullable, nonatomic, retain) NSString* categoryOfVehicleName;
@property (nullable, nonatomic, retain) NSString* insuranceCompany;
@property (nullable, nonatomic, retain) NSString* coverage;
@property (nullable, nonatomic, retain) NSString* issuedAt;
@property (nullable, nonatomic, retain) NSString* authorityId;
@property (nullable, nonatomic, retain) PRDocumentModel* relatedPassport;
@property (nullable, nonatomic, retain) NSMutableOrderedSet<PRDocumentModel*>* relatedVisas;

+ (RKObjectMapping*_Nullable)inverseMapping;
+ (RKObjectMapping*_Nullable)mappingForCreateDocument;

@end

#endif