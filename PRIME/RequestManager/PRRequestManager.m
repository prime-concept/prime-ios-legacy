//
//  PRRequestManager.m
//  PRIME
//
//  Created by Simon on 31/01/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "DefaultHandler.h"
#import "DocumentImage.h"
#import "PRLoyalCardModel.h"
#import "PRProfileContactModel.h"
#import "PRProfileEmailModel.h"
#import "PRRequestManager.h"
#import "Reachability.h"
#import "TouchIDAuth.h"
#import "XNTKeychainStore.h"

@interface PRRequestManager ()

@end

static Reachability* internetReachability;

@implementation PRRequestManager

+ (Reachability*)internetReachability
{
    return internetReachability;
}

+ (BOOL)connectionRequired
{
    return internetReachability.currentReachabilityStatus == NotReachable;
}

+ (void)initReachability
{
    internetReachability = [Reachability reachabilityForInternetConnection];
    [internetReachability startNotifier];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
}

+ (void)reachabilityChanged:(NSNotification*)notification
{
}

+ (void)sendRequest:(Request)request whitRequestMode:(PRRequestOption)mode
{

    __block int repeatCount = 3;

    Request repeat = ^(Request repeat, PRRequestOption mode) {

        --repeatCount;

        if (repeatCount <= 0) {
            mode ^= PRRequestOption_Repeat;
        }

        request(repeat, mode);
    };

    mode |= PRRequestOption_Repeat;

    request(repeat, mode);
}

+ (void)refreshAccessTokenWithSuccess:(void (^)())success
                              failure:(void (^)())failure
{
    NSLog(@"refreshAccessTokenWithSuccess");

    AFOAuthCredential* credential = [AFOAuthCredential objectFromKeychainWithKey:kCredentialKeyPath];

    if (credential == nil) {

        if (![self connectionRequired]) {
            [TouchIDAuth authorizeWithStoredPassWithView:nil
                setupCoreData:NO
                success:^{

                    success();

                }
                offline:^(NSString* phone, NSString* passCode) {

                }
                fallback:^{
                    if (failure) {
                        NSMutableDictionary* errorDetail = [NSMutableDictionary dictionary];
                        [errorDetail setValue:@"Failed to get credentials" forKey:NSLocalizedDescriptionKey];
                        NSError* error = [NSError errorWithDomain:@"world" code:405 userInfo:errorDetail];
                        failure(405, error);
                    }
                }];
        } else {
            success();
        }

        return;
    }

    if (!credential.isExpired) {
        NSLog(@"refreshAccessTokenWithSuccess: credential has not expired");

        success();
        return;
    }

    NSLog(@"refreshAccessTokenWithSuccess: refreshing credential");

    [[CRMRestClient sharedClient] refreshAccessToken:credential.refreshToken
                                             success:^(AFOAuthCredential* credential) {
                                                 BOOL b = [credential storeToKeychainWithKey:kCredentialKeyPath];

                                                 //TODO: Close APP !!!
                                                 NSAssert(b, @"Credentials are not saved");
                                                 success();
                                             }
                                             failure:failure];
}

+ (NSString*)currentLanguage
{
    return [[NSBundle mainBundle] preferredLocalizations][0];
}

+ (void)registerFCMToken:(NSString*)token
                    view:(UIView*)view
                    mode:(PRRequestMode)mode
                 success:(void (^)())success
                 failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [[CRMRestClient sharedClient] registerFCMToken:token
                                               success:[DefaultHandler success:success view:view mode:option]
                                               failure:[DefaultHandler failure:failure
                                                                          view:view
                                                                          mode:option
                                                                        repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)registerMobileWithPhone:(NSString*)phone
                           view:(UIView*)view
                           mode:(PRRequestMode)mode
                        success:(void (^)())success
                        failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [[CRMRestClient sharedClient] registerMobileWithPhone:phone
                                                      success:[DefaultHandler success:success view:view mode:option]
                                                      failure:[DefaultHandler failure:failure
                                                                                 view:view
                                                                                 mode:option
                                                                               repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)verifyCardNumber:(NSString*)cardNumber
                    view:(UIView*)view
                    mode:(PRRequestMode)mode
                 success:(void (^)())success
                 failure:(void (^)())failure
             unknownCard:(void (^)())unknownCard
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [[CRMRestClient sharedClient] verifyCardNumber:cardNumber
                                               success:[DefaultHandler success:success view:view mode:option]
                                               failure:[DefaultHandler failure:failure
                                                                       offline:nil
                                                                   unknownCard:unknownCard
                                                                          view:view
                                                                          mode:option
                                                                        repeat:repeat]];
    };

    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)registerUserProfile:(NSDictionary*)userParameters
                       view:(UIView*)view
                       mode:(PRRequestMode)mode
                    success:(void (^)())success
                    failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [[CRMRestClient sharedClient] registerUserProfile:userParameters
                                                  success:[DefaultHandler success:success view:view mode:option]
                                                  failure:[DefaultHandler failure:failure
                                                                             view:view
                                                                             mode:option
                                                                           repeat:repeat]];
    };

    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)verifyWithPhone:(NSString*)phone
                   code:(NSString*)code
                   view:(UIView*)view
                   mode:(PRRequestMode)mode
                success:(void (^)())success
                failure:(void (^)())failure
            unknownUser:(void (^)())unknownUser

