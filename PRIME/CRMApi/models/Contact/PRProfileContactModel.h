//
//  PRProfileContactModel.h
//  PRIME
//
//  Created by Nerses Hakobyan on 12/28/15.
//  Copyright © 2015 XNTrends. All rights reserved.
//

#import "PRContactTypeModel.h"
#import "PRProfileContactEmailModel.h"
#import "PRProfileContactPhoneModel.h"
#import "PRProfileContactDocumentModel.h"
#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@interface PRProfileContactModel : PRModel

@property (nullable, nonatomic, retain) NSString* firstName;
@property (nullable, nonatomic, retain) NSString* middleName;
@property (nullable, nonatomic, retain) NSNumber* contactId;
@property (nullable, nonatomic, retain) NSString* lastName;
@property (nullable, nonatomic, retain) NSString* birthDate;
@property (nullable, nonatomic, retain) PRContactTypeModel* contactType;
@property (nullable, nonatomic, retain) NSMutableOrderedSet<PRProfileContactPhoneModel*>* phones;
@property (nullable, nonatomic, retain) NSMutableOrderedSet<PRProfileContactEmailModel*>* emails;
@property (nullable, nonatomic, retain) NSMutableOrderedSet<PRProfileContactDocumentModel*>* documents;
@property (nullable, nonatomic, retain) NSNumber* state;

- (NSOrderedSet<PRProfileContactPhoneModel*>* _Nonnull)nonDeletedPhones;
- (NSOrderedSet<PRProfileContactEmailModel*>* _Nonnull)nonDeletedEmails;
- (NSOrderedSet<PRProfileContactDocumentModel*>* _Nonnull)nonDeletedDocuments;
- (NSUInteger)nonDeletedPhonesCount;
- (NSUInteger)nonDeletedEmailsCount;
- (NSUInteger)nonDeletedDocumentsCount;

@end

NS_ASSUME_NONNULL_BEGIN

@interface PRProfileContactModel (CoreDataGeneratedAccessors)

- (void)insertObject:(PRProfileContactEmailModel*)value inEmailsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromEmailsAtIndex:(NSUInteger)idx;
- (void)insertEmails:(NSArray<PRProfileContactEmailModel*>*)value atIndexes:(NSIndexSet*)indexes;
- (void)removeEmailsAtIndexes:(NSIndexSet*)indexes;
- (void)replaceObjectInEmailsAtIndex:(NSUInteger)idx withObject:(PRProfileContactEmailModel*)value;
- (void)replaceEmailsAtIndexes:(NSIndexSet*)indexes withEmails:(NSArray<PRProfileContactEmailModel*>*)values;
- (void)addEmailsObject:(PRProfileContactEmailModel*)value;
- (void)removeEmailsObject:(PRProfileContactEmailModel*)value;
- (void)addEmails:(NSOrderedSet<PRProfileContactEmailModel*>*)values;
- (void)removeEmails:(NSOrderedSet<PRProfileContactEmailModel*>*)values;

- (void)insertObject:(PRProfileContactPhoneModel*)value inPhonesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPhonesAtIndex:(NSUInteger)idx;
- (void)insertPhones:(NSArray<PRProfileContactPhoneModel*>*)value atIndexes:(NSIndexSet*)indexes;
- (void)removePhonesAtIndexes:(NSIndexSet*)indexes;
- (void)replaceObjectInPhonesAtIndex:(NSUInteger)idx withObject:(PRProfileContactPhoneModel*)value;
- (void)replacePhonesAtIndexes:(NSIndexSet*)indexes withPhones:(NSArray<PRProfileContactPhoneModel*>*)values;
- (void)addPhonesObject:(PRProfileContactPhoneModel*)value;
- (void)removePhonesObject:(PRProfileContactPhoneModel*)value;
- (void)addPhones:(NSOrderedSet<PRProfileContactPhoneModel*>*)values;
- (void)removePhones:(NSOrderedSet<PRProfileContactPhoneModel*>*)values;

@end

NS_ASSUME_NONNULL_END
