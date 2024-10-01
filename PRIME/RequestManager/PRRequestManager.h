//
//  PRRequestManager.h
//  PRIME
//
//  Created by Simon on 31/01/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#ifndef PRIME_PRRequestManager_h
#define PRIME_PRRequestManager_h

#import "CRMRestClient.h"
#import "DocumentImage.h"
#import "PRFeedbackModel.h"
#import "PRUserProfileFeaturesModel.h"
#import "PRSubscriptionModel.h"
#import "PRMediaMessageModel.h"


#import <AFOAuth2Client/AFOAuth2Client.h>

typedef NS_OPTIONS(NSUInteger, PRRequestOption) {
    PRRequestOption_None = 0,
    PRRequestOption_ShowErrorMessages = 1 << 0,
    PRRequestOption_ShowProgress = 2 << 0,
    PRRequestOption_Repeat = 4 << 0,
};

typedef NS_ENUM(NSInteger, PRRequestMode) {
    PRRequestMode_ShowErrorMessagesAndProgress = PRRequestOption_ShowErrorMessages | PRRequestOption_ShowProgress,
    PRRequestMode_ShowOnlyErrorMessages = PRRequestOption_ShowErrorMessages,
    PRRequestMode_ShowOnlyProgress = PRRequestOption_ShowProgress,
    PRRequestMode_ShowNothing = PRRequestOption_None
};

@class Reachability;

@interface PRRequestManager : NSObject

+ (Reachability*)internetReachability;

+ (BOOL)connectionRequired;

+ (void)initReachability;

+ (void)registerFCMToken:(NSString*)token
                    view:(UIView*)view
                    mode:(PRRequestMode)mode
                 success:(void (^)())success
                 failure:(void (^)())failure;

+ (void)registerMobileWithPhone:(NSString*)phone
                           view:(UIView*)view
                           mode:(PRRequestMode)mode
                        success:(void (^)())success
                        failure:(void (^)())failure;

+ (void)verifyCardNumber:(NSString*)cardNumber
                    view:(UIView*)view
                    mode:(PRRequestMode)mode
                 success:(void (^)())success
                 failure:(void (^)())failure
             unknownCard:(void (^)())unknownCard;

+ (void)registerUserProfile:(NSDictionary*)userParameters
                       view:(UIView*)view
                       mode:(PRRequestMode)mode
                    success:(void (^)())success
                    failure:(void (^)())failure;

+ (void)verifyWithPhone:(NSString*)phone
                   code:(NSString*)code
                   view:(UIView*)view
                   mode:(PRRequestMode)mode
                success:(void (^)())success
                failure:(void (^)())failure
            unknownUser:(void (^)())unknownUser;

+ (void)loginWithRequest:(NSString*)loginRequest
                    view:(UIView*)view
                    mode:(PRRequestMode)mode
                 success:(void (^)())success
                 failure:(void (^)())failure
             unknownUser:(void (^)())unknownUser;

+ (void)setPassword:(NSString*)password
              phone:(NSString*)phone
               view:(UIView*)view
               mode:(PRRequestMode)mode
            success:(void (^)())success
            failure:(void (^)())failure;

+ (void)changePassword:(NSString*)password
                 phone:(NSString*)phone
                  view:(UIView*)view
                  mode:(PRRequestMode)mode
               success:(void (^)())success
               failure:(void (^)())failure;

+ (void)getDocumentsWithView:(UIView*)view
                        mode:(PRRequestMode)mode
                     success:(void (^)())success
                     failure:(void (^)())failure;

+ (void)deleteDocument:(PRDocumentModel*)document
                  view:(UIView*)view
                  mode:(PRRequestMode)mode
               success:(void (^)())success
               failure:(void (^)())failure;

+ (void)getDocument:(NSNumber*)documentId
               view:(UIView*)view
               mode:(PRRequestMode)mode
            success:(void (^)(PRDocumentModel*))success
            failure:(void (^)())failure;

