//
//  PRDatabase.m
//  PRIME
//
//  Created by Simon on 05/02/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRDatabase.h"

#import "ChatUtility.h"
#import "PRActionModel.h"
#import "PRBalanceModel.h"
#import "PRContactTypeModel.h"
#import "PRDocumentModel.h"
#import "PREmailTypeModel.h"
#import "PRExchangeModel.h"
#import "PRLoyalCardModel.h"
#import "PRPhoneTypeModel.h"
#import "PRProfileBaseTypeModel.h"
#import "PRTasksTypesModel.h"
#import "PRTransactionModel.h"
#import "PRWebSocketMessageBaseModel.h"
#import "PRWebSocketMessageModelTasklink.h"
#import "Utils.h"

@interface PRDatabase ()
@end
@implementation PRDatabase

+ (NSFetchedResultsController*)getTasksClosed
{

    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(completed = %@) ", @(YES)];
    return [PRTaskDetailModel MR_fetchAllGroupedBy:@"day" withPredicate:predicate sortedBy:@"requestDate" ascending:NO];
}

+ (NSFetchedResultsController*)getTasksOpened
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(completed = %@ AND (ANY orders.@count = 0))", @(NO)];

    return [PRTaskDetailModel MR_fetchAllGroupedBy:@"day" withPredicate:predicate sortedBy:@"requestDate" ascending:YES];
}

+ (NSArray<PRTaskDetailModel*>*)getLastOpenedTasksWithCount:(NSInteger)count {
    NSFetchedResultsController* fetchedResultsController = [self getTasksOpened];
    NSArray *openedTasks = [fetchedResultsController fetchedObjects];
    if (openedTasks.count <= count) {
        return openedTasks;
    }

    NSMutableArray *tasks = [NSMutableArray new];
    for (NSInteger i = 0; i < count; i++) {
        [tasks addObject:openedTasks[i]];
    }
    return tasks;
}

+ (NSFetchedResultsController*)getTasksNeedToPay
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(completed = %@  AND (ANY orders.@count > 0))", @(NO)];

    return [PRTaskDetailModel MR_fetchAllGroupedBy:@"day" withPredicate:predicate sortedBy:@"requestDate" ascending:YES];
}

+ (NSArray<PRTaskDetailModel*>*)getLastNeedToPayTasksWithCount:(NSInteger)count{
    NSFetchedResultsController* fetchedResultsController = [self getTasksNeedToPay];
    NSArray *needToPayTasks = [fetchedResultsController fetchedObjects];
    if (needToPayTasks.count <= count) {
        return needToPayTasks;
    }

    NSMutableArray *tasks = [NSMutableArray new];
    for (NSInteger i = 0; i < count; i++) {
        [tasks addObject:needToPayTasks[i]];
    }
    return tasks;
}

+ (NSFetchedResultsController*)getTasksForTodayAndTomorrow
{
    NSDate* today = [self.class dateToLocalDate:[NSDate date]];
    NSDate* tomorrow = [self.class dateToLocalDate:[NSDate mt_endOfTomorrow]];

    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"requestDate >= %@ AND requestDate <= %@", today, tomorrow];
    return [PRTaskDetailModel MR_fetchAllGroupedBy:@"day" withPredicate:predicate sortedBy:@"requestDate" ascending:NO];
}

+ (NSArray<PRTaskDetailModel*>*)getTasksForTodayAndTomorrowWithPDFDocuments
{
    NSArray<PRTaskDetailModel*>* tasks = [PRDatabase getTasksForTodayAndTomorrow].fetchedObjects;
    return [tasks filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(ANY items.itemName CONTAINS[cd] %@) AND (ANY items.itemType == %@)", @".pdf", @"link"]];
}

+ (NSDate*)dateToLocalDate:(NSDate*)date
{
    NSTimeZone* tz = [NSTimeZone defaultTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate:date];
    return [NSDate dateWithTimeInterval:seconds sinceDate:date];
}

+ (NSFetchedResultsController*)getTasksReserved
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(reserved = %@)", @(YES)];

    return [PRTaskDetailModel MR_fetchAllGroupedBy:@"day"
                                     withPredicate:predicate
                                          sortedBy:@"requestDate"
                                         ascending:YES];
}

+ (NSArray<PRTaskDetailModel*>*)getLastTasksReservedOnTodayOrAfter
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* todaysComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
    NSDate* today = [calendar dateFromComponents:todaysComponents];

    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(reserved = %@) AND requestDate >= %@", @(YES), today];

    NSArray* tasks = [[PRTaskDetailModel MR_fetchAllGroupedBy:@"day"
                                                withPredicate:predicate
                                                     sortedBy:@"requestDate"
                                                    ascending:YES] fetchedObjects];
    return tasks;
}

+ (NSFetchedResultsController*)getTasksForId:(NSNumber*)typeId
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(taskType.typeId = %@)", typeId];

    return [PRTaskDetailModel MR_fetchAllGroupedBy:@"day" withPredicate:predicate sortedBy:@"requestDate" ascending:NO];
}

+ (NSArray<PRTaskDetailModel*>*)taskIdsForChatIds:(NSArray<NSString*>*)chatIds
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(chatId in %@)", chatIds];
    return [PRTaskDetailModel MR_findAllSortedBy:@"requestDate"
                                       ascending:NO
                                   withPredicate:predicate];
}

+ (NSFetchedResultsController*)getTasksGroupedByCategoryType
{
    return [PRTaskDetailModel MR_fetchAllGroupedBy:@"taskType.typeId"
                                     withPredicate:nil
                                          sortedBy:@"taskType.typeId"
                                         ascending:YES];
}

+ (NSUInteger)getTasksOpenOrdersCount
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(ANY orders != nil)"];
    return [PRTaskDetailModel MR_countOfEntitiesWithPredicate:predicate];
}

+ (NSUInteger)getTasksCloseOrdersCount
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"NOT (ANY orders != nil)"];
    return [PRTaskDetailModel MR_countOfEntitiesWithPredicate:predicate];
}

+ (NSArray<PRTasksTypesModel*>*)getTasksTypes
{
    return [PRTasksTypesModel MR_findAllSortedBy:@"count" ascending:NO];
}

+ (NSInteger)ordersCount
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(completed = %@ AND (ANY orders != nil))", @(NO)];

    return [PRTaskDetailModel MR_countOfEntitiesWithPredicate:predicate];
}

+ (NSInteger)taskDetailsCount
{
    return [PRTaskDetailModel MR_countOfEntities];
}

+ (PRTaskDetailModel*)getTaskDetailByID:(NSNumber*)taskID inContext:(NSManagedObjectContext*)context
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"taskId.integerValue = %@", @(taskID.integerValue)];
    NSArray<PRTaskDetailModel*>* resalt = [PRTaskDetailModel MR_findAllWithPredicate:predicate inContext:context];

    return [resalt firstObject];
}

+ (PRTaskDetailModel*)getTaskDetailById:(NSNumber*)taskId
{
    NSArray<PRTaskDetailModel*>* resultArray = [PRTaskDetailModel MR_findByAttribute:@"taskId" withValue:[taskId stringValue]];

    return [resultArray firstObject];
}

+ (NSNumber*)getTaskIdByTaskLinkId:(NSString*)taskLinkId
{
    NSArray<PRTaskDetailModel*>* resultArray = [PRTaskDetailModel MR_findByAttribute:@"taskLinkId" withValue:taskLinkId];

    PRTaskDetailModel* model = [resultArray firstObject];

    return model.taskId;
}

+ (NSOrderedSet<PRActionModel*>*)getActionsForTaskId:(NSNumber*)taskId
{
    PRTaskDetailModel* taskDetailModel = [self getTaskDetailById:taskId];
    return taskDetailModel.actions;
}

+ (PRUserProfileModel*)getUserProfile
{
    NSArray<PRUserProfileModel*>* profiles = [PRUserProfileModel MR_findAllInContext:[NSManagedObjectContext MR_rootSavingContext]];

    NSUInteger count = [profiles count];

    NSAssert(count <= 1, @"Profile should not be more then one");

    if (count) {
        return [profiles firstObject];
    }
    return nil;
}

