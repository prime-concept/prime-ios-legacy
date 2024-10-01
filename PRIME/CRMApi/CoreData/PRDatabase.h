//
//  PRDatabase.h
//  PRIME
//
//  Created by Simon on 05/02/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#ifndef PRIME_PRDatabase_h
#define PRIME_PRDatabase_h

#import "PRActionModel.h"
#import "PRCardTypeModel.h"
#import "PRExchangeModel.h"
#import "PRTaskDetailModel.h"
#import "PRTasksTypesModel.h"
#import "PRUserProfileFeaturesModel.h"
#import "PRWebSocketFeedbackContent.h"
#import "PRWebSocketFeedbackModel.h"
#import "PRWebSocketMessageContent.h"
#import "PRWebSocketMessageModel.h"
#import "PRWebSocketMessageModelTasklink.h"
#import "PRWebSocketRegistrationModel.h"
#import "PRWebSocketResponseModel.h"
#import "PRInformationModel.h"
#import "PRDocumentTypeModel.h"

typedef NS_ENUM(NSInteger, TransactionFilter) {
    TransactionFilter_All = 0,
    TransactionFilter_Prime,
    TransactionFilter_Partner,
    TransactionFilter_Count
};

typedef NS_ENUM(NSInteger, CurrencyFilter) {
    CurrencyFilter_All = 0,
    CurrencyFilter_EUR,
    CurrencyFilter_USD,
    CurrencyFilter_RUB,
    CurrencyFilter_Count
};

typedef NS_ENUM(NSInteger, ModelStatus) {
    ModelStatus_Synched = 0,
    ModelStatus_Deleted,
    ModelStatus_Added,
    ModelStatus_Updated,
    ModelStatus_AddedWithoutParent
};

typedef NS_ENUM(NSInteger, ProfileFeature) {
    ProfileFeature_PondMobile = 0,
    ProfileFeature_TaskLink,
    ProfileFeature_SMS_Messages,
    ProfileFeature_ApplePay,
    ProfileFeature_Car,
    ProfileFeature_Chat_Debug,
    ProfileFeature_Wallet
};

typedef NS_ENUM(NSInteger, DocumentType) {
    DocumentType_Other = 0,
    DocumentType_Passport = 1,
    DocumentType_Visa = 2,
    DocumentType_Foreign_Passport = 3,
    DocumentType_National_Passport = 4,
    DocumentType_Birth_Certificate = 5,
    DocumentType_Driving_Licence = 6,
    DocumentType_Insurance = 7,
    DocumentType_Residence_Permit = 8,
    DocumentType_Military_Identity_Card = 9,
    DocumentType_Temporary_Identity_Card = 10,
    DocumentType_Diplomatic_Passport = 11,
    DocumentType_Marine_Passport = 12,
    DocumentType_Passport_Any_Country = 13,
    DocumentType_Certificate_For_To_CIS_Countries = 14,
    DocumentType_Service_Passport = 15,
    DocumentType_Certificate_For_Exempting = 16,
    DocumentType_Temporary_Certificate_Of_Offender = 17,
    DocumentType_Officer_Identity_Card = 18
};

@interface PRDatabase : NSObject

+ (NSFetchedResultsController*)getTasksClosed;
+ (NSFetchedResultsController*)getTasksOpened;
+ (NSArray<PRTaskDetailModel*>*)getLastOpenedTasksWithCount:(NSInteger)count;
+ (NSFetchedResultsController*)getTasksNeedToPay;
+ (NSArray<PRTaskDetailModel*>*)getLastNeedToPayTasksWithCount:(NSInteger)count;
+ (NSFetchedResultsController*)getTasksForTodayAndTomorrow;
+ (NSArray<PRTaskDetailModel*>*)getTasksForTodayAndTomorrowWithPDFDocuments;
+ (NSFetchedResultsController*)getTasksReserved;
+ (NSArray<PRTaskDetailModel*>*)getLastTasksReservedOnTodayOrAfter;
+ (NSFetchedResultsController*)getTasksForId:(NSNumber*)typeId;

+ (NSFetchedResultsController*)getTasksGroupedByCategoryType;

+ (NSUInteger)getTasksOpenOrdersCount;

+ (NSUInteger)getTasksCloseOrdersCount;

+ (NSArray<PRTasksTypesModel*>*)getTasksTypes;

+ (NSInteger)ordersCount;