+ (void)createDocument:(PRDocumentModel*)document
                  view:(UIView*)view
                  mode:(PRRequestMode)mode
               success:(void (^)())success
               failure:(void (^)())failure;

+ (void)updateDocument:(PRDocumentModel*)document
                  view:(UIView*)view
                  mode:(PRRequestMode)mode
               success:(void (^)())success
               failure:(void (^)())failure;

+ (void)authorizeWithUsername:(NSString*)username
                     password:(NSString*)password
                setupCoreData:(BOOL)setupCoreData
                         view:(UIView*)view
                         mode:(PRRequestMode)mode
                      success:(void (^)())success
                      failure:(void (^)())failure
                      offline:(void (^)())offline
       incorrectPasswordBlock:(void (^)())incorrectPasswordBlock;

+ (void)validatePassword:(NSString*)password
                username:(NSString*)username
                    view:(UIView*)view
                    mode:(PRRequestMode)mode
                 success:(void (^)())success
                 failure:(void (^)())failure
                 offline:(void (^)())offline;

+ (void)getBalanceWithYear:(NSString*)year
         startingWithMonth:(NSString*)month
                monthCount:(NSInteger)count
                      view:(UIView*)view
                      mode:(PRRequestMode)mode
                   success:(void (^)(NSArray* balances))success
                   failure:(void (^)())failure;

+ (void)getTasksWithView:(UIView*)view
                    mode:(PRRequestMode)mode
                 success:(void (^)(/*NSArray *tasks*/))success
                 failure:(void (^)())failure;

+ (void)getTasksTypesWithview:(UIView*)view
                         mode:(PRRequestMode)mode
                      success:(void (^)(NSArray* types))success
                      failure:(void (^)())failure;

+ (void)sendFeedbackWithView:(UIView*)view
                        mode:(PRRequestMode)mode
                     message:(PRFeedbackModel*)feedback
                     success:(void (^)())success
                     failure:(void (^)())failure;

+ (void)getTaskWithId:(NSNumber*)taskId
                 view:(UIView*)view
                 mode:(PRRequestMode)mode
              success:(void (^)(PRTaskDetailModel* task))success
              failure:(void (^)())failure;

+ (void)getMessagesForChannelId:(NSString*)channelId
                           guid:(NSString*)guid
                          limit:(NSNumber*)limit
                         toDate:(NSNumber*)toDate
                       fromDate:(NSNumber*)fromDate
                        success:(void (^)(NSArray<PRMessageModel*>* messages))success
                        failure:(void (^)())failure;

+ (void)getSubscriptions:(void (^)(NSArray<PRSubscriptionModel*>* subscriptions))success
                 failure:(void (^)(NSInteger statusCode, NSError* error))failure;

+ (void)updateMessageStatus:(PRMessageStatusModel*)statusUpdate
                    success:(void (^)())success
                    failure:(void (^)())failure;

+ (void)sendMessage:(PRMessageModel*)message
            success:(void (^)())success
            failure:(void (^)(NSInteger statusCode, NSError* error))failure;

+ (void)sendMessageFromReplyAction:(PRMessageModel*)message
                           success:(void (^)())success
                           failure:(void (^)(NSInteger statusCode, NSError* error))failure;

+ (void)sendAudioFile:(NSData*)message
                 success:(void (^)(PRVoiceMessageModel* voiceMessageModel))success
                 failure:(void (^)(NSInteger statusCode, NSError* error))failure;

+ (void)sendMediaFile:(NSData*)message
             mimeType:(NSString*)mimeType
              success:(void (^)(PRMediaMessageModel* mediaMessageModel))success
              failure:(void (^)(NSInteger statusCode, NSError* error))failure;

+ (void)getMediaUploadStatus:(NSString*)uuid
                     success:(void (^)(NSNumber* percent))success
                     failure:(void (^)(NSInteger statusCode, NSError* error))failure;

