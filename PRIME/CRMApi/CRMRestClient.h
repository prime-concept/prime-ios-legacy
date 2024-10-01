//
//  CRMRestClient.h
//  PRIME
//
//  Created by Simon on 13/01/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#ifndef PRIME_CRMRestClient_h
#define PRIME_CRMRestClient_h

#import "DocumentImage.h"
#import "PRDocumentModel.h"
#import "PRFeedbackModel.h"
#import "PRProfileContactEmailModel.h"
#import "PRProfileContactModel.h"
#import "PRProfileContactPhoneModel.h"
#import "PRProfileContactDocumentModel.h"
#import "PRProfileEmailModel.h"
#import "PRMessageStatusModel.h"
#import "PRProfilePhoneModel.h"
#import "PRServicesModel.h"
#import "PRTaskDetailModel.h"
#import "PRMessageModel.h"
#import "PRVoiceMessageModel.h"
#import "PRMediaMessageModel.h"
#import "PRUploadFIleInfoModel.h"
#import "PRUserProfileFeaturesModel.h"
#import "PRUserProfileModel.h"
#import "PRPaymentDataModel.h"
#import "PRApplePayResponseModel.h"
#import "PRApplePayToken.h"
#import "PRCarModel.h"
#import "PRSubscriptionModel.h"

@class PRLoyalCardModel;

#import "AFOAuth2Client+BasicAuthentication.h"

@interface CRMRestClient : NSObject

+ (NSString*)getUniqueDeviceIdentifierAsString;

+ (CRMRestClient*)sharedClient;

+ (void)cleanupCoreDataAndSetupForPhone:(NSString*)phone;

- (void)registerFCMToken:(NSString*)token
                 success:(void (^)())success
                 failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)registerMobileWithPhone:(NSString*)phone
                        success:(void (^)())success
                        failure:(void (^)(NSInteger statusCode, NSError* error))failure;
- (void)verifyCardNumber:(NSString*)cardNumber
                 success:(void (^)())success
                 failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)registerUserProfile:(NSDictionary*)userParameters
                    success:(void (^)())success
                    failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)verifyWithPhone:(NSString*)phone
                   code:(NSString*)code
                success:(void (^)())success
                failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)loginWithRequest:(NSString*)loginRequest
                 success:(void (^)())success
                 failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)setPassword:(NSString*)password
              phone:(NSString*)phone
            success:(void (^)())success
            failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)changePassword:(NSString*)password
                 phone:(NSString*)phone
               success:(void (^)())success
               failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)authorizeWithUsername:(NSString*)username
                     password:(NSString*)password
                setupCoreData:(BOOL)setupCoreData
                      success:(void (^)(AFOAuthCredential* credential))success
                      failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)refreshAccessToken:(NSString*)refreshToken
                   success:(void (^)(AFOAuthCredential* credential))success
                   failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)logoutWithSuccess:(void (^)())success
                  failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)generateTemporaryPasswordWithPhone:(NSString*)phone
                                  username:(NSString*)username
                                   success:(void (^)())success
                                   failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)getProfileWithLang:(NSString*)lang
                   success:(void (^)(PRUserProfileModel* userprofile))success
                   failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)getProfileFeaturesWithSuccess:(void (^)(NSArray<PRUserProfileFeaturesModel*>* profileFeatures))success
                              failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)getApplePayOrderInfoWithPaymentID:(NSString*)paymentID
                                  success:(void (^)(PRPaymentDataModel* paymentDataModel))success
                                  failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)sendApplePayToken:(PRApplePayToken*)token
                  success:(void (^)(PRApplePayResponseModel* applePayResponseModel))success
                  failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)getDocumentsWithLang:(NSString*)lang
                     success:(void (^)(NSArray* documents))success
                     failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)getDocument:(NSNumber*)document
               lang:(NSString*)lang
            success:(void (^)(PRDocumentModel* document))success
            failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)deleteDocument:(PRDocumentModel*)document
               success:(void (^)(void))success
               failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)updateDocument:(PRDocumentModel*)document
               success:(void (^)())success
               failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)createDocument:(PRDocumentModel*)document
               success:(void (^)())success
               failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)getTasksTypesWithSuccess:(void (^)(NSArray* types))success
                         failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)getTasksWithLang:(NSString*)lang
                 success:(void (^)())success
                 failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)getTaskWithId:(NSNumber*)taskId
                 lang:(NSString*)lang
              success:(void (^)(PRTaskDetailModel* task))success
              failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)getActionsWithTaskId:(NSNumber*)taskId
                        lang:(NSString*)lang
                     success:(void (^)(NSOrderedSet* actions))success
                     failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)sendFeedbackWithText:(PRFeedbackModel*)feedback
                     success:(void (^)())success
                     failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)cancelTask:(NSNumber*)taskId
           success:(void (^)())success
           failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)getBalanceWithYear:(NSString*)year
         startingWithMonth:(NSString*)month
                monthCount:(NSInteger)count
                      lang:(NSString*)lang
                   success:(void (^)(NSArray* balances))success
                   failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)addEvent;