{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [[CRMRestClient sharedClient] verifyWithPhone:phone
                                                 code:code
                                              success:[DefaultHandler success:success view:view mode:option]
                                              failure:[DefaultHandler failure:failure
                                                                      offline:nil
                                                                  unknownUser:unknownUser
                                                                         view:view
                                                                         mode:option
                                                                       repeat:repeat
                                                       incorrectPasswordBlock:nil]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)loginWithRequest:(NSString*)loginRequest
                    view:(UIView*)view
                    mode:(PRRequestMode)mode
                 success:(void (^)())success
                 failure:(void (^)())failure
             unknownUser:(void (^)())unknownUser
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [[CRMRestClient sharedClient] loginWithRequest:loginRequest
                                               success:[DefaultHandler success:success view:view mode:option]
                                               failure:[DefaultHandler failure:failure
                                                                       offline:nil
                                                                   unknownUser:unknownUser
                                                                          view:view
                                                                          mode:option
                                                                        repeat:repeat
                                                        incorrectPasswordBlock:nil]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)setPassword:(NSString*)password
              phone:(NSString*)phone
               view:(UIView*)view
               mode:(PRRequestMode)mode
            success:(void (^)())success
            failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [[CRMRestClient sharedClient] setPassword:password
                                            phone:phone
                                          success:[DefaultHandler success:success view:view mode:option]
                                          failure:[DefaultHandler failure:failure
                                                                     view:view
                                                                     mode:option
                                                                   repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)changePassword:(NSString*)password
                 phone:(NSString*)phone
                  view:(UIView*)view
                  mode:(PRRequestMode)mode
               success:(void (^)())success
               failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [[CRMRestClient sharedClient] changePassword:password
                                               phone:phone
                                             success:[DefaultHandler success:success view:view mode:option]
                                             failure:[DefaultHandler failure:failure
                                                                        view:view
                                                                        mode:option
                                                                      repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)authorizeWithUsername:(NSString*)username
                     password:(NSString*)password
                setupCoreData:(BOOL)setupCoreData
                         view:(UIView*)view
                         mode:(PRRequestMode)mode
                      success:(void (^)())success
                      failure:(void (^)())failure
                      offline:(void (^)())offline
       incorrectPasswordBlock:(void (^)())incorrectPasswordBlock
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [[CRMRestClient sharedClient] authorizeWithUsername:username
                                                   password:password
                                              setupCoreData:setupCoreData
                                                    success:^(AFOAuthCredential* credential) {

                                                        [XNTKeychainStore setDefaultIdentifier:username];
                                                        [XNTKeychainStore setDefaultKeyPrefix:username];

                                                        BOOL b = [credential storeToKeychainWithKey:kCredentialKeyPath];
                                                        NSAssert(b, @"Credentials are not saved");

                                                        [DefaultHandler success:success view:view mode:option]();
                                                    }
                                                    failure:[DefaultHandler failure:failure
                                                                            offline:offline
                                                                        unknownUser:nil
                                                                               view:view
                                                                               mode:option
                                                                             repeat:repeat
                                                             incorrectPasswordBlock:incorrectPasswordBlock]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)validatePassword:(NSString*)password
                username:(NSString*)username
                    view:(UIView*)view
                    mode:(PRRequestMode)mode
                 success:(void (^)())success
                 failure:(void (^)())failure
                 offline:(void (^)())offline
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [[CRMRestClient sharedClient] authorizeWithUsername:username
                                                   password:password
                                              setupCoreData:NO
                                                    success:^(AFOAuthCredential* credential) {

                                                        [XNTKeychainStore setDefaultIdentifier:username];
                                                        [XNTKeychainStore setDefaultKeyPrefix:username];

                                                        BOOL b = [credential storeToKeychainWithKey:kCredentialKeyPath];
                                                        NSAssert(b, @"Credentials are not saved");

                                                        [DefaultHandler success:success view:view mode:option]();
                                                    }
                                                    failure:[DefaultHandler failure:failure
                                                                            offline:offline
                                                                        unknownUser:nil
                                                                               view:view
                                                                               mode:PRRequestOption_None
                                                                             repeat:repeat
                                                             incorrectPasswordBlock:nil]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)logoutWithView:(UIView*)view
                  mode:(PRRequestMode)mode
               success:(void (^)())success
               failure:(void (^)())failure

{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [XNTKeychainStore setDefaultIdentifier:nil];
        [XNTKeychainStore setDefaultKeyPrefix:nil];

        [[CRMRestClient sharedClient] logoutWithSuccess:[DefaultHandler success:success view:view mode:option]
                                                failure:[DefaultHandler failure:failure
                                                                           view:view
                                                                           mode:option
                                                                         repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)getDocumentsWithView:(UIView*)view
                        mode:(PRRequestMode)mode
                     success:(void (^)())success
                     failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            NSString* lang = [self.class currentLanguage];

            [[CRMRestClient sharedClient] getDocumentsWithLang:lang
                                                       success:[DefaultHandler success:success view:view mode:option]
                                                       failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };

    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)deleteDocument:(PRDocumentModel*)document
                  view:(UIView*)view
                  mode:(PRRequestMode)mode
               success:(void (^)())success
               failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] deleteDocument:document
                                                 success:[DefaultHandler success:success view:view mode:option]
                                                 failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };

    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)getDocument:(NSNumber*)documentId
               view:(UIView*)view
               mode:(PRRequestMode)mode
            success:(void (^)(PRDocumentModel*))success
            failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            NSString* lang = [self.class currentLanguage];

            [[CRMRestClient sharedClient] getDocument:documentId
                                                 lang:lang
                                              success:[DefaultHandler successWithObjectResult:success view:view mode:option]
                                              failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };

    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)createDocument:(PRDocumentModel*)document
                  view:(UIView*)view
                  mode:(PRRequestMode)mode
               success:(void (^)())success
               failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] createDocument:document
                                                 success:[DefaultHandler success:success view:view mode:option]
                                                 failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };

    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)updateDocument:(PRDocumentModel*)document
                  view:(UIView*)view
                  mode:(PRRequestMode)mode
               success:(void (^)())success
               failure:(void (^)())failure
{

    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] updateDocument:document
                                                 success:[DefaultHandler success:success view:view mode:option]
                                                 failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };

    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)linkDocument:(NSNumber*)documentId
          toDocument:(NSNumber*)toDocumentId
                view:(UIView*)view
                mode:(PRRequestMode)mode
             success:(void (^)())success
             failure:(void (^)())failure
{

    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] linkDocument:documentId
                                            toDocument:toDocumentId
                                               success:[DefaultHandler success:success view:view mode:option]
                                               failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };

    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)linkDocument:(NSNumber*)documentId
          toDocument:(NSNumber*)toDocumentId
          forContact:(NSNumber*)contactId
                view:(UIView*)view
                mode:(PRRequestMode)mode
             success:(void (^)())success
             failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] linkDocument:documentId
                                            toDocument:toDocumentId
                                            forContact:contactId
                                               success:[DefaultHandler success:success view:view mode:option]
                                               failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };

    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)detachVisaFromPassportForDocument:(NSNumber*)documentId
                                        view:(UIView*)view
                                        mode:(PRRequestMode)mode
                                     success:(void (^)())success
                                     failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] detachVisaFromPassportForDocument:documentId
                                                                              success:[DefaultHandler success:success view:view mode:option]
                                                                              failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)detachVisaFromPassportForContactDocument:(NSNumber*)contactId
                                         documentId:(NSNumber*)documentId
                                               view:(UIView*)view
                                               mode:(PRRequestMode)mode
                                            success:(void (^)())success
                                            failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] detachVisaFromPassportForContactDocument:contactId
                                                   documentId:documentId
                                                      success:[DefaultHandler success:success view:view mode:option]
                                                      failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };

    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)getBalanceWithYear:(NSString*)year
         startingWithMonth:(NSString*)month
                monthCount:(NSInteger)count
                      view:(UIView*)view
                      mode:(PRRequestMode)mode
                   success:(void (^)(NSArray* balances))success
                   failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            NSString* lang = [self.class currentLanguage];

            [[CRMRestClient sharedClient] getBalanceWithYear:year
                                           startingWithMonth:month
                                                  monthCount:count
                                                        lang:lang
                                                     success:[DefaultHandler successWithArrayResult:success view:view mode:option]
                                                     failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };

    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)getTasksWithView:(UIView*)view
                    mode:(PRRequestMode)mode
                 success:(void (^)(/*NSArray *tasks*/))success
                 failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            NSString* lang = [self.class currentLanguage];

            [[CRMRestClient sharedClient] getTasksWithLang:lang
                                                   success:[DefaultHandler success:success view:view mode:option]
                                                   failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];

    };

    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)getTaskWithId:(NSNumber*)taskId
                 view:(UIView*)view
                 mode:(PRRequestMode)mode
              success:(void (^)(PRTaskDetailModel* task))success
              failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            NSString* lang = [self.class currentLanguage];

            [[CRMRestClient sharedClient] getTaskWithId:taskId
                                                   lang:lang
                                                success:[DefaultHandler successWithObjectResult:success view:view mode:option]
                                                failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];

    };

    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)getActionsWithTaskId:(NSNumber*)taskId
                        view:(UIView*)view
                        mode:(PRRequestMode)mode
                     success:(void (^)(NSOrderedSet* actions))success
                     failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            NSString* lang = [self.class currentLanguage];

            [[CRMRestClient sharedClient] getActionsWithTaskId:taskId
                                                          lang:lang
                                                       success:[DefaultHandler successWithOrderedSetResult:success view:view mode:option]
                                                       failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];

    };

    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)getTasksTypesWithview:(UIView*)view
                         mode:(PRRequestMode)mode
                      success:(void (^)(NSArray* types))success
                      failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] getTasksTypesWithSuccess:
                                              [DefaultHandler successWithArrayResult:success
                                                                                view:view
                                                                                mode:option]
                                                           failure:
                                                               [DefaultHandler failure:failure
                                                                                  view:view
                                                                                  mode:option
                                                                                repeat:repeat]];

        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];

    };

    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)sendFeedbackWithView:(UIView*)view
                        mode:(PRRequestMode)mode
                     message:(PRFeedbackModel*)feedback
                     success:(void (^)())success
                     failure:(void (^)())failure
{

    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{

            [[CRMRestClient sharedClient] sendFeedbackWithText:feedback
                                                       success:[DefaultHandler success:success view:view mode:option]
                                                       failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];

        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];

    };

    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)getMessagesForChannelId:(NSString*)channelId
                           guid:(NSString*)guid
                          limit:(NSNumber*)limit
                         toDate:(NSNumber*)toDate
                       fromDate:(NSNumber*)fromDate
                        success:(void (^)(NSArray<PRMessageModel*>* messages))success
                        failure:(void (^)())failure
{
    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{

            [[CRMRestClient sharedClient] getMessagesForChannelId:channelId
                                                             guid:guid
                                                            limit:limit
                                                           toDate:toDate
                                                         fromDate:fromDate
                                                          success:[DefaultHandler successWithObjectResult:success view:nil mode:PRRequestOption_None]
                                                          failure:[DefaultHandler failure:failure view:nil mode:PRRequestOption_None repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:nil mode:option repeat:repeat]];

    };

    [self sendRequest:request whitRequestMode:PRRequestOption_None];
}