+ (void)getMediaInfoWithUUID:(NSString *)uuid
                     success:(void (^)(NSData *))success
                     failure:(void (^)(NSInteger, NSError *))failure;

+ (void)getAudioFileFromPath:(NSString*)path
                     success:(void (^)(NSData* audioFile))success
                     failure:(void (^)(NSInteger statusCode, NSError* error))failure;

+ (void)getActionsWithTaskId:(NSNumber*)taskId
                        view:(UIView*)view
                        mode:(PRRequestMode)mode
                     success:(void (^)(NSOrderedSet* actions))success
                     failure:(void (^)())failure;

+ (void)getProfileWithView:(UIView*)view
                      mode:(PRRequestMode)mode
                   success:(void (^)(PRUserProfileModel* userProfile))success
                   failure:(void (^)())failure;

+ (void)getProfileFeaturesWithView:(UIView*)view
                              mode:(PRRequestMode)mode
                           success:(void (^)(NSArray<PRUserProfileFeaturesModel*>* profileFeatures))success
                           failure:(void (^)())failure;

+ (void)getApplePayOrderInfoWithPaymentID:(NSString*)paymentID
                                     view:(UIView*)view
                                     mode:(PRRequestMode)mode
                                  success:(void (^)(PRPaymentDataModel* paymentDataModel))success
                                  failure:(void (^)())failure;

+ (void)sendApplePayToken:(PRApplePayToken*)token
                     view:(UIView*)view
                     mode:(PRRequestMode)mode
                  success:(void (^)(PRApplePayResponseModel* applePayResponseModel))success
                  failure:(void (^)(NSInteger statusCode, NSError* error))failure;

+ (void)logoutWithView:(UIView*)view
                  mode:(PRRequestMode)mode
               success:(void (^)())success
               failure:(void (^)())failure;

+ (void)cancelTask:(UIView*)view
              mode:(PRRequestMode)mode
            taskId:(NSNumber*)taskId
           success:(void (^)())success
           failure:(void (^)())failure;

+ (void)updateProfile:(PRUserProfileModel*)userProfile
                 view:(UIView*)view
                 mode:(PRRequestMode)mode
              success:(void (^)())success
              failure:(void (^)())failure;

+ (void)uploadAvatar:(UIImage*)image
           createdAt:(NSDate*)createdAt
                view:(UIView*)view
                mode:(PRRequestMode)mode
             success:(void (^)(PRUploadFileInfoModel* imageInfo))success
             failure:(void (^)())failure;

+ (void)downloadAvatarByUID:(NSString*)uid
                       view:(UIView*)view
                       mode:(PRRequestMode)mode
                    success:(void (^)(UIImage* image))success
                    failure:(void (^)())failure;

+ (void)listAvatarWithView:(UIView*)view
                      mode:(PRRequestMode)mode
                   success:(void (^)(NSArray* filesInfo))success
                   failure:(void (^)())failure;

+ (void)uploadImageForDocument:(NSNumber*)documentId
                         image:(UIImage*)image
                     createdAt:(NSDate*)createdAt
                          view:(UIView*)view
                          mode:(PRRequestMode)mode
                       success:(void (^)(PRUploadFileInfoModel* imageInfo))success
                       failure:(void (^)())failure;

+ (void)downloadImageForDocumentByUID:(NSString*)uid
                                 view:(UIView*)view
                                 mode:(PRRequestMode)mode
                              success:(void (^)(DocumentImage* image))success
                              failure:(void (^)())failure;

+ (void)downloadTaskDocumentByUID:(NSString*)uid
                             view:(UIView*)view
                             mode:(PRRequestMode)mode
                          success:(void (^)(NSData* itemDocumentData))success
                          failure:(void (^)())failure;

+ (void)deleteImageByUID:(NSString*)uid
                    view:(UIView*)view
                    mode:(PRRequestMode)mode
                 success:(void (^)())success
                 failure:(void (^)())failure;

