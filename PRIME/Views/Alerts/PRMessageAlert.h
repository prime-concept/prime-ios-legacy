//
//  PRMessageAlert.h
//  PRIME
//
//  Created by Simon on 31/01/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#ifndef PRMessageAlert_h
#define PRMessageAlert_h

@interface PRMessageAlert : UIAlertView <UIAlertViewDelegate>

typedef NS_ENUM(NSInteger, Message) {
    Message_PasswordDoesnotMatch,
    Message_InvalidCard,
    Message_InvalidExpDate,
    Message_OnlyMasterVisaSupported,
    Message_PaymentCardAlreadyRegistered,
    Message_InvalidEmail,
    Message_ConnectedToInternet,
    Message_Logout,
    Message_EmptyTextField,
    Message_AutofillCardData,
    Message_SaveCardData,
    Message_SaveModification,
    Message_FeedBackSend,
    Messgae_UnableToSynchronizeAvatarWithServer,
    Message_UnableToLoginWithTouchID,
    Message_InternetConnectionOffline,
    Message_UberTimeIsExpired,
    Message_SaveContactFailed,
    Message_CouldNotPlayAudioFile,
    Message_IncorrectPassword,
    Message_AccountDeleted
};

+ (void)showMessageWithStatus:(NSInteger)statusCode
                        error:(NSError*)error;

+ (void)showMessageWithStatus:(NSInteger)statusCode
                        error:(NSError*)error
                           ok:(void (^)())ok;

+ (void)showMessageWithStatus:(NSInteger)statusCode
                        error:(NSError*)error
                           ok:(void (^)())ok
                       repeat:(void (^)())repeat;

+ (void)showMessage:(Message)message
                 ok:(void (^)())ok;

+ (void)showToastWithMessage:(Message)message;

+ (void)showMessage:(Message)message;

+ (void)showMessage:(Message)message
                yes:(void (^)())yes
                 no:(void (^)())no;

@end

#endif