+ (BOOL)isUserProfileFeatureEnabled:(ProfileFeature)feature
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"feature = %@", [self getNameForFeature:feature]];

    NSArray<PRUserProfileFeaturesModel*>* profileFeatures = [PRUserProfileFeaturesModel MR_findAllWithPredicate:predicate];

    if (profileFeatures.count == 0) {
        return NO;
    }

    return YES;
}

+ (NSString*)getNameForFeature:(ProfileFeature)feature
{
    switch (feature) {
    case ProfileFeature_PondMobile:
        return @"pondmobile.button";
    case ProfileFeature_TaskLink:
        return @"tasklinks";
    case ProfileFeature_SMS_Messages:
        return @"sms_messages";
    case ProfileFeature_ApplePay:
        return @"applepay";
    case ProfileFeature_Car:
        return @"cars";
    case ProfileFeature_Chat_Debug:
        return @"chat.debug";
    case ProfileFeature_Wallet:
        return @"wallet";
    default:
        return nil;
    }
}

+ (NSArray<PRServicesModel*>*)getServices
{
    return [PRServicesModel MR_findAllSortedBy:@"serviceId" ascending:YES];
}

+ (PRServicesModel*)serviceWithID:(NSString*)serviceID
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"serviceId.integerValue = %@", @(serviceID.integerValue)];
    NSArray<PRServicesModel*>* services = [PRServicesModel MR_findAllWithPredicate:predicate];

    return [services firstObject];
}

+ (NSArray<PRDocumentModel*>*)getDocuments
{
    return [PRDocumentModel MR_findAllSortedBy:@"documentNumber" ascending:YES];
}

+ (PRDocumentModel*)getDocumentById:(NSNumber*)documentId
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@" (documentId = %@)", documentId];
    return [[PRDocumentModel MR_findAllWithPredicate:predicate] firstObject];
}

+ (NSArray<PRDocumentModel*>*)getPassports
{
    //TODO: sorted by documentNumber !!!
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@" documentType = %lu || documentType = %lu || documentType = %lu || documentType = %lu || documentType = %lu || documentType = %lu",DocumentType_Passport, DocumentType_Foreign_Passport,DocumentType_National_Passport, DocumentType_Diplomatic_Passport, DocumentType_Passport_Any_Country, DocumentType_Service_Passport];
    return [PRDocumentModel MR_findAllSortedBy:@"documentNumber" ascending:YES withPredicate:predicate];
}

+ (NSArray<PRDocumentModel*>*)getVisas
{
    //TODO: sorted by documentNumber !!!
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@" (documentType = 2)"];
    return [PRDocumentModel MR_findAllSortedBy:@"documentNumber" ascending:YES withPredicate:predicate];
}

+ (NSArray<PRUploadFileInfoModel*>*)getFilesInfoForDocument:(NSNumber*)documentId
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@" (ANY documentId = %@)", documentId]]; // Nil is Avatar.
    return [PRUploadFileInfoModel MR_findAllWithPredicate:predicate];
}

+ (NSArray<PRLoyalCardModel*>*)getDiscounts
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@" (syncStatus != %@)", @(-1)]]; //Not deleted cards.
    return [PRLoyalCardModel MR_findAllSortedBy:@"type.position,type.name" ascending:YES withPredicate:predicate];
}

+ (NSArray<PRLoyalCardModel*>*)getDeletedDiscounts
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@" (syncStatus == %@)", @(-1)]]; //Deleted cards.
    return [PRLoyalCardModel MR_findAllWithPredicate:predicate];
}

+ (NSArray<PRLoyalCardModel*>*)getAddedDiscounts
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@" (syncStatus == %@)", @(1)]]; //Added cards.
    return [PRLoyalCardModel MR_findAllWithPredicate:predicate];
}

+ (NSArray<PRCardTypeModel*>*)getDiscountTypes
{
    return [PRCardTypeModel MR_findAllSortedBy:@"position,name" ascending:YES];
}

+ (PRLoyalCardModel*)getDiscountForId:(NSNumber*)cardId
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@" (cardId = %@)", cardId];
    return [[PRLoyalCardModel MR_findAllWithPredicate:predicate] firstObject];
}

+ (PRCardTypeModel*)getTypeForId:(NSNumber*)typeId
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@" (typeId = %@)", typeId];
    return [[PRCardTypeModel MR_findAllWithPredicate:predicate] firstObject];
}

+ (NSArray<PRBalanceModel*>*)getBalanceWithYear:(NSString*)year
                                          month:(NSString*)month
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(year = %@) AND (month = %@)", year, month];
    return [PRBalanceModel MR_findAllSortedBy:@"currency" ascending:YES withPredicate:predicate];
}

+ (NSArray<PRBalanceModel*>*)getBalanceWithYears:(NSArray<NSString*>*)years
                                          months:(NSArray<NSString*>*)months
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(year in %@) AND (month in %@)", years, months];

    return [PRBalanceModel MR_findAllSortedBy:@"currency" ascending:YES withPredicate:predicate];
}

+ (NSArray<PRBalanceModel*>*)getBalanceWithYear:(NSString*)year
                                          month:(NSString*)month
                                       currency:(NSString*)currency
{
    if (currency == nil) {
        return [self getBalanceWithYear:year month:month];
    }
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(year = %@) AND (month = %@) AND (currency = %@)", year, month, currency];
    return [PRBalanceModel MR_findAllSortedBy:@"currency" ascending:YES withPredicate:predicate];
}

+ (PRExchangeModel*)getExchangeForDate:(NSString*)date
                              currency:(NSString*)currency
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(date = %@) AND (currency = %@)", date, currency];

    return [[PRExchangeModel MR_findAllWithPredicate:predicate] firstObject];
}

+ (NSFetchedResultsController*)getTransactionsWithYear:(NSString*)year
                                                 month:(NSString*)month
{
    NSArray* balances = [self getBalanceWithYear:year month:month];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"balance in %@", balances];
    return [PRTransactionModel MR_fetchAllGroupedBy:@"day" withPredicate:predicate sortedBy:@"period" ascending:NO];
}

+ (NSFetchedResultsController*)getTransactionsWithBalances:(NSArray<PRBalanceModel*>*)balances
                                               andCategory:(NSString*)categoryName
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(balance in %@) AND category = %@", balances, categoryName];

    return [PRTransactionModel MR_fetchAllGroupedBy:@"day" withPredicate:predicate sortedBy:@"period" ascending:NO];
}

+ (NSFetchedResultsController*)getTransactionsWithBalances:(NSArray<PRBalanceModel*>*)balances
                                                 andFilter:(TransactionFilter)filter
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"balance in %@", balances];
    if (filter != TransactionFilter_All) {
        const BOOL isDirectPayment = (filter == TransactionFilter_Partner);
        predicate = [NSPredicate predicateWithFormat:@"(balance in %@) AND directPayment = %@", balances, @(isDirectPayment)];
    }
    return [PRTransactionModel MR_fetchAllGroupedBy:@"day" withPredicate:predicate sortedBy:@"period" ascending:NO];
}

+ (NSArray<PRBalanceModel*>*)getTransactionsGroupedWithCategoryForBalances:(NSArray<PRBalanceModel*>*)balances
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"balance in %@", balances];
    return [PRTransactionModel MR_findAllWithPredicate:predicate];
}

+ (PRTaskTypeModel*)getTypeForTaskId:(NSNumber*)taskId
{
    PRTaskDetailModel* taskDetailModel = [self getTaskDetailById:taskId];
    return taskDetailModel.taskType;
}

static NSString* const filterKey = @"TransactionFilterKey";
+ (TransactionFilter)getSelectedFilterForTransaction
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey:filterKey];
}

+ (void)setSelectedFilterForTransaction:(TransactionFilter)filter
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:filter forKey:filterKey];
    [defaults synchronize];
}

static NSString* const currencyfilterKey = @"CurrencyFilterKey";
+ (void)setSelectedFilterForCurrency:(CurrencyFilter)filter
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:filter forKey:currencyfilterKey];
    [defaults synchronize];
}

+ (CurrencyFilter)getSelectedFilterForCurrency
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey:currencyfilterKey];
}

#pragma mark Chat db