+ (void)listImagesForDocument:(NSNumber*)documentId
                         view:(UIView*)view
                         mode:(PRRequestMode)mode
                      success:(void (^)(NSArray* filesInfo))success
                      failure:(void (^)())failure;

+ (void)getDiscountsWithView:(UIView*)view
                        mode:(PRRequestMode)mode
                     success:(void (^)(NSArray* result))success
                     failure:(void (^)())failure;

+ (void)getDiscountTypesWithView:(UIView*)view
                            mode:(PRRequestMode)mode
                         success:(void (^)(NSArray* result))success
                         failure:(void (^)())failure;

+ (void)getDiscount:(NSNumber*)discountId
               view:(UIView*)view
               mode:(PRRequestMode)mode
            success:(void (^)(PRLoyalCardModel* model))success
            failure:(void (^)())failure;

+ (void)updateDiscount:(PRLoyalCardModel*)model
                  view:(UIView*)view
                  mode:(PRRequestMode)mode
               success:(void (^)(PRLoyalCardModel*))success
               failure:(void (^)())failure;

+ (void)createDiscount:(PRLoyalCardModel*)model
                  view:(UIView*)view
                  mode:(PRRequestMode)mode
               success:(void (^)(PRLoyalCardModel*))success
               failure:(void (^)())failure;

+ (void)deleteDiscount:(PRLoyalCardModel*)discountId
                  view:(UIView*)view
                  mode:(PRRequestMode)mode
               success:(void (^)())success
               failure:(void (^)())failure;

+ (void)getBalanceWithYear:(NSString*)year
                     month:(NSString*)month
                      view:(UIView*)view
                      mode:(PRRequestMode)mode
                   success:(void (^)(NSArray* balances))success
                   failure:(void (^)())failure;

+ (void)getServicesWithLongitude:(NSNumber*)longitude
                        latitude:(NSNumber*)latitude
                        datetime:(NSDate*)datetime
                            view:(UIView*)view
                            mode:(PRRequestMode)mode
                         success:(void (^)(NSArray* services))success
                         failure:(void (^)())failure;

+ (void)getExchangeWithYear:(NSString*)year
                      month:(NSString*)month
                       view:(UIView*)view
                       mode:(PRRequestMode)mode
                    success:(void (^)(NSArray* balances))success
                    failure:(void (^)())failure;

+ (void)callBackToClient:(NSString*)phoneNumber
                    view:(UIView*)view
                    mode:(PRRequestMode)mode
                 success:(void (^)())success
                 failure:(void (^)())failure;

+ (void)getProfilePhonesWithView:(UIView*)view
                            mode:(PRRequestMode)mode
                         success:(void (^)(NSArray* selfPhones))success
                         failure:(void (^)())failure;

+ (void)getProfileEmailsWithView:(UIView*)view
                            mode:(PRRequestMode)mode
                         success:(void (^)(NSArray* selfEmails))success
                         failure:(void (^)())failure;

+ (void)getProfileContactsWithView:(UIView*)view
                              mode:(PRRequestMode)mode
                           success:(void (^)(NSArray* selfContacts))success
                           failure:(void (^)())failure;

+ (void)getProfileContactPhonesWithContactId:(NSNumber*)contactId
                                        view:(UIView*)view
                                        mode:(PRRequestMode)mode
                                     success:(void (^)(NSArray* contactPhones))success
                                     failure:(void (^)())failure;

+ (void)getProfileContactDocumentsWithContactId:(NSNumber*)contactId
                                           view:(UIView*)view
                                           mode:(PRRequestMode)mode
                                        success:(void (^)(NSArray* contactDocuments))success
                                        failure:(void (^)())failure;

+ (void)getProfileContactEmailsWithContactId:(NSNumber*)contactId
                                        view:(UIView*)view
                                        mode:(PRRequestMode)mode
                                     success:(void (^)(NSArray* contactEmails))success
                                     failure:(void (^)())failure;

