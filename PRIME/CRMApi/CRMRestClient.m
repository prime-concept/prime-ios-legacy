//
//  CRMRestClient.m
//  PRIME
//
//  Created by Simon on 14/01/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "CRMRestClient.h"

#import "Config.h"
#import "DefaultHandler.h"
#import "AuthError.h"
#import "Base64.h"
#import "OrderedDictionary.h"
#import "PRActionModel.h"
#import "PRBalanceModel.h"
#import "PRCardTypeModel.h"
#import "PRDocumentModel.h"
#import "PRExchangeModel.h"
#import "PRFeedbackModel.h"
#import "PRListFileInfoModel.h"
#import "PRLoyalCardModel.h"
#import "PRMediaMessageHeaderModel.h"
#import "PRProfileContactEmailModel.h"
#import "PRProfileContactModel.h"
#import "PRProfileContactPhoneModel.h"
#import "PRProfileEmailModel.h"
#import "PRProfilePhoneModel.h"
#import "PRStatusModel.h"
#import "PRCarModel.h"
#import "PRTaskDetailModel.h"
#import "PRTaskTypeModel.h"
#import "PRTasksTypesModel.h"
#import "PRTransactionModel.h"
#import "PRUploadFileInfoModel.h"
#import "PRUploadMediaFileProgressInfoModel.h"
#import "PRMediaFileInfoModel.h"
#import "PRUserProfileModel.h"
#import "PRVerifyResponseModel.h"
#import "RKDotNetNumberDateFormatter.h"
#import "XNTKeychainStore.h"
#import "PRDatabase.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <RestKit/RestKit.h>
#import <RestKit/Search/RKManagedObjectStore+RKSearchAdditions.h>
#import <AVFoundation/AVFoundation.h>
#import "PRUserDefaultsManager.h"
//#import <Crashlytics/Crashlytics.h>
#import <FirebaseCrashlytics/FirebaseCrashlytics.h>
#import "PRDocumentTypeModel.h"

static NSString* const kFirebaseRegistrationPath = @"fcm/register"; // Should not be '/' at the end.
static NSString* const kCardVerificationPath = @"mobile/card"; // Should not be '/' at the end.
static NSString* const kUserRegistrationPath = @"mobile/profile"; // Should not be '/' at the end.
static NSString* const kRegistrationPath = @"mobile/register"; // Should not be '/' at the end.
static NSString* const kVerificationPath = @"mobile/verify"; // Should not be '/' at the end.
static NSString* const kLoginPath = @"mobile/login/:request";
static NSString* const kSetPasswordPath = @"mobile/password"; // Should not be '/' at the end.
static NSString* const kCallbackPath = @"mobile/callback"; // Should not be '/' at the end.
static NSString* const kLogoutPath = @"logout"; // Should not be '/' at the end.
static NSString* const kGenerateTemporaryPasswordPath = @"auth/temp"; // Should not be '/' at the end.
static NSString* const kUserProfilePath = @"me"; // Should not be '/' at the end.
static NSString* const kUserProfileFeaturesPath = @"me/features";
static NSString* const kDocumentsPath = @"me/documents"; // Should not be '/' at the end.
static NSString* const kDocumentPathPattern = @"me/documents/:documentId/"; // Should be '/' at the end.
static NSString* const kDocumentLinkToDocumentPathPattern = @"me/documents/add_to_passport?documentId=:documentId&passportId=:passportId"; // Should be '/' at the end.
static NSString* const kDetachVisaForDocumentPathPattern = @"me/documents/add_to_passport?documentId=:documentId"; // Should be '/' at the end.
static NSString* const kContactDocumentLinkDocumentPathPattern = @"me/contacts/:contactId/documents/add_to_passport?documentId=:documentId&passportId=:passportId"; // Should be '/' at the end.
static NSString* const kDetachVisaForContactDocumentPathPattern = @"me/contacts/:contactId/documents/add_to_passport?documentId=:documentId"; // Should be '/' at the end.
static NSString* const kDocumentTypesPath = @"dict/documentTypes"; // Should not be '/' at the end.
static NSString* const kDiscountsPath = @"me/discounts"; // Should not be '/' at the end.
static NSString* const kDiscountPathPattern = @"me/discounts/:discountId/"; // Should be '/' at the end.
static NSString* const kDiscountTypePath = @"dict/discounts"; // Should not be '/' at the end.
static NSString* const kBalancePathPattern = @"me/balance/:year/:month/"; // Should be '/' at the end.
static NSString* const kExchangePathPattern = @"exchange/:year/:month/"; // Should be '/' at the end.

static NSString* const kTaskTypesPath = @"tasks/types"; // Should not be '/' at the end.
static NSString* const kTasksPath = @"tasks"; // Should not be '/' at the end.
static NSString* const kTasksDetailPathPattern = @"tasks/:taskId/"; // Should be '/' at the end.
static NSString* const kActionsPathPattern = @"tasks/:taskId/actions"; // Should not be '/' at the end.
static NSString* const kCancelTaskPathPattern = @"tasks/:taskId/cancel"; // Should not be '/' at the end.
static NSString* const kGetEventsByYearMonthPathPattern = @"events/:year/:month/"; // Should be '/' at the end.
static NSString* const kGetEventsByYearMonthDayPathPattern = @"events/:year/:month/:day/"; // Should be '/' at the end.
static NSString* const kAddEventPath = @"events"; // Should not be '/' at the end.
static NSString* const kDeleteEventPathPattern = @"events/:eventId/"; // Should be '/' at the end.
static NSString* const kUploadFilePath = @"files/upload"; // Should not be '/' at the end.
static NSString* const kVoiceMessageUploadPath = @"files";
static NSString* const kAsyncUploadPath = @"files/async";
static NSString* const kAsyncUploadPathWithParameter = @"files/async/:uuid";
static NSString* const kMediaFileInfoPathWithParameter = @"files/info/:uuid";
static NSString* const kUploadFilePathWithParameters = @"files/upload?path=:path"; // Should not be '/' at the end.
static NSString* const kListFilesPath = @"files/list"; // Should not be '/' at the end.
static NSString* const kListFilesPathWithParameters = @"files/list?path=:path"; // Should not be '/' at the end.
static NSString* const kDownloadFilePathPattern = @"files/thumbnail/:uid/"; // Should be '/' at the end.

static NSString* const kFeedbackPath = @"me/feedback"; // Should not be '/' at the end.
static NSString* const kDeleteFilePath = @"files/remove/:uid/"; // Should be '/' at the end.

static NSString* const kServicesPath = @"me/services";

static NSString* const kPhonesPath = @"me/phones";
static NSString* const kPhonesModifyPath = @"me/phones/:phoneId/";
static NSString* const kMessageStatusUpdatePath = @"messages?access_token=%@&guid=%@&status=%@&X-Client-Id=%@&X-Device-Id=%@";
static NSString* const kAudioFileGetPath = @"files:path";
static NSString* const kEmailsPath = @"me/emails";
static NSString* const kEmailsModifyPath = @"me/emails/:emailId/";
static NSString* const kContactsPath = @"me/contacts";
static NSString* const kContactsModifyPath = @"me/contacts/:contactId/";
static NSString* const kContactPhonesPath = @"me/contacts/:contactId/phones";
static NSString* const kContactPhoneModifyPath = @"me/contacts/:contactId/phones/:phoneId/";
static NSString* const kContactDocumentsPath = @"me/contacts/:contactId/documents";
static NSString* const kContactDocumentModifyPath = @"me/contacts/:contactId/documents/:documentId/";
static NSString* const kContactEmailModifyPath = @"me/contacts/:contactId/emails/:emailId/";
static NSString* const kContactEmailsPath = @"me/contacts/:contactId/emails";
static NSString* const kPhoneTypesPath = @"dict/phoneTypes";
static NSString* const kEmailTypesPath = @"dict/emailTypes";
static NSString* const kContactTypesPath = @"dict/contactTypes";
static NSString* const kCarModifyPath = @"me/cars/:carId";
static NSString* const kCarPath = @"me/cars/";

static NSString* const kFileDateSeparator = @"$$";
static NSString* const kAvatarJpgFileName = @"avatar";

static NSString* const kMessages = @"messages";
static NSString* const kApplePayGetOrderPath = @"getOrder";
static NSString* const kApplePaySendTokenPath = @"applepay";
static NSString* const kSubscriptions = @"subscriptions";

@interface CRMRestClient ()

@end

#ifdef USE_COREDATA
// Use a class extension to expose access to MagicalRecord's private setter methods.
@interface NSManagedObjectContext ()
+ (void)MR_setRootSavingContext:(NSManagedObjectContext*)context;
+ (void)MR_setDefaultContext:(NSManagedObjectContext*)moc;
@end

@interface RKManagedObjectStore ()
- (void)recreateManagedObjectContexts;
@end

#endif //USE_COREDATA

@implementation CRMRestClient

#pragma mark Singleton
#pragma mark -

+ (CRMRestClient*)sharedClient
{
    static CRMRestClient* sharedClient = nil;

    pr_dispatch_once({
        sharedClient = [[self alloc] init];
    });

    return sharedClient;
}

#pragma mark Initialize
#pragma mark -

+ (void)setupObjectManagerForRegistration
{
    [RKObjectManager setSharedManager:[self.class getRegistrationManager]];
}

+ (void)setupObjectManagerForAuthorization
{
    // Initialize RestKit Object Manager.
    NSURL* url = [NSURL URLWithString:Config.crmEndpoint];

    AFOAuth2Client* oauthClient = [AFOAuth2Client clientWithBaseURL:url
                                                           clientID:kClientID
                                                             secret:kClientSecret];

    oauthClient.allowsInvalidSSLCertificate = YES;

    // Assign the oauthclient to the default manager.
    RKObjectManager* manager = [[RKObjectManager alloc] initWithHTTPClient:oauthClient];

    [manager setAcceptHeaderWithMIMEType:RKMIMETypeJSON];
    [[manager HTTPClient] setDefaultHeader:@"Content-Type" value:RKMIMETypeJSON];

    // Any object that we will attach to the request (sending to the web service,
    // in other words) will be serialized into a JSON string.
    [manager setRequestSerializationMIMEType:RKMIMETypeJSON];

    [RKObjectManager setSharedManager:manager];
}

+ (void)setupObjectManagerForRegistrationWithCard
{
    // Initialize RestKit Object Manager.
    NSURL* url = [NSURL URLWithString:Config.crmEndpoint];

    AFHTTPClient* client = [[AFHTTPClient alloc] initWithBaseURL:url];

    client.allowsInvalidSSLCertificate = YES;

    // Initialize RestKit.
    RKObjectManager* manager = [[RKObjectManager alloc] initWithHTTPClient:client];

    [RKObjectManager setSharedManager:manager];
}

+ (void)setupObjectManagerForChatRequests
{
    // Initialize RestKit Object Manager.
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/chat-server/v3_1/", Config.chatEndpoint]];

    AFHTTPClient* client = [[AFHTTPClient alloc] initWithBaseURL:url];

    client.allowsInvalidSSLCertificate = YES;

    // Initialize RestKit.
    RKObjectManager* manager = [[RKObjectManager alloc] initWithHTTPClient:client];
    [manager setManagedObjectStore:[RKManagedObjectStore defaultStore]];

    [RKObjectManager setSharedManager:manager];
}

+ (void)setupObjectManagerForVoiceMessage
{
    // Initialize RestKit Object Manager.
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/storage/", Config.chatEndpoint]];

    AFHTTPClient* client = [[AFHTTPClient alloc] initWithBaseURL:url];

    NSString* accessToken = [XNTKeychainStore accessToken];
    [client setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@", accessToken]];

    client.allowsInvalidSSLCertificate = YES;

    // Initialize RestKit.
    RKObjectManager* manager = [[RKObjectManager alloc] initWithHTTPClient:client];
    [manager setManagedObjectStore:[RKManagedObjectStore defaultStore]];

    [RKObjectManager setSharedManager:manager];
}

+ (void)setupObjectManagerForApplePay
{
	NSString *endpoint = [Config.crmEndpoint stringByReplacingOccurrencesOfString:@"v3/" withString:@""];
	NSString* kApplePayBaseUrl = [NSString stringWithFormat:@"%@/applepay/", endpoint];
    NSURL* url = [NSURL URLWithString:kApplePayBaseUrl];

    AFHTTPClient* client = [[AFHTTPClient alloc] initWithBaseURL:url];

    client.allowsInvalidSSLCertificate = YES;

    // Initialize RestKit object manager.
    RKObjectManager* manager = [[RKObjectManager alloc] initWithHTTPClient:client];

    [RKObjectManager setSharedManager:manager];
}

+ (RKObjectManager*)getRegistrationManager
{
    // Initialize RestKit Object Manager.
    NSURL* url = [NSURL URLWithString:Config.crmEndpoint];

    AFHTTPClient* client = [[AFHTTPClient alloc] initWithBaseURL:url];

    client.allowsInvalidSSLCertificate = YES;

    // Initialize RestKit.
    RKObjectManager* manager = [[RKObjectManager alloc] initWithHTTPClient:client];
    return manager;
}

#ifdef USE_COREDATA
+ (NSPersistentStore*)addSQLitePersistentStoreAtPath:(NSString*)storePath
                               forManagedObjectStore:(RKManagedObjectStore*)managedObjectStore
{
    NSError* error = nil;

    return [managedObjectStore addSQLitePersistentStoreAtPath:storePath
                                       fromSeedDatabaseAtPath:nil
                                            withConfiguration:nil
                                                      options:@{
                                                          NSInferMappingModelAutomaticallyOption : @YES,
                                                          NSMigratePersistentStoresAutomaticallyOption : @YES
                                                      }
                                                        error:&error];
}

+ (void)setupCoreData:(NSString*)username
{
    static RKManagedObjectStore* managedObjectStore = nil;
    pr_dispatch_once({
        NSURL* modelURL = [NSURL fileURLWithPath:
                                     [[NSBundle mainBundle] pathForResource:@"crmapi"
                                                                     ofType:@"momd"]];

        // Due to an iOS 5 bug, the managed object model returned is immutable.
        NSManagedObjectModel* managedObjectModel =
            [[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] mutableCopy];

        managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    });

    NSString* storeFileName = [NSString stringWithFormat:@"%@%@%@", @"crmapi", username, @".sqlite"];

    NSString* storePath = [RKApplicationDataDirectory()
        stringByAppendingPathComponent:storeFileName];

    NSError* localError;
    //TODO probably it used in case when setupcoreData is colled twice after logout. Check it.
    for (NSPersistentStore* persistentStore in managedObjectStore.persistentStoreCoordinator.persistentStores) {
        BOOL success = [managedObjectStore.persistentStoreCoordinator removePersistentStore:persistentStore error:&localError];
        NSAssert(success, @"removePersistentStore should always success");
        if (!success) {
            exit(1);
        }
    }

    //TODO: reset search indexes and others !!!

    NSError* error = nil;

    NSPersistentStore* persistentStore = [self.class addSQLitePersistentStoreAtPath:storePath forManagedObjectStore:managedObjectStore];

    // If we don't have our migrated store, prepare it
    if ([[NSFileManager defaultManager] fileExistsAtPath:storePath]) {

        if (persistentStore == nil) {
            [[NSFileManager defaultManager] removeItemAtPath:storePath error:&error];

            NSAssert(error == nil, @"Unable to remove persistent store file");
            if (error != nil) {
                exit(1);
            }

            persistentStore = [self.class addSQLitePersistentStoreAtPath:storePath forManagedObjectStore:managedObjectStore];
        }
    }

    NSAssert(persistentStore, @"Failed to add persistent store with error: %@", error);

    // Create default contexts for main thread and background processing.
    [managedObjectStore recreateManagedObjectContexts];

    // Configure a managed object cache to ensure we do not create duplicate objects.
    [managedObjectStore setManagedObjectCache:
                            [[RKInMemoryManagedObjectCache alloc]
                                initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext]];

    // Set the default store shared instance.
    [RKManagedObjectStore setDefaultStore:managedObjectStore];

    // Configure MagicalRecord to use RestKit's Core Data stack.
    [NSPersistentStoreCoordinator MR_setDefaultStoreCoordinator:managedObjectStore.persistentStoreCoordinator];
    [NSManagedObjectContext MR_setRootSavingContext:managedObjectStore.persistentStoreManagedObjectContext];
    [NSManagedObjectContext MR_setDefaultContext:managedObjectStore.mainQueueManagedObjectContext];

    // Assign Managed object store to Object manager.
    [[RKObjectManager sharedManager] setManagedObjectStore:[RKManagedObjectStore defaultStore]];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kCoreDataDidSetup];
    [[NSNotificationCenter defaultCenter] postNotificationName:kCoreDataDidSetupKey object:nil];
}

+ (void)cleanupCoreDataAndSetupForPhone:(NSString*)phone
{
    [MagicalRecord cleanUp];
    [self.class setupCoreData:phone];
}

#endif //USE_COREDATA

+ (void)setupMappingsForRegistration
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSIndexSet* statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);

    NSIndexSet* statusErrorCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError);

    // Registration.
    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRStatusModel mapping]
                                                              method:RKRequestMethodPOST
                                                         pathPattern:kRegistrationPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRStatusModel mapping]
                                                              method:RKRequestMethodPOST
                                                         pathPattern:kRegistrationPath
                                                             keyPath:nil
                                                         statusCodes:statusErrorCodes]];

    [self.class setupMappingsForVerification];
}

+ (void)setupMappingsForChatRequests
{
    RKObjectManager* manager = [RKObjectManager sharedManager];
    NSIndexSet* statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRMessageModel mapping]
                                                              method:RKRequestMethodGET
                                                         pathPattern:kMessages
                                                             keyPath:@"items"
                                                         statusCodes:statusCodes]];

    [manager addRequestDescriptor:
                 [RKRequestDescriptor requestDescriptorWithMapping:[PRMessageModel inverseMappingForTextMessage]
                                                       objectClass:[PRMessageModel class]
                                                       rootKeyPath:nil
                                                            method:RKRequestMethodPOST]];
}