+ (NSMutableArray<PRWebSocketMessageModel*>*)webSocketMessageModelToResend
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"isSent = %@", @(NO)];
    NSMutableArray* array = [[PRWebSocketMessageModel MR_findAllWithPredicate:predicate] mutableCopy];
    [array addObjectsFromArray:[PRWebSocketFeedbackModel MR_findAllWithPredicate:predicate]];
    return array;
}

+ (NSArray<PRWebSocketMessageContent*>*)webSocketMessageContentUnseenForRequestsWithClientId:(NSString*)clientId andChatId:(NSString*)chatId
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"status != %@ AND chatId != %@ AND clientId != %@ ",
                                          @(WebSoketMessageStatus_Seen),
                                          chatId,
                                          clientId];

    NSArray<PRWebSocketMessageContent*>* textContent = [PRWebSocketMessageContentText MR_findAllWithPredicate:predicate];
    NSArray<PRWebSocketMessageContent*>* taskLinkContent = [NSArray array];

    if ([self isUserProfileFeatureEnabled:ProfileFeature_TaskLink]) {
        predicate = [NSPredicate predicateWithFormat:@"status != %@ AND chatId != %@ AND clientId != %@ AND content.task.taskId > 0",
                                 @(WebSoketMessageStatus_Seen),
                                 chatId,
                                 clientId];
        taskLinkContent = [[PRWebSocketMessageContentTasklink MR_findAllWithPredicate:predicate] mutableCopy];
    }

    return [textContent arrayByAddingObjectsFromArray:taskLinkContent];
}

+ (NSArray<PRWebSocketMessageContent*>*)webSocketMessageContentUnseenForClientId:(NSString*)clientId
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"status != %@ AND clientId != %@ ",
                                          @(WebSoketMessageStatus_Seen),
                                          clientId];

    NSArray<PRWebSocketMessageContent*>* textContent = [PRWebSocketMessageContentText MR_findAllWithPredicate:predicate];

    NSArray<PRWebSocketMessageContent*>* taskLinkContent = [NSArray array];

    if ([self isUserProfileFeatureEnabled:ProfileFeature_TaskLink]) {
        predicate = [NSPredicate predicateWithFormat:@"status != %@ AND clientId != %@ AND content.task.taskId > 0 AND content.task.completed == 0",
                                 @(WebSoketMessageStatus_Seen),
                                 clientId];
        taskLinkContent = [[PRWebSocketMessageContentTasklink MR_findAllWithPredicate:predicate] mutableCopy];
    }

    return [textContent arrayByAddingObjectsFromArray:taskLinkContent];
}

+ (NSArray<PRMessageModel*>*)messagesToResend
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"isSent = %@", @(NO)];
    return [PRMessageModel MR_findAllWithPredicate:predicate];
}

+ (void)deleteInvalidMessagesWithoutAssociatedTask
{
    NSArray<PRMessageModel*>* allMessages = [PRMessageModel MR_findAll];
    for (PRMessageModel* message in allMessages) {
        NSArray<PRTaskDetailModel*>* taskDetail = [PRTaskDetailModel MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"chatId == %@", [message.channelId substringFromIndex:1]]];
        if (!taskDetail.count && ![[ChatUtility mainChatIdWithPrefix] isEqualToString:message.channelId]) {
            [PRMessageModel MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"guid == %@", message.guid]];
        }
    }

    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kInvalidMessagesDeletionDidComplete];

    // Functionality with websocket message models.
    /*
    NSArray<PRWebSocketMessageContent*>* allMessages = [PRWebSocketMessageContent MR_findAll];
    for (PRWebSocketMessageContent* message in allMessages) {
        NSArray<PRTaskDetailModel*>* taskDetail = [PRTaskDetailModel MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"chatId == %@", [message.chatId substringFromIndex:1]]];
        if (!taskDetail.count && ![[ChatUtility mainChatIdWithPrefix] isEqualToString:message.chatId]) {
            [PRWebSocketMessageContent MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"messageId == %@", message.messageId]];
        }
    }
     */
}

+ (NSArray<PRWebSocketMessageContent*>*)webSocketMessageContentUnseenForChatId:(NSString*)chatId andClientId:(NSString*)clientId
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"status != %@ AND chatId = %@ AND clientId != %@ ",
                                          @(WebSoketMessageStatus_Seen),
                                          chatId,
                                          clientId];

    NSArray<PRWebSocketMessageContent*>* textContent = [PRWebSocketMessageContentText MR_findAllWithPredicate:predicate];

    NSArray<PRWebSocketMessageContent*>* taskLinkContent = [NSArray array];

    if ([self isUserProfileFeatureEnabled:ProfileFeature_TaskLink]) {
        predicate = [NSPredicate predicateWithFormat:@"status != %@ AND chatId = %@ AND clientId != %@ AND content.task.taskId > 0 AND content.task.completed == 0",
                                 @(WebSoketMessageStatus_Seen),
                                 chatId,
                                 clientId];
        taskLinkContent = [[PRWebSocketMessageContentTasklink MR_findAllWithPredicate:predicate] mutableCopy];
    }

    return [textContent arrayByAddingObjectsFromArray:taskLinkContent];
}

+ (NSArray<PRMessageModel*>*)unseenMessagesForChannelId:(NSString*)channelId andClientId:(NSString*)clientId
{
    // In case of text/voice message "content" is an empty and "text" property should not be nil.
    // In case of tasklink message vice versa.
    // In case, if that two properties is a "nil" simultaneously, that it is a status update.

    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"status != %@ AND status != %@ AND channelId = %@ AND clientId != %@ AND content = nil AND text != nil",
                                          kMessageStatus_Seen,
                                          kMessageStatus_Deleted,
                                          channelId,
                                          clientId];

    NSArray<PRMessageModel*>* messages = [PRMessageModel MR_findAllWithPredicate:predicate];
    NSArray<PRMessageModel*>* taskLinkMessages = [NSArray array];

    if ([self isUserProfileFeatureEnabled:ProfileFeature_TaskLink]) {
        predicate = [NSPredicate predicateWithFormat:@"status != %@ AND status != %@ AND channelId = %@ AND clientId != %@ AND content.task.taskId > 0 AND content.task.completed == 0",
                                 kMessageStatus_Seen,
                                 kMessageStatus_Deleted,
                                 channelId,
                                 clientId];
        taskLinkMessages = [[PRMessageModel MR_findAllWithPredicate:predicate] mutableCopy];
    }

    return [messages arrayByAddingObjectsFromArray:taskLinkMessages];
}

+ (NSArray<PRMessageModel*>*)unseenMessagesForTask:(NSNumber*)taskID channelId:(NSString*)channelId clientId:(NSString*)clientId inContext:(NSManagedObjectContext*)context
{
    NSArray<PRMessageModel*>* taskLinkMessages = [NSArray array];

    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"status != %@ AND status != %@ AND channelId = %@ AND clientId != %@ AND (content.task.taskLinkId.integerValue = %@) AND (content.task.completed == 0)",
                                          kMessageStatus_Seen,
                                          kMessageStatus_Deleted,
                                          channelId,
                                          clientId,
                                          @(taskID.integerValue)];

    taskLinkMessages = [PRMessageModel MR_findAllWithPredicate:predicate inContext:context];

    return taskLinkMessages;
}

+ (NSArray<PRMessageModel*>*)taskLinkMessagesByTaskId:(NSNumber*)taskId
{
    NSArray<PRMessageModel*>* taskLinkMessages = [NSArray array];

    if (!taskId) {
        return taskLinkMessages;
    }

    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"content.task.taskLinkId.integerValue = %@", @(taskId.integerValue)];
    taskLinkMessages = [PRMessageModel MR_findAllSortedBy:@"timestamp" ascending:YES withPredicate:predicate];

    return taskLinkMessages;
}