- (void)deleteEventWithId:(NSNumber*)eventId;

- (void)updateProfile:(PRUserProfileModel*)userprofile
                 lang:(NSString*)lang
              success:(void (^)())success
              failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)uploadAvatar:(UIImage*)image
           createdAt:(NSDate*)createdAt
             success:(void (^)(PRUploadFileInfoModel* imageInfo))success
             failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)downloadAvatarByUID:(NSString*)uid
                    success:(void (^)(UIImage* image))success
                    failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)listAvatarWithSuccess:(void (^)(NSArray* filesInfo))success
                      failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)uploadImageForDocument:(NSNumber*)documentId
                         image:(UIImage*)image
                     createdAt:(NSDate*)createdAt
                       success:(void (^)(PRUploadFileInfoModel* imageInfo))success
                       failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)downloadImageForDocumentByUID:(NSString*)uid
                              success:(void (^)(DocumentImage* image))success
                              failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)downloadTaskDocumentByUID:(NSString*)uid
                          success:(void (^)(NSData* itemDocumentData))success
                          failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)deleteImageForDocumentByUID:(NSString*)uid
                            success:(void (^)())success
                            failure:(void (^)(NSInteger statuscode, NSError* error))failure;

- (void)listImagesForDocument:(NSNumber*)documentId
                      success:(void (^)(NSArray* filesInfo))success
                      failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)getDiscountsWithLang:(NSString*)lang
                     success:(void (^)(NSArray* discounts))success
                     failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)getDiscountTypesWithLang:(NSString*)lang
                         success:(void (^)(NSArray* discountTypes))success
                         failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)getDocumentTypesWithLang:(NSString*)lang
                         success:(void (^)(NSArray* documentTypes))success
                         failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)createDiscount:(PRLoyalCardModel*)cardModel
                  lang:(NSString*)lang
               success:(void (^)())success
               failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)getDiscountWithId:(NSNumber*)discountId
                     lang:(NSString*)lang
                  success:(void (^)(PRLoyalCardModel* discount))success
                  failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)updateDiscount:(PRLoyalCardModel*)cardModel
                  lang:(NSString*)lang
               success:(void (^)(PRLoyalCardModel* discount))success
               failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)deleteDiscountWithId:(PRLoyalCardModel*)discount
                        lang:(NSString*)lang
                     success:(void (^)())success
                     failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)getBalanceWithYear:(NSString*)year
                     month:(NSString*)month
                      lang:(NSString*)lang
                   success:(void (^)(NSArray* events))success
                   failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)getExchangeWithYear:(NSString*)year
                      month:(NSString*)month
                       lang:(NSString*)lang
                    success:(void (^)(NSArray* events))success
                    failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)callBack:(NSString*)phoneNumber
         success:(void (^)())success
         failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)getSelfPhonesForProfileWithSuccess:(void (^)(NSArray<PRProfilePhoneModel*>* object))success
                                   failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)getSelfEmailsForProfileWithSuccess:(void (^)(NSArray<PRProfileEmailModel*>* object))success
                                   failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)getSelfContactsForProfileWithSuccess:(void (^)(NSArray<PRProfileContactModel*>* object))success
                                     failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)getProfileContactPhonesWithContactId:(NSNumber*)contactId view:(UIView*)view success:(void (^)(NSArray<PRProfileContactPhoneModel*>* object))success
                                     failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)getProfileContactDocumentsWithContactId:(NSNumber*)contactId view:(UIView*)view success:(void (^)(NSArray<PRProfileContactDocumentModel*>* object))success
                                        failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)getProfileContactEmailsWithContactId:(NSNumber*)contactId view:(UIView*)view success:(void (^)(NSArray<PRProfileContactEmailModel*>* object))success
                                     failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)getProfilePhoneTypesWithSuccess:(void (^)(NSArray<PRPhoneTypeModel*>* object))success
                                failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)getProfileEmailTypesWithSuccess:(void (^)(NSArray<PREmailTypeModel*>* object))success
                                failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)getProfileContactTypesWithSuccess:(void (^)(NSArray<PRContactTypeModel*>* object))success
                                  failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)getCarsForProfileWithSuccess:(void (^)(NSArray<PRCarModel*>* object))success
                             failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)getMessagesForChannelId:(NSString*)channelId
                           guid:(NSString*)guid
                          limit:(NSNumber*)limit
                         toDate:(NSNumber*)toDate
                       fromDate:(NSNumber*)fromDate
                        success:(void (^)(NSArray<PRMessageModel*>* messages))success
                        failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)getSubscriptions:(void (^)(NSArray<PRSubscriptionModel*>* subscriptions))success
                 failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)updateMessageStatus:(PRMessageStatusModel*)statusUpdate
                    success:(void (^)())success
                    failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)sendMessage:(PRMessageModel*)message
            success:(void (^)())success
            failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)sendMessageFromReplyAction:(PRMessageModel*)message
                           success:(void (^)())success
                           failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)sendAudioFile:(NSData*)message
              success:(void (^)(PRVoiceMessageModel* voiceMessageModel))success
              failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)sendMediaFileHeader:(NSData*)message
                   mimeType:(NSString*)mimeType
                    success:(void (^)(PRMediaMessageModel* mediaMessageModel))success
                    failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)getMediaUploadStatus:(NSString*)uuid
                     success:(void (^)(NSNumber* percent))success
                     failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)getMediaInfoWithUUID:(NSString*)uuid
                        success:(void (^)(NSData* documentInfoData))success
                        failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)getAudioFileFromPath:(NSString*)path
                     success:(void (^)(NSData* audioFile))success
                     failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)getServicesWithLongitude:(NSNumber*)longitude
                        latitude:(NSNumber*)latitude
                        datetime:(NSString*)datetime
                         success:(void (^)(NSArray<PRServicesModel*>* object))success
                         failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)addPhoneForProfile:(PRProfilePhoneModel*)phoneModel
                   success:(void (^)())success
                   failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)addEmailForProfile:(PRProfileEmailModel*)emailModel
                   success:(void (^)())success
                   failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)addContactForProfile:(PRProfileContactModel*)contactModel
                     success:(void (^)(PRProfileContactModel*))success
                     failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)addContactPhone:(PRProfileContactPhoneModel*)phoneModel
          withContactId:(NSNumber*)contactId
                success:(void (^)())success
                failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)addContactDocument:(PRProfileContactDocumentModel*)documentModel
             withContactId:(NSNumber*)contactId
                   success:(void (^)())success
                   failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)addContactEmail:(PRProfileContactEmailModel*)emailModel
          withContactId:(NSNumber*)contactId
                success:(void (^)())success
                failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)addCarForProfile:(PRCarModel*)carModel
                 success:(void (^)())success
                 failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)updateProfilePhone:(PRProfilePhoneModel*)phoneModel
                   success:(void (^)())success
                   failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)updateProfileEmail:(PRProfileEmailModel*)emailModel
                   success:(void (^)())success
                   failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)updateProfileContact:(PRProfileContactModel*)contactModel
                     success:(void (^)())success
                     failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)updateProfileContactPhone:(PRProfileContactPhoneModel*)phoneModel
                    withContactId:(NSNumber*)contactId
                          phoneId:(NSString*)phoneId
                          success:(void (^)())success
                          failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)updateProfileContactDocument:(PRProfileContactDocumentModel*)documentModel
                       withContactId:(NSNumber*)contactId
                          documentId:(NSNumber*)documentId
                             success:(void (^)())success
                             failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)updateProfileContactEmail:(PRProfileContactEmailModel*)emailModel
                    withContactId:(NSNumber*)contactId
                          emailId:(NSString*)emailId
                          success:(void (^)())success
                          failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)updateCarForProfile:(PRCarModel*)carModel
                    success:(void (^)())success
                    failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)deleteProfilePhoneWithPhoneId:(NSString*)phoneId
                              success:(void (^)())success
                              failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)deleteProfileEmailWithEmailId:(NSString*)emailId
                              success:(void (^)())success
                              failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)deleteProfileContactWithContactId:(NSNumber*)contactId
                                  success:(void (^)())success
                                  failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)deleteProfileContactPhoneWithContactId:(NSNumber*)contactId
                                       phoneId:(NSString*)phoneId
                                       success:(void (^)())success
                                       failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)deleteProfileContactDocumentWithContactId:(NSNumber*)contactId
                                       documentId:(NSNumber*)documentId
                                          success:(void (^)())success
                                          failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)deleteProfileContactEmailWithContactId:(NSNumber*)contactId
                                       emailId:(NSString*)emailId
                                       success:(void (^)())success
                                       failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)deleteProfileCarWithCarId:(NSNumber*)carId
                          success:(void (^)())success
                          failure:(void (^)(NSInteger statusCode, NSError* error))failure;

+ (void)setupCoreData:(NSString*)username;

- (void)linkDocument:(NSNumber*)documentId
          toDocument:(NSNumber*)toDocumentId
             success:(void (^)())success
             failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)linkDocument:(NSNumber*)documentId
          toDocument:(NSNumber*)toDocumentId
          forContact:(NSNumber*)contactId
             success:(void (^)())success
             failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)detachVisaFromPassportForContactDocument:(NSNumber*)contactId
                                         documentId:(NSNumber*)documentId
                                            success:(void (^)())success
                                            failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)detachVisaFromPassportForDocument:(NSNumber*)documentId
                                     success:(void (^)())success
                                     failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)getProfileContactDocumentWithContactId:(NSNumber*)contactId
                                    documentId:(NSNumber*)documentId
                                          view:(UIView*)view
                                       success:(void (^)(NSArray<PRProfileContactDocumentModel*>* object))success
                                       failure:(void (^)(NSInteger statusCode, NSError* error))failure;

- (void)deleteAccount:(void (^)())success
              failure:(void (^)(NSInteger statusCode, NSError* error))failure;

@end

#endif