+ (NSInteger)taskDetailsCount;

+ (void)deleteInvalidMessagesWithoutAssociatedTask;

+ (PRTaskDetailModel*)getTaskDetailByID:(NSNumber*)taskID inContext:(NSManagedObjectContext*)context;

+ (PRTaskDetailModel*)getTaskDetailById:(NSNumber*)taskId;

+ (NSArray<PRTaskDetailModel*>*)taskIdsForChatIds:(NSArray<NSString*>*)chatIds;

+ (NSOrderedSet<PRActionModel*>*)getActionsForTaskId:(NSNumber*)taskId;

+ (PRUserProfileModel*)getUserProfile;

+ (BOOL)isUserProfileFeatureEnabled:(ProfileFeature)feature;

+ (NSArray<PRDocumentModel*>*)getPassports;

+ (NSNumber*)getTaskIdByTaskLinkId:(NSString*)taskLinkId;

+ (NSArray<PRServicesModel*>*)getServices;

+ (PRServicesModel*)serviceWithID:(NSString*)serviceID;

+ (NSArray<PRDocumentModel*>*)getVisas;

+ (NSArray<PRDocumentModel*>*)getDocuments;

+ (PRDocumentModel*)getDocumentById:(NSNumber*)documentId;

+ (NSArray<PRUploadFileInfoModel*>*)getFilesInfoForDocument:(NSNumber*)documentId;

+ (NSArray<PRLoyalCardModel*>*)getDiscounts;

+ (NSArray<PRLoyalCardModel*>*)getDeletedDiscounts;

+ (NSArray<PRLoyalCardModel*>*)getAddedDiscounts;

+ (NSArray<PRCardTypeModel*>*)getDiscountTypes;

+ (PRLoyalCardModel*)getDiscountForId:(NSNumber*)cardId;

+ (PRCardTypeModel*)getTypeForId:(NSNumber*)typeId;

+ (NSArray<PRBalanceModel*>*)getBalanceWithYear:(NSString*)year
                                          month:(NSString*)month;

+ (NSArray<PRBalanceModel*>*)getBalanceWithYears:(NSArray<NSString*>*)years
                                          months:(NSArray<NSString*>*)months;

+ (NSArray<PRBalanceModel*>*)getBalanceWithYear:(NSString*)year
                                          month:(NSString*)month
                                       currency:(NSString*)currency;

+ (PRExchangeModel*)getExchangeForDate:(NSString*)date
                              currency:(NSString*)currency;

+ (NSFetchedResultsController*)getTransactionsWithYear:(NSString*)year
                                                 month:(NSString*)month;

+ (NSFetchedResultsController*)getTransactionsWithBalances:(NSArray<PRBalanceModel*>*)balances
                                               andCategory:(NSString*)categoryName;

+ (NSFetchedResultsController*)getTransactionsWithBalances:(NSArray<PRBalanceModel*>*)balances
                                                 andFilter:(TransactionFilter)filter;

+ (NSArray<PRBalanceModel*>*)getTransactionsGroupedWithCategoryForBalances:(NSArray<PRBalanceModel*>*)balances;

+ (TransactionFilter)getSelectedFilterForTransaction;

+ (void)setSelectedFilterForTransaction:(TransactionFilter)filter;

+ (void)setSelectedFilterForCurrency:(CurrencyFilter)filter;
+ (CurrencyFilter)getSelectedFilterForCurrency;

+ (PRTaskTypeModel*)getTypeForTaskId:(NSNumber*)taskId;

+ (NSMutableArray<PRWebSocketMessageModel*>*)webSocketMessageModelToResend;

+ (NSArray<PRWebSocketMessageContent*>*)webSocketMessageContentUnseenForRequestsWithClientId:(NSString*)clientId
                                                                                   andChatId:(NSString*)chatId;

+ (NSArray<PRWebSocketMessageContent*>*)webSocketMessageContentUnseenForClientId:(NSString*)clientId;

+ (NSArray<PRWebSocketMessageContent*>*)webSocketMessageContentUnseenForChatId:(NSString*)chatId
                                                                   andClientId:(NSString*)clientId;

+ (PRWebSocketMessageModel*)webSocketLastSynchMessageContentForChatId:(NSString*)chatId
                                                          andClientId:(NSString*)clientId;

+ (PRWebSocketMessageBaseModel*)webSocketMessageModelForGuid:(NSString*)guid;

