//
//  SendMessageIntentHandler.m
//  SiriPrime
//
//  Created by Hamlet on 10/25/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import "SendMessageIntentHandler.h"
#import "PRURLSessionRequestManager.h"
#import "ChatUtility.h"
#import "Constants.h"
#import "NSObject+Motis.h"
#import "WebSocketConstants.h"
#import "AccessTokenGenerator.h"
#import "XNTKeychainStore.h"

@interface SendMessageIntentHandler ()

@property (strong, nonatomic) PRURLSessionRequestManager* sessionManager;
@property (strong, nonatomic) NSUserDefaults* defaults;

@end

@implementation SendMessageIntentHandler

- (void)resolveContentForSendMessage:(INSendMessageIntent *)intent withCompletion:(void (^)(INStringResolutionResult *resolutionResult))completion {
    NSString *text = intent.content;
    if (text && ![text isEqualToString:@""]) {
        completion([INStringResolutionResult successWithResolvedString:text]);
    } else {
        completion([INStringResolutionResult needsValue]);
    }
}

// Once resolution is completed, perform validation on the intent and provide confirmation (optional).

- (void)confirmSendMessage:(INSendMessageIntent *)intent completion:(void (^)(INSendMessageIntentResponse *response))completion {
    // Verify user is authenticated and your app is ready to send a message.

    NSUserActivity *userActivity = [[NSUserActivity alloc] initWithActivityType:NSStringFromClass([INSendMessageIntent class])];
    INSendMessageIntentResponse *response = [[INSendMessageIntentResponse alloc] initWithCode:INSendMessageIntentResponseCodeReady userActivity:userActivity];
    completion(response);
}

- (void)handleSendMessage:(INSendMessageIntent *)intent completion:(void (^)(INSendMessageIntentResponse *response))completion {
    // Implement your application logic to send a message here.

    NSUserActivity *userActivity = [[NSUserActivity alloc] initWithActivityType:NSStringFromClass([INSendMessageIntent class])];
    __block INSendMessageIntentResponse *response;
    _defaults = [[NSUserDefaults alloc] initWithSuiteName:kSiriUserDefaultsSuiteName];
    NSString* userName = [_defaults objectForKey:kCustomerId];
    if (!userName) {
        response = [[INSendMessageIntentResponse alloc] initWithCode:INSendMessageIntentResponseCodeFailure userActivity:userActivity];
        completion(response);
    }
    NSDictionary* messageDictionary = [self createMessageDictionaryWithMessage:intent.content forChannelWithID:userName];
    AccessTokenGenerator* tokenGenerator = [[AccessTokenGenerator alloc] init];

    NSString* uniqueDeviceID = [self getUniqueDeviceIdentifierAsString];

    if (!self.sessionManager) {
        self.sessionManager = [[PRURLSessionRequestManager alloc] init];
    }
    __weak SendMessageIntentHandler* weakSelf = self;

    if([_defaults objectForKey:kAccessTokenKey]) {
        [tokenGenerator refreshAccessTokenWithSuccess:^{
            SendMessageIntentHandler* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            [strongSelf sendMessage:messageDictionary toChannelWithID:userName withAccessToken:[_defaults objectForKey:kAccessTokenKey] andWithDeviceID:uniqueDeviceID :^{
                response = [[INSendMessageIntentResponse alloc] initWithCode:INSendMessageIntentResponseCodeSuccess userActivity:userActivity];
                completion(response);
            } failure:^{
                response = [[INSendMessageIntentResponse alloc] initWithCode:INSendMessageIntentResponseCodeFailure userActivity:userActivity];
                completion(response);
            }];
        } failure:^{
            response = [[INSendMessageIntentResponse alloc] initWithCode:INSendMessageIntentResponseCodeFailure userActivity:userActivity];
            completion(response);
        }];
    } else {
        [tokenGenerator authorizeWithUsername:userName success:^(AFOAuthCredential *credential) {
            NSString* newAccessToken = credential.accessToken;
            [_defaults setObject:newAccessToken forKey:kAccessTokenKey];
            [self sendMessage:messageDictionary toChannelWithID:userName withAccessToken:newAccessToken andWithDeviceID:uniqueDeviceID :^{
                response = [[INSendMessageIntentResponse alloc] initWithCode:INSendMessageIntentResponseCodeSuccess userActivity:userActivity];
                completion(response);
            } failure:^{
                response = [[INSendMessageIntentResponse alloc] initWithCode:INSendMessageIntentResponseCodeFailure userActivity:userActivity];
                completion(response);
            }];
        } failure:^{
            response = [[INSendMessageIntentResponse alloc] initWithCode:INSendMessageIntentResponseCodeFailure userActivity:userActivity];
            completion(response);
        }];
    }
}

-(void)sendMessage:(NSDictionary*)message toChannelWithID:userName withAccessToken:accessToken andWithDeviceID:uniqueDeviceID :(void (^)(void))success
           failure:(void (^)(void))failure
{
    [self.sessionManager sendMessage:message
                           toChannel:userName
                     withAccessToken:accessToken
                        withDeviceID:uniqueDeviceID
                             success:^{
                                success();
                             }
                             failure:^(NSInteger statusCode, NSError* error) {
                                               failure();
                             }];
}

-(NSDictionary*)createMessageDictionaryWithMessage:(NSString*)message forChannelWithID:(NSString*)channelId {
    NSMutableDictionary* messageDictonary = [NSMutableDictionary new];
    NSString* guid = [[NSUUID UUID] UUIDString];
    NSNumber* timeStamp = @((long)[[NSDate new] timeIntervalSince1970]);

    [messageDictonary setValue:[kClientPrefix stringByAppendingString:channelId] forKey:kClientId];
    [messageDictonary setValue:[kMainChatPrefix stringByAppendingString:channelId] forKey:kChannelId];
    [messageDictonary setValue:message forKey:kContent];
    [messageDictonary setValue:guid forKey:kGuidKey];
    [messageDictonary setValue:@"SIRI" forKey:kSource];
    [messageDictonary setValue:@"NEW" forKey:kStatus];
    [messageDictonary setValue:timeStamp forKey:kTimestamp];
    [messageDictonary setValue:@"TEXT" forKey:kTypeKey];

    return messageDictonary;
}

-(NSString*)getUniqueDeviceIdentifierAsString
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

@end