+ (void)setupMappingsForSubscriptions
{
    RKObjectManager* manager = [RKObjectManager sharedManager];
    NSIndexSet* statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);

    [manager addResponseDescriptor:
     [RKResponseDescriptor responseDescriptorWithMapping:[PRSubscriptionModel mapping]
                                                  method:RKRequestMethodGET
                                             pathPattern:kSubscriptions
                                                 keyPath:@"channels"
                                             statusCodes:statusCodes]];
}

+ (void)setupMappingsForVoiceMessage
{
    RKObjectManager* manager = [RKObjectManager sharedManager];
    NSIndexSet* statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRVoiceMessageModel mapping]
                                                              method:RKRequestMethodPOST
                                                         pathPattern:kVoiceMessageUploadPath
                                                             keyPath:@"result"
                                                         statusCodes:statusCodes]];
}

+ (void)setupMappingsForMediaMessageHeader
{
    RKObjectManager* manager = [RKObjectManager sharedManager];
    NSIndexSet* statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);

    [manager addResponseDescriptor:
     [RKResponseDescriptor responseDescriptorWithMapping:[PRMediaMessageModel mapping]
                                                  method:RKRequestMethodPOST
                                             pathPattern:kAsyncUploadPath
                                                 keyPath:@"result"
                                             statusCodes:statusCodes]];

    [manager addResponseDescriptor:
     [RKResponseDescriptor responseDescriptorWithMapping:[PRMediaMessageModel mapping]
                                                  method:RKRequestMethodPOST
                                             pathPattern:kAsyncUploadPathWithParameter
                                                 keyPath:nil
                                             statusCodes:statusCodes]];
    [manager addResponseDescriptor:
     [RKResponseDescriptor responseDescriptorWithMapping:[PRUploadMediaFileProgressInfoModel mapping]
                                                  method:RKRequestMethodGET
                                             pathPattern:kAsyncUploadPathWithParameter
                                                 keyPath:nil
                                             statusCodes:statusCodes]];
}

+ (void)setupMappingsForMediaFileInfo
{
    RKObjectManager* manager = [RKObjectManager sharedManager];
    NSIndexSet* statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);

    [manager addResponseDescriptor:
     [RKResponseDescriptor responseDescriptorWithMapping:[PRMediaFileInfoModel mapping]
                                                  method:RKRequestMethodGET
                                             pathPattern:kMediaFileInfoPathWithParameter
                                                 keyPath:nil
                                             statusCodes:statusCodes]];
}

+ (void)setupMappingsForVerification
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSIndexSet* statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);

    NSIndexSet* statusErrorCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError);

    // Verification.
    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRVerifyResponseModel mapping]
                                                              method:RKRequestMethodPOST
                                                         pathPattern:kVerificationPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRStatusModel mapping]
                                                              method:RKRequestMethodPOST
                                                         pathPattern:kVerificationPath
                                                             keyPath:nil
                                                         statusCodes:statusErrorCodes]];

    // Login.
    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRVerifyResponseModel mapping]
                                                              method:RKRequestMethodPOST
                                                         pathPattern:kLoginPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRStatusModel mapping]
                                                              method:RKRequestMethodPOST
                                                         pathPattern:kLoginPath
                                                             keyPath:nil
                                                         statusCodes:statusErrorCodes]];

    // Set password.
    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRStatusModel mapping]
                                                              method:RKRequestMethodPOST
                                                         pathPattern:kSetPasswordPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRStatusModel mapping]
                                                              method:RKRequestMethodPOST
                                                         pathPattern:kSetPasswordPath
                                                             keyPath:nil
                                                         statusCodes:statusErrorCodes]];

    // Call back.
    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRStatusModel mapping]
                                                              method:RKRequestMethodPOST
                                                         pathPattern:kCallbackPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRStatusModel mapping]
                                                              method:RKRequestMethodPOST
                                                         pathPattern:kCallbackPath
                                                             keyPath:nil
                                                         statusCodes:statusErrorCodes]];
}