+ (NSArray<PRMessageModel*>*)messagesToResend;

+ (NSArray<PRMessageModel*>*)unseenMessagesForChannelId:(NSString*)chatId andClientId:(NSString*)clientId;

+ (PRMessageModel*)lastMessageForChannelId:(NSString*)channelId andClientId:(NSString*)clientId;

+ (PRMessageModel*)messageByGuid:(NSString*)guid;

+ (PRMessageModel*)messageByGuid:(NSString*)guid inContext:(NSManagedObjectContext*)context;

+ (PRMessageStatusModel*)messageStatusModelByGuid:(NSString*)guid inContext:(NSManagedObjectContext*)context;

+ (NSArray<PRMessageModel*>*)messagesForChannelId:(NSString*)channelId;

+ (NSArray<PRMessageModel*>*)messagesForChannelId:(NSString*)channelId timestamp:(NSNumber*)timestamp;

+ (PRMessageModel*)getTaskLinkLastMessage:(PRMessageModel*)tasklinkMessage;

+ (void)deleteMessageModelWithGuid:(NSString*)guid;

+ (void)deleteMessageModelsFromArray:(NSArray<PRMessageModel*>*)messagesToRemove;

+ (void)removeDuplicateTaskLinks:(NSArray<PRMessageModel*>*)messageModels completion:(void (^)(bool objectsDidRemoved))completion;

+ (NSArray<PRMessageStatusModel*>*)statusUpdatesToResend;

+ (void)deleteUnneededStatusUpdates;

+ (BOOL)isMessageForChannelExisted:(NSString*)channelId;

+ (PRTaskDetailModel*) getTaskForChannelId:(NSString*)channelId inContext:(NSManagedObjectContext *)context;

+ (NSArray<PRMessageModel*>*)unseenMessagesForTask:(NSNumber*)taskID channelId:(NSString*)channelId clientId:(NSString*)clientId inContext:(NSManagedObjectContext*)context;

+ (NSArray<PRMessageModel*>*)taskLinkMessagesByTaskId:(NSNumber*)taskId;

+ (NSString*)deleteWebSocketMessageModelWithMessageId:(NSString*)messageId;

+ (PRWebSocketMessageContent*)webSocketMessageContentForMessageId:(NSString*)messageId inContext:(NSManagedObjectContext*)context;

+ (PRWebSocketFeedbackModel*)webSocketFeedbackModelForGuid:(NSString*)guid;

+ (PRWebSocketMessageModel*)getTaskLastMessageForTaskLink:(PRWebSocketTasklinkContent*)tasklinkMessage;

+ (PRWebSocketMessageModelTasklink*)webSocketTasklinkModelForContentMessageId:(NSString*)messageId;

+ (PRWebSocketMessageModelTasklink*)webSocketTasklinkModelForTaskId:(NSNumber*)taskId inContext:(NSManagedObjectContext*)context;

+ (PRWebSocketMessageModelTasklink*)webSocketTasklinkModelWithChatId:(NSString*)chatId;

+ (__kindof PRWebSocketMessageContent*)webSocketMessageContentForGuid:(NSString*)guid;

+ (PRWebSocketFeedbackContent*)webSocketFeedbackContentForGuid:(NSString*)guid;

+ (NSArray<PRWebSocketMessageBaseModel*>*)webSocketMessageModelForChatId:(NSString*)chatId;

+ (PRWebSocketMessageModel*)messageById:(NSString*)guid;

+ (NSArray<PRProfilePhoneModel*>*)profilePhones:(NSManagedObjectContext*)context;

+ (NSArray<PRProfileEmailModel*>*)profileEmails:(NSManagedObjectContext*)context;

+ (NSArray<PRProfileContactModel*>*)profileContacts:(NSManagedObjectContext*)context;

+ (NSArray<PRProfilePhoneModel*>*)profilePhonesForModifyInContext:(NSManagedObjectContext*)context;

+ (NSArray<PRProfileEmailModel*>*)profileEmailsForModifyInContext:(NSManagedObjectContext*)context;

+ (NSArray<PRProfileContactModel*>*)profileContactsForModifyInContext:(NSManagedObjectContext*)context;

+ (NSArray<PRProfileContactPhoneModel*>*)profileContactPhonesForModify;