+ (void)getSubscriptions:(void (^)(NSArray<PRSubscriptionModel*>* subscriptions))success
                 failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    Request request = ^(Request repeat, PRRequestOption option) {
        [self refreshAccessTokenWithSuccess:^{

            [[CRMRestClient sharedClient] getSubscriptions:[DefaultHandler successWithObjectResult:success view:nil mode:PRRequestOption_None]
                                               failure:[DefaultHandler failure:failure view:nil mode:PRRequestOption_None repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:nil mode:option repeat:repeat]];

    };

    [self sendRequest:request whitRequestMode:PRRequestOption_None];
}

+ (void)updateMessageStatus:(PRMessageStatusModel*)statusUpdate
                    success:(void (^)())success
                    failure:(void (^)())failure
{
    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] updateMessageStatus:statusUpdate
                                                      success:[DefaultHandler success:success view:nil mode:option]
                                                      failure:[DefaultHandler failure:failure view:nil mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:nil mode:option repeat:repeat]];

    };

    [self sendRequest:request whitRequestMode:PRRequestOption_None];
}

+ (void)sendMessage:(PRMessageModel*)message
            success:(void (^)())success
            failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] sendMessage:message
                                              success:[DefaultHandler success:success view:nil mode:option]
                                              failure:[DefaultHandler failure:failure view:nil mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:nil mode:option repeat:repeat]];

    };

    [self sendRequest:request whitRequestMode:PRRequestOption_None];
}