+ (PRWebSocketMessageBaseModel*)webSocketLastSynchMessageContentForChatId:(NSString*)chatId andClientId:(NSString*)clientId
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"body.chatId = %@", chatId];

    NSArray<PRWebSocketMessageBaseModel*>* textModel = [PRWebSocketMessageModel MR_findAllWithPredicate:predicate];

    NSArray<PRWebSocketMessageBaseModel*>* taskLinkModel = [NSArray array];

    if ([self isUserProfileFeatureEnabled:ProfileFeature_TaskLink]) {
        predicate = [NSPredicate predicateWithFormat:@"body.chatId = %@ AND body.clientId != %@ AND body.content.task.taskId > 0",
                                 chatId,
                                 clientId];
        taskLinkModel = [[PRWebSocketMessageModelTasklink MR_findAllWithPredicate:predicate] mutableCopy];
    }

    NSMutableArray<PRWebSocketMessageBaseModel*>* allMessages = [[textModel arrayByAddingObjectsFromArray:taskLinkModel] mutableCopy];

    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"body.timestamp"
                                                                   ascending:YES];
    ;
    NSArray* sortDescriptors = [NSArray arrayWithObject:sortDescriptor];

    return [[allMessages sortedArrayUsingDescriptors:sortDescriptors] lastObject];
}

+ (PRMessageModel*)lastMessageForChannelId:(NSString*)channelId andClientId:(NSString*)clientId
{
    // In case of text message "content" is an empty and "text" property should not be nil.
    // In case of tasklink message vice versa.
    // In case of voice message "content" is an empty and "text" or "audioFileName" should not be nil.
    // In case if that two properties is a "nil" simultaneously, that it is a status update.

    NSPredicate* predicate = [NSPredicate predicateWithFormat:
                              @"channelId = %@ AND content = nil AND (text != nil OR audioFileName != nil) AND (status = %@ OR status = %@ OR status = %@) AND isReceivedFromServer = %@",
                              channelId,
                              kMessageStatus_Sent,
                              kMessageStatus_Delivered,
                              kMessageStatus_Seen,
                              @(YES)];

    NSArray<PRMessageModel*>* messages = [PRMessageModel MR_findAllWithPredicate:predicate];
    NSArray<PRMessageModel*>* taskLinkMessages = [NSArray array];

    if ([self isUserProfileFeatureEnabled:ProfileFeature_TaskLink]) {
        predicate = [NSPredicate predicateWithFormat:
                     @"channelId = %@ AND clientId != %@ AND content.task.taskId > 0 AND (status = %@ OR status = %@ OR status = %@) AND isReceivedFromServer = %@",
                     channelId,
                     clientId,
                     kMessageStatus_Sent,
                     kMessageStatus_Delivered,
                     kMessageStatus_Seen,
                     @(YES)];
        taskLinkMessages = [[PRMessageModel MR_findAllWithPredicate:predicate] mutableCopy];
    }

    NSMutableArray<PRMessageModel*>* allMessages = [[messages arrayByAddingObjectsFromArray:taskLinkMessages] mutableCopy];
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    NSArray* sortDescriptors = [NSArray arrayWithObject:sortDescriptor];

    return [[allMessages sortedArrayUsingDescriptors:sortDescriptors] lastObject];
}

+ (PRTaskDetailModel*)getTaskForChannelId:(NSString*)channelId inContext:(NSManagedObjectContext *)context
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"chatId.integerValue = %@", @(channelId.integerValue) ];

    return [PRTaskDetailModel MR_findFirstWithPredicate:predicate inContext:context];
}

+ (PRSubscriptionModel*)getSubscriptionForChannelId:(NSString*)channelId inContext:(NSManagedObjectContext *)context
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"channelId == %@", channelId];

    return [PRSubscriptionModel MR_findFirstWithPredicate:predicate inContext:context];
}

+ (PRWebSocketMessageBaseModel*)webSocketMessageModelForGuid:(NSString*)guid
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"guid = %@", guid];
    NSArray<PRWebSocketMessageBaseModel*>* textModel = [PRWebSocketMessageModel MR_findAllWithPredicate:predicate];
    NSArray<PRWebSocketMessageBaseModel*>* taskLinkModel = [NSArray array];

    if ([self isUserProfileFeatureEnabled:ProfileFeature_TaskLink]) {
        predicate = [NSPredicate predicateWithFormat:@"guid = %@ AND body.content.task.taskId > 0", guid];
        taskLinkModel = [[PRWebSocketMessageModelTasklink MR_findAllWithPredicate:predicate] mutableCopy];
    }

    return [[textModel arrayByAddingObjectsFromArray:taskLinkModel] firstObject];
}

+ (PRMessageModel*)messageByGuid:(NSString*)guid
{
    return [self.class messageByGuid:guid inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (PRMessageModel*)messageByGuid:(NSString*)guid inContext:(NSManagedObjectContext*)context
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"guid = %@ AND (content != nil OR text != nil OR audioFileName != nil)", guid];
    NSArray<PRMessageModel*>* messages = [PRMessageModel MR_findAllSortedBy:@"timestamp" ascending:YES withPredicate:predicate inContext:context];
    NSAssert([messages count] <= 1, @"In database can not be two object with same guid.");

    return [messages lastObject];
}

+ (PRMessageStatusModel*)messageStatusModelByGuid:(NSString*)guid inContext:(NSManagedObjectContext*)context
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"guid = %@", guid];
    NSArray<PRMessageStatusModel*>* objects = [PRMessageStatusModel MR_findAllWithPredicate:predicate inContext:context];
    NSAssert([objects count] <= 1, @"In database can not be two object with same guid.");

    return [objects lastObject];
}

+ (NSArray<PRMessageModel*>*)messagesForChannelId:(NSString*)channelId
{
    return [self.class messagesForChannelId:channelId timestamp:nil];
}

+ (BOOL)isMessageForChannelExisted:(NSString*)channelId
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"channelId = %@ AND (content != nil OR text != nil OR audioFileName != nil)", channelId];
    return [PRMessageModel MR_findFirstWithPredicate:predicate] != nil;
}

+ (NSArray<PRMessageModel*>*)messagesForChannelId:(NSString*)channelId timestamp:(NSNumber*)timestamp
{
    // In case of text message "content" is an empty and "text" property should not be nil.
    // In case of tasklink message vice versa.
    // In case of voice message "content" is an empty and "text" or "audioFileName" should not be nil.
    // In case, if that two properties is a "nil" simultaneously, that it is a status update.

    NSPredicate* predicateForTasklink = [NSPredicate predicateWithFormat:@"channelId = %@ AND content.task.taskId > 0", channelId];
    NSPredicate* predicateForTextAndVoiceMessages = [NSPredicate predicateWithFormat:@"channelId = %@ AND content = nil AND (text != nil OR audioFileName != nil)", channelId];
    NSArray<PRMessageModel*>* taskLinksMessages = [NSArray array];

    if (timestamp) {
        predicateForTasklink = [NSPredicate predicateWithFormat:@"(channelId = %@) AND (content.task.taskId.integerValue > 0) AND (timestamp.doubleValue > %@)", channelId, @([timestamp doubleValue])];
        predicateForTextAndVoiceMessages = [NSPredicate predicateWithFormat:@"(channelId = %@) AND (content = nil) AND (text != nil OR audioFileName != nil) AND (timestamp.doubleValue > %@)", channelId, @([timestamp doubleValue])];
    }

    if ([self isUserProfileFeatureEnabled:ProfileFeature_TaskLink]) {
        taskLinksMessages = [[PRMessageModel MR_findAllSortedBy:@"timestamp" ascending:YES withPredicate:predicateForTasklink] mutableCopy];
    }

    NSArray<PRMessageModel*>* messages = [PRMessageModel MR_findAllSortedBy:@"timestamp" ascending:YES withPredicate:predicateForTextAndVoiceMessages];
    NSArray<PRMessageModel*>* allMessages = [messages arrayByAddingObjectsFromArray:taskLinksMessages];

    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    allMessages = [allMessages sortedArrayUsingDescriptors:@[ sortDescriptor ]];

    return [PRDatabase deleteInvalidTaskLinks:allMessages];
}

