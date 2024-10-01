//
//  PRAssistantContactModel.h
//  PRIME
//
//  Created by Artak on 2/26/16.
//  Copyright (c) 2016 XNTrends. All rights reserved.
//

#import "PRAssistantEmailModel.h"
#import "PRAssistantPhoneModel.h"
#import "PRAssistantTypeModel.h"
#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PRAssistantContactModel : PRModel

@property (nullable, nonatomic, retain) NSNumber* contactId;
@property (nullable, nonatomic, retain) NSString* firstName;
@property (nullable, nonatomic, retain) NSString* lastName;
@property (nullable, nonatomic, retain) NSString* middleName;
@property (nullable, nonatomic, retain) NSNumber* state;
@property (nullable, nonatomic, retain) PRAssistantTypeModel* contactType;
@property (nullable, nonatomic, retain) NSOrderedSet<PRAssistantEmailModel*>* emails;
@property (nullable, nonatomic, retain) NSOrderedSet<PRAssistantPhoneModel*>* phones;

@end

@interface PRAssistantContactModel (CoreDataGeneratedAccessors)

- (void)insertObject:(PRAssistantEmailModel*)value inEmailsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromEmailsAtIndex:(NSUInteger)idx;
- (void)insertEmails:(NSArray<PRAssistantEmailModel*>*)value atIndexes:(NSIndexSet*)indexes;
- (void)removeEmailsAtIndexes:(NSIndexSet*)indexes;
- (void)replaceObjectInEmailsAtIndex:(NSUInteger)idx withObject:(PRAssistantEmailModel*)value;
- (void)replaceEmailsAtIndexes:(NSIndexSet*)indexes withEmails:(NSArray<PRAssistantEmailModel*>*)values;
- (void)addEmailsObject:(PRAssistantEmailModel*)value;
- (void)removeEmailsObject:(PRAssistantEmailModel*)value;
- (void)addEmails:(NSOrderedSet<PRAssistantEmailModel*>*)values;
- (void)removeEmails:(NSOrderedSet<PRAssistantEmailModel*>*)values;

- (void)insertObject:(PRAssistantPhoneModel*)value inPhonesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPhonesAtIndex:(NSUInteger)idx;
- (void)insertPhones:(NSArray<PRAssistantPhoneModel*>*)value atIndexes:(NSIndexSet*)indexes;
- (void)removePhonesAtIndexes:(NSIndexSet*)indexes;
- (void)replaceObjectInPhonesAtIndex:(NSUInteger)idx withObject:(PRAssistantPhoneModel*)value;
- (void)replacePhonesAtIndexes:(NSIndexSet*)indexes withPhones:(NSArray<PRAssistantPhoneModel*>*)values;
- (void)addPhonesObject:(PRAssistantPhoneModel*)value;
- (void)removePhonesObject:(PRAssistantPhoneModel*)value;
- (void)addPhones:(NSOrderedSet<PRAssistantPhoneModel*>*)values;
- (void)removePhones:(NSOrderedSet<PRAssistantPhoneModel*>*)values;

@end
NS_ASSUME_NONNULL_END