+ (void)setupMappings
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    if (manager.responseDescriptors.count > 20) {
        return;
    }

    NSIndexSet* statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);

    NSIndexSet* statusErrorCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError);

    // Firebase.
    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRStatusModel mapping]
                                                              method:RKRequestMethodPOST
                                                         pathPattern:kFirebaseRegistrationPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRStatusModel mapping]
                                                              method:RKRequestMethodPOST
                                                         pathPattern:kFirebaseRegistrationPath
                                                             keyPath:nil
                                                         statusCodes:statusErrorCodes]];

    // User Profile.
    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRUserProfileModel mapping]
                                                              method:RKRequestMethodGET
                                                         pathPattern:kUserProfilePath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addRequestDescriptor:
                 [RKRequestDescriptor requestDescriptorWithMapping:[[PRUserProfileModel mapping] inverseMapping]
                                                       objectClass:[PRUserProfileModel class]
                                                       rootKeyPath:nil
                                                            method:RKRequestMethodPUT]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRUserProfileFeaturesModel mapping]
                                                              method:RKRequestMethodGET
                                                         pathPattern:kUserProfileFeaturesPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRStatusModel mapping]
                                                              method:RKRequestMethodPUT | RKRequestMethodDELETE
                                                         pathPattern:kUserProfilePath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRProfilePhoneModel mapping]
                                                              method:RKRequestMethodGET
                                                         pathPattern:kPhonesPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRProfileEmailModel mapping]
                                                              method:RKRequestMethodGET
                                                         pathPattern:kEmailsPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRProfileContactModel mapping]
                                                              method:RKRequestMethodGET
                                                         pathPattern:kContactsPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRProfileContactModel mapping]
                                                              method:RKRequestMethodPUT
                                                         pathPattern:kContactsModifyPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRStatusModel mapping]
                                                              method:RKRequestMethodDELETE
                                                         pathPattern:kContactsModifyPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRProfileContactPhoneModel mapping]
                                                              method:RKRequestMethodGET
                                                         pathPattern:kContactPhonesPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRProfileContactDocumentModel mapping]
                                                              method:RKRequestMethodGET
                                                         pathPattern:kContactDocumentsPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRProfileContactEmailModel mapping]
                                                              method:RKRequestMethodGET
                                                         pathPattern:kContactEmailsPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRProfilePhoneModel mapping]
                                                              method:RKRequestMethodPOST
                                                         pathPattern:kPhonesPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRProfilePhoneModel mapping]
                                                              method:RKRequestMethodPUT
                                                         pathPattern:kPhonesModifyPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addRequestDescriptor:
                 [RKRequestDescriptor requestDescriptorWithMapping:[[PRProfilePhoneModel mapping] inverseMapping]
                                                       objectClass:[PRProfilePhoneModel class]
                                                       rootKeyPath:nil
                                                            method:RKRequestMethodPOST | RKRequestMethodPUT]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRProfileEmailModel mapping]
                                                              method:RKRequestMethodPOST
                                                         pathPattern:kEmailsPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addRequestDescriptor:
                 [RKRequestDescriptor requestDescriptorWithMapping:[[PRProfileEmailModel mapping] inverseMapping]
                                                       objectClass:[PRProfileEmailModel class]
                                                       rootKeyPath:nil
                                                            method:RKRequestMethodPOST | RKRequestMethodPUT]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRProfileContactModel mapping]
                                                              method:RKRequestMethodPOST
                                                         pathPattern:kContactsPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addRequestDescriptor:
                 [RKRequestDescriptor requestDescriptorWithMapping:[[PRProfileContactModel mapping] inverseMapping]
                                                       objectClass:[PRProfileContactModel class]
                                                       rootKeyPath:nil
                                                            method:RKRequestMethodPOST | RKRequestMethodPUT]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRProfileContactPhoneModel mapping]
                                                              method:RKRequestMethodPOST
                                                         pathPattern:kContactPhonesPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRProfileContactDocumentModel mappingForCreateDocument]
                                                              method:RKRequestMethodPOST
                                                         pathPattern:kContactDocumentsPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
     [RKResponseDescriptor responseDescriptorWithMapping:[PRProfileContactDocumentModel mapping]
                                                  method:RKRequestMethodGET
                                             pathPattern:kContactDocumentModifyPath
                                                 keyPath:nil
                                             statusCodes:statusCodes]];

    [manager addRequestDescriptor:
                 [RKRequestDescriptor requestDescriptorWithMapping:[[PRProfileContactPhoneModel mapping] inverseMapping]
                                                       objectClass:[PRProfileContactPhoneModel class]
                                                       rootKeyPath:nil
                                                            method:RKRequestMethodPOST | RKRequestMethodPUT]];

    [manager addRequestDescriptor:
                 [RKRequestDescriptor requestDescriptorWithMapping:[PRProfileContactDocumentModel inverseMapping]
                                                       objectClass:[PRProfileContactDocumentModel class]
                                                       rootKeyPath:nil
                                                            method:RKRequestMethodPOST | RKRequestMethodPUT]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PREmailTypeModel mapping]
                                                              method:RKRequestMethodGET
                                                         pathPattern:kEmailTypesPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];
    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRPhoneTypeModel mapping]
                                                              method:RKRequestMethodGET
                                                         pathPattern:kPhoneTypesPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRContactTypeModel mapping]
                                                              method:RKRequestMethodGET
                                                         pathPattern:kContactTypesPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRProfileContactEmailModel mapping]
                                                              method:RKRequestMethodPOST
                                                         pathPattern:kContactEmailsPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addRequestDescriptor:
                 [RKRequestDescriptor requestDescriptorWithMapping:[[PRProfileContactEmailModel mapping] inverseMapping]
                                                       objectClass:[PRProfileContactEmailModel class]
                                                       rootKeyPath:nil
                                                            method:RKRequestMethodPOST | RKRequestMethodPUT]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRStatusModel mapping]
                                                              method:RKRequestMethodDELETE
                                                         pathPattern:kPhonesModifyPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRStatusModel mapping]
                                                              method:RKRequestMethodDELETE
                                                         pathPattern:kEmailsModifyPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRProfileEmailModel mapping]
                                                              method:RKRequestMethodPUT
                                                         pathPattern:kEmailsModifyPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRStatusModel mapping]
                                                              method:RKRequestMethodDELETE
                                                         pathPattern:kContactPhoneModifyPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRProfileContactPhoneModel mapping]
                                                              method:RKRequestMethodPUT
                                                         pathPattern:kContactPhoneModifyPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRProfileContactDocumentModel mapping]
                                                              method:RKRequestMethodPUT
                                                         pathPattern:kContactDocumentModifyPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRProfileContactEmailModel mapping]
                                                              method:RKRequestMethodPUT
                                                         pathPattern:kContactEmailModifyPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRStatusModel mapping]
                                                              method:RKRequestMethodDELETE
                                                         pathPattern:kContactEmailModifyPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    // Documents.
    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRDocumentModel mapping]
                                                              method:RKRequestMethodGET
                                                         pathPattern:kDocumentsPath
                                                             keyPath:@"data"
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
     [RKResponseDescriptor responseDescriptorWithMapping:[PRDocumentModel mappingForCreateDocument]
                                                  method:RKRequestMethodPOST
                                             pathPattern:kDocumentsPath
                                                 keyPath:nil
                                             statusCodes:statusCodes]];

    [manager addResponseDescriptor:
     [RKResponseDescriptor responseDescriptorWithMapping:[PRDocumentModel mappingForCreateDocument]
                                                  method:RKRequestMethodPUT
                                             pathPattern:kDocumentPathPattern
                                                 keyPath:nil
                                             statusCodes:statusCodes]];

    [manager addRequestDescriptor:
     [RKRequestDescriptor requestDescriptorWithMapping:[PRDocumentModel inverseMapping]
                                           objectClass:[PRDocumentModel class]
                                           rootKeyPath:nil
                                                method:RKRequestMethodPOST | RKRequestMethodPUT]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRStatusModel mapping]
                                                              method:RKRequestMethodGET
                                                         pathPattern:kDocumentsPath
                                                             keyPath:@"data"
                                                         statusCodes:statusErrorCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRStatusModel mapping]
                                                              method:RKRequestMethodDELETE
                                                         pathPattern:kDocumentPathPattern
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRStatusModel mapping]
                                                              method:RKRequestMethodPOST
                                                         pathPattern:kDocumentsPath
                                                             keyPath:nil
                                                         statusCodes:statusErrorCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRStatusModel mapping]
                                                              method:RKRequestMethodDELETE | RKRequestMethodPUT | RKRequestMethodGET
                                                         pathPattern:kDocumentPathPattern
                                                             keyPath:nil
                                                         statusCodes:statusErrorCodes]];

    // Cars

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRCarModelResponse mapping]
                                                              method:RKRequestMethodGET
                                                         pathPattern:kCarPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRCarModel mapping]
                                                              method:RKRequestMethodPOST
                                                         pathPattern:kCarPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addRequestDescriptor:
                 [RKRequestDescriptor requestDescriptorWithMapping:[[PRCarModel mapping] inverseMapping]
                                                       objectClass:[PRCarModel class]
                                                       rootKeyPath:nil
                                                            method:RKRequestMethodPOST | RKRequestMethodPUT]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRCarModel mapping]
                                                              method:RKRequestMethodPUT
                                                         pathPattern:kCarModifyPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    // Task types.
    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRTasksTypesModel mapping]
                                                              method:RKRequestMethodGET
                                                         pathPattern:kTaskTypesPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRStatusModel mapping]
                                                              method:RKRequestMethodGET
                                                         pathPattern:kTaskTypesPath
                                                             keyPath:nil
                                                         statusCodes:statusErrorCodes]];

    // Tasks.
    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRTaskDetailModel mapping]
                                                              method:RKRequestMethodGET
                                                         pathPattern:kTasksPath
                                                             keyPath:@"data"
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRStatusModel mapping]
                                                              method:RKRequestMethodGET
                                                         pathPattern:kTasksPath
                                                             keyPath:nil
                                                         statusCodes:statusErrorCodes]];

    //    [manager.router.routeSet addRoute:[RKRoute routeWithClass:[PRTaskDetailModel class] pathPattern:kActionsPathPattern method:RKRequestMethodGET]];

    // Feedback.
    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRFeedbackModel mapping]
                                                              method:RKRequestMethodPOST
                                                         pathPattern:kFeedbackPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRStatusModel mapping]
                                                              method:RKRequestMethodPOST
                                                         pathPattern:kFeedbackPath
                                                             keyPath:nil
                                                         statusCodes:statusErrorCodes]];

    // Task Details.
    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRTaskDetailModel mapping]
                                                              method:RKRequestMethodGET
                                                         pathPattern:kTasksDetailPathPattern
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRStatusModel mapping]
                                                              method:RKRequestMethodGET
                                                         pathPattern:kTasksDetailPathPattern
                                                             keyPath:nil
                                                         statusCodes:statusErrorCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRStatusModel mapping]
                                                              method:RKRequestMethodGET
                                                         pathPattern:kGetEventsByYearMonthPathPattern
                                                             keyPath:@"data"
                                                         statusCodes:statusErrorCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRStatusModel mapping]
                                                              method:RKRequestMethodGET
                                                         pathPattern:kGetEventsByYearMonthDayPathPattern
                                                             keyPath:@"data"
                                                         statusCodes:statusErrorCodes]];

    // Logout.
    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRStatusModel mapping]
                                                              method:RKRequestMethodGET
                                                         pathPattern:kLogoutPath
                                                             keyPath:@"data"
                                                         statusCodes:statusCodes]];

    // Authorization.
    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRStatusModel mapping]
                                                              method:RKRequestMethodAny
                                                         pathPattern:kAuthorizationPath
                                                             keyPath:nil
                                                         statusCodes:statusErrorCodes]];

    //    [manager addResponseDescriptor:
    //                 [RKResponseDescriptor responseDescriptorWithMapping:[PRTaskDetailModel mappingForActions]
    //                                                              method:RKRequestMethodGET
    //                                                         pathPattern:kActionsPathPattern
    //                                                             keyPath:nil
    //                                                         statusCodes:statusCodes]];
    //
    //    [manager addResponseDescriptor:
    //                 [RKResponseDescriptor responseDescriptorWithMapping:[PRStatusModel mapping]
    //                                                              method:RKRequestMethodGET
    //                                                         pathPattern:kActionsPathPattern
    //                                                             keyPath:nil
    //                                                         statusCodes:statusErrorCodes]];

    // Upload File.
    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRUploadFileInfoModel mapping]
                                                              method:RKRequestMethodPOST
                                                         pathPattern:kUploadFilePath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRStatusModel mapping]
                                                              method:RKRequestMethodPOST
                                                         pathPattern:kUploadFilePath
                                                             keyPath:nil
                                                         statusCodes:statusErrorCodes]];

    // Files list.
    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRListFileInfoModel mapping]
                                                              method:RKRequestMethodGET
                                                         pathPattern:kListFilesPath
                                                             keyPath:@"data"
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRStatusModel mapping]
                                                              method:RKRequestMethodGET
                                                         pathPattern:kListFilesPath
                                                             keyPath:nil
                                                         statusCodes:statusErrorCodes]];

    // Discounts list.
    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRLoyalCardModel mapping]
                                                              method:RKRequestMethodGET | RKRequestMethodPOST
                                                         pathPattern:kDiscountsPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRStatusModel mapping]
                                                              method:RKRequestMethodGET | RKRequestMethodPOST | RKRequestMethodPUT
                                                         pathPattern:kDiscountsPath
                                                             keyPath:nil
                                                         statusCodes:statusErrorCodes]];

    [manager addRequestDescriptor:
                 [RKRequestDescriptor requestDescriptorWithMapping:[[PRLoyalCardModel mapping] inverseMapping]
                                                       objectClass:[PRLoyalCardModel class]
                                                       rootKeyPath:nil
                                                            method:RKRequestMethodPOST | RKRequestMethodPUT]];

    // Discount.
    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRLoyalCardModel mapping]
                                                              method:RKRequestMethodGET | RKRequestMethodPUT
                                                         pathPattern:kDiscountPathPattern
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRStatusModel mapping]
                                                              method:RKRequestMethodDELETE
                                                         pathPattern:kDiscountPathPattern
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRStatusModel mapping]
                                                              method:RKRequestMethodGET
                                                         pathPattern:kDiscountPathPattern
                                                             keyPath:nil
                                                         statusCodes:statusErrorCodes]];

    [manager addRequestDescriptor:
                 [RKRequestDescriptor requestDescriptorWithMapping:[[PRLoyalCardModel mapping] inverseMapping]
                                                       objectClass:[PRLoyalCardModel class]
                                                       rootKeyPath:nil
                                                            method:RKRequestMethodPOST]];

    // Discounts types.
    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRCardTypeModel mapping]
                                                              method:RKRequestMethodGET
                                                         pathPattern:kDiscountTypePath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    // Documents types.
    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRDocumentTypeModel mapping]
                                                              method:RKRequestMethodGET
                                                         pathPattern:kDocumentTypesPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRStatusModel mapping]
                                                              method:RKRequestMethodGET
                                                         pathPattern:kDiscountTypePath
                                                             keyPath:nil
                                                         statusCodes:statusErrorCodes]];

    // Balance.
    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRBalanceModel mapping]
                                                              method:RKRequestMethodGET
                                                         pathPattern:kBalancePathPattern
                                                             keyPath:@"data"
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRStatusModel mapping]
                                                              method:RKRequestMethodGET
                                                         pathPattern:kBalancePathPattern
                                                             keyPath:nil
                                                         statusCodes:statusErrorCodes]];

    // Exchange.
    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRExchangeModel mapping]
                                                              method:RKRequestMethodGET
                                                         pathPattern:kExchangePathPattern
                                                             keyPath:@"data"
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRStatusModel mapping]
                                                              method:RKRequestMethodGET
                                                         pathPattern:kExchangePathPattern
                                                             keyPath:nil
                                                         statusCodes:statusErrorCodes]];

    //Services
    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRServicesModel mapping]
                                                              method:RKRequestMethodGET
                                                         pathPattern:kServicesPath
                                                             keyPath:@"data"
                                                         statusCodes:statusCodes]];

    // Deleting orphaned objects.

    // User Profile
    [manager addFetchRequestBlock:^NSFetchRequest*(NSURL* URL) {
        // Create a path matcher.
        RKPathMatcher* pathMatcher = [RKPathMatcher pathMatcherWithPattern:kUserProfilePath];

        // Dictionary to store request arguments.
        NSDictionary* argsDict = nil;

        // Match the URL with pathMatcher and retrieve arguments.
        BOOL match = [pathMatcher matchesPath:[URL relativePath]
                         tokenizeQueryStrings:NO
                              parsedArguments:&argsDict];

        // If url matched, create NSFetchRequest.
        if (match) {
            NSFetchRequest* fetchRequest = [PRUserProfileModel MR_requestAll];
            return fetchRequest;
        }

        return nil;
    }];

    // User Profile Features.
    [manager addFetchRequestBlock:^NSFetchRequest*(NSURL* URL) {
        // Create a path matcher.
        RKPathMatcher* pathMatcher = [RKPathMatcher pathMatcherWithPattern:kUserProfileFeaturesPath];

        // Dictionary to store request arguments.
        NSDictionary* argsDict = nil;

        // Match the URL with pathMatcher and retrieve arguments.
        BOOL match = [pathMatcher matchesPath:[URL relativePath]
                         tokenizeQueryStrings:NO
                              parsedArguments:&argsDict];

        // If url matched, create NSFetchRequest.
        if (match) {
            return [PRUserProfileFeaturesModel MR_requestAll];
        }

        return nil;
    }];

    // Documents.
    [manager addFetchRequestBlock:^NSFetchRequest*(NSURL* URL) {
        // Create a path matcher.
        RKPathMatcher* pathMatcher = [RKPathMatcher pathMatcherWithPattern:kDocumentsPath];

        // Dictionary to store request arguments.
        NSDictionary* argsDict = nil;

        // Match the URL with pathMatcher and retrieve arguments.
        BOOL match = [pathMatcher matchesPath:[URL relativePath]
                         tokenizeQueryStrings:NO
                              parsedArguments:&argsDict];

        // If url matched, create NSFetchRequest.
        if (match) {
            return [PRDocumentModel MR_requestAll];
        }

        return nil;
    }];

    // Document Types.
    [manager addFetchRequestBlock:^NSFetchRequest*(NSURL* URL) {
        // Create a path matcher.
        RKPathMatcher* pathMatcher = [RKPathMatcher pathMatcherWithPattern:kDocumentTypesPath];

        // Dictionary to store request arguments.
        NSDictionary* argsDict = nil;

        // Match the URL with pathMatcher and retrieve arguments.
        BOOL match = [pathMatcher matchesPath:[URL relativePath]
                         tokenizeQueryStrings:NO
                              parsedArguments:&argsDict];

        // If url matched, create NSFetchRequest.
        if (match) {
            return [PRDocumentTypeModel MR_requestAll];
        }

        return nil;
    }];

    // Card types.
    [manager addFetchRequestBlock:^NSFetchRequest*(NSURL* URL) {
        // Create a path matcher.
        RKPathMatcher* pathMatcher = [RKPathMatcher pathMatcherWithPattern:kDiscountTypePath];

        // Dictionary to store request arguments.
        NSDictionary* argsDict = nil;

        // Match the URL with pathMatcher and retrieve arguments.
        BOOL match = [pathMatcher matchesPath:[URL relativePath]
                         tokenizeQueryStrings:NO
                              parsedArguments:&argsDict];

        // If url matched, create NSFetchRequest.
        if (match) {
            return [PRCardTypeModel MR_requestAll];
        }

        return nil;
    }];

    // Cards.
    [manager addFetchRequestBlock:^NSFetchRequest*(NSURL* URL) {
        // Create a path matcher.
        RKPathMatcher* pathMatcher = [RKPathMatcher pathMatcherWithPattern:kDiscountsPath];

        // Dictionary to store request arguments.
        NSDictionary* argsDict = nil;

        // Match the URL with pathMatcher and retrieve arguments.
        BOOL match = [pathMatcher matchesPath:[URL relativePath]
                         tokenizeQueryStrings:NO
                              parsedArguments:&argsDict];

        // If url matched, create NSFetchRequest.
        if (match) {
            return [PRLoyalCardModel MR_requestAll];
        }

        return nil;
    }];

    // Task types.
    [manager addFetchRequestBlock:^NSFetchRequest*(NSURL* URL) {
        // Create a path matcher.
        RKPathMatcher* pathMatcher = [RKPathMatcher pathMatcherWithPattern:kTaskTypesPath];

        // Dictionary to store request arguments.
        NSDictionary* argsDict = nil;

        // Match the URL with pathMatcher and retrieve arguments.
        BOOL match = [pathMatcher matchesPath:[URL relativePath]
                         tokenizeQueryStrings:NO
                              parsedArguments:&argsDict];

        // If url matched, create NSFetchRequest.
        if (match) {
            return [PRTasksTypesModel MR_requestAll];
        }

        return nil;
    }];

    // Tasks.
    [manager addFetchRequestBlock:^NSFetchRequest*(NSURL* URL) {

        // Create a path matcher.
        RKPathMatcher* pathMatcher = [RKPathMatcher pathMatcherWithPattern:kTasksPath];

        // Dictionary to store request arguments.
        NSDictionary* argsDict = nil;

        // Match the URL with pathMatcher and retrieve arguments.
        BOOL match = [pathMatcher matchesPath:[URL relativeString]
                         tokenizeQueryStrings:YES
                              parsedArguments:&argsDict];

        // If url matched, create NSFetchRequest.
        if (match) {
            return [PRTaskDetailModel MR_requestAll];
        }

        return nil;
    }];

    // Actions.
    // TODO: Add featchRequetsBlock !!!

    // Files.
    [manager addFetchRequestBlock:^NSFetchRequest*(NSURL* URL) {

        // Create a path matcher.
        RKPathMatcher* pathMatcher = [RKPathMatcher pathMatcherWithPattern:kUploadFilePath];

        // Dictionary to store request arguments.
        NSDictionary* argsDict = nil;

        // Match the URL with pathMatcher and retrieve arguments.
        BOOL match = [pathMatcher matchesPath:[URL relativeString]
                         tokenizeQueryStrings:YES
                              parsedArguments:&argsDict];

        // If url matched, create NSFetchRequest.
        if (match) {

            NSString* documentId = [NSString extractString:argsDict[@"path"]
                                                 toLookFor:@"/"
                                         onlyStringBetween:YES
                                              toStopBefore:nil];

            NSPredicate* predicate = nil;

            if (documentId == nil) {
                predicate = [NSPredicate predicateWithFormat:@"(ANY documentId = nil)"];
            } else {
                predicate = [NSPredicate predicateWithFormat:@"(documentId = %@)", documentId];
            }

            NSFetchRequest* fetchRequest = [PRUploadFileInfoModel MR_requestAllWithPredicate:predicate];
            return fetchRequest;
        }

        return nil;
    }];

    // Events by Year and Month.
    [manager addFetchRequestBlock:^NSFetchRequest*(NSURL* URL) {
        // Create a path matcher.
        NSString* pattern = [kBalancePathPattern substringToIndex:[kBalancePathPattern length] - 1];
        RKPathMatcher* pathMatcher = [RKPathMatcher pathMatcherWithPattern:pattern];

        // Dictionary to store request arguments.
        NSDictionary* argsDict = nil;

        // Match the URL with pathMatcher and retrieve arguments.
        BOOL match = [pathMatcher matchesPath:[URL relativePath]
                         tokenizeQueryStrings:NO
                              parsedArguments:&argsDict];

        // If url matched, create NSFetchRequest.
        if (match) {
            NSString* year = argsDict[@"year"];
            NSString* month = argsDict[@"month"];

            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(year = %@) AND (month = %@)",
                                                  year, month];

            NSFetchRequest* fetchRequest = [PRBalanceModel MR_requestAllWithPredicate:predicate];
            return fetchRequest;
        }

        return nil;
    }];

    // Exchange by Year and Month.
    [manager addFetchRequestBlock:^NSFetchRequest*(NSURL* URL) {
        // Create a path matcher
        NSString* pattern = [kExchangePathPattern substringToIndex:[kExchangePathPattern length] - 1];
        RKPathMatcher* pathMatcher = [RKPathMatcher pathMatcherWithPattern:pattern];

        // Dictionary to store request arguments.
        NSDictionary* argsDict = nil;

        // Match the URL with pathMatcher and retrieve arguments.
        BOOL match = [pathMatcher matchesPath:[URL relativePath]
                         tokenizeQueryStrings:NO
                              parsedArguments:&argsDict];

        // If url matched, create NSFetchRequest.
        if (match) {
            NSString* year = argsDict[@"year"];
            NSString* month = argsDict[@"month"];
            NSString* dateString = [NSString stringWithFormat:@"%@-%@", year, month];
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(date CONTAINS[cd] %@)",
                                                  dateString];

            NSFetchRequest* fetchRequest = [PRExchangeModel MR_requestAllWithPredicate:predicate];
            return fetchRequest;
        }

        return nil;
    }];

    // Profile phones.
    [manager addFetchRequestBlock:^NSFetchRequest*(NSURL* URL) {
        // Create a path matcher.
        NSString* pattern = kPhonesPath;
        RKPathMatcher* pathMatcher = [RKPathMatcher pathMatcherWithPattern:pattern];

        // Dictionary to store request arguments.
        NSDictionary* argsDict = nil;

        // Match the URL with pathMatcher and retrieve arguments.
        BOOL match = [pathMatcher matchesPath:[URL relativePath]
                         tokenizeQueryStrings:NO
                              parsedArguments:&argsDict];

        // If url matched, create NSFetchRequest.
        if (match) {
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"state in %@", @[ @(ModelStatus_Synched), @(ModelStatus_Deleted) ]];
            NSFetchRequest* fetchRequest = [PRProfilePhoneModel MR_requestAllWithPredicate:predicate];

            return fetchRequest;
        }

        return nil;
    }];

    //Services.
    [manager addFetchRequestBlock:^NSFetchRequest*(NSURL* URL) {
        // Create a path matcher.
        NSString* pattern = kServicesPath;
        RKPathMatcher* pathMatcher = [RKPathMatcher pathMatcherWithPattern:pattern];

        // Dictionary to store request arguments.
        NSDictionary* argsDict = nil;

        // Match the URL with pathMatcher and retrieve arguments.
        BOOL match = [pathMatcher matchesPath:[URL relativePath]
                         tokenizeQueryStrings:NO
                              parsedArguments:&argsDict];

        // If url matched, create NSFetchRequest.
        if (match) {
            return [PRServicesModel MR_requestAll];
        }
        return nil;
    }];

    // Profile emails.
    [manager addFetchRequestBlock:^NSFetchRequest*(NSURL* URL) {
        // Create a path matcher.
        NSString* pattern = kEmailsPath;
        RKPathMatcher* pathMatcher = [RKPathMatcher pathMatcherWithPattern:pattern];

        // Dictionary to store request arguments.
        NSDictionary* argsDict = nil;

        // Match the URL with pathMatcher and retrieve arguments.
        BOOL match = [pathMatcher matchesPath:[URL relativePath]
                         tokenizeQueryStrings:NO
                              parsedArguments:&argsDict];

        // If url matched, create NSFetchRequest.
        if (match) {

            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"state in %@", @[ @(ModelStatus_Synched), @(ModelStatus_Deleted) ]];
            NSFetchRequest* fetchRequest = [PRProfileEmailModel MR_requestAllWithPredicate:predicate];
            return fetchRequest;
        }

        return nil;
    }];

    // Profile contacts.
    [manager addFetchRequestBlock:^NSFetchRequest*(NSURL* URL) {
        // Create a path matcher.
        NSString* pattern = kContactsPath;
        RKPathMatcher* pathMatcher = [RKPathMatcher pathMatcherWithPattern:pattern];

        // Dictionary to store request arguments.
        NSDictionary* argsDict = nil;

        // Match the URL with pathMatcher and retrieve arguments.
        BOOL match = [pathMatcher matchesPath:[URL relativePath]
                         tokenizeQueryStrings:NO
                              parsedArguments:&argsDict];

        // If url matched, create NSFetchRequest.
        if (match) {

            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"state in %@", @[ @(ModelStatus_Synched), @(ModelStatus_Deleted) ]];
            return [PRProfileContactModel MR_requestAllWithPredicate:predicate];
        }

        return nil;
    }];

    // Profile phone types.
    [manager addFetchRequestBlock:^NSFetchRequest*(NSURL* URL) {
        // Create a path matcher.
        NSString* pattern = kPhoneTypesPath;
        RKPathMatcher* pathMatcher = [RKPathMatcher pathMatcherWithPattern:pattern];

        // Dictionary to store request arguments.
        NSDictionary* argsDict = nil;

        // Match the URL with pathMatcher and retrieve arguments.
        BOOL match = [pathMatcher matchesPath:[URL relativePath]
                         tokenizeQueryStrings:NO
                              parsedArguments:&argsDict];

        // If url matched, create NSFetchRequest.
        if (match) {

            return [PRPhoneTypeModel MR_requestAll];
        }

        return nil;
    }];

    // Profile email types.
    [manager addFetchRequestBlock:^NSFetchRequest*(NSURL* URL) {
        // Create a path matcher.
        NSString* pattern = kEmailTypesPath;
        RKPathMatcher* pathMatcher = [RKPathMatcher pathMatcherWithPattern:pattern];

        // Dictionary to store request arguments.
        NSDictionary* argsDict = nil;

        // Match the URL with pathMatcher and retrieve arguments.
        BOOL match = [pathMatcher matchesPath:[URL relativePath]
                         tokenizeQueryStrings:NO
                              parsedArguments:&argsDict];

        // If url matched, create NSFetchRequest.
        if (match) {

            return [PREmailTypeModel MR_requestAll];
        }

        return nil;
    }];

    // Profile contact types.
    [manager addFetchRequestBlock:^NSFetchRequest*(NSURL* URL) {
        // Create a path matcher.
        NSString* pattern = kContactTypesPath;
        RKPathMatcher* pathMatcher = [RKPathMatcher pathMatcherWithPattern:pattern];

        // Dictionary to store request arguments.
        NSDictionary* argsDict = nil;
        // Match the URL with pathMatcher and retrieve arguments.
        BOOL match = [pathMatcher matchesPath:[URL relativePath]
                         tokenizeQueryStrings:NO
                              parsedArguments:&argsDict];

        // If url matched, create NSFetchRequest.
        if (match) {

            return [PRContactTypeModel MR_requestAll];
        }

        return nil;
    }];

    // Cars
    [manager addFetchRequestBlock:^NSFetchRequest*(NSURL* URL) {
        // Create a path matcher.
        NSString* pattern = kCarPath;
        RKPathMatcher* pathMatcher = [RKPathMatcher pathMatcherWithPattern:pattern];

        // Dictionary to store request arguments.
        NSDictionary* argsDict = nil;

        // Match the URL with pathMatcher and retrieve arguments.
        BOOL match = [pathMatcher matchesPath:[URL relativePath]
                         tokenizeQueryStrings:NO
                              parsedArguments:&argsDict];

        // If url matched, create NSFetchRequest.
        if (match) {

            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"state in %@", @[ @(ModelStatus_Synched), @(ModelStatus_Deleted) ]];
            NSFetchRequest* fetchRequest = [PRCarModel MR_requestAllWithPredicate:predicate];
            return fetchRequest;
        }

        return nil;
    }];
}