+ (NSString*)deleteWebSocketMessageModelWithMessageId:(NSString*)messageId
{
    __block NSString* deletedMessageId = messageId;

    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext* _Nonnull localContext) {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"body.messageId == %@", messageId];
        NSArray<PRWebSocketMessageBaseModel*>* textModel = [PRWebSocketMessageModel MR_findAllWithPredicate:predicate inContext:localContext];
        NSArray<PRWebSocketMessageBaseModel*>* taskLinkModel = [NSArray array];

        if ([self isUserProfileFeatureEnabled:ProfileFeature_TaskLink]) {
            predicate = [NSPredicate predicateWithFormat:@"body.messageId == %@ AND body.content.task.taskId > 0", messageId];
            taskLinkModel = [[PRWebSocketMessageModelTasklink MR_findAllWithPredicate:predicate inContext:localContext] mutableCopy];
        }

        PRWebSocketMessageBaseModel* deletedMessageModel = [[textModel arrayByAddingObjectsFromArray:taskLinkModel] firstObject];

        // Delete TaskLink message model.
        if ([deletedMessageModel isKindOfClass:[PRWebSocketMessageModelTasklink class]]) {
            PRWebSocketMessageModelTasklink* deletedTaskLink = (PRWebSocketMessageModelTasklink*)deletedMessageModel;
            NSNumber* taskLinkId = deletedTaskLink.body.content.task.taskLinkId;
            deletedMessageId = deletedTaskLink.body.messageId;
            [PRWebSocketTasklinkContent MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"task.taskLinkId == %@", taskLinkId] inContext:localContext];
            [PRWebSocketMessageContentTasklink MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"content.task.taskLinkId == %@", taskLinkId] inContext:localContext];
            [PRWebSocketMessageModelTasklink MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"body.content.task.taskLinkId == %@", taskLinkId] inContext:localContext];
        }

        // Delete Text message model.
        if ([deletedMessageModel isKindOfClass:[PRWebSocketMessageModel class]]) {
            [PRWebSocketMessageModel MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"body.messageId == %@", messageId] inContext:localContext];
        }
    }];

    return deletedMessageId;
}

+ (void)deleteMessageModelsFromArray:(NSArray<PRMessageModel*>*)messagesToRemove
{
    for (PRMessageModel* messageModel in messagesToRemove) {
        [self.class deleteMessageModelWithGuid:messageModel.guid];
    }
}

+ (void)deleteMessageModelWithGuid:(NSString*)guid
{
    // In case of text message "content" is an empty and "text" property should not be nil.
    // In case of tasklink message vice versa.
    // In case of voice message "content" is an empty and "text" or "audioFileName" should not be nil.
    // In case, if that two properties is a "nil" simultaneously, that it is a status update.

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext* _Nonnull localContext) {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"guid = %@ AND content = nil AND (text != nil OR audioFileName != nil)", guid];
        NSArray<PRMessageModel*>* messageModel = [PRMessageModel MR_findAllWithPredicate:predicate inContext:localContext];
        NSArray<PRMessageModel*>* taskLinkModel = [NSArray array];

        if ([self isUserProfileFeatureEnabled:ProfileFeature_TaskLink]) {
            predicate = [NSPredicate predicateWithFormat:@"guid = %@ AND content.task.taskId > 0", guid];
            taskLinkModel = [[PRMessageModel MR_findAllWithPredicate:predicate inContext:localContext] mutableCopy];
        }

        PRMessageModel* deletedMessageModel = [[messageModel arrayByAddingObjectsFromArray:taskLinkModel] firstObject];

        // Delete TaskLink message model.
        if ([deletedMessageModel isTasklink]) {
            NSNumber* taskLinkId = deletedMessageModel.content.task.taskLinkId;
            NSString* chatId = [ChatUtility chatIdWithPrefix:[taskLinkId stringValue]];

            [PRTasklinkMessage MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"body.chatId = %@", chatId] inContext:localContext];
            [PRTasklinkMessageBody MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"chatId = %@", chatId] inContext:localContext];
            [PRMessageModel MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"content.task.taskLinkId = %@", taskLinkId] inContext:localContext];
            [PRTasklinkContent MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"task.taskLinkId = %@", taskLinkId] inContext:localContext];
            [PRTasklinkTask MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"taskLinkId = %@", taskLinkId] inContext:localContext];
        } else { // Delete Text message model.
            [PRMessageModel MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"guid = %@", guid] inContext:localContext];
        }
    }];
}

+ (void)removeDuplicateTaskLinks:(NSArray<PRMessageModel*>*)messageModels completion:(void (^)(bool))completion
{
    if (!messageModels || ![messageModels count]) {
        completion(NO);
        return;
    }

    NSManagedObjectContext* mainContext = [NSManagedObjectContext MR_contextForCurrentThread];
    NSPredicate* predicate;

    for (PRMessageModel* model in messageModels) {
        NSNumber* taskLinkId = model.content.task.taskLinkId;
        NSAssert(taskLinkId != nil, @"'taskLinkId' can not be nil.");

        predicate = [NSPredicate predicateWithFormat:@"guid != %@ AND (content.task.taskLinkId.integerValue = %@)", model.guid, @(taskLinkId.integerValue)];
        [PRMessageModel MR_deleteAllMatchingPredicate:predicate inContext:mainContext];
    }

    [mainContext MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError* _Nullable error) {
        completion(YES);
    }];
}

+ (PRWebSocketFeedbackModel*)webSocketFeedbackModelForGuid:(NSString*)guid
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"guid = %@", guid];
    return [[PRWebSocketFeedbackModel MR_findAllWithPredicate:predicate] firstObject];
}

+ (PRWebSocketMessageModelTasklink*)webSocketTasklinkModelForContentMessageId:(NSString*)messageId
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"body.messageId = %@", messageId];

    NSArray<PRWebSocketMessageModelTasklink*>* taskLinkModels = [PRWebSocketMessageModelTasklink MR_findAllWithPredicate:predicate];

    return [taskLinkModels firstObject];
}

+ (PRWebSocketMessageModelTasklink*)webSocketTasklinkModelForTaskId:(NSNumber*)taskId inContext:(NSManagedObjectContext*)context
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"body.content.task.taskLinkId == %@", taskId];

    NSArray<PRWebSocketMessageModelTasklink*>* taskLinkModels = [PRWebSocketMessageModelTasklink MR_findAllWithPredicate:predicate inContext:context ?: [NSManagedObjectContext MR_defaultContext]];

    return [taskLinkModels firstObject];
}

+ (PRWebSocketMessageModelTasklink*)webSocketTasklinkModelWithChatId:(NSString*)chatId
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"body.content.task.taskLinkId==%@", [chatId substringFromIndex:1]];
    return [[PRWebSocketMessageModelTasklink MR_findAllWithPredicate:predicate] lastObject];
}

+ (__kindof PRWebSocketMessageContent*)webSocketMessageContentForGuid:(NSString*)guid
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"messageId = %@", guid];

    NSArray<PRWebSocketMessageContent*>* textContent = [PRWebSocketMessageContentText MR_findAllWithPredicate:predicate];
    NSArray<PRWebSocketMessageContentTasklink*>* taskLinkContent = [NSArray array];

    if ([self isUserProfileFeatureEnabled:ProfileFeature_TaskLink]) {
        taskLinkContent = [[PRWebSocketMessageContentTasklink MR_findAllWithPredicate:predicate] mutableCopy];
    }

    return [[textContent arrayByAddingObjectsFromArray:taskLinkContent] firstObject];
}

+ (NSArray<PRMessageStatusModel*>*)statusUpdatesToResend
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"delivered = %@", @(NO)];
    return [PRMessageStatusModel MR_findAllWithPredicate:predicate];
}

+ (void)deleteUnneededStatusUpdates
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"delivered = %@ OR (guid = nil AND status = nil)", @(YES)];
    [PRMessageStatusModel MR_deleteAllMatchingPredicate:predicate];

    predicate = [NSPredicate predicateWithFormat:@"content = nil AND text = nil AND audioFileName = nil"];
    [PRMessageModel MR_deleteAllMatchingPredicate:predicate];
}

+ (PRWebSocketFeedbackContent*)webSocketFeedbackContentForGuid:(NSString*)guid
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"messageId = %@", guid];
    return [[PRWebSocketFeedbackContent MR_findAllWithPredicate:predicate] firstObject];
}