+ (void)sendMessageFromReplyAction:(PRMessageModel*)message
            success:(void (^)())success
            failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    Request request = ^(Request repeat, PRRequestOption option) {
        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] sendMessageFromReplyAction:message
                                              success:[DefaultHandler success:success view:nil mode:option]
                                              failure:[DefaultHandler failure:failure view:nil mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:nil mode:option repeat:repeat]];

    };

    [self sendRequest:request whitRequestMode:PRRequestOption_None];
}

+ (void)sendAudioFile:(NSData*)message
              success:(void (^)(PRVoiceMessageModel* voiceMessageModel))success
              failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] sendAudioFile:message
                                                success:[DefaultHandler successWithObjectResult:success view:nil mode:option]
                                                failure:[DefaultHandler failure:failure view:nil mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:nil mode:option repeat:repeat]];

    };

    [self sendRequest:request whitRequestMode:PRRequestOption_None];
}

+ (void)sendMediaFile:(NSData*)message
             mimeType:(NSString*)mimeType
              success:(void (^)(PRMediaMessageModel* mediaMessageModel))success
              failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] sendMediaFileHeader:message
                                                     mimeType:mimeType
                                                      success:[DefaultHandler successWithObjectResult:success view:nil mode:option]
                                                      failure:[DefaultHandler failure:failure view:nil mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:nil mode:option repeat:repeat]];

    };

    [self sendRequest:request whitRequestMode:PRRequestOption_None];
}

+ (void)getMediaUploadStatus:(NSString*)uuid
                     success:(void (^)(NSNumber* percent))success
                     failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] getMediaUploadStatus:uuid
                                                       success:[DefaultHandler successWithObjectResult:success view:nil mode:option]
                                                       failure:[DefaultHandler failure:failure view:nil mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:nil mode:option repeat:repeat]];

    };

    [self sendRequest:request whitRequestMode:PRRequestOption_None];
}

+ (void)getMediaInfoWithUUID:(NSString *)uuid
                     success:(void (^)(NSData *))success
                     failure:(void (^)(NSInteger, NSError *))failure
{
    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] getMediaInfoWithUUID:uuid
                                                       success:[DefaultHandler successWithObjectResult:success view:nil mode:option]
                                                       failure:[DefaultHandler failure:failure view:nil mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:nil mode:option repeat:repeat]];

    };

    [self sendRequest:request whitRequestMode:PRRequestOption_None];
}

+ (void)getAudioFileFromPath:(NSString*)path
                     success:(void (^)(NSData* audioFile))success
                     failure:(void (^)(NSInteger statusCode, NSError* error))failure

{
    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] getAudioFileFromPath:path
                                                       success:[DefaultHandler successWithObjectResult:success view:nil mode:option]
                                                       failure:[DefaultHandler failure:failure view:nil mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:nil mode:option repeat:repeat]];

    };

    [self sendRequest:request whitRequestMode:PRRequestOption_None];
}