+ (void)setupMappingsForApplePay
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSIndexSet* statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);

    // Apple Pay.
    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRPaymentDataModel mapping]
                                                              method:RKRequestMethodGET
                                                         pathPattern:kApplePayGetOrderPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addResponseDescriptor:
                 [RKResponseDescriptor responseDescriptorWithMapping:[PRApplePayResponseModel mapping]
                                                              method:RKRequestMethodPOST
                                                         pathPattern:kApplePaySendTokenPath
                                                             keyPath:nil
                                                         statusCodes:statusCodes]];

    [manager addRequestDescriptor:
                 [RKRequestDescriptor requestDescriptorWithMapping:[[PRApplePayToken mapping] inverseMapping]
                                                       objectClass:[PRApplePayToken class]
                                                       rootKeyPath:nil
                                                            method:RKRequestMethodPOST | RKRequestMethodPUT]];
}

+ (void)initialize
{
// Initialize RestKit logging.
#ifdef DEBUG
    RKLogConfigureFromEnvironment();
#endif

#if DEBUG_RESTKIT >= 1
    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
#endif

#if DEBUG_RESTKIT >= 2
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
#endif

#if DEBUG_RESTKIT >= 3
    RKLogConfigureByName("RestKit/Network*", RKLogLevelTrace);
#endif

    // Set Default Date Transformer.
    [RKObjectMapping alloc]; // Do not remove ! It should be called before 'insertValueTransformer'.

    [[RKValueTransformer defaultValueTransformer] insertValueTransformer:[RKDotNetNumberDateFormatter dotNetDateFormatterWithTimeZone:nil]
                                                                 atIndex:0]; //For NSNumber.
    [[RKValueTransformer defaultValueTransformer] insertValueTransformer:[RKDotNetDateFormatter dotNetDateFormatterWithTimeZone:nil] atIndex:1]; //For String.

    // Add @"image/jpg" in the set of acceptable content types.
    [AFImageRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"image/jpg"]];
}

#pragma mard Private Methods
#pragma mark -

+ (NSString*)getUniqueDeviceIdentifierAsString
{
    NSString* strApplicationUUID = [XNTKeychainStore stringForKey:@"password"
                                                       identifier:@"device"];
    if (strApplicationUUID == nil) {
        strApplicationUUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [XNTKeychainStore setString:strApplicationUUID
                             forKey:@"password"
                         identifier:@"device"];
    }

    return strApplicationUUID;
}

+ (NSString*)signParametersWithString:(NSString*)parameters
                           withSecret:(NSString*)clientSecret
{
    // Base64 Decode.
    NSData* keyData = [Base64 decodeString:clientSecret];

    // DO NOT USE !!! [[NSData alloc] initWithBase64EncodedString:clientSecret options:0];

    const char* cData = [parameters cStringUsingEncoding:NSASCIIStringEncoding];

    if (cData == NULL) {
        cData = [parameters UTF8String];
    }

    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];

    // Sign with HMAC SHA1.
    CCHmac(kCCHmacAlgSHA1, [keyData bytes], [keyData length], cData, strlen(cData), cHMAC);

    NSData* HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];

    // Base64 Encode.
    return [HMAC base64EncodedStringWithOptions:0];
}

+ (NSInteger)getStatusCodeFromOperation:(RKObjectRequestOperation*)operation
{
    return [self.class getAFHTTPStatusCodeFromOperation:operation.HTTPRequestOperation];
}

+ (NSInteger)getAFHTTPStatusCodeFromOperation:(AFHTTPRequestOperation*)operation
{
    return operation.response.statusCode;
}

+ (NSError*)getNSErrorFromOperation:(RKObjectRequestOperation*)operation
{
    return [operation.HTTPRequestOperation error];
}

+ (NSString*)signParametersWithDictionary:(NSDictionary*)parameters
                               withSecret:(NSString*)clientSecret
{
    NSMutableString* params = [[NSMutableString alloc] init];

    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL* stop) {
        [params appendString:object];
    }];

    return [self.class signParametersWithString:params
                                     withSecret:clientSecret];
}

+ (NSString*)signParametersWithDictionary:(NSDictionary*)parameters
{
    return [self.class signParametersWithDictionary:parameters
                                         withSecret:kClientSecret];
}

#pragma mark Api Methods
#pragma mark -

- (void)registerFCMToken:(NSString*)token
                 success:(void (^)())success
                 failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    MutableOrderedDictionary* parameters = [[MutableOrderedDictionary alloc] init];

    [parameters setObject:token
                   forKey:@"token"];
    [parameters setObject:kClientID
                   forKey:@"client_id"];
    [parameters setObject:[self.class getUniqueDeviceIdentifierAsString]
                   forKey:@"device_id"];

    // Keeps default serialization MIME type in order to restore manager's serialization MIME type at the end of the request.
    NSString* const oldSerializationMIMEType = [manager requestSerializationMIMEType];

    // Change request parameters serialization MIME type to "application/x-www-form-urlencoded".
    [manager setRequestSerializationMIMEType:RKMIMETypeFormURLEncoded];

    // Adding "text/plain" MIME type to response expected serialization MIME types list.
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];

    [manager postObject:nil
        path:kFirebaseRegistrationPath
        parameters:parameters
        success:^(RKObjectRequestOperation* operation, RKMappingResult* mappingResult) {

            success();
        }
        failure:^(RKObjectRequestOperation* operation, NSError* error) {

            NSLog(@"Error: %@", [error localizedDescription]);
            failure([self.class getStatusCodeFromOperation:operation], error);
        }];

    [manager setRequestSerializationMIMEType:oldSerializationMIMEType];
}

- (void)registerMobileWithPhone:(NSString*)phone
                        success:(void (^)())success
                        failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    [self.class setupObjectManagerForRegistration];

    [self.class setupMappingsForRegistration];

    RKObjectManager* manager = [RKObjectManager sharedManager];

    MutableOrderedDictionary* parameters = [[MutableOrderedDictionary alloc] init];

    // Do not change the order !!!
    [parameters setObject:kClientID
                   forKey:@"client_id"];
    [parameters setObject:[self.class getUniqueDeviceIdentifierAsString]
                   forKey:@"device_id"];
    [parameters setObject:phone
                   forKey:@"phone"];
    [parameters setObject:[self.class signParametersWithDictionary:parameters]
                   forKey:@"signature"];

    [manager postObject:nil
        path:kRegistrationPath
        parameters:parameters
        success:^(RKObjectRequestOperation* operation, RKMappingResult* mappingResult) {
            success();
        }
        failure:^(RKObjectRequestOperation* operation, NSError* error) {

            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)verifyCardNumber:(NSString*)cardNumber
                 success:(void (^)())success
                 failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    [self.class setupObjectManagerForRegistrationWithCard];

    RKObjectManager* manager = [RKObjectManager sharedManager];
    MutableOrderedDictionary* parameters = [[MutableOrderedDictionary alloc] init];

    // Do not change the order !!!
    [parameters setObject:kClientID
                   forKey:@"client_id"];
    [parameters setObject:[self.class getUniqueDeviceIdentifierAsString]
                   forKey:@"device_id"];
    [parameters setObject:cardNumber
                   forKey:@"card_number"];
    [parameters setObject:[self.class signParametersWithDictionary:parameters]
                   forKey:@"signature"];

    [manager postObject:nil
        path:kCardVerificationPath
        parameters:parameters
        success:^(RKObjectRequestOperation* operation, RKMappingResult* mappingResult) {
            success();
        }
        failure:^(RKObjectRequestOperation* operation, NSError* error) {

            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)registerUserProfile:(NSDictionary*)userParameters
                    success:(void (^)())success
                    failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];
    MutableOrderedDictionary* parameters = [[MutableOrderedDictionary alloc] init];

    [parameters setObject:kClientID
                   forKey:@"client_id"];
    [parameters setObject:[self.class getUniqueDeviceIdentifierAsString]
                   forKey:@"device_id"];
    [parameters setObject:[userParameters valueForKey:@"card_number"]
                   forKey:@"card_number"];
    [parameters setObject:[userParameters valueForKey:@"first_name"]
                   forKey:@"first_name"];
    [parameters setObject:[userParameters valueForKey:@"middle_name"]
                   forKey:@"middle_name"];
    [parameters setObject:[userParameters valueForKey:@"last_name"]
                   forKey:@"last_name"];
    [parameters setObject:[userParameters valueForKey:@"birthday"]
                   forKey:@"birthday"];
    [parameters setObject:[userParameters valueForKey:@"phone"]
                   forKey:@"phone"];
    [parameters setObject:[userParameters valueForKey:@"email"]
                   forKey:@"email"];
    [parameters setObject:[self.class signParametersWithDictionary:parameters]
                   forKey:@"signature"];

    [manager postObject:nil
        path:kUserRegistrationPath
        parameters:parameters
        success:^(RKObjectRequestOperation* operation, RKMappingResult* mappingResult) {
            success();
        }
        failure:^(RKObjectRequestOperation* operation, NSError* error) {

            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)verifyWithPhone:(NSString*)phone
                   code:(NSString*)code
                success:(void (^)())success
                failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

#if defined(Otkritie) || defined(Raiffeisen) || defined(PrivateBankingPRIMEClub) || defined(PrimeRRClub) || defined(PrimeClubConcierge)
    [self.class setupObjectManagerForRegistration];
    [self.class setupMappingsForVerification];
    manager = [RKObjectManager sharedManager];
#endif

    MutableOrderedDictionary* parameters = [[MutableOrderedDictionary alloc] init];

    // Do not change the order !!!
    [parameters setObject:kClientID
                   forKey:@"client_id"];
    [parameters setObject:[self.class getUniqueDeviceIdentifierAsString]
                   forKey:@"device_id"];
    [parameters setObject:phone
                   forKey:@"phone"];
    [parameters setObject:code
                   forKey:@"key"];
    [parameters setObject:[self.class signParametersWithDictionary:parameters]
                   forKey:@"signature"];

    [manager postObject:nil
        path:kVerificationPath
        parameters:parameters
        success:^(RKObjectRequestOperation* operation, RKMappingResult* mappingResult) {
            NSArray<PRVerifyResponseModel*>* objects = [mappingResult array];

            NSLog(@"Loaded objects: %@", objects);

            PRVerifyResponseModel* object = [objects firstObject];

            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            NSUserDefaults* siriDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSiriUserDefaultsSuiteName];
            NSUserDefaults* extensionsDefault = [[NSUserDefaults alloc] initWithSuiteName:kSiriUserDefaultsSuiteName];
            [siriDefaults setObject:object.username forKey:kCustomerId];
            [defaults setObject:object.username forKey:kCustomerId];
            [extensionsDefault setObject:object.username  forKey:kCustomerId];
//            [CrashlyticsKit setUserIdentifier:object.username];
            [[FIRCrashlytics crashlytics] setUserID:object.username];
            [defaults synchronize];

            success();
        }
        failure:^(RKObjectRequestOperation* operation, NSError* error) {
           
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)loginWithRequest:(NSString*)loginRequest
                 success:(void (^)())success
                 failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    [self.class setupObjectManagerForRegistration];
    [self.class setupMappingsForRegistration];

    RKObjectManager* manager = [RKObjectManager sharedManager];
    NSDictionary* pathParams = @{
        @"request" : loginRequest
    };

    NSString* path = RKPathFromPatternWithObject(
        kLoginPath,
        pathParams);

    [manager postObject:nil
        path:path
        parameters:nil
        success:^(RKObjectRequestOperation* operation, RKMappingResult* mappingResult) {
            NSArray<PRVerifyResponseModel*>* objects = [mappingResult array];

            NSLog(@"Loaded objects: %@", objects);

            PRVerifyResponseModel* object = [objects firstObject];

            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:object.username forKey:kCustomerId];
            [defaults synchronize];

            success();
        }
        failure:^(RKObjectRequestOperation* operation, NSError* error) {

            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)setPassword:(NSString*)password
              phone:(NSString*)phone
            success:(void (^)())success
            failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    MutableOrderedDictionary* parameters = [[MutableOrderedDictionary alloc] init];

    // Do not change the order !!!
    [parameters setObject:kClientID
                   forKey:@"client_id"];
    [parameters setObject:[self.class getUniqueDeviceIdentifierAsString]
                   forKey:@"device_id"];
    [parameters setObject:phone
                   forKey:@"phone"];
    [parameters setObject:password
                   forKey:@"password"];
    [parameters setObject:[self.class signParametersWithDictionary:parameters]
                   forKey:@"signature"];

    [manager postObject:nil
        path:kSetPasswordPath
        parameters:parameters
        success:^(RKObjectRequestOperation* operation, RKMappingResult* mappingResult) {

            success();
        }
        failure:^(RKObjectRequestOperation* operation, NSError* error) {

            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)changePassword:(NSString*)password
                 phone:(NSString*)phone
               success:(void (^)())success
               failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    [self.class setupObjectManagerForRegistration];
    [self.class setupMappingsForRegistration];

    [self setPassword:password
                phone:phone
              success:success
              failure:failure];
}

// FIXME:(PRIM-234): Separate operation managers for registration and authorization.
- (void)authorizeWithUsername:(NSString*)username
                     password:(NSString*)password
                setupCoreData:(BOOL)setupCoreData
                      success:(void (^)(AFOAuthCredential* credential))success
                      failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    [self.class setupObjectManagerForAuthorization];

    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSAssert([manager.HTTPClient isKindOfClass:[AFOAuth2Client class]],
        @"manager.HTTPClient should be instance of AFOAuth2Client class!");

    AFOAuth2Client* oauthClient = (AFOAuth2Client*)[manager HTTPClient];

    void (^coreDataSetup)(void) = ^(void) {

#ifdef USE_COREDATA
        // Setup CoreData stack after Object Manager.
        [self.class setupCoreData:username];
#endif

    };

    id repeat = ^{
        [self authorizeWithUsername:username password:password setupCoreData:setupCoreData success:success failure:failure];
    };

    [oauthClient authenticateUsingOAuthWithPath:kAuthorizationPath
        username:username
        password:password
        scope:@"private"
        success:^(AFOAuthCredential* credential) {

            [oauthClient setAuthorizationHeaderWithToken:credential.accessToken];
            [[PRUserDefaultsManager sharedInstance] saveToken:credential.accessToken];

            if (setupCoreData) {
                coreDataSetup();
            } else {
                [[RKObjectManager sharedManager] setManagedObjectStore:[RKManagedObjectStore defaultStore]];
            }

            [self.class setupMappings];

            success(credential);
        }
        failure:^(NSError* error) {
            NSAssert([error isKindOfClass:[PRAuthError class]], @"Error should be instance of PRAuthError");
            PRAuthError* authError = (PRAuthError*)error;

            if (error.code == kCFURLErrorNotConnectedToInternet || error.code == kCFURLErrorInternationalRoamingOff || error.code == kCFURLErrorNetworkConnectionLost) {
                if (setupCoreData) {
                    coreDataSetup();
                } else {
                    [[RKObjectManager sharedManager] setManagedObjectStore:[RKManagedObjectStore defaultStore]];
                }
                [self.class setupMappings];
            } else if ([self.class getAFHTTPStatusCodeFromOperation:authError.operation] == 404) {
                // Retry to login.
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), repeat);
                return;
            }

            failure([self.class getAFHTTPStatusCodeFromOperation:authError.operation], error);
            NSLog(@"Error: %@", error);
        }];
}

- (void)refreshAccessToken:(NSString*)refreshToken
                   success:(void (^)(AFOAuthCredential* credential))success
                   failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSAssert([manager.HTTPClient isKindOfClass:[AFOAuth2Client class]],
        @"manager.HTTPClient should be instance of AFOAuth2Client class!");

    AFOAuth2Client* oauthClient = (AFOAuth2Client*)[manager HTTPClient];
    [oauthClient setAuthorizationHeaderWithUsername:kClientID password:kClientSecret];

    [oauthClient authenticateUsingOAuthWithPath:kAuthorizationPath
        refreshToken:refreshToken
        success:^(AFOAuthCredential* credential) {

            [oauthClient setAuthorizationHeaderWithToken:credential.accessToken];
            success(credential);
        }
        failure:^(NSError* error) {

            NSAssert([error isKindOfClass:[PRAuthError class]], @"Error should be instance of PRAuthError");
            PRAuthError* authError = (PRAuthError*)error;
            failure([self.class getAFHTTPStatusCodeFromOperation:authError.operation], error);
            NSLog(@"Error: %@", error);
        }];
}

- (void)logoutWithSuccess:(void (^)())success
                  failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];
	if (manager == nil) {
		[self.class setupObjectManagerForRegistration];
	}

    [manager getObjectsAtPath:kLogoutPath
        parameters:nil
        success:^(RKObjectRequestOperation* operation, RKMappingResult* mappingResult) {
            success();
        }
        failure:^(RKObjectRequestOperation* operation, NSError* error) {

            NSLog(@"Error: %@", [error localizedDescription]);

            NSInteger statusCode = [self.class getStatusCodeFromOperation:operation];

            if (statusCode == 200) {
                success();
            } else {
                failure(statusCode, error);
            }
        }];
}