+ (void)getProfilePhoneTypesWithView:(UIView*)view
                                mode:(PRRequestMode)mode
                             success:(void (^)(NSArray* phoneTypes))success
                             failure:(void (^)())failure;

+ (void)getProfileEmailTypesWithView:(UIView*)view
                                mode:(PRRequestMode)mode
                             success:(void (^)(NSArray* emailTypes))success
                             failure:(void (^)())failure;

+ (void)getProfileContactTypesWithView:(UIView*)view
                                  mode:(PRRequestMode)mode
                               success:(void (^)(NSArray* contactTypes))success
                               failure:(void (^)())failure;

+ (void)getProfileCarsWithView:(UIView*)view
                          mode:(PRRequestMode)mode
                       success:(void (^)(NSArray<PRCarModel*>* profileCars))success
                       failure:(void (^)())failure;

+ (void)addPhoneForProfile:(PRProfilePhoneModel*)phoneModel
                      view:(UIView*)view
                      mode:(PRRequestMode)mode
                   success:(void (^)())success
                   failure:(void (^)())failure;

+ (void)addEmailForProfile:(PRProfileEmailModel*)emailModel
                      view:(UIView*)view
                      mode:(PRRequestMode)mode
                   success:(void (^)())success
                   failure:(void (^)())failure;

+ (void)addContactForProfile:(PRProfileContactModel*)contactModel
                        view:(UIView*)view
                        mode:(PRRequestMode)mode
                     success:(void (^)(PRProfileContactModel*))success
                     failure:(void (^)())failure;

+ (void)addContactPhone:(PRProfileContactPhoneModel*)phoneModel
          withContactId:(NSNumber*)contactId
                   view:(UIView*)view
                   mode:(PRRequestMode)mode
                success:(void (^)())success
                failure:(void (^)())failure;

+ (void)addContactDocument:(PRProfileContactDocumentModel*)documentModel
             withContactId:(NSNumber*)contactId
                      view:(UIView*)view
                      mode:(PRRequestMode)mode
                   success:(void (^)())success
                   failure:(void (^)())failure;

+ (void)addContactEmail:(PRProfileContactEmailModel*)emailModel
          withContactId:(NSNumber*)contactId
                   view:(UIView*)view
                   mode:(PRRequestMode)mode
                success:(void (^)())success
                failure:(void (^)())failure;

+ (void)addCarForProfile:(PRCarModel*)carModel
                    view:(UIView*)view
                    mode:(PRRequestMode)mode
                 success:(void (^)())success
                 failure:(void (^)())failure;

+ (void)updateProfilePhone:(PRProfilePhoneModel*)phoneModel
                      view:(UIView*)view
                      mode:(PRRequestMode)mode
                   success:(void (^)())success
                   failure:(void (^)())failure;

+ (void)updateProfileEmail:(PRProfileEmailModel*)emailModel
                      view:(UIView*)view
                      mode:(PRRequestMode)mode
                   success:(void (^)())success
                   failure:(void (^)())failure;

+ (void)updateProfileContact:(PRProfileContactModel*)contactModel
                        view:(UIView*)view
                        mode:(PRRequestMode)mode
                     success:(void (^)())success
                     failure:(void (^)())failure;

+ (void)updateProfileContactPhone:(PRProfileContactPhoneModel*)phoneModel
                    withContactId:(NSNumber*)contactId
                          phoneId:(NSString*)phoneId
                             view:(UIView*)view
                             mode:(PRRequestMode)mode
                          success:(void (^)())success
                          failure:(void (^)())failure;

+ (void)updateProfileContactDocument:(PRProfileContactDocumentModel*)documentModel
                       withContactId:(NSNumber*)contactId
                          documentId:(NSNumber*)documentId
                                view:(UIView*)view
                                mode:(PRRequestMode)mode
                             success:(void (^)())success
                             failure:(void (^)())failure;