+ (NSArray<PRWebSocketMessageBaseModel*>*)webSocketMessageModelForChatId:(NSString*)chatId
{

    NSPredicate* predicate = nil;
    NSArray<PRWebSocketMessageBaseModel*>* taskLinksMessages = [NSArray array];

    if ([self isUserProfileFeatureEnabled:ProfileFeature_TaskLink]) {
        predicate = [NSPredicate predicateWithFormat:@"body.chatId = %@ AND body.content.task.taskId > 0", chatId];
        taskLinksMessages = [[PRWebSocketMessageModelTasklink MR_findAllSortedBy:@"body.timestamp" ascending:YES withPredicate:predicate] mutableCopy];
    }

    predicate = [NSPredicate predicateWithFormat:@"body.chatId = %@", chatId];
    NSArray<PRWebSocketMessageBaseModel*>* textMessages = [PRWebSocketMessageModel MR_findAllSortedBy:@"body.timestamp" ascending:YES withPredicate:predicate];

    NSArray<PRWebSocketMessageBaseModel*>* all = [textMessages arrayByAddingObjectsFromArray:taskLinksMessages];

    textMessages = nil;
    taskLinksMessages = nil;

    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"body.timestamp" ascending:YES];
    return [all sortedArrayUsingDescriptors:@[ sortDescriptor ]];
}

+ (PRWebSocketMessageContent*)webSocketMessageContentForMessageId:(NSString*)messageId inContext:(NSManagedObjectContext*)context
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"messageId = %@", messageId];
    return [[PRWebSocketMessageContent MR_findAllWithPredicate:predicate inContext:context ?: [NSManagedObjectContext MR_defaultContext]] lastObject];
}

+ (PRWebSocketMessageModel*)getTaskLastMessageForTaskLink:(PRWebSocketTasklinkContent*)tasklinkMessage
{
    PRWebSocketMessageBaseModel* chatLastMessage = [[self.class webSocketMessageModelForChatId:[ChatUtility
                                                                                                   chatIdWithPrefix:tasklinkMessage.task.taskLinkId.stringValue]]
        lastObject];
    if (tasklinkMessage.message.body.content && [tasklinkMessage.message.body.timestamp longValue] >= [chatLastMessage.body.timestamp longValue]) {
        return tasklinkMessage.message;
    }
    return (PRWebSocketMessageModel*)chatLastMessage;
}

+ (PRMessageModel*)getTaskLinkLastMessage:(PRMessageModel*)tasklinkMessage
{
    NSString* channelId = [ChatUtility chatIdWithPrefix:tasklinkMessage.content.task.taskLinkId.stringValue];
    NSArray<PRMessageModel*>* messages = [self.class messagesForChannelId:channelId timestamp:nil];

    return [messages count] ? [messages lastObject] : tasklinkMessage;
}

+ (PRWebSocketBaseModel*)messageById:(NSString*)guid
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"guid = %@", guid];
    return [[PRWebSocketBaseModel MR_findAllWithPredicate:predicate] firstObject];
}

+ (NSArray<PRProfilePhoneModel*>*)profilePhones:(NSManagedObjectContext*)context
{
    NSString* predicateString = @"state != %@";
    if (![PRRequestManager connectionRequired]) {
        predicateString = [predicateString stringByAppendingString:@"&& phoneId != nil"];
    }

    NSPredicate* predicate = [NSPredicate predicateWithFormat:predicateString, @(ModelStatus_Deleted)];
    return [PRProfilePhoneModel MR_findAllWithPredicate:predicate inContext:context ? context : [NSManagedObjectContext MR_defaultContext]];
}

+ (NSArray<PRProfileEmailModel*>*)profileEmails:(NSManagedObjectContext*)context
{
    NSString* predicateString = @"state != %@";
    if (![PRRequestManager connectionRequired]) {
        predicateString = [predicateString stringByAppendingString:@"&& emailId != nil"];
    }

    NSPredicate* predicate = [NSPredicate predicateWithFormat:predicateString, @(ModelStatus_Deleted)];
    return [PRProfileEmailModel MR_findAllWithPredicate:predicate inContext:context ? context : [NSManagedObjectContext MR_defaultContext]];
}

+ (NSArray<PRProfileContactModel*>*)profileContacts:(NSManagedObjectContext*)context
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"state != %@", @(ModelStatus_Deleted)];

    return [PRProfileContactModel MR_findAllWithPredicate:predicate inContext:context ? context : [NSManagedObjectContext MR_defaultContext]];
}

+ (NSArray<PRProfilePhoneModel*>*)profilePhonesForModifyInContext:(NSManagedObjectContext*)context
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"state != %@", @(ModelStatus_Synched)];

    return [PRProfilePhoneModel MR_findAllWithPredicate:predicate inContext:context ?: [NSManagedObjectContext MR_defaultContext]];
}

+ (NSArray<PRProfileEmailModel*>*)profileEmailsForModifyInContext:(NSManagedObjectContext*)context
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"state != %@", @(ModelStatus_Synched)];

    return [PRProfileEmailModel MR_findAllWithPredicate:predicate inContext:context ?: [NSManagedObjectContext MR_defaultContext]];
}

+ (NSArray<PRContactTypeModel*>*)profileContactTypes:(NSManagedObjectContext*)context
{
    return [PRContactTypeModel MR_findAllInContext:context ? context : [NSManagedObjectContext MR_defaultContext]];
}

+ (NSArray<PREmailTypeModel*>*)profileEmailTyes:(NSManagedObjectContext*)context
{
    return [PREmailTypeModel MR_findAllInContext:context ? context : [NSManagedObjectContext MR_defaultContext]];
}

+ (NSArray<PRPhoneTypeModel*>*)profilePhoneTypes:(NSManagedObjectContext*)context
{
    return [PRPhoneTypeModel MR_findAllInContext:context ? context : [NSManagedObjectContext MR_defaultContext]];
}

+ (NSArray<PRProfileContactModel*>*)profileContactsForModifyInContext:(NSManagedObjectContext*)context
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(state != %@ || (ANY emails.state != %@) || (ANY phones.state != %@))", @(ModelStatus_Synched), @(ModelStatus_Synched), @(ModelStatus_Synched)];

    return [PRProfileContactModel MR_findAllWithPredicate:predicate inContext:context ?: [NSManagedObjectContext MR_defaultContext]];
}

+ (NSArray<PRProfileContactPhoneModel*>*)profileContactPhonesForModify
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"state != %@", @(ModelStatus_Synched)];

    return [PRProfileContactPhoneModel MR_findAllWithPredicate:predicate];
}

+ (NSArray<PRProfileContactPhoneModel*>*)profileContactPhonesForContactId:(NSNumber*)contactId inContext:(NSManagedObjectContext*)context
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"profileContact.contactId == %@ ", contactId];

    return [PRProfileContactPhoneModel MR_findAllWithPredicate:predicate inContext:context ?: [NSManagedObjectContext MR_defaultContext]];
}

+ (NSArray<PRProfileContactPhoneModel*>*)profileContactNonDeletedPhonesForContactId:(NSNumber*)contactId inContext:(NSManagedObjectContext*)context
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"profileContact.contactId == %@ && state != %@", contactId, @(ModelStatus_Deleted)];

    return [PRProfileContactPhoneModel MR_findAllWithPredicate:predicate inContext:context ?: [NSManagedObjectContext MR_defaultContext]];
}

+ (NSArray<PRProfileContactDocumentModel*>*)profileContactDocumentsForContactId:(NSNumber*)contactId inContext:(NSManagedObjectContext*)context
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"profileContact.contactId == %@ ", contactId];

    return [PRProfileContactDocumentModel MR_findAllWithPredicate:predicate inContext:context ?: [NSManagedObjectContext MR_defaultContext]];
}

+ (NSArray<PRProfileContactDocumentModel*>*)profileContactNonDeletedPassportsForContactId:(NSNumber*)contactId inContext:(NSManagedObjectContext*)context
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"profileContact.contactId == %@ && state != %@ && documentType.intValue == %@", contactId, @(ModelStatus_Deleted), @1];

    return [PRProfileContactDocumentModel MR_findAllWithPredicate:predicate inContext:context ?: [NSManagedObjectContext MR_defaultContext]];
}

+ (NSArray<PRProfileContactDocumentModel*>*)profileContactNonDeletedVisasForContactId:(NSNumber*)contactId inContext:(NSManagedObjectContext*)context
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"profileContact.contactId == %@ && state != %@ && documentType.intValue == %@", contactId, @(ModelStatus_Deleted), @2];

    return [PRProfileContactDocumentModel MR_findAllWithPredicate:predicate inContext:context ?: [NSManagedObjectContext MR_defaultContext]];
}