- (void)generateTemporaryPasswordWithPhone:(NSString*)phone
                                  username:(NSString*)username
                                   success:(void (^)())success
                                   failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    [manager postObject:nil
        path:kGenerateTemporaryPasswordPath
        parameters:@{
            @"phone" : phone,
            @"username" : username
        }
        success:^(RKObjectRequestOperation* operation, RKMappingResult* mappingResult) {

            NSLog(@"Loaded objects: %@", [mappingResult array]);

            success();
        }
        failure:^(RKObjectRequestOperation* operation, NSError* error) {

            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

+ (void)reformatFileInfo:(NSObject*)object
              documentId:(NSNumber*)documentId
         withJPGFileName:(NSString*)JPGFileName
           withCreatedAt:(NSDate*)createdAt
{
    if (![object conformsToProtocol:@protocol(PRFileInfoInterface)]) {
        return;
    }
    id<PRFileInfoInterface> fileInfoModel = (id<PRFileInfoInterface>)object;

    BOOL modified = FALSE;

    // Set creation date if not exist.
    if (JPGFileName == nil) {
        JPGFileName = @"";
    }

    NSString* ISODateFromString = [NSString extractString:[fileInfoModel fileName]
                                                toLookFor:[JPGFileName stringByAppendingString:kFileDateSeparator]
                                        onlyStringBetween:YES
                                             toStopBefore:@".jpg"];
    if ([fileInfoModel createdAt] == nil) {
        if (ISODateFromString != nil) {
            [fileInfoModel setCreatedAt:[NSDate mt_dateFromISOString:ISODateFromString]];

            modified = TRUE;
        } else {
            [fileInfoModel setCreatedAt:createdAt];
        }
    }

    if (ISODateFromString != nil) {
        [fileInfoModel setFileName:[JPGFileName stringByAppendingString:@".jpg"]];
    }

    // Set documentId.
    if (documentId != nil) {
        [fileInfoModel setDocumentId:documentId];
        modified = TRUE;
    }

    if (!modified || ![fileInfoModel respondsToSelector:@selector(save)]) {
        return;
    }

    [fileInfoModel save];
}

- (void)uploadFile:(UIImage*)image
         createdAt:(NSDate*)createdAt
              path:(NSString*)path
        documentId:(NSNumber*)documentId
       JPGFileName:(NSString*)JPGFileName
           success:(void (^)(PRUploadFileInfoModel* imageInfo))success
           failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSDictionary* parameters = @{
        @"path" : (documentId == nil) ? path : [NSString stringWithFormat:@"%@/%@", path, documentId]
    };

    NSString* _path = RKPathFromPatternWithObject(
        kUploadFilePathWithParameters,
        parameters);

    NSString* fileName = [NSString stringWithFormat:@"%@%@%@.jpg",
                                   JPGFileName,
                                   kFileDateSeparator,
                                   [createdAt mt_stringFromDateWithISODateTime]];

    NSMutableURLRequest* request =
        [manager multipartFormRequestWithObject:nil
                                         method:RKRequestMethodPOST
                                           path:_path
                                     parameters:nil
                      constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {

                          [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 100)
                                                      name:@"file"
                                                  fileName:fileName
                                                  mimeType:@"image/jpg"];
                      }];

    RKObjectRequestOperation* operation =
        [[RKObjectManager sharedManager] managedObjectRequestOperationWithRequest:request
            managedObjectContext:[NSManagedObjectContext MR_defaultContext]
            success:^(RKObjectRequestOperation* operation, RKMappingResult* mappingResult) {

                NSArray* objects = [mappingResult array];

                NSLog(@"Loaded objects: %@", objects);

                NSObject* object = [objects firstObject];

                NSAssert([object isKindOfClass:[PRUploadFileInfoModel class]],
                    @"Object should be instance of PRUploadFileInfoModel class!");

                [self.class reformatFileInfo:object
                                  documentId:documentId
                             withJPGFileName:JPGFileName
                               withCreatedAt:createdAt];

                success((PRUploadFileInfoModel*)object);

            }
            failure:^(RKObjectRequestOperation* operation, NSError* error) {

                failure([self.class getStatusCodeFromOperation:operation], error);

            }];

    [[RKObjectManager sharedManager] enqueueObjectRequestOperation:operation];
}

- (void)listFilesAtPath:(NSString*)path
             documentId:(NSNumber*)documentId
                success:(void (^)(NSArray* filesInfo))success
                failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSDictionary* parameters = @{
        @"path" : (documentId == nil) ? path : [NSString stringWithFormat:@"%@/%@", path, documentId]
    };

    NSString* _path = RKPathFromPatternWithObject(
        kListFilesPathWithParameters,
        parameters);

    [manager getObjectsAtPath:_path
        parameters:nil
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {
            NSArray* objects = [mappingResult array];

            NSLog(@"Loaded objects: %@", objects);

            for (NSObject* object in objects) {
                [self.class reformatFileInfo:object
                                  documentId:documentId
                             withJPGFileName:kAvatarJpgFileName
                               withCreatedAt:nil];
            }

            success(objects);
        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)downloadFileByUID:(NSString*)uid
                  success:(void (^)(NSObject* object))success
                  failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSDictionary* parameters = @{
        @"uid" : uid
    };
    NSString* path = RKPathFromPatternWithObject(
        kDownloadFilePathPattern,
        parameters);

    NSMutableURLRequest* downloadRequest = [manager requestWithObject:nil
                                                               method:RKRequestMethodGET
                                                                 path:path
                                                           parameters:nil];

    AFHTTPRequestOperation* requestOperation =
        [[AFImageRequestOperation alloc] initWithRequest:downloadRequest];

    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation* operation, id responseObject) {

        success(responseObject);

    }
        failure:^(AFHTTPRequestOperation* operation, NSError* error) {

            failure([self.class getAFHTTPStatusCodeFromOperation:operation], error);

        }];

    [manager.HTTPClient enqueueHTTPRequestOperation:requestOperation];
}

- (void)downloadImageByUID:(NSString*)uid
                   success:(void (^)(UIImage* image))success
                   failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    [self downloadFileByUID:uid
                    success:^(NSObject* object) {

                        if ([object isKindOfClass:[UIImage class]]) {
                            success((UIImage*)object);
                        } else if ([object isKindOfClass:[NSData class]]) {
                            UIImage* image = [UIImage imageWithData:(NSData*)object];
                            success(image);
                        } else if (failure) {
                            failure(200, nil);
                        }
                    }

                    failure:failure];
}

- (void)downloadImageForDocumentByUID:(NSString*)uid
                              success:(void (^)(DocumentImage* image))success
                              failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    [self downloadImageByUID:uid
                     success:^(UIImage* image) {
                         DocumentImage* documentImage = [[DocumentImage alloc] initWithImage:image andUid:uid andState:@(DocumentImageStatus_Created)];
                         success(documentImage);
                     }
                     failure:failure];
}

- (void)downloadTaskDocumentByUID:(NSString*)uid
                          success:(void (^)(NSData* itemDocumentData))success
                          failure:(void (^)(NSInteger statusCode, NSError* error))failure
{

    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSDictionary* parameters = @{
        @"uid" : uid
    };
    NSString* path = RKPathFromPatternWithObject(
        kDownloadFilePathPattern,
        parameters);

    NSMutableURLRequest* downloadRequest = [manager requestWithObject:nil
                                                               method:RKRequestMethodGET
                                                                 path:path
                                                           parameters:nil];

    AFHTTPRequestOperation* requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:downloadRequest];

    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation* operation, id responseObject) {

        success((NSData*)responseObject);

    }
        failure:^(AFHTTPRequestOperation* operation, NSError* error) {

            failure([self.class getAFHTTPStatusCodeFromOperation:operation], error);

        }];

    [manager.HTTPClient enqueueHTTPRequestOperation:requestOperation];
}

- (void)uploadAvatar:(UIImage*)image
           createdAt:(NSDate*)createdAt
             success:(void (^)(PRUploadFileInfoModel* imageInfo))success
             failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    [self uploadFile:image
           createdAt:createdAt
                path:@"photo"
          documentId:nil
         JPGFileName:kAvatarJpgFileName
             success:success
             failure:failure];
}

- (void)uploadImageForDocument:(NSNumber*)documentId
                         image:(UIImage*)image
                     createdAt:(NSDate*)createdAt
                       success:(void (^)(PRUploadFileInfoModel* imageInfo))success
                       failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    [self uploadFile:image
           createdAt:createdAt
                path:@"documents"
          documentId:documentId
         JPGFileName:@"document"
             success:success
             failure:failure];
}

- (void)downloadAvatarByUID:(NSString*)uid
                    success:(void (^)(UIImage* image))success
                    failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    [self downloadImageByUID:uid
                     success:success
                     failure:failure];
}