+ (NSArray<PRProfileContactPhoneModel*>*)profileContactPhonesForContactId:(NSNumber*)contactId inContext:(NSManagedObjectContext*)context;

+ (NSArray<PRProfileContactPhoneModel*>*)profileContactNonDeletedPhonesForContactId:(NSNumber*)contactId inContext:(NSManagedObjectContext*)context;

+ (NSArray<PRProfileContactDocumentModel*>*)profileContactDocumentsForContactId:(NSNumber*)contactId inContext:(NSManagedObjectContext*)context;

+ (NSArray<PRProfileContactDocumentModel*>*)profileContactNonDeletedDocumentsForContactId:(NSNumber*)contactId inContext:(NSManagedObjectContext*)context;

+ (NSArray<PRProfileContactDocumentModel*>*)profileContactNonDeletedPassportsForContactId:(NSNumber*)contactId inContext:(NSManagedObjectContext*)context;

+ (NSArray<PRProfileContactDocumentModel*>*)profileContactNonDeletedVisasForContactId:(NSNumber*)contactId inContext:(NSManagedObjectContext*)context;

+ (NSArray<PRProfileContactEmailModel*>*)profileContactEmailsForModify;

+ (NSArray<PRProfileContactEmailModel*>*)profileContactEmailsForContactId:(NSNumber*)contactId inContext:(NSManagedObjectContext*)context;

+ (NSArray<PRProfileContactEmailModel*>*)profileContactNonDeletedEmailsForContactId:(NSNumber*)contactId inContext:(NSManagedObjectContext*)context;

+ (NSArray<PRContactTypeModel*>*)profileContactTypes:(NSManagedObjectContext*)context;

+ (NSArray<PREmailTypeModel*>*)profileEmailTyes:(NSManagedObjectContext*)context;

+ (NSArray<PRPhoneTypeModel*>*)profilePhoneTypes:(NSManagedObjectContext*)context;

+ (PREmailTypeModel*)emailTypeWithId:(NSNumber*)typeId;

+ (PRPhoneTypeModel*)phoneTypeWithId:(NSNumber*)typeId;

+ (NSArray<PRContactTypeModel*>*)profileContactTypesWithContext:(NSManagedObjectContext*)context;

+ (PRContactTypeModel*)contactTypeWithId:(NSNumber*)typeId;

+ (NSArray<PRCarModel*>*)profileCarsWithContext:(NSManagedObjectContext*)context;

+ (NSArray<PRCarModel*>*)profileCarsForModifyInContext:(NSManagedObjectContext*)context;

+ (PRInformationModel*)getInformation;

+ (NSInteger)unseenMessagesMainCount;

+ (NSInteger)requestsUnseenMessagesCountFromSubscriptions;

+ (NSInteger)requestsUnseenMessagesCountFromSubscriptionsForChannelId:(NSString*)channelId;

+ (void)decrementUnseenMessagesCountOfSubscriptionForChannelId:(NSString*)channelId;

+ (void)updateUnseenMessagesCountOfSubscriptionForChannelId:(NSString*)channelId;

+ (void)removeExpiredMessages;

+ (void)removeExpiredRequests;

+ (NSArray<PRMessageModel*>*)getUnseenMessagesForComplatedTasks:(NSManagedObjectContext*)context;

+ (NSMutableArray<PRMessageModel*>*)deleteInvalidTaskLinks:(NSArray<PRMessageModel*>*)messages;

+ (NSArray<PRDocumentTypeModel*>*)getDocumentTypes;

+ (PRDocumentTypeModel*)getDocumentTypeForId:(NSNumber*)typeId;

+ (NSArray<PRDocumentModel*>*)getDocumentsByType:(NSNumber*)type;

+ (PRDocumentTypeModel*)getDocumentTypeById:(NSNumber*)typeId;

+ (NSDictionary<NSString*,NSArray<PRDocumentModel*>*>*)getDocumentsDictionary;

+ (NSDictionary<NSString*,NSArray<PRProfileContactDocumentModel*>*>*)getProfileContactDocumentsDictionaryForContact:(NSNumber*)contactId inContext:(NSManagedObjectContext*) context;

+ (NSArray<PRProfileContactDocumentModel*>*)profileContactNonDeletedDocumentsForContactId:(NSNumber*)contactId withType:(NSNumber*)type;

+ (BOOL)isPassport:(NSNumber*)typeId;

@end

#endif