+ (NSArray<PRProfileContactDocumentModel*>*)profileContactNonDeletedDocumentsForContactId:(NSNumber*)contactId inContext:(NSManagedObjectContext*)context
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"profileContact.contactId == %@ && state != %@", contactId, @(ModelStatus_Deleted)];

    return [PRProfileContactDocumentModel MR_findAllWithPredicate:predicate inContext:context ?: [NSManagedObjectContext MR_defaultContext]];
}

+ (NSArray<PRProfileContactEmailModel*>*)profileContactEmailsForModify
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"state != %@", @(ModelStatus_Synched)];

    return [PRProfileContactEmailModel MR_findAllWithPredicate:predicate];
}

+ (NSArray<PRProfileContactEmailModel*>*)profileContactEmailsForContactId:(NSNumber*)contactId inContext:(NSManagedObjectContext*)context
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"profileContact.contactId == %@", contactId];

    return [PRProfileContactEmailModel MR_findAllWithPredicate:predicate inContext:context ?: [NSManagedObjectContext MR_defaultContext]];
}

+ (NSArray<PRProfileContactEmailModel*>*)profileContactNonDeletedEmailsForContactId:(NSNumber*)contactId inContext:(NSManagedObjectContext*)context
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"profileContact.contactId == %@ && state != %@", contactId, @(ModelStatus_Deleted)];

    return [PRProfileContactEmailModel MR_findAllWithPredicate:predicate inContext:context ?: [NSManagedObjectContext MR_defaultContext]];
}

+ (PREmailTypeModel*)emailTypeWithId:(NSNumber*)typeId
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"typeId == %@", typeId];

    return [[PREmailTypeModel MR_findAllWithPredicate:predicate] firstObject];
}

+ (PRPhoneTypeModel*)phoneTypeWithId:(NSNumber*)typeId
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"typeId == %@", typeId];

    return [[PRPhoneTypeModel MR_findAllWithPredicate:predicate] firstObject];
}

+ (NSArray<PRContactTypeModel*>*)profileContactTypesWithContext:(NSManagedObjectContext*)context
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"typeId > 0"];
    return [PRContactTypeModel MR_findAllWithPredicate:predicate inContext:context];
}

+ (PRContactTypeModel*)contactTypeWithId:(NSNumber*)typeId
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"typeId == %@", typeId];

    return [[PRContactTypeModel MR_findAllWithPredicate:predicate] firstObject];
}

+ (NSArray<PRCarModel*>*)profileCarsWithContext:(NSManagedObjectContext*)context
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"state != %@", @(ModelStatus_Deleted)];
    return [PRCarModel MR_findAllWithPredicate:predicate inContext:context ?: [NSManagedObjectContext MR_defaultContext]];
}

+ (NSArray<PRCarModel*>*)profileCarsForModifyInContext:(NSManagedObjectContext*)context
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"state != %@", @(ModelStatus_Synched)];

    return [PRCarModel MR_findAllWithPredicate:predicate inContext:context ?: [NSManagedObjectContext MR_defaultContext]];
}

+ (NSInteger)unseenMessagesMainCount
{
    NSString* clientId = [ChatUtility clientIdWithPrefix];
    NSString* mainChatId = [ChatUtility mainChatIdWithPrefix];
    NSArray<PRMessageModel*>* messages = [self.class unseenMessagesForChannelId:mainChatId
                                                                    andClientId:clientId];
    if (messages) {
        return messages.count;
    }
    return 0;
}

+ (NSInteger)requestsUnseenMessagesCountFromSubscriptions
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"channelId != %@", [ChatUtility mainChatIdWithPrefix]];
    NSArray<PRSubscriptionModel*>* subscriptions = [PRSubscriptionModel MR_findAllWithPredicate:predicate];
    NSManagedObjectContext* mainContext = [NSManagedObjectContext MR_contextForCurrentThread];

    if (subscriptions) {
        NSInteger messagesCount = 0;

        for (PRSubscriptionModel* subscription in subscriptions) {
            PRTaskDetailModel* task = [PRDatabase getTaskForChannelId:[subscription.channelId substringFromIndex:1] inContext:mainContext];
            if(task && task.completed.integerValue != 1) {
                messagesCount += [subscription.unseenMessagesCount integerValue];
            }
        }
        return messagesCount;
    }
    return 0;
}

+ (NSInteger)requestsUnseenMessagesCountFromSubscriptionsForChannelId:(NSString*)channelId
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"channelId == %@", channelId];
    PRSubscriptionModel* subscription = [[PRSubscriptionModel MR_findAllWithPredicate:predicate] firstObject];

    if ([PRDatabase isTaskCompleted:channelId]) {
        return 0;
    }

    return [subscription.unseenMessagesCount integerValue] ;
}

+ (PRInformationModel*)getInformation
{
    NSArray<PRInformationModel*>* informationModel = [PRInformationModel MR_findAll];

    return [informationModel firstObject];
}

+ (void)decrementUnseenMessagesCountOfSubscriptionForChannelId:(NSString*)channelId
{
    NSManagedObjectContext* mainContext = [NSManagedObjectContext MR_contextForCurrentThread];
    PRSubscriptionModel* subscription = [PRDatabase getSubscriptionForChannelId:channelId inContext:mainContext];

    // There is no need to decrement completed tasks unseen messages count.
    if ([PRDatabase isTaskCompleted:channelId]) {
        return;
    }

    if(subscription) {
        NSInteger unseenMessagesCount = [subscription.unseenMessagesCount integerValue];
        if(unseenMessagesCount != 0) {
            subscription.unseenMessagesCount = @(--unseenMessagesCount);
            [mainContext MR_saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            }];
        }
    }
}

+ (void)updateUnseenMessagesCountOfSubscriptionForChannelId:(NSString*)channelId
{
    NSManagedObjectContext* mainContext = [NSManagedObjectContext MR_contextForCurrentThread];

    PRTaskDetailModel* task = [PRDatabase getTaskForChannelId:[channelId substringFromIndex:1] inContext:mainContext];
    if(task && task.completed.integerValue != 1){
        PRUserProfileModel* profile = [[PRUserProfileModel MR_findAllInContext:[NSManagedObjectContext MR_rootSavingContext]] firstObject];
        if (profile.username) {
            NSString* clientId = [NSString stringWithFormat:@"%@%@", kClientPrefix, profile.username];

            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"text != nil AND status != %@ AND status != %@ AND channelId = %@ AND clientId != %@ ",
                                  kMessageStatus_Seen,
                                  kMessageStatus_Deleted,
                                  channelId,
                                  clientId];

            NSArray<PRMessageModel*>* messages = [PRMessageModel MR_findAllWithPredicate:predicate];
            if(messages){
                PRSubscriptionModel* subscription = [PRDatabase getSubscriptionForChannelId:channelId inContext:mainContext];
                if(subscription) {
                    subscription.unseenMessagesCount = @([messages count]);
                    [mainContext MR_saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
                    }];
                }
            }
        }
    }
}

+ (void)removeExpiredMessages
{
   NSDate* offsetMonthsAgo = [Utils dateWithOffsetFromNow:kDataExpirationMonthOffset];
   double offsetMonthsAgoTimeInterval = [offsetMonthsAgo timeIntervalSince1970];
   double todayTimeInterval = [[NSDate date] timeIntervalSince1970];

   NSPredicate* predicate = [NSPredicate predicateWithFormat:@"timestamp < %f OR (ttl < %f AND ttl != 0)",offsetMonthsAgoTimeInterval, todayTimeInterval];
   NSArray<PRMessageModel*>* messagesToDelete = [PRMessageModel MR_findAllWithPredicate:predicate];

   if(messagesToDelete.count > 0) {
       NSManagedObjectContext* mainContext = [NSManagedObjectContext MR_contextForCurrentThread];
       [mainContext MR_deleteObjects:(messagesToDelete)];
   }
}

+ (void)removeExpiredRequests
{
   NSDate* offsetMonthsAgo = [Utils dateWithOffsetFromNow:kDataExpirationMonthOffset];

   NSPredicate* predicate = [NSPredicate predicateWithFormat:@"requestDate < %@", offsetMonthsAgo];
   NSArray<PRTaskDetailModel*>* tasksToDelete = [PRTaskDetailModel MR_findAllWithPredicate:predicate];

   if(tasksToDelete.count > 0) {
       NSManagedObjectContext* mainContext = [NSManagedObjectContext MR_contextForCurrentThread];
       [mainContext MR_deleteObjects:(tasksToDelete)];
   }
}