- (void)deleteImageForDocumentByUID:(NSString*)uid
                            success:(void (^)())success
                            failure:(void (^)(NSInteger statuscode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSDictionary* parameters = @{
        @"uid" : uid
    };
    NSString* path = RKPathFromPatternWithObject(
        kDeleteFilePath,
        parameters);

    [manager getObjectsAtPath:path
        parameters:nil
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {

            NSLog(@"Loaded objects: %@", [mappingResult array]);

            success();
        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)listAvatarWithSuccess:(void (^)(NSArray* filesInfo))success
                      failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    [self listFilesAtPath:@"photo"
               documentId:nil
                  success:success
                  failure:failure];
}

- (void)listImagesForDocument:(NSNumber*)documentId
                      success:(void (^)(NSArray* filesInfo))success
                      failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    [self listFilesAtPath:@"documents"
               documentId:documentId
                  success:success
                  failure:failure];
}

- (void)getProfileWithLang:(NSString*)lang
                   success:(void (^)(PRUserProfileModel* userprofile))success
                   failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSDictionary* parameters = @{
        @"lang" : lang
    };

    [manager getObjectsAtPath:kUserProfilePath
        parameters:parameters
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {
            NSArray* objects = [mappingResult array];

            NSLog(@"Loaded objects: %@", objects);

            NSObject* object = [objects firstObject];

            NSAssert([object isKindOfClass:[PRUserProfileModel class]],
                @"Object should be instance of PRUserProfileModel class!");

            success((PRUserProfileModel*)object);
        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}
- (void)updateProfile:(PRUserProfileModel*)userprofile
                 lang:(NSString*)lang
              success:(void (^)())success
              failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    [manager putObject:userprofile
        path:kUserProfilePath
        parameters:nil
        success:^(RKObjectRequestOperation* operation, RKMappingResult* mappingResult) {

            NSLog(@"Loaded objects: %@", [mappingResult array]);

            success();

        }
        failure:^(RKObjectRequestOperation* operation, NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)getProfileFeaturesWithSuccess:(void (^)(NSArray<PRUserProfileFeaturesModel*>* profileFeatures))success
                              failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    [manager getObjectsAtPath:kUserProfileFeaturesPath
        parameters:nil
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {
            NSArray* objects = [mappingResult array];

            NSLog(@"Loaded objects: %@", objects);

            success(objects);
        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)getApplePayOrderInfoWithPaymentID:(NSString*)paymentID
                                  success:(void (^)(PRPaymentDataModel* paymentDataModel))success
                                  failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* oldManager = [RKObjectManager sharedManager];

    [self.class setupObjectManagerForApplePay];
    [self.class setupMappingsForApplePay];

    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSDictionary* parameters = @{
        @"uid" : paymentID
    };

    [manager getObjectsAtPath:kApplePayGetOrderPath
        parameters:parameters
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {
            NSArray* objects = [mappingResult array];

            NSLog(@"Loaded objects: %@", objects);

            NSObject* object = [objects firstObject];

            NSAssert([object isKindOfClass:[PRPaymentDataModel class]],
                @"Object should be instance of PRPaymentDataModel class!");

            success((PRPaymentDataModel*)object);
        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];

    [RKObjectManager setSharedManager:oldManager];
}

- (void)sendApplePayToken:(PRApplePayToken*)token
                  success:(void (^)(PRApplePayResponseModel* applePayResponseModel))success
                  failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* oldManager = [RKObjectManager sharedManager];

    [self.class setupObjectManagerForApplePay];
    [self.class setupMappingsForApplePay];

    RKObjectManager* manager = [RKObjectManager sharedManager];
    [manager setRequestSerializationMIMEType:RKMIMETypeJSON];

    [manager postObject:token
        path:kApplePaySendTokenPath
        parameters:nil
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {
            NSArray* objects = [mappingResult array];

            NSLog(@"Loaded objects: %@", objects);

            NSObject* object = [objects firstObject];

            NSAssert([object isKindOfClass:[PRApplePayResponseModel class]],
                @"Object should be instance of PRApplePayResponseModel class!");

            success((PRApplePayResponseModel*)object);
        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];

    [RKObjectManager setSharedManager:oldManager];
}

- (void)getDocumentsWithLang:(NSString*)lang
                     success:(void (^)(NSArray* documents))success
                     failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    [manager getObjectsAtPath:kDocumentsPath
        parameters:@{
            @"lang" : lang
        }
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {
            NSArray* objects = [mappingResult array];

            NSLog(@"Loaded objects: %@", objects);

            success(objects);
        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)getDocument:(NSNumber*)document
               lang:(NSString*)lang
            success:(void (^)(PRDocumentModel* document))success
            failure:(void (^)(NSInteger statusCode, NSError* error))failure
{

    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSDictionary* pathParams = @{
        @"documentId" : document,
    };

    NSString* path = RKPathFromPatternWithObject(
        kDocumentPathPattern,
        pathParams);

    [manager getObjectsAtPath:path
        parameters:@{
            @"lang" : lang
        }
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {
            NSArray* objects = [mappingResult array];

            NSLog(@"Loaded objects: %@", objects);

            success([objects firstObject]);
        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)deleteDocument:(PRDocumentModel*)document
               success:(void (^)(void))success
               failure:(void (^)(NSInteger statusCode, NSError* error))failure
{

    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSString* path = RKPathFromPatternWithObject(kDocumentPathPattern, document);

    [manager deleteObject:document
        path:path
        parameters:nil
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {

            NSArray* objects = [mappingResult array];

            NSLog(@"Loaded objects: %@", objects);

            success();

        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)updateDocument:(PRDocumentModel*)document
               success:(void (^)())success
               failure:(void (^)(NSInteger statusCode, NSError* error))failure
{

    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSNumber* documentId = document.documentId;
    MutableOrderedDictionary* parameters = [[MutableOrderedDictionary alloc] init];
    
    [parameters setObject:documentId
                   forKey:@"documentId"];
    
    NSString* path = RKPathFromPatternWithObject(kDocumentPathPattern, parameters);

    [manager putObject:document
        path:path
        parameters:nil
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {
            NSArray* objects = [mappingResult array];

            NSLog(@"Loaded objects: %@", objects);

            success();
        }
        failure:^(RKObjectRequestOperation* operation,
                  NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);
                
            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)linkDocument:(NSNumber*)documentId
          toDocument:(NSNumber*)toDocumentId
             success:(void (^)())success
             failure:(void (^)(NSInteger statusCode, NSError* error))failure
{

    RKObjectManager* manager = [RKObjectManager sharedManager];

    MutableOrderedDictionary* parameters = [[MutableOrderedDictionary alloc] init];

    [parameters setObject:documentId
                   forKey:@"documentId"];
    [parameters setObject:toDocumentId
                   forKey:@"passportId"];

    NSString* path = RKPathFromPatternWithObject(kDocumentLinkToDocumentPathPattern, parameters);

    [manager postObject:parameters
                  path:path
            parameters:nil
               success:^(RKObjectRequestOperation* operation,
                         RKMappingResult* mappingResult) {

                   success();
               }
               failure:^(RKObjectRequestOperation* operation,
                         NSError* error) {
                   NSLog(@"Error: %@", [error localizedDescription]);

                   failure([self.class getStatusCodeFromOperation:operation], error);
               }];
}

- (void)detachVisaFromPassportForDocument:(NSNumber*)documentId
                                     success:(void (^)())success
                                     failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    MutableOrderedDictionary* parameters = [[MutableOrderedDictionary alloc] init];

    [parameters setObject:documentId
                   forKey:@"documentId"];

    NSString* path = RKPathFromPatternWithObject(kDetachVisaForDocumentPathPattern, parameters);

    [manager postObject:parameters
                   path:path
             parameters:nil
                success:^(RKObjectRequestOperation* operation,
                          RKMappingResult* mappingResult) {

                    success();
                }
                failure:^(RKObjectRequestOperation* operation,
                          NSError* error) {
                    NSLog(@"Error: %@", [error localizedDescription]);

                    failure([self.class getStatusCodeFromOperation:operation], error);
                }];
}

- (void)linkDocument:(NSNumber*)documentId
          toDocument:(NSNumber*)toDocumentId
          forContact:(NSNumber*)contactId
             success:(void (^)())success
             failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    MutableOrderedDictionary* parameters = [[MutableOrderedDictionary alloc] init];

    [parameters setObject:contactId
                   forKey:@"contactId"];
    [parameters setObject:documentId
                   forKey:@"documentId"];
    [parameters setObject:toDocumentId
                   forKey:@"passportId"];

    NSString* path = RKPathFromPatternWithObject(kContactDocumentLinkDocumentPathPattern, parameters);

    [manager postObject:parameters
                   path:path
             parameters:nil
                success:^(RKObjectRequestOperation* operation,
                          RKMappingResult* mappingResult) {
                    NSArray* objects = [mappingResult array];

                    NSLog(@"Loaded objects: %@", objects);

                    success();
                }
                failure:^(RKObjectRequestOperation* operation,
                          NSError* error) {
                    NSLog(@"Error: %@", [error localizedDescription]);

                    failure([self.class getStatusCodeFromOperation:operation], error);
                }];
}

- (void)detachVisaFromPassportForContactDocument:(NSNumber*)contactId
                                         documentId:(NSNumber*)documentId
                                            success:(void (^)())success
                                            failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    MutableOrderedDictionary* parameters = [[MutableOrderedDictionary alloc] init];

    [parameters setObject:contactId
                   forKey:@"contactId"];
    [parameters setObject:documentId
                   forKey:@"documentId"];

    NSString* path = RKPathFromPatternWithObject(kDetachVisaForContactDocumentPathPattern, parameters);

    [manager postObject:parameters
                   path:path
             parameters:nil
                success:^(RKObjectRequestOperation* operation,
                          RKMappingResult* mappingResult) {
                    NSArray* objects = [mappingResult array];

                    NSLog(@"Loaded objects: %@", objects);

                    success();
                }
                failure:^(RKObjectRequestOperation* operation,
                          NSError* error) {
                    NSLog(@"Error: %@", [error localizedDescription]);

                    failure([self.class getStatusCodeFromOperation:operation], error);
                }];
}

- (void)createDocument:(PRDocumentModel*)document
               success:(void (^)())success
               failure:(void (^)(NSInteger statusCode, NSError* error))failure
{

    RKObjectManager* manager = [RKObjectManager sharedManager];

    [manager postObject:document
        path:kDocumentsPath
        parameters:nil
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {
            NSArray* objects = [mappingResult array];

            NSLog(@"Loaded objects: %@", objects);

            success();
        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)getTasksTypesWithSuccess:(void (^)(NSArray* types))success
                         failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    [manager getObjectsAtPath:kTaskTypesPath
        parameters:nil
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {
            NSArray* objects = [mappingResult array];

            NSLog(@"Loaded objects: %@", objects);

            success(objects);
        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)getTasksWithLang:(NSString*)lang
                 success:(void (^)(/*NSArray *tasks*/))success
                 failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    [manager getObjectsAtPath:kTasksPath
        parameters:nil
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {
            NSArray* objects = [mappingResult array];

            // Deletes messages which will have not any associate task.
            [PRDatabase deleteInvalidMessagesWithoutAssociatedTask];

            NSLog(@"Loaded objects: %@", objects);

            success(objects);
        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)getTaskWithId:(NSNumber*)taskId
                 lang:(NSString*)lang
              success:(void (^)(PRTaskDetailModel* task))success
              failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    NSDictionary* pathParams = @{
        @"taskId" : taskId
    };

    NSDictionary* parameters = @{
        @"lang" : lang
    };

    NSString* path = RKPathFromPatternWithObject(
        kTasksDetailPathPattern,
        pathParams);

    RKObjectManager* manager = [RKObjectManager sharedManager];

    [manager getObjectsAtPath:path
        parameters:parameters
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {
            NSArray* objects = [mappingResult array];

            NSLog(@"Loaded objects: %@", objects);

            NSObject* object = [objects firstObject];

            NSAssert([object isKindOfClass:[PRTaskDetailModel class]],
                @"Object should be instance of PRTaskDetailModel class!");

            success((PRTaskDetailModel*)object);

        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)getMessagesForChannelId:(NSString*)channelId
                           guid:(NSString*)guid
                          limit:(NSNumber*)limit
                         toDate:(NSNumber*)toDate
                       fromDate:(NSNumber*)fromDate
                        success:(void (^)(NSArray<PRMessageModel*>* messages))success
                        failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* oldManager = [RKObjectManager sharedManager];

    [self.class setupObjectManagerForChatRequests];
    [self.class setupMappingsForChatRequests];

    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSString* accessToken = [XNTKeychainStore accessToken];
    NSNumber* timeStamp = @((long)[[NSDate new] timeIntervalSince1970]);

    MutableOrderedDictionary* parameters = [[MutableOrderedDictionary alloc] init];

    [parameters setObject:accessToken
                   forKey:@"access_token"];

    if(channelId)
    {
        [parameters setObject:channelId
                       forKey:@"channelId"];
    }

    [parameters setObject:timeStamp
                   forKey:@"t"];
    [parameters setObject:kClientID
                   forKey:@"X-Client-Id"];
    [parameters setObject:[self.class getUniqueDeviceIdentifierAsString]
                   forKey:@"X-Device-Id"];

    if (guid) {
        [parameters setObject:guid
                       forKey:@"guid"];
    }

    if (limit) {
        [parameters setObject:[NSString stringWithFormat:@"%ld", (long)[limit integerValue]]
                       forKey:@"limit"];
    }

    if (toDate) {
        [parameters setObject:toDate
                       forKey:@"to"];
    }

    if (fromDate) {
        [parameters setObject:fromDate
                       forKey:@"from"];
    }

    [manager getObjectsAtPath:kMessages
        parameters:parameters
        success:^(RKObjectRequestOperation* operation, RKMappingResult* mappingResult) {
            success((NSArray<PRMessageModel*>*)mappingResult.array);
        }
        failure:^(RKObjectRequestOperation* operation, NSError* error) {
            failure([self.class getStatusCodeFromOperation:operation], error);
        }];

    [RKObjectManager setSharedManager:oldManager];
}

- (void)getSubscriptions:(void (^)(NSArray<PRSubscriptionModel*>* subscription))success
             failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* oldManager = [RKObjectManager sharedManager];

    [self.class setupObjectManagerForChatRequests];
    [self.class setupMappingsForSubscriptions];

    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSString* accessToken = [XNTKeychainStore accessToken];

    MutableOrderedDictionary* parameters = [[MutableOrderedDictionary alloc] init];

    [parameters setObject:accessToken
                   forKey:@"access_token"];

    [manager getObjectsAtPath:kSubscriptions
                   parameters:parameters
                      success:^(RKObjectRequestOperation* operation, RKMappingResult* mappingResult) {
                          NSArray* objects = [mappingResult array];

                          NSLog(@"Loaded objects: %@", objects);

                          success(objects);
                      }
                      failure:^(RKObjectRequestOperation* operation, NSError* error) {
                          failure([self.class getStatusCodeFromOperation:operation], error);
                      }];

    [RKObjectManager setSharedManager:oldManager];
}

- (void)updateMessageStatus:(PRMessageStatusModel*)statusUpdate
                    success:(void (^)())success
                    failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    if (!statusUpdate.guid || !statusUpdate.status) {
//        NSAssert(false, @"'guid' and 'status' properties should not be nil.");
        return;
    }

    RKObjectManager* oldManager = [RKObjectManager sharedManager];

    [self.class setupObjectManagerForChatRequests];
    [self.class setupMappingsForChatRequests];

    RKObjectManager* manager = [RKObjectManager sharedManager];
    NSString* accessToken = [XNTKeychainStore accessToken];

    NSString* path = [NSString stringWithFormat:kMessageStatusUpdatePath, accessToken, statusUpdate.guid, statusUpdate.status, kClientID, [self.class getUniqueDeviceIdentifierAsString]];

    [manager putObject:nil
        path:path
        parameters:nil
        success:^(RKObjectRequestOperation* operation, RKMappingResult* mappingResult) {
            success();
        }
        failure:^(RKObjectRequestOperation* operation, NSError* error) {
            failure([self.class getStatusCodeFromOperation:operation], error);
        }];

    [RKObjectManager setSharedManager:oldManager];
}

- (void)sendMessage:(PRMessageModel*)message
            success:(void (^)())success
            failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* oldManager = [RKObjectManager sharedManager];

    [self.class setupObjectManagerForChatRequests];
    [self.class setupMappingsForChatRequests];

    RKObjectManager* manager = [RKObjectManager sharedManager];

    // Any object that we will attach to the request (sending to the web service,
    // in other words) will be serialized into a JSON string.
    [manager setRequestSerializationMIMEType:RKMIMETypeJSON];

    NSString* accessToken = [XNTKeychainStore accessToken];
    NSNumber* timeStamp = @((long)[[NSDate new] timeIntervalSince1970]);

    NSString* path = [NSString stringWithFormat:kMessageSendPath, accessToken, timeStamp, kClientID, [self.class getUniqueDeviceIdentifierAsString]];

    [manager postObject:message
        path:path
        parameters:nil
        success:^(RKObjectRequestOperation* operation, RKMappingResult* mappingResult) {
            success();
        }
        failure:^(RKObjectRequestOperation* operation, NSError* error) {
            failure([self.class getStatusCodeFromOperation:operation], error);
        }];

    [RKObjectManager setSharedManager:oldManager];
}

- (void)sendMessageFromReplyAction:(PRMessageModel*)message
                           success:(void (^)())success
                           failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    NSString* accessToken = [XNTKeychainStore accessToken];
    NSNumber* timeStamp = @((long)[[NSDate new] timeIntervalSince1970]);
    NSString* path = [NSString stringWithFormat:kMessageSendPath, accessToken, timeStamp, kClientID, [self.class getUniqueDeviceIdentifierAsString]];

	NSString *kChatBaseUrl = [NSString stringWithFormat:@"%@/chat-server/v3_1/", Config.chatEndpoint];
    NSMutableString* messagesUrl = [[NSMutableString alloc] initWithString:kChatBaseUrl];
    [messagesUrl appendString:path];
    NSURL* url = [NSURL URLWithString:messagesUrl];
    NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];

    NSMutableDictionary* messageDictonary = [NSMutableDictionary new];

    [messageDictonary setValue:message.senderName forKey:kSenderName];
    [messageDictonary setValue:message.clientId forKey:kClientId];
    [messageDictonary setValue:message.guid forKey:kGuidKey];
    [messageDictonary setValue:message.source forKey:kSource];
    [messageDictonary setValue:message.type forKey:kTypeKey];
    [messageDictonary setValue:message.ttl forKey:kTimeToLive];
    [messageDictonary setValue:message.timestamp forKey:kTimestamp];
    [messageDictonary setValue:message.status forKey:kStatus];
    [messageDictonary setValue:message.updatedAt forKey:kUpdatedAt];
    [messageDictonary setValue:message.text forKey:kContent];
    [messageDictonary setValue:message.channelId forKey:kChannelId];

    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:messageDictonary options:0 error:nil];
    NSString* jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];

    NSData* requestData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
    [urlRequest setHTTPMethod:@"POST"];
    NSString* authorizationValue = [NSString stringWithFormat:@"Bearer %@", accessToken];
    [urlRequest setValue:authorizationValue forHTTPHeaderField:@"Authorization"];
    [urlRequest setValue:RKMIMETypeJSON forHTTPHeaderField:@"Content-Type"];
    urlRequest.HTTPBody = requestData;

    NSURLSessionDataTask* messagePostTask = [[NSURLSession sharedSession] dataTaskWithRequest:urlRequest
                                                                            completionHandler:^(NSData* data,
                                                                                NSURLResponse* response,
                                                                                NSError* error) {
                                                                                NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                                                                                if (httpResponse.statusCode == kStatusCodeSuccess) {

                                                                                    success();

                                                                                } else {

                                                                                    failure(httpResponse.statusCode, error);
                                                                                }
                                                                            }];

    [messagePostTask resume];
}

- (void)sendAudioFile:(NSData*)message
              success:(void (^)(PRVoiceMessageModel* voiceMessageModel))success
              failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* oldManager = [RKObjectManager sharedManager];

    [self.class setupObjectManagerForVoiceMessage];
    [self.class setupMappingsForVoiceMessage];

    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSMutableURLRequest* request =
        [manager multipartFormRequestWithObject:nil
                                         method:RKRequestMethodPOST
                                           path:kVoiceMessageUploadPath
                                     parameters:nil
                      constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                          [formData appendPartWithFileData:message
                                                      name:@"file"
                                                  fileName:@"audio"
                                                  mimeType:@"audio/mp4"];
                      }];

    RKObjectRequestOperation* operation =
        [manager managedObjectRequestOperationWithRequest:request
            managedObjectContext:[NSManagedObjectContext MR_defaultContext]
            success:^(RKObjectRequestOperation* operation, RKMappingResult* mappingResult) {
                if ([[mappingResult array] count]) {
                    PRVoiceMessageModel* model = [[mappingResult array] firstObject];
                    success(model);
                }
            }
            failure:^(RKObjectRequestOperation* operation, NSError* error) {
                failure([self.class getStatusCodeFromOperation:operation], error);
            }];

    [manager enqueueObjectRequestOperation:operation];

    [RKObjectManager setSharedManager:oldManager];
}

- (void)sendMediaFileContent:(NSData*)message
                        uuid:(NSString*)uuid
                    mimeType:(NSString*)mimeType
                     success:(void (^)(PRMediaMessageModel* mediaMessageModel))success
                     failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* oldManager = [RKObjectManager sharedManager];

    [self.class setupObjectManagerForVoiceMessage];
    [self.class setupMappingsForMediaMessageHeader];

    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSDictionary* pathParams = @{
                                 @"uuid" : uuid
                                 };

    NSString* path = RKPathFromPatternWithObject(kAsyncUploadPathWithParameter, pathParams);

    NSString *fileName = @"media";
    NSArray *mimeTypeParts = [mimeType componentsSeparatedByString:@"/"];
    if([mimeTypeParts count] == 1)
    {
        fileName = mimeType;
        mimeType = @"";
    }
    NSMutableURLRequest* request =
    [manager multipartFormRequestWithObject:nil
                                     method:RKRequestMethodPOST
                                       path:path
                                 parameters:nil
                  constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                      [formData appendPartWithFileData:message
                                                  name:@"file"
                                              fileName:fileName
                                              mimeType:mimeType];
                  }];

    RKObjectRequestOperation* operation =
    [manager managedObjectRequestOperationWithRequest:request
                                 managedObjectContext:[NSManagedObjectContext MR_defaultContext]
                                              success:^(RKObjectRequestOperation* operation, RKMappingResult* mappingResult) {
                                                  if ([[mappingResult array] count]) {
                                                      PRMediaMessageModel* model = [[mappingResult array] firstObject];
                                                      success(model);
                                                  }
                                              }
                                              failure:^(RKObjectRequestOperation* operation, NSError* error) {
                                                  failure([self.class getStatusCodeFromOperation:operation], error);
                                              }];

    [manager enqueueObjectRequestOperation:operation];

    [RKObjectManager setSharedManager:oldManager];
}

- (void)sendMediaFileHeader:(NSData*)message
                   mimeType:(NSString*)mimeType
                    success:(void (^)(PRMediaMessageModel* mediaMessageModel))success
                    failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* oldManager = [RKObjectManager sharedManager];

    [self.class setupObjectManagerForVoiceMessage];
    [self.class setupMappingsForMediaMessageHeader];

    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSDictionary<NSString*, NSString*>* dictionary = @{
                                                       @"file" : @"mediafile"
                                                       };
    NSMutableURLRequest* request =
    [manager requestWithObject:nil
                        method:RKRequestMethodPOST
                          path:kAsyncUploadPath
                    parameters:dictionary];

    RKObjectRequestOperation* operation =
    [manager managedObjectRequestOperationWithRequest:request
                                 managedObjectContext:[NSManagedObjectContext MR_defaultContext]
                                              success:^(RKObjectRequestOperation* operation, RKMappingResult* mappingResult) {

                                                  if ([[mappingResult array] count]) {
                                                      PRMediaMessageModel* model = [[mappingResult array] firstObject];
                                                      [[NSNotificationCenter defaultCenter] postNotificationName:kSendUUIDKey object:nil userInfo:@{@"uuid": model.uuid}];
                                                      [self sendMediaFileContent:message
                                                                            uuid:model.uuid
                                                                        mimeType:mimeType
                                                                         success:^(PRMediaMessageModel* mediaMessageModel) {
                                                                             success(mediaMessageModel);
                                                                         }
                                                                         failure:^(NSInteger statusCode, NSError* error) {
                                                                             failure([self.class getStatusCodeFromOperation:operation], error);
                                                                         }];
                                                  }
                                              }
                                              failure:^(RKObjectRequestOperation* operation, NSError* error) {
                                                  failure([self.class getStatusCodeFromOperation:operation], error);
                                              }];

    [manager enqueueObjectRequestOperation:operation];

    [RKObjectManager setSharedManager:oldManager];
}

- (void)getMediaUploadStatus:(NSString*)uuid
                     success:(void (^)(NSNumber* percent))success
                     failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* oldManager = [RKObjectManager sharedManager];

    [self.class setupObjectManagerForVoiceMessage];
    [self.class setupMappingsForMediaMessageHeader];

    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSDictionary* pathParams = @{
                                 @"uuid" : uuid
                                 };

    NSString* path = RKPathFromPatternWithObject(kAsyncUploadPathWithParameter, pathParams);

    NSMutableURLRequest* request =
    [manager requestWithObject:nil
                        method:RKRequestMethodGET
                          path:path
                    parameters:nil];

    RKObjectRequestOperation* operation =
    [manager managedObjectRequestOperationWithRequest:request
                                 managedObjectContext:[NSManagedObjectContext MR_defaultContext]
                                              success:^(RKObjectRequestOperation* operation, RKMappingResult* mappingResult) {
                                                  if ([[mappingResult array] count]) {
                                                      PRUploadMediaFileProgressInfoModel* model = [[mappingResult array] firstObject];
                                                      if(model.state)
                                                      {
                                                          if([model.state isEqualToString:@"TRANSFER_COMPLETED_EVENT"])
                                                          {
                                                              success([NSNumber numberWithInteger:100]);
                                                          }
                                                      }
                                                      success(model.percentTransfered);
                                                  }
                                              }
                                              failure:^(RKObjectRequestOperation* operation, NSError* error) {
                                                  failure([self.class getStatusCodeFromOperation:operation], error);
                                              }];

    [manager enqueueObjectRequestOperation:operation];

    [RKObjectManager setSharedManager:oldManager];
}

- (void)getMediaInfoWithUUID:(NSString *)uuid
                     success:(void (^)(NSData *))success
                     failure:(void (^)(NSInteger, NSError *))failure
{
    RKObjectManager* oldManager = [RKObjectManager sharedManager];

    [self.class setupObjectManagerForVoiceMessage];
    [self.class setupMappingsForMediaFileInfo];

    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSDictionary* pathParams = @{
                                 @"uuid" : uuid
                                 };

    NSString* path = RKPathFromPatternWithObject(kMediaFileInfoPathWithParameter, pathParams);

    NSMutableURLRequest* request =
    [manager requestWithObject:nil
                        method:RKRequestMethodGET
                          path:path
                    parameters:nil];

    RKObjectRequestOperation* operation =
    [manager managedObjectRequestOperationWithRequest:request
                                 managedObjectContext:[NSManagedObjectContext MR_defaultContext]
                                              success:^(RKObjectRequestOperation* operation, RKMappingResult* mappingResult) {
                                                  if ([[mappingResult array] count]) {
                                                      PRMediaFileInfoModel* model = [[mappingResult array] firstObject];
                                                      NSString *fileExtension = @"";
                                                      NSArray *fileNameSeperated = [model.name componentsSeparatedByString:@"."];
                                                      if([fileNameSeperated count] > 1)
                                                      {
                                                          fileExtension = [fileNameSeperated lastObject];
                                                      }
                                                      NSDictionary *documentInfo = @{kDocumentMessageFileNameKey: model.name,
                                                                                     kDocumentMessageFileSizeKey: [NSString stringWithFormat:@"%ld", model.size],
                                                                                     kDocumentMessageFileExtensionKey: fileExtension
                                                                                     };
                                                      NSData *documentInfoData = [NSKeyedArchiver archivedDataWithRootObject:documentInfo];
                                                      success(documentInfoData);
                                                  }
                                              }
                                              failure:^(RKObjectRequestOperation* operation, NSError* error) {
                                                  failure([self.class getStatusCodeFromOperation:operation], error);
                                              }];

    [manager enqueueObjectRequestOperation:operation];

    [RKObjectManager setSharedManager:oldManager];
}