+ (void)updateProfileContactEmail:(PRProfileContactEmailModel*)emailModel
                    withContactId:(NSNumber*)contactId
                          emailId:(NSString*)emailId
                             view:(UIView*)view
                             mode:(PRRequestMode)mode
                          success:(void (^)())success
                          failure:(void (^)())failure;

+ (void)updateCarForProfile:(PRCarModel*)carModel
                       view:(UIView*)view
                       mode:(PRRequestMode)mode
                    success:(void (^)())success
                    failure:(void (^)())failure;

+ (void)deleteProfilePhoneWithPhoneId:(NSString*)phoneId
                                 view:(UIView*)view
                                 mode:(PRRequestMode)mode
                              success:(void (^)())success
                              failure:(void (^)())failure;

+ (void)deleteProfileEmailWithEmailId:(NSString*)emailId
                                 view:(UIView*)view
                                 mode:(PRRequestMode)mode
                              success:(void (^)())success
                              failure:(void (^)())failure;

+ (void)deleteProfileContactWithContactId:(NSNumber*)contactId
                                     view:(UIView*)view
                                     mode:(PRRequestMode)mode
                                  success:(void (^)())success
                                  failure:(void (^)())failure;

+ (void)deleteProfileContactPhoneWithContactId:(NSNumber*)contactId
                                       phoneId:(NSString*)phoneId
                                          view:(UIView*)view
                                          mode:(PRRequestMode)mode
                                       success:(void (^)())success
                                       failure:(void (^)())failure;

+ (void)deleteProfileContactDocumentWithContactId:(NSNumber*)contactId
                                       documentId:(NSNumber*)documentId
                                             view:(UIView*)view
                                             mode:(PRRequestMode)mode
                                          success:(void (^)())success
                                          failure:(void (^)())failure;

+ (void)deleteProfileContactEmailWithContactId:(NSNumber*)contactId
                                       emailId:(NSString*)emailId
                                          view:(UIView*)view
                                          mode:(PRRequestMode)mode
                                       success:(void (^)())success
                                       failure:(void (^)())failure;

+ (void)deleteProfileCarWithCarId:(NSNumber*)carId
                             view:(UIView*)view
                             mode:(PRRequestMode)mode
                          success:(void (^)())success
                          failure:(void (^)())failure;

+ (void)getDocumentTypesWithView:(UIView*)view
                            mode:(PRRequestMode)mode
                         success:(void (^)(NSArray* result))success
                         failure:(void (^)())failure;

+ (void)linkDocument:(NSNumber*)documentId
          toDocument:(NSNumber*)toDocumentId
                view:(UIView*)view
                mode:(PRRequestMode)mode
             success:(void (^)())success
             failure:(void (^)())failure;

+ (void)linkDocument:(NSNumber*)documentId
          toDocument:(NSNumber*)toDocumentId
          forContact:(NSNumber*)contactId
                view:(UIView*)view
                mode:(PRRequestMode)mode
             success:(void (^)())success
             failure:(void (^)())failure;

+ (void)detachVisaFromPassportForDocument:(NSNumber*)documentId
                                        view:(UIView*)view
                                        mode:(PRRequestMode)mode
                                     success:(void (^)())success
                                     failure:(void (^)())failure;

+ (void)detachVisaFromPassportForContactDocument:(NSNumber*)contactId
                                         documentId:(NSNumber*)documentId
                                               view:(UIView*)view
                                               mode:(PRRequestMode)mode
                                            success:(void (^)())success
                                            failure:(void (^)())failure;

+ (void)getProfileContactDocumentWithContactId:(NSNumber*)contactId
                                    documentId:(NSNumber*)documentId
                                          view:(UIView*)view
                                          mode:(PRRequestMode)mode
                                       success:(void (^)(NSArray* contactDocuments))success
                                       failure:(void (^)())failure;

+ (void)deleteAccount:(UIView*)view
                 mode:(PRRequestMode)mode
              success:(void (^)())success
              failure:(void (^)())failure;

@end

#endif