+ (NSArray<PRMessageModel*>*)getUnseenMessagesForComplatedTasks:(NSManagedObjectContext*)context
{
    NSString* clientId = [ChatUtility clientIdWithPrefix];
    NSMutableArray<PRMessageModel*>* messages = [NSMutableArray array];

    NSPredicate* predicateForTaskDetails = [NSPredicate predicateWithFormat:@"completed == 1"];
    NSArray<PRTaskDetailModel*>* taskDetails = [PRTaskDetailModel MR_findAllWithPredicate:predicateForTaskDetails inContext:context];

    for (PRTaskDetailModel* taskDetail in taskDetails) {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"status != %@ AND status != %@ AND clientId != %@ AND channelId == %@",
                                                                kMessageStatus_Seen,
                                                                kMessageStatus_Deleted,
                                                                clientId,
                                                                [kChatPrefix stringByAppendingString:taskDetail.chatId.stringValue]];
        NSArray<PRMessageModel*>* messagesForChannelID = [PRMessageModel MR_findAllWithPredicate:predicate inContext:context];

        [messages addObjectsFromArray:messagesForChannelID];
    }
    return messages;
}

+ (BOOL)isTaskCompleted:(NSString*)channelId
{
    // channelId must be without prefix.

    NSString* channeldWithoutPrefix = [[channelId substringToIndex:kChatPrefix.length] isEqualToString:kChatPrefix] ? [channelId substringFromIndex:kChatPrefix.length] : channelId;
    NSManagedObjectContext* mainContext = [NSManagedObjectContext MR_contextForCurrentThread];
    PRTaskDetailModel* task = [PRDatabase getTaskForChannelId:channeldWithoutPrefix inContext:mainContext];

    return task.completed.integerValue == 1;
}

+ (NSMutableArray<PRMessageModel*>*)deleteInvalidTaskLinks:(NSArray<PRMessageModel*>*)messages
{
    NSMutableArray<PRMessageModel*>* allMessages = [messages mutableCopy];

    NSPredicate* taskLinkPredicate = [NSPredicate predicateWithFormat:@"content != nil"];
    NSMutableArray<PRMessageModel*>* taskLinksArray = [[allMessages filteredArrayUsingPredicate:taskLinkPredicate] mutableCopy];

    if (![taskLinksArray count]) {
        return allMessages;
    }

    NSArray<PRTaskDetailModel*>* tasks = [PRTaskDetailModel MR_findAll];

    for (PRMessageModel* taskLink in taskLinksArray) {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"chatId == %@", taskLink.content.task.taskLinkId];
        NSArray<PRTaskDetailModel*>* task = [PRTaskDetailModel MR_findAllWithPredicate:predicate];

        if ([tasks count] && ![task count]) {
            [PRDatabase deleteMessageModelWithGuid:taskLink.guid];
            [allMessages removeObject:taskLink];
        }
    }

    return allMessages;
}

+ (NSArray<PRDocumentTypeModel*>*)getDocumentTypes
{
    return [PRDocumentTypeModel MR_findAllSortedBy:@"typeId" ascending:YES];
}

+ (PRDocumentTypeModel*)getDocumentTypeForId:(NSNumber*)typeId
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@" (typeId = %@)", typeId];
    return [[PRDocumentTypeModel MR_findAllWithPredicate:predicate] firstObject];
}

+ (NSArray<PRDocumentModel*>*)getDocumentsByType:(NSNumber*)type
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@" (documentType = %@)", type];
    return [PRDocumentModel MR_findAllWithPredicate:predicate];
}

+ (PRDocumentTypeModel*)getDocumentTypeById:(NSNumber*)typeId
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@" (typeId = %@)", typeId];
    return [[PRDocumentTypeModel MR_findAllWithPredicate:predicate] firstObject];
}

+ (NSDictionary<NSString*,NSArray<PRDocumentModel*>*>*)getDocumentsDictionary
{
    if ([PRDocumentTypeModel MR_findAll].count == 0) {
        return [NSDictionary new];
    }

    NSManagedObjectContext* mainContext = [NSManagedObjectContext MR_contextForCurrentThread];
    NSFetchRequest* fetchGroupSummary = [NSFetchRequest fetchRequestWithEntityName:@"PRDocumentModel"];
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"PRDocumentModel" inManagedObjectContext:mainContext];
    NSAttributeDescription* groupName = [entity.attributesByName objectForKey:@"documentType"];

    [fetchGroupSummary setEntity:entity];
    [fetchGroupSummary setPropertiesToFetch:[NSArray arrayWithObjects:groupName, nil]];
    [fetchGroupSummary setPropertiesToGroupBy:[NSArray arrayWithObject:groupName]];
    [fetchGroupSummary setResultType:NSDictionaryResultType];

    NSError* error = nil;
    NSArray* groups = [mainContext executeFetchRequest:fetchGroupSummary error:&error];
    NSMutableDictionary<NSString*, NSArray<PRDocumentModel*>*>* documentsDictionary = [NSMutableDictionary new];
    for (NSInteger i=0; i<groups.count; i++) {
        NSInteger typeId = [[groups[i] objectForKey:@"documentType"] integerValue];
        NSArray<PRDocumentModel*>* documentKindOfType = [self.class getDocumentsByType:@(typeId)];
        NSString* typeName = [self.class getDocumentTypeForId:@(typeId)].name;
        [documentsDictionary setValue:documentKindOfType forKey:typeName];
    }

    return documentsDictionary;
}

+ (NSArray<PRProfileContactDocumentModel*>*)profileContactNonDeletedDocumentsForContactId:(NSNumber*)contactId withType:(NSNumber*)type
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"profileContact.contactId == %@ && state != %@ && documentType = %@", contactId, @(ModelStatus_Deleted), type];

    return [PRProfileContactDocumentModel MR_findAllWithPredicate:predicate];
}

+ (NSDictionary<NSString*,NSArray<PRProfileContactDocumentModel*>*>*)getProfileContactDocumentsDictionaryForContact:(NSNumber*)contactId inContext:(NSManagedObjectContext*) context
{
    if ([PRDocumentTypeModel MR_findAll].count == 0) {
        return [NSDictionary new];
    }

    NSFetchRequest* fetchGroupSummary = [NSFetchRequest fetchRequestWithEntityName:@"PRProfileContactDocumentModel"];
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"PRProfileContactDocumentModel" inManagedObjectContext:context];
    NSAttributeDescription* groupName = [entity.attributesByName objectForKey:@"documentType"];

    [fetchGroupSummary setEntity:entity];
    [fetchGroupSummary setPropertiesToFetch:[NSArray arrayWithObjects:groupName, nil]];
    [fetchGroupSummary setPropertiesToGroupBy:[NSArray arrayWithObject:groupName]];
    [fetchGroupSummary setResultType:NSDictionaryResultType];

    NSError* error = nil;
    NSArray* groups = [context executeFetchRequest:fetchGroupSummary error:&error];
    NSMutableDictionary<NSString*, NSArray<PRProfileContactDocumentModel*>*>* documentsDictionary = [NSMutableDictionary new];
    for (NSInteger i=0; i<groups.count; i++) {
        NSInteger typeId = [[groups[i] objectForKey:@"documentType"] integerValue];
        NSArray<PRProfileContactDocumentModel*>* documentKindOfType = [self.class profileContactNonDeletedDocumentsForContactId:contactId withType:@(typeId)];
        if (documentKindOfType.count == 0) {
            continue;
        }
        NSString* typeName = [self.class getDocumentTypeForId:@(typeId)].name;
        [documentsDictionary setValue:documentKindOfType forKey:typeName];
    }

    return documentsDictionary;
}

+ (BOOL)isPassport:(NSNumber*)typeId
{
    NSInteger type = [typeId integerValue];
    return type == DocumentType_Passport || type == DocumentType_Foreign_Passport || type == DocumentType_National_Passport || type == DocumentType_Diplomatic_Passport || type == DocumentType_Passport_Any_Country || type == DocumentType_Service_Passport;
}

@end