- (void)getAudioFileFromPath:(NSString*)path
                     success:(void (^)(NSData* audioFile))success
                     failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    if (!path) {
        return;
    }

    RKObjectManager* oldManager = [RKObjectManager sharedManager];

    [self.class setupObjectManagerForVoiceMessage];
    [self.class setupMappingsForVoiceMessage];

    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSString* tmpPath = RKPathFromPatternWithObject(
        kAudioFileGetPath,
        @{
           @"path" : [path stringByReplacingOccurrencesOfString:@"chat." withString:@""],
        });

    NSMutableURLRequest* downloadRequest = [manager requestWithObject:nil
                                                               method:RKRequestMethodGET
                                                                 path:tmpPath
                                                           parameters:nil];

    AFHTTPRequestOperation* requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:downloadRequest];

    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation* operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSData class]]) {
            success((NSData*)responseObject);
        } else {
        }
    }
        failure:^(AFHTTPRequestOperation* operation, NSError* error) {

            failure([self.class getAFHTTPStatusCodeFromOperation:operation], error);

        }];

    [manager.HTTPClient enqueueHTTPRequestOperation:requestOperation];

    [RKObjectManager setSharedManager:oldManager];
}

- (void)getActionsWithTaskId:(NSNumber*)taskId
                        lang:(NSString*)lang
                     success:(void (^)(NSOrderedSet* actions))success
                     failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    NSDictionary* parameters = @{
        @"lang" : lang
    };

    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSArray* tasks = [PRTaskDetailModel MR_findByAttribute:@"taskId" withValue:taskId];

    if ([tasks count]) {
        PRTaskDetailModel* model = [tasks firstObject];
        [manager getObject:model
            path:nil
            parameters:parameters
            success:^(RKObjectRequestOperation* operation,
                RKMappingResult* mappingResult) {
                NSArray* objects = [mappingResult array];

                NSLog(@"Loaded objects: %@", objects);

                PRTaskDetailModel* object = [objects firstObject];

                NSAssert([object isKindOfClass:[PRTaskDetailModel class]],
                    @"Object should be instance of PRTaskDetailModel class!");

                success(object.actions);
            }
            failure:^(RKObjectRequestOperation* operation,
                NSError* error) {
                NSLog(@"Error: %@", [error localizedDescription]);

                failure([self.class getStatusCodeFromOperation:operation], error);
            }];
    }
}