+ (void)cancelTask:(UIView*)view
              mode:(PRRequestMode)mode
            taskId:(NSNumber*)taskId
           success:(void (^)())success
           failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{

            [[CRMRestClient sharedClient] cancelTask:taskId
                                             success:[DefaultHandler success:success view:view mode:option]
                                             failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];

    };

    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)getProfileWithView:(UIView*)view
                      mode:(PRRequestMode)mode
                   success:(void (^)(PRUserProfileModel* userProfile))success
                   failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{

            NSString* lang = [self.class currentLanguage];

            [[CRMRestClient sharedClient] getProfileWithLang:lang
                                                     success:[DefaultHandler successWithObjectResult:success view:view mode:option]
                                                     failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];

    };

    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)updateProfile:(PRUserProfileModel*)userProfile
                 view:(UIView*)view
                 mode:(PRRequestMode)mode
              success:(void (^)())success
              failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{

            NSString* lang = [self.class currentLanguage];

            [[CRMRestClient sharedClient] updateProfile:userProfile
                                                   lang:lang
                                                success:[DefaultHandler success:success view:view mode:option]
                                                failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];

    };

    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)getApplePayOrderInfoWithPaymentID:(NSString*)paymentID
                                     view:(UIView*)view
                                     mode:(PRRequestMode)mode
                                  success:(void (^)(PRPaymentDataModel* paymentDataModel))success
                                  failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{

            [[CRMRestClient sharedClient] getApplePayOrderInfoWithPaymentID:paymentID
                                                                    success:[DefaultHandler successWithObjectResult:success view:view mode:option]
                                                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];

    };

    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)sendApplePayToken:(PRApplePayToken*)token
                     view:(UIView*)view
                     mode:(PRRequestMode)mode
                  success:(void (^)(PRApplePayResponseModel* applePayResponseModel))success
                  failure:(void (^)(NSInteger statusCode, NSError* error))failure;
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{

            [[CRMRestClient sharedClient] sendApplePayToken:token
                                                    success:[DefaultHandler successWithObjectResult:success view:view mode:option]
                                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];

    };

    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)getProfileFeaturesWithView:(UIView*)view
                              mode:(PRRequestMode)mode
                           success:(void (^)(NSArray<PRUserProfileFeaturesModel*>* profileFeatures))success
                           failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{

            [[CRMRestClient sharedClient] getProfileFeaturesWithSuccess:
                                              [DefaultHandler successWithArrayResult:success
                                                                                view:view
                                                                                mode:option]
                                                                failure:
                                                                    [DefaultHandler failure:failure
                                                                                       view:view
                                                                                       mode:option
                                                                                     repeat:repeat]];

        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];

    };

    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)uploadAvatar:(UIImage*)image
           createdAt:(NSDate*)createdAt
                view:(UIView*)view
                mode:(PRRequestMode)mode
             success:(void (^)(PRUploadFileInfoModel* imageInfo))success
             failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{

            [[CRMRestClient sharedClient] uploadAvatar:image
                                             createdAt:createdAt
                                               success:[DefaultHandler successWithObjectResult:success view:view mode:option]
                                               failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];

    };

    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)downloadAvatarByUID:(NSString*)uid
                       view:(UIView*)view
                       mode:(PRRequestMode)mode
                    success:(void (^)(UIImage* image))success
                    failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{

            [[CRMRestClient sharedClient] downloadAvatarByUID:uid
                                                      success:[DefaultHandler successWithObjectResult:success view:view mode:option]
                                                      failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];

        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)listAvatarWithView:(UIView*)view
                      mode:(PRRequestMode)mode
                   success:(void (^)(NSArray* filesInfo))success
                   failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{

            [[CRMRestClient sharedClient] listAvatarWithSuccess:[DefaultHandler successWithObjectResult:success view:view mode:option]
                                                        failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];

        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)uploadImageForDocument:(NSNumber*)documentId
                         image:(UIImage*)image
                     createdAt:(NSDate*)createdAt
                          view:(UIView*)view
                          mode:(PRRequestMode)mode
                       success:(void (^)(PRUploadFileInfoModel* imageInfo))success
                       failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{

            [[CRMRestClient sharedClient] uploadImageForDocument:documentId
                                                           image:image
                                                       createdAt:createdAt
                                                         success:[DefaultHandler successWithObjectResult:success view:view mode:option]
                                                         failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)downloadImageForDocumentByUID:(NSString*)uid
                                 view:(UIView*)view
                                 mode:(PRRequestMode)mode
                              success:(void (^)(DocumentImage* image))success
                              failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] downloadImageForDocumentByUID:uid
                                                                success:[DefaultHandler successWithObjectResult:success view:view mode:option]
                                                                failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];

        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)downloadTaskDocumentByUID:(NSString*)uid
                             view:(UIView*)view
                             mode:(PRRequestMode)mode
                          success:(void (^)(NSData* itemDocumentData))success
                          failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] downloadTaskDocumentByUID:uid
                                                            success:[DefaultHandler successWithObjectResult:success view:view mode:option]
                                                            failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)deleteImageByUID:(NSString*)uid
                    view:(UIView*)view
                    mode:(PRRequestMode)mode
                 success:(void (^)())success
                 failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] deleteImageForDocumentByUID:uid
                                                              success:[DefaultHandler success:success view:view mode:option]
                                                              failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];

        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)listImagesForDocument:(NSNumber*)documentId
                         view:(UIView*)view
                         mode:(PRRequestMode)mode
                      success:(void (^)(NSArray* filesInfo))success
                      failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] listImagesForDocument:documentId
                                                        success:[DefaultHandler successWithObjectResult:success view:view mode:option]
                                                        failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];

        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)getDiscountsWithView:(UIView*)view
                        mode:(PRRequestMode)mode
                     success:(void (^)(NSArray* result))success
                     failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            NSString* lang = [self.class currentLanguage];

            [[CRMRestClient sharedClient] getDiscountsWithLang:lang
                                                       success:[DefaultHandler successWithArrayResult:success view:view mode:option]
                                                       failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];

        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)getDiscountTypesWithView:(UIView*)view
                            mode:(PRRequestMode)mode
                         success:(void (^)(NSArray* result))success
                         failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            NSString* lang = [self.class currentLanguage];

            [[CRMRestClient sharedClient] getDiscountTypesWithLang:lang
                                                           success:[DefaultHandler successWithArrayResult:success view:view mode:option]
                                                           failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];

        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)getDocumentTypesWithView:(UIView*)view
                            mode:(PRRequestMode)mode
                         success:(void (^)(NSArray* result))success
                         failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            NSString* lang = [self.class currentLanguage];

            [[CRMRestClient sharedClient] getDocumentTypesWithLang:lang
                                                           success:[DefaultHandler successWithArrayResult:success view:view mode:option]
                                                           failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];

        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)getDiscount:(NSNumber*)discountId
               view:(UIView*)view
               mode:(PRRequestMode)mode
            success:(void (^)(PRLoyalCardModel* model))success
            failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            NSString* lang = [self.class currentLanguage];

            [[CRMRestClient sharedClient] getDiscountWithId:discountId
                                                       lang:lang
                                                    success:[DefaultHandler successWithObjectResult:success view:view mode:option]
                                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];

        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)updateDiscount:(PRLoyalCardModel*)model
                  view:(UIView*)view
                  mode:(PRRequestMode)mode
               success:(void (^)(PRLoyalCardModel*))success
               failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            NSString* lang = [self.class currentLanguage];

            [[CRMRestClient sharedClient] updateDiscount:model
                                                    lang:lang
                                                 success:[DefaultHandler successWithObjectResult:success view:view mode:option]
                                                 failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];

        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)createDiscount:(PRLoyalCardModel*)model
                  view:(UIView*)view
                  mode:(PRRequestMode)mode
               success:(void (^)(PRLoyalCardModel*))success
               failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            NSString* lang = [self.class currentLanguage];

            [[CRMRestClient sharedClient] createDiscount:model
                                                    lang:lang
                                                 success:[DefaultHandler successWithObjectResult:success view:view mode:option]
                                                 failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];

        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)deleteDiscount:(PRLoyalCardModel*)discount
                  view:(UIView*)view
                  mode:(PRRequestMode)mode
               success:(void (^)())success
               failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            NSString* lang = [self.class currentLanguage];

            [[CRMRestClient sharedClient] deleteDiscountWithId:discount
                                                          lang:lang
                                                       success:[DefaultHandler success:success view:view mode:option]
                                                       failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];

        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)getBalanceWithYear:(NSString*)year
                     month:(NSString*)month
                      view:(UIView*)view
                      mode:(PRRequestMode)mode
                   success:(void (^)(NSArray* balances))success
                   failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            NSString* lang = [self.class currentLanguage];

            [[CRMRestClient sharedClient] getBalanceWithYear:year
                                                       month:month
                                                        lang:lang
                                                     success:[DefaultHandler successWithArrayResult:success view:view mode:option]
                                                     failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)getServicesWithLongitude:(NSNumber*)longitude
                        latitude:(NSNumber*)latitude
                        datetime:(NSDate*)datetime
                            view:(UIView*)view
                            mode:(PRRequestMode)mode
                         success:(void (^)(NSArray* services))success
                         failure:(void (^)())failure
{

    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSString* givenDatetime = [formatter stringFromDate:datetime];

    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{

            [[CRMRestClient sharedClient] getServicesWithLongitude:longitude
                                                          latitude:latitude
                                                          datetime:givenDatetime
                                                           success:[DefaultHandler successWithArrayResult:success view:view mode:option]
                                                           failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)getExchangeWithYear:(NSString*)year
                      month:(NSString*)month
                       view:(UIView*)view
                       mode:(PRRequestMode)mode
                    success:(void (^)(NSArray* balances))success
                    failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            NSString* lang = [self.class currentLanguage];

            [[CRMRestClient sharedClient] getExchangeWithYear:year
                                                        month:month
                                                         lang:lang
                                                      success:[DefaultHandler successWithArrayResult:success view:view mode:option]
                                                      failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)callBackToClient:(NSString*)phoneNumber
                    view:(UIView*)view
                    mode:(PRRequestMode)mode
                 success:(void (^)())success
                 failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [[CRMRestClient sharedClient] callBack:phoneNumber
                                       success:[DefaultHandler success:success view:view mode:option]
                                       failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

#pragma mark UserProfileInformation

+ (void)getProfilePhonesWithView:(UIView*)view
                            mode:(PRRequestMode)mode
                         success:(void (^)(NSArray* selfPhones))success
                         failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] getSelfPhonesForProfileWithSuccess:[DefaultHandler successWithArrayResult:success view:view mode:option]
                                                                     failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)getProfileEmailsWithView:(UIView*)view
                            mode:(PRRequestMode)mode
                         success:(void (^)(NSArray* selfEmails))success
                         failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] getSelfEmailsForProfileWithSuccess:[DefaultHandler successWithArrayResult:success view:view mode:option]
                                                                     failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)getProfileContactsWithView:(UIView*)view
                              mode:(PRRequestMode)mode
                           success:(void (^)(NSArray* selfContacts))success
                           failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] getSelfContactsForProfileWithSuccess:[DefaultHandler successWithArrayResult:success view:view mode:option]
                                                                       failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)getProfileContactPhonesWithContactId:(NSNumber*)contactId
                                        view:(UIView*)view
                                        mode:(PRRequestMode)mode
                                     success:(void (^)(NSArray* contactPhones))success
                                     failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] getProfileContactPhonesWithContactId:contactId
                                                                          view:view
                                                                       success:[DefaultHandler successWithArrayResult:success view:view mode:option]
                                                                       failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)getProfileContactDocumentsWithContactId:(NSNumber*)contactId
                                           view:(UIView*)view
                                           mode:(PRRequestMode)mode
                                        success:(void (^)(NSArray* contactDocuments))success
                                        failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] getProfileContactDocumentsWithContactId:contactId
                                                                             view:view
                                                                          success:[DefaultHandler successWithArrayResult:success view:view mode:option]
                                                                          failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)getProfileContactDocumentWithContactId:(NSNumber*)contactId
                                    documentId:(NSNumber*)documentId
                                          view:(UIView*)view
                                          mode:(PRRequestMode)mode
                                       success:(void (^)(NSArray* contactDocuments))success
                                       failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] getProfileContactDocumentWithContactId:contactId
                                                                      documentId:documentId
                                                                            view:view
                                                                         success:[DefaultHandler successWithArrayResult:success view:view mode:option]
                                                                         failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)getProfileContactEmailsWithContactId:(NSNumber*)contactId
                                        view:(UIView*)view
                                        mode:(PRRequestMode)mode
                                     success:(void (^)(NSArray* contactEmails))success
                                     failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] getProfileContactEmailsWithContactId:contactId
                                                                          view:view
                                                                       success:[DefaultHandler successWithArrayResult:success view:view mode:option]
                                                                       failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)getProfilePhoneTypesWithView:(UIView*)view
                                mode:(PRRequestMode)mode
                             success:(void (^)(NSArray* phoneTypes))success
                             failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] getProfilePhoneTypesWithSuccess:[DefaultHandler successWithArrayResult:success view:view mode:option]
                                                                  failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)getProfileEmailTypesWithView:(UIView*)view
                                mode:(PRRequestMode)mode
                             success:(void (^)(NSArray* emailTypes))success
                             failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] getProfileEmailTypesWithSuccess:[DefaultHandler successWithArrayResult:success view:view mode:option]
                                                                  failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)getProfileContactTypesWithView:(UIView*)view
                                  mode:(PRRequestMode)mode
                               success:(void (^)(NSArray* contactTypes))success
                               failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] getProfileContactTypesWithSuccess:[DefaultHandler successWithArrayResult:success view:view mode:option]
                                                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)getProfileCarsWithView:(UIView*)view
                          mode:(PRRequestMode)mode
                       success:(void (^)(NSArray<PRCarModel*>* profileCars))success
                       failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] getCarsForProfileWithSuccess:[DefaultHandler successWithArrayResult:success view:view mode:option]
                                                               failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)addPhoneForProfile:(PRProfilePhoneModel*)phoneModel
                      view:(UIView*)view
                      mode:(PRRequestMode)mode
                   success:(void (^)())success
                   failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] addPhoneForProfile:phoneModel
                                                     success:[DefaultHandler success:success view:view mode:option]
                                                     failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)addEmailForProfile:(PRProfileEmailModel*)emailModel
                      view:(UIView*)view
                      mode:(PRRequestMode)mode
                   success:(void (^)())success
                   failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] addEmailForProfile:emailModel
                                                     success:[DefaultHandler success:success view:view mode:option]
                                                     failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)addContactForProfile:(PRProfileContactModel*)contactModel
                        view:(UIView*)view
                        mode:(PRRequestMode)mode
                     success:(void (^)(PRProfileContactModel*))success
                     failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] addContactForProfile:contactModel
                                                       success:[DefaultHandler successWithObjectResult:success view:view mode:option]
                                                       failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)addContactPhone:(PRProfileContactPhoneModel*)phoneModel
          withContactId:(NSNumber*)contactId
                   view:(UIView*)view
                   mode:(PRRequestMode)mode
                success:(void (^)())success
                failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] addContactPhone:phoneModel
                                            withContactId:contactId
                                                  success:[DefaultHandler success:success view:view mode:option]
                                                  failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)addContactDocument:(PRProfileContactDocumentModel*)documentModel
             withContactId:(NSNumber*)contactId
                      view:(UIView*)view
                      mode:(PRRequestMode)mode
                   success:(void (^)())success
                   failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] addContactDocument:documentModel
                                               withContactId:contactId
                                                     success:[DefaultHandler success:success view:view mode:option]
                                                     failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)addContactEmail:(PRProfileContactEmailModel*)emailModel
          withContactId:(NSNumber*)contactId
                   view:(UIView*)view
                   mode:(PRRequestMode)mode
                success:(void (^)())success
                failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] addContactEmail:emailModel
                                            withContactId:contactId
                                                  success:[DefaultHandler success:success view:view mode:option]
                                                  failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)addCarForProfile:(PRCarModel*)carModel
                    view:(UIView*)view
                    mode:(PRRequestMode)mode
                 success:(void (^)())success
                 failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{

            [[CRMRestClient sharedClient] addCarForProfile:carModel
                                                   success:[DefaultHandler success:success view:view mode:option]
                                                   failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)updateProfilePhone:(PRProfilePhoneModel*)phoneModel
                      view:(UIView*)view
                      mode:(PRRequestMode)mode
                   success:(void (^)())success
                   failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] updateProfilePhone:phoneModel
                                                     success:[DefaultHandler success:success view:view mode:option]
                                                     failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)updateProfileEmail:(PRProfileEmailModel*)emailModel
                      view:(UIView*)view
                      mode:(PRRequestMode)mode
                   success:(void (^)())success
                   failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] updateProfileEmail:emailModel
                                                     success:[DefaultHandler success:success view:view mode:option]
                                                     failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)updateProfileContact:(PRProfileContactModel*)contactModel
                        view:(UIView*)view
                        mode:(PRRequestMode)mode
                     success:(void (^)())success
                     failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] updateProfileContact:contactModel
                                                       success:[DefaultHandler success:success view:view mode:option]
                                                       failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)updateProfileContactPhone:(PRProfileContactPhoneModel*)phoneModel
                    withContactId:(NSNumber*)contactId
                          phoneId:(NSString*)phoneId
                             view:(UIView*)view
                             mode:(PRRequestMode)mode
                          success:(void (^)())success
                          failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] updateProfileContactPhone:phoneModel
                                                      withContactId:contactId
                                                            phoneId:phoneId
                                                            success:[DefaultHandler success:success view:view mode:option]
                                                            failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)updateProfileContactDocument:(PRProfileContactDocumentModel*)documentModel
                       withContactId:(NSNumber*)contactId
                          documentId:(NSNumber*)documentId
                                view:(UIView*)view
                                mode:(PRRequestMode)mode
                             success:(void (^)())success
                             failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] updateProfileContactDocument:documentModel
                                                         withContactId:contactId
                                                            documentId:documentId
                                                               success:[DefaultHandler success:success view:view mode:option]
                                                               failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)updateProfileContactEmail:(PRProfileContactEmailModel*)emailModel
                    withContactId:(NSNumber*)contactId
                          emailId:(NSString*)emailId
                             view:(UIView*)view
                             mode:(PRRequestMode)mode
                          success:(void (^)())success
                          failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] updateProfileContactEmail:emailModel
                                                      withContactId:contactId
                                                            emailId:emailId
                                                            success:[DefaultHandler success:success view:view mode:option]
                                                            failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)updateCarForProfile:(PRCarModel*)carModel
                       view:(UIView*)view
                       mode:(PRRequestMode)mode
                    success:(void (^)())success
                    failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] updateCarForProfile:carModel
                                                      success:[DefaultHandler success:success view:view mode:option]
                                                      failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)deleteProfilePhoneWithPhoneId:(NSString*)phoneId
                                 view:(UIView*)view
                                 mode:(PRRequestMode)mode
                              success:(void (^)())success
                              failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] deleteProfilePhoneWithPhoneId:phoneId
                                                                success:[DefaultHandler success:success view:view mode:option]
                                                                failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)deleteProfileEmailWithEmailId:(NSString*)emailId
                                 view:(UIView*)view
                                 mode:(PRRequestMode)mode
                              success:(void (^)())success
                              failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] deleteProfileEmailWithEmailId:emailId
                                                                success:[DefaultHandler success:success view:view mode:option]
                                                                failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)deleteProfileContactWithContactId:(NSNumber*)contactId
                                     view:(UIView*)view
                                     mode:(PRRequestMode)mode
                                  success:(void (^)())success
                                  failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] deleteProfileContactWithContactId:contactId
                                                                    success:[DefaultHandler success:success view:view mode:option]
                                                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)deleteProfileContactPhoneWithContactId:(NSNumber*)contactId
                                       phoneId:(NSString*)phoneId
                                          view:(UIView*)view
                                          mode:(PRRequestMode)mode
                                       success:(void (^)())success
                                       failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] deleteProfileContactPhoneWithContactId:contactId
                                                                         phoneId:phoneId
                                                                         success:[DefaultHandler success:success view:view mode:option]
                                                                         failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)deleteProfileContactDocumentWithContactId:(NSNumber*)contactId
                                       documentId:(NSNumber*)documentId
                                             view:(UIView*)view
                                             mode:(PRRequestMode)mode
                                          success:(void (^)())success
                                          failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] deleteProfileContactDocumentWithContactId:contactId
                                                                         documentId:documentId
                                                                            success:[DefaultHandler success:success view:view mode:option]
                                                                            failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)deleteProfileContactEmailWithContactId:(NSNumber*)contactId
                                       emailId:(NSString*)emailId
                                          view:(UIView*)view
                                          mode:(PRRequestMode)mode
                                       success:(void (^)())success
                                       failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] deleteProfileContactEmailWithContactId:contactId
                                                                         emailId:emailId
                                                                         success:[DefaultHandler success:success view:view mode:option]
                                                                         failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)deleteProfileCarWithCarId:(NSNumber*)carId
                             view:(UIView*)view
                             mode:(PRRequestMode)mode
                          success:(void (^)())success
                          failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] deleteProfileCarWithCarId:carId
                                                            success:[DefaultHandler success:success view:view mode:option]
                                                            failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

+ (void)deleteAccount:(UIView *)view
                 mode:(PRRequestMode)mode
              success:(void (^)())success
              failure:(void (^)())failure
{
    [self.class showProgressIfNedded:view mode:mode];

    Request request = ^(Request repeat, PRRequestOption option) {

        [self refreshAccessTokenWithSuccess:^{
            [[CRMRestClient sharedClient] deleteAccount:[DefaultHandler success:success view:view mode:option]
                                                failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
        }
                                    failure:[DefaultHandler failure:failure view:view mode:option repeat:repeat]];
    };
    [self sendRequest:request whitRequestMode:(PRRequestOption)mode];
}

#pragma mark Private Functions
#pragma mark -

+ (void)showProgressIfNedded:(UIView*)view
                        mode:(PRRequestMode)mode
{
    if (mode == PRRequestMode_ShowErrorMessagesAndProgress || mode == PRRequestMode_ShowOnlyProgress) {
        [MBProgressHUD showHUDAddedTo:view animated:YES];
    }
}

#pragma mark - Dealloc

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kReachabilityChangedNotification
                                                  object:nil];
}

@end