- (void)sendFeedbackWithText:(PRFeedbackModel*)feedback
                     success:(void (^)())success
                     failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    NSString* encodedText = [feedback.comment stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSDictionary* pathParams = @{
        @"objectId" : feedback.objectId,
        @"stars" : feedback.stars,
        @"objectType" : feedback.objectType,
        @"comment" : encodedText
    };

    RKObjectManager* manager = [RKObjectManager sharedManager];

    [manager postObject:feedback
        path:kFeedbackPath
        parameters:pathParams
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {

            NSLog(@"Loaded objects: %@", [mappingResult array]);

            success();
        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)cancelTask:(NSNumber*)taskId
           success:(void (^)())success
           failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    NSDictionary* pathParams = @{
        @"taskId" : taskId,
    };

    NSString* path = RKPathFromPatternWithObject(
        kCancelTaskPathPattern,
        pathParams);

    RKObjectManager* manager = [RKObjectManager sharedManager];

    [manager postObject:nil
        path:path
        parameters:nil
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {

            NSLog(@"Loaded objects: %@", [mappingResult array]);

            success();
        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

+ (NSString*)eventsPathFromYear:(NSString*)year
                          month:(NSString*)month
                     deltaMonth:(NSInteger)deltaMonth
{
    NSDate* date = [NSDate mt_dateFromYear:[year integerValue]
                                     month:[month integerValue] + deltaMonth
                                       day:1];

    NSDictionary* pathParams = @{
        @"year" : [date mt_stringFromDateWithFormat:@"YYYY" localized:NO],
        @"month" : [date mt_stringFromDateWithFormat:@"MM" localized:NO]
    };

    return RKPathFromPatternWithObject(
        kGetEventsByYearMonthPathPattern,
        pathParams);
}

+ (NSString*)pathFromYear:(NSString*)year
                    month:(NSString*)month
                  pattern:(NSString*)pattern
               deltaMonth:(NSInteger)deltaMonth
{
    NSDate* date = [NSDate mt_dateFromYear:[year integerValue]
                                     month:[month integerValue] + deltaMonth
                                       day:1];

    NSDictionary* pathParams = @{
        @"year" : [date mt_stringFromDateWithFormat:@"YYYY" localized:NO],
        @"month" : [date mt_stringFromDateWithFormat:@"MM" localized:NO]
    };

    return RKPathFromPatternWithObject(
        pattern,
        pathParams);
}

- (NSMutableArray*)operationsForPathPattern:(NSString*)path
                                   withYear:(NSString*)year
                                  withMonth:(NSString*)month
                                 monthCount:(NSInteger)count
                                    andLang:(NSString*)lang
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSDictionary* parameters = @{
        @"lang" : lang
    };

    NSMutableArray* array = [NSMutableArray arrayWithCapacity:count];

    for (int i = 0; i < count; i++) {
        RKObjectRequestOperation* operation =
            [manager appropriateObjectRequestOperationWithObject:nil
                                                          method:RKRequestMethodGET
                                                            path:[self.class pathFromYear:year month:month pattern:path deltaMonth:-(i)]
                                                      parameters:parameters];

        [array addObject:operation];
    }

    return array;
}

- (void)getBalanceWithYear:(NSString*)year
         startingWithMonth:(NSString*)month
                monthCount:(NSInteger)count
                      lang:(NSString*)lang
                   success:(void (^)(NSArray* balances))success
                   failure:(void (^)(NSInteger statusCode, NSError* error))failure
{

    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSArray* operations = [self operationsForPathPattern:kBalancePathPattern
                                                withYear:year
                                               withMonth:month
                                              monthCount:count
                                                 andLang:lang];

    [manager enqueueBatchOfObjectRequestOperations:operations
        progress:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
            NSLog(@"Progress: %lu of %lu", (unsigned long)numberOfFinishedOperations, (unsigned long)totalNumberOfOperations);
        }
        completion:^(NSArray* operations) {

            NSMutableArray* result = [NSMutableArray array];

            for (RKObjectRequestOperation* operation in operations) {
                NSInteger statusCode = [self.class getStatusCodeFromOperation:operation];

                if (statusCode < 200 || statusCode > 299) {
                    NSError* error = [self.class getNSErrorFromOperation:operation];

                    failure(statusCode, error);
                    return;
                }

                NSString* pattern = [NSString stringWithFormat:@"/%@/%@", BASE_URL_ROOT, [kBalancePathPattern substringToIndex:[kBalancePathPattern length] - 1]];
                RKPathMatcher* pathMatcher = [RKPathMatcher pathMatcherWithPattern:pattern];

                // Dictionary to store request arguments.
                NSDictionary* argsDict = nil;

                // Match the URL with pathMatcher and retrieve arguments.
                BOOL match = [pathMatcher matchesPath:operation.HTTPRequestOperation.response.URL.relativePath
                                 tokenizeQueryStrings:NO
                                      parsedArguments:&argsDict];

                // If url matched, create NSFetchRequest.
                if (match) {
                    NSString* year = argsDict[@"year"];
                    NSString* month = argsDict[@"month"];
                    [result addObjectsFromArray:operation.mappingResult.array];

                    for (PRBalanceModel* balance in operation.mappingResult.array) {

                        balance.year = year;
                        balance.month = month;

                        [balance save];
                    }
                    NSLog(@"month: %@", month);
                    NSLog(@"count: %lu", (unsigned long)operation.mappingResult.array.count);
                }
            }

            operations = [self operationsForPathPattern:kExchangePathPattern
                                               withYear:year
                                              withMonth:month
                                             monthCount:count
                                                andLang:lang];

            [manager enqueueBatchOfObjectRequestOperations:operations
                progress:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {

                }
                completion:^(NSArray* operations) {

                    for (RKObjectRequestOperation* operation in operations) {
                        NSInteger statusCode = [self.class getStatusCodeFromOperation:operation];

                        if (statusCode < 200 || statusCode > 299) {
                            NSError* error = [self.class getNSErrorFromOperation:operation];

                            failure(statusCode, error);
                            return;
                        }
                    }

                    success(result);
                }];
        }];
}

- (void)addEvent
{
    //TODO: !!!
}

- (void)deleteEventWithId:(NSNumber*)eventId
{
    //TODO: !!!
}

- (void)getDiscountsWithLang:(NSString*)lang
                     success:(void (^)(NSArray* discounts))success
                     failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    [manager getObjectsAtPath:kDiscountsPath
        parameters:@{
            @"lang" : lang
        }
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {
            NSArray* objects = [mappingResult array];

            NSLog(@"Loaded objects: %@", objects);

            success(objects);
        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)getDiscountTypesWithLang:(NSString*)lang
                         success:(void (^)(NSArray* discounts))success
                         failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    [manager getObjectsAtPath:kDiscountTypePath
        parameters:@{
            @"lang" : lang
        }
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {
            NSArray* objects = [mappingResult array];

            NSLog(@"Loaded objects: %@", objects);

            success(objects);
        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)getDocumentTypesWithLang:(NSString*)lang
                         success:(void (^)(NSArray* discounts))success
                         failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    [manager getObjectsAtPath:kDocumentTypesPath
                   parameters:@{
                                @"lang" : lang
                                }
                      success:^(RKObjectRequestOperation* operation,
                                RKMappingResult* mappingResult) {
                          NSArray* objects = [mappingResult array];

                          NSLog(@"Loaded objects: %@", objects);

                          success(objects);
                      }
                      failure:^(RKObjectRequestOperation* operation,
                                NSError* error) {
                          NSLog(@"Error: %@", [error localizedDescription]);

                          failure([self.class getStatusCodeFromOperation:operation], error);
                      }];
}

- (void)createDiscount:(PRLoyalCardModel*)cardModel
                  lang:(NSString*)lang
               success:(void (^)())success
               failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];

    [parameters setObject:cardModel.cardNumber
                   forKey:@"cardNumber"];

    if (cardModel.issueDate) {
        [parameters setObject:cardModel.issueDate
                       forKey:@"issueDate"];
    }

    if (cardModel.expiryDate) {
        [parameters setObject:cardModel.expiryDate
                       forKey:@"expiryDate"];
    }

    if (cardModel.cardDescription) {
        [parameters setObject:cardModel.cardDescription
                       forKey:@"description"];
    }

    if (cardModel.type.typeId) {
        [parameters setObject:@{ @"id" : cardModel.type.typeId }
                       forKey:@"type"];
    }

    [manager postObject:cardModel
        path:kDiscountsPath
        parameters:parameters
        success:^(RKObjectRequestOperation* operation, RKMappingResult* mappingResult) {

            NSArray* objects = [mappingResult array];

            NSLog(@"Loaded objects: %@", objects);

            success(objects);

        }
        failure:^(RKObjectRequestOperation* operation, NSError* error) {

            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)getDiscountWithId:(NSNumber*)discountId
                     lang:(NSString*)lang
                  success:(void (^)(PRLoyalCardModel* discount))success
                  failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSDictionary* parameters = @{
        @"discountId" : discountId
    };
    NSString* path = RKPathFromPatternWithObject(
        kDiscountPathPattern,
        parameters);

    [manager getObjectsAtPath:path
        parameters:@{
            @"lang" : lang
        }
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {
            PRLoyalCardModel* object = [[mappingResult array] firstObject];

            NSLog(@"Loaded objects: %@", object);

            success(object);
        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)updateDiscount:(PRLoyalCardModel*)cardModel
                  lang:(NSString*)lang
               success:(void (^)(PRLoyalCardModel* discount))success
               failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSString* path = RKPathFromPatternWithObject(
        kDiscountPathPattern,
        @{
            @"discountId" : cardModel.cardId
        });

    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];

    [parameters setObject:cardModel.cardNumber
                   forKey:@"cardNumber"];

    if (cardModel.issueDate) {
        [parameters setObject:cardModel.issueDate
                       forKey:@"issueDate"];
    }

    if (cardModel.expiryDate) {
        [parameters setObject:cardModel.expiryDate
                       forKey:@"expiryDate"];
    }

    if (cardModel.cardDescription) {
        [parameters setObject:cardModel.cardDescription
                       forKey:@"description"];
    }

    if (cardModel.type.typeId) {
        [parameters setObject:@{ @"id" : cardModel.type.typeId }
                       forKey:@"type"];
    }

    [manager putObject:cardModel
        path:path
        parameters:parameters
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {

            PRLoyalCardModel* objects = [[mappingResult array] firstObject];

            NSLog(@"Loaded objects: %@", objects);

            NSLog(@"Loaded objects: %@", objects);

            success(objects);
        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)deleteDiscountWithId:(PRLoyalCardModel*)discount
                        lang:(NSString*)lang
                     success:(void (^)())success
                     failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSDictionary* parameters = @{
        @"discountId" : discount.cardId
    };
    NSString* path = RKPathFromPatternWithObject(
        kDiscountPathPattern,
        parameters);

    [manager deleteObject:discount
        path:path
        parameters:nil
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {
            PRLoyalCardModel* objects = [[mappingResult array] firstObject];

            NSLog(@"Loaded objects: %@", objects);

            success();
        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)getBalanceWithYear:(NSString*)year
                     month:(NSString*)month
                      lang:(NSString*)lang
                   success:(void (^)(NSArray* balances))success
                   failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    NSDictionary* pathParams = @{
        @"year" : year,
        @"month" : month
    };

    NSDictionary* parameters = @{
        @"lang" : lang
    };

    NSString* path = RKPathFromPatternWithObject(
        kBalancePathPattern,
        pathParams);

    RKObjectManager* manager = [RKObjectManager sharedManager];

    [manager getObjectsAtPath:path
        parameters:parameters
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {

            NSArray* objects = [mappingResult array];

            NSLog(@"Loaded objects: %@", objects);

            for (PRBalanceModel* balance in objects) {

                balance.year = year;
                balance.month = month;

                [balance save];
            }

            success(objects);
        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)getExchangeWithYear:(NSString*)year
                      month:(NSString*)month
                       lang:(NSString*)lang
                    success:(void (^)(NSArray* events))success
                    failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    NSDictionary* pathParams = @{
        @"year" : year,
        @"month" : month
    };

    NSDictionary* parameters = @{
        @"lang" : lang
    };

    NSString* path = RKPathFromPatternWithObject(
        kExchangePathPattern,
        pathParams);

    RKObjectManager* manager = [RKObjectManager sharedManager];

    [manager getObjectsAtPath:path
        parameters:parameters
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {

            NSArray* objects = [mappingResult array];

            NSLog(@"Loaded objects: %@", objects);

            success(objects);
        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)callBack:(NSString*)phoneNumber
         success:(void (^)())success
         failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    MutableOrderedDictionary* parameters = [[MutableOrderedDictionary alloc] init];

    // Do not change the order !!!
    [parameters setObject:kClientID
                   forKey:@"client_id"];
    [parameters setObject:[self.class getUniqueDeviceIdentifierAsString]
                   forKey:@"device_id"];
    [parameters setObject:phoneNumber
                   forKey:@"phone"];
    [parameters setObject:[self.class signParametersWithDictionary:parameters]
                   forKey:@"signature"];

    [manager postObject:nil
        path:kCallbackPath
        parameters:parameters
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {

            NSLog(@"Loaded objects: %@", [mappingResult array]);

            success();
        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)getSelfPhonesForProfileWithSuccess:(void (^)(NSArray<PRProfilePhoneModel*>* object))success
                                   failure:(void (^)(NSInteger statusCode, NSError* error))failure

{
    RKObjectManager* manager = [RKObjectManager sharedManager];
    [manager getObjectsAtPath:kPhonesPath
        parameters:nil
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {

            NSArray<PRProfilePhoneModel*>* objects = [mappingResult array];

            NSLog(@"Loaded objects: %@", objects);

            success(objects);
        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)getSelfEmailsForProfileWithSuccess:(void (^)(NSArray<PRProfileEmailModel*>* object))success
                                   failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];
    [manager getObjectsAtPath:kEmailsPath
        parameters:nil
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {

            NSArray<PRProfileEmailModel*>* objects = [mappingResult array];
            NSLog(@"Loaded objects: %@", objects);

            success(objects);
        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)getSelfContactsForProfileWithSuccess:(void (^)(NSArray<PRProfileContactModel*>* object))success
                                     failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];
    [manager getObjectsAtPath:kContactsPath
        parameters:@{ @"fields" : @"emails,phones" }
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {

            NSArray<PRProfileContactModel*>* objects = [mappingResult array];
            NSLog(@"Loaded objects: %@", objects);

            success(objects);
        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)getServicesWithLongitude:(NSNumber*)longitude
                        latitude:(NSNumber*)latitude
                        datetime:(NSString*)datetime
                         success:(void (^)(NSArray<PRServicesModel*>* object))success
                         failure:(void (^)(NSInteger statusCode, NSError* error))failure
{

    NSDictionary* parameters = @{
        @"longitude" : longitude,
        @"latitude" : latitude,
        @"datetime" : datetime
    };

    RKObjectManager* manager = [RKObjectManager sharedManager];
    [manager getObjectsAtPath:kServicesPath
        parameters:parameters
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {

            NSArray<PRServicesModel*>* objects = [mappingResult array];
            NSLog(@"Loaded objects: %@", objects);

            success(objects);
        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)getProfileContactPhonesWithContactId:(NSNumber*)contactId
                                        view:(UIView*)view
                                     success:(void (^)(NSArray<PRProfileContactPhoneModel*>* object))success
                                     failure:(void (^)(NSInteger statusCode, NSError* error))failure;
{
    NSDictionary* parameters = @{
        @"contactId" : contactId
    };
    NSString* path = RKPathFromPatternWithObject(
        kContactPhonesPath,
        parameters);
    RKObjectManager* manager = [RKObjectManager sharedManager];
    [manager getObjectsAtPath:path
        parameters:parameters
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {

            NSArray<PRProfileContactPhoneModel*>* objects = [mappingResult array];
            NSLog(@"Loaded objects: %@", objects);

            success(objects);
        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)getProfileContactDocumentsWithContactId:(NSNumber*)contactId
                                           view:(UIView*)view
                                        success:(void (^)(NSArray<PRProfileContactDocumentModel*>* object))success
                                        failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    NSDictionary* parameters = @{
        @"contactId" : contactId
    };
    NSString* path = RKPathFromPatternWithObject(
        kContactDocumentsPath,
        parameters);
    RKObjectManager* manager = [RKObjectManager sharedManager];
    [manager getObjectsAtPath:path
        parameters:parameters
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {

            NSArray<PRProfileContactDocumentModel*>* objects = [mappingResult array];
            NSLog(@"Loaded objects: %@", objects);

            success(objects);
        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)getProfileContactDocumentWithContactId:(NSNumber*)contactId
                                    documentId:(NSNumber*)documentId
                                           view:(UIView*)view
                                        success:(void (^)(NSArray<PRProfileContactDocumentModel*>* object))success
                                        failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    MutableOrderedDictionary* parameters = [[MutableOrderedDictionary alloc] init];
    [parameters setObject:contactId forKey:@"contactId"];
    [parameters setObject:documentId forKey:@"documentId"];

    NSString* path = RKPathFromPatternWithObject(kContactDocumentModifyPath,parameters);

    RKObjectManager* manager = [RKObjectManager sharedManager];
    [manager getObjectsAtPath:path parameters:parameters success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSArray<PRProfileContactDocumentModel*>* objects = [mappingResult array];
        NSLog(@"Loaded objects: %@", objects);

        success(objects);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);

        failure([self.class getStatusCodeFromOperation:operation], error);
    }];
}

- (void)getProfileContactEmailsWithContactId:(NSNumber*)contactId
                                        view:(UIView*)view
                                     success:(void (^)(NSArray<PRProfileContactEmailModel*>* object))success
                                     failure:(void (^)(NSInteger statusCode, NSError* error))failure;
{
    NSDictionary* parameters = @{
        @"contactId" : contactId
    };
    NSString* path = RKPathFromPatternWithObject(
        kContactEmailsPath,
        parameters);
    RKObjectManager* manager = [RKObjectManager sharedManager];
    [manager getObjectsAtPath:path
        parameters:parameters
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {

            NSArray<PRProfileContactEmailModel*>* objects = [mappingResult array];
            NSLog(@"Loaded objects: %@", objects);

            success(objects);
        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)getProfilePhoneTypesWithSuccess:(void (^)(NSArray<PRPhoneTypeModel*>* object))success
                                failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];
    [manager getObjectsAtPath:kPhoneTypesPath
        parameters:nil
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {

            NSArray<PRPhoneTypeModel*>* objects = [mappingResult array];
            NSLog(@"Loaded objects: %@", objects);

            success(objects);
        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)getProfileEmailTypesWithSuccess:(void (^)(NSArray<PREmailTypeModel*>* object))success
                                failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];
    [manager getObjectsAtPath:kEmailTypesPath
        parameters:nil
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {

            NSArray<PREmailTypeModel*>* objects = [mappingResult array];
            NSLog(@"Loaded objects: %@", objects);

            success(objects);
        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)getProfileContactTypesWithSuccess:(void (^)(NSArray<PRContactTypeModel*>* object))success
                                  failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];
    [manager getObjectsAtPath:kContactTypesPath
        parameters:nil
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {

            NSArray<PRContactTypeModel*>* objects = [mappingResult array];
            NSLog(@"Loaded objects: %@", objects);

            success(objects);
        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)getCarsForProfileWithSuccess:(void (^)(NSArray<PRCarModel*>* object))success
                             failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    [manager getObjectsAtPath:kCarPath
        parameters:nil
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {

            PRCarModelResponse* carModelsResponse = [[mappingResult array] firstObject];
            NSLog(@"Loaded objects: %@", carModelsResponse.data);

            success([carModelsResponse.data array]);
        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)addPhoneForProfile:(PRProfilePhoneModel*)phoneModel
                   success:(void (^)())success
                   failure:(void (^)(NSInteger statusCode, NSError* error))failure

{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    [manager postObject:phoneModel
        path:kPhonesPath
        parameters:nil
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {
            NSArray<PRProfilePhoneModel*>* objects = [mappingResult array];

            PRProfilePhoneModel* model = [objects firstObject];
            [model setState:@(ModelStatus_Synched)];
            [model save];

            success();
        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)addEmailForProfile:(PRProfileEmailModel*)emailModel
                   success:(void (^)())success
                   failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    [manager postObject:emailModel
        path:kEmailsPath
        parameters:nil
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {
            NSArray* objects = [mappingResult array];

            PRProfileEmailModel* model = [objects firstObject];
            [model setState:@(ModelStatus_Synched)];
            [model save];

            success();
        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)addContactForProfile:(PRProfileContactModel*)contactModel
                     success:(void (^)(PRProfileContactModel*))success
                     failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    [manager postObject:contactModel
        path:kContactsPath
        parameters:nil
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {
            NSArray* objects = [mappingResult array];

            PRProfileContactModel* model = [[mappingResult array] firstObject];
            [model setState:@(ModelStatus_Synched)];
            [model save];

            success([objects firstObject]);
        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)addContactPhone:(PRProfileContactPhoneModel*)phoneModel
          withContactId:(NSNumber*)contactId
                success:(void (^)())success
                failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSDictionary* parameters = @{
        @"contactId" : contactId
    };

    NSString* path = RKPathFromPatternWithObject(kContactPhonesPath, parameters);

    [manager postObject:phoneModel
        path:path
        parameters:nil
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {
            NSArray* objects = [mappingResult array];

            PRProfileContactPhoneModel* model = [objects firstObject];
            [model setState:@(ModelStatus_Synched)];
            [model save];

            success();
        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)addContactDocument:(PRProfileContactDocumentModel*)documentModel
             withContactId:(NSNumber*)contactId
                   success:(void (^)())success
                   failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSDictionary* parameters = @{
        @"contactId" : contactId
    };

    NSString* path = RKPathFromPatternWithObject(kContactDocumentsPath, parameters);

    [manager postObject:documentModel
        path:path
        parameters:nil
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {
            NSArray* objects = [mappingResult array];

            PRProfileContactDocumentModel* model = [objects firstObject];
            [model setState:@(ModelStatus_Synched)];
            [model save];

            success();
        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)addContactEmail:(PRProfileContactEmailModel*)emailModel
          withContactId:(NSNumber*)contactId
                success:(void (^)())success
                failure:(void (^)(NSInteger statusCode, NSError* error))failure;
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSDictionary* parameters = @{
        @"contactId" : contactId
    };

    NSString* path = RKPathFromPatternWithObject(kContactEmailsPath, parameters);

    [manager postObject:emailModel
        path:path
        parameters:nil
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {
            NSArray* objects = [mappingResult array];

            PRProfileContactEmailModel* model = [objects firstObject];
            [model setState:@(ModelStatus_Synched)];
            [model save];

            success();
        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)addCarForProfile:(PRCarModel*)carModel
                 success:(void (^)())success
                 failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    [manager postObject:carModel
        path:kCarPath
        parameters:nil
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {
            NSArray* objects = [mappingResult array];

            PRCarModel* model = [objects firstObject];
            [model setState:@(ModelStatus_Synched)];
            [model save];

            success();
        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)updateProfilePhone:(PRProfilePhoneModel*)phoneModel
                   success:(void (^)())success
                   failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];
    NSDictionary* parameters = @{
        @"phoneId" : phoneModel.phoneId
    };

    NSString* path = RKPathFromPatternWithObject(kPhonesModifyPath, parameters);

    [manager putObject:phoneModel
        path:path
        parameters:nil
        success:^(RKObjectRequestOperation* operation, RKMappingResult* mappingResult) {

            NSLog(@"Loaded objects: %@", [mappingResult array]);

            PRProfilePhoneModel* model = [[mappingResult array] firstObject];
            [model setState:@(ModelStatus_Synched)];
            [model save];

            success();

        }
        failure:^(RKObjectRequestOperation* operation, NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)updateProfileEmail:(PRProfileEmailModel*)emailModel
                   success:(void (^)())success
                   failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSDictionary* parameters = @{
        @"emailId" : emailModel.emailId
    };

    NSString* path = RKPathFromPatternWithObject(kEmailsModifyPath, parameters);

    [manager putObject:emailModel
        path:path
        parameters:nil
        success:^(RKObjectRequestOperation* operation, RKMappingResult* mappingResult) {

            PRProfileEmailModel* model = [[mappingResult array] firstObject];
            [model setState:@(ModelStatus_Synched)];
            [model save];

            success();

        }
        failure:^(RKObjectRequestOperation* operation, NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)updateProfileContact:(PRProfileContactModel*)contactModel
                     success:(void (^)())success
                     failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSDictionary* parameters = @{
        @"contactId" : contactModel.contactId
    };

    NSString* path = RKPathFromPatternWithObject(kContactsModifyPath, parameters);

    [manager putObject:contactModel
        path:path
        parameters:nil
        success:^(RKObjectRequestOperation* operation, RKMappingResult* mappingResult) {

            PRProfileContactModel* model = [[mappingResult array] firstObject];
            [model setState:@(ModelStatus_Synched)];
            [model save];

            success();

        }
        failure:^(RKObjectRequestOperation* operation, NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)updateProfileContactPhone:(PRProfileContactPhoneModel*)phoneModel
                    withContactId:(NSNumber*)contactId
                          phoneId:(NSString*)phoneId
                          success:(void (^)())success
                          failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSDictionary* parameters = @{
        @"contactId" : contactId,
        @"phoneId" : phoneId
    };

    NSString* path = RKPathFromPatternWithObject(kContactPhoneModifyPath, parameters);

    [manager putObject:phoneModel
        path:path
        parameters:nil
        success:^(RKObjectRequestOperation* operation, RKMappingResult* mappingResult) {

            PRProfileContactPhoneModel* model = [[mappingResult array] firstObject];

            model.state = @(ModelStatus_Synched);
            [model save];

            success();

        }
        failure:^(RKObjectRequestOperation* operation, NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)updateProfileContactDocument:(PRProfileContactDocumentModel*)documentModel
                       withContactId:(NSNumber*)contactId
                          documentId:(NSNumber*)documentId
                             success:(void (^)())success
                             failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSDictionary* parameters = @{
        @"contactId" : contactId,
        @"documentId" : documentId
    };

    NSString* path = RKPathFromPatternWithObject(kContactDocumentModifyPath, parameters);

    [manager putObject:documentModel
        path:path
        parameters:nil
        success:^(RKObjectRequestOperation* operation, RKMappingResult* mappingResult) {

            PRProfileContactDocumentModel* model = [[mappingResult array] firstObject];

            model.state = @(ModelStatus_Synched);
            [model save];

            success();

        }
        failure:^(RKObjectRequestOperation* operation, NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)updateProfileContactEmail:(PRProfileContactEmailModel*)emailModel
                    withContactId:(NSNumber*)contactId
                          emailId:(NSString*)emailId
                          success:(void (^)())success
                          failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSDictionary* parameters = @{
        @"contactId" : contactId,
        @"emailId" : emailId
    };

    NSString* path = RKPathFromPatternWithObject(kContactEmailModifyPath, parameters);

    [manager putObject:emailModel
        path:path
        parameters:parameters
        success:^(RKObjectRequestOperation* operation, RKMappingResult* mappingResult) {

            PRProfileContactEmailModel* model = [[mappingResult array] firstObject];
            [model setState:@(ModelStatus_Synched)];
            [model save];

            success();

        }
        failure:^(RKObjectRequestOperation* operation, NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)updateCarForProfile:(PRCarModel*)carModel
                    success:(void (^)())success
                    failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSDictionary* parameters = @{
        @"carId" : carModel.carId
    };

    NSString* path = RKPathFromPatternWithObject(kCarModifyPath, parameters);

    [manager putObject:carModel
        path:path
        parameters:nil
        success:^(RKObjectRequestOperation* operation, RKMappingResult* mappingResult) {

            PRCarModel* model = [[mappingResult array] firstObject];
            [model setState:@(ModelStatus_Synched)];
            [model save];

            success();

        }
        failure:^(RKObjectRequestOperation* operation, NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)deleteProfilePhoneWithPhoneId:(NSString*)phoneId
                              success:(void (^)())success
                              failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSDictionary* parameters = @{
        @"phoneId" : phoneId
    };
    NSString* path = RKPathFromPatternWithObject(
        kPhonesModifyPath,
        parameters);

    [manager deleteObject:nil
        path:path
        parameters:nil
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {

            NSArray* objects = [mappingResult array];

            NSLog(@"Loaded objects: %@", objects);

            success();

        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)deleteProfileEmailWithEmailId:(NSString*)emailId
                              success:(void (^)())success
                              failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSDictionary* parameters = @{
        @"emailId" : emailId
    };

    NSString* path = RKPathFromPatternWithObject(
        kEmailsModifyPath,
        parameters);

    [manager deleteObject:nil
        path:path
        parameters:nil
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {

            NSArray* objects = [mappingResult array];

            NSLog(@"Loaded objects: %@", objects);

            success();

        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)deleteProfileContactWithContactId:(NSNumber*)contactId
                                  success:(void (^)())success
                                  failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSDictionary* parameters = @{
        @"contactId" : contactId
    };

    NSString* path = RKPathFromPatternWithObject(
        kContactsModifyPath,
        parameters);

    [manager deleteObject:nil
        path:path
        parameters:nil
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {

            NSArray* objects = [mappingResult array];

            NSLog(@"Loaded objects: %@", objects);

            success();

        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)deleteProfileContactPhoneWithContactId:(NSNumber*)contactId
                                       phoneId:(NSString*)phoneId
                                       success:(void (^)())success
                                       failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSDictionary* parameters = @{
        @"contactId" : contactId,
        @"phoneId" : phoneId
    };

    NSString* path = RKPathFromPatternWithObject(
        kContactPhoneModifyPath,
        parameters);

    [manager deleteObject:nil
        path:path
        parameters:nil
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {

            NSArray* objects = [mappingResult array];

            NSLog(@"Loaded objects: %@", objects);

            success();

        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)deleteProfileContactDocumentWithContactId:(NSNumber*)contactId
                                       documentId:(NSNumber*)documentId
                                          success:(void (^)())success
                                          failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSDictionary* parameters = @{
        @"contactId" : contactId,
        @"documentId" : documentId
    };

    NSString* path = RKPathFromPatternWithObject(
        kContactDocumentModifyPath,
        parameters);

    [manager deleteObject:nil
        path:path
        parameters:nil
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {

            NSArray* objects = [mappingResult array];

            NSLog(@"Loaded objects: %@", objects);

            success();

        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)deleteProfileContactEmailWithContactId:(NSNumber*)contactId
                                       emailId:(NSString*)emailId
                                       success:(void (^)())success
                                       failure:(void (^)(NSInteger statusCode, NSError* error))failure
{

    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSDictionary* parameters = @{
        @"contactId" : contactId,
        @"emailId" : emailId
    };

    NSString* path = RKPathFromPatternWithObject(
        kContactEmailModifyPath,
        parameters);

    [manager deleteObject:nil
        path:path
        parameters:nil
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {

            NSArray* objects = [mappingResult array];

            NSLog(@"Loaded objects: %@", objects);

            success();

        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)deleteProfileCarWithCarId:(NSNumber*)carId
                          success:(void (^)())success
                          failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSDictionary* parameters = @{
        @"carId" : carId
    };

    NSString* path = RKPathFromPatternWithObject(
        kCarModifyPath,
        parameters);

    [manager deleteObject:nil
        path:path
        parameters:nil
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {

            NSArray* objects = [mappingResult array];

            NSLog(@"Loaded objects: %@", objects);

            success();

        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

- (void)deleteAccount:(void (^)())success
              failure:(void (^)(NSInteger, NSError *))failure
{
    RKObjectManager* manager = [RKObjectManager sharedManager];

    [manager deleteObject:nil
        path:kUserProfilePath
        parameters:nil
        success:^(RKObjectRequestOperation* operation,
            RKMappingResult* mappingResult) {

            NSArray* objects = [mappingResult array];

            NSLog(@"Loaded objects: %@", objects);

            success();
        }
        failure:^(RKObjectRequestOperation* operation,
            NSError* error) {
            NSLog(@"Error: %@", [error localizedDescription]);

            failure([self.class getStatusCodeFromOperation:operation], error);
        }];
}

@end

