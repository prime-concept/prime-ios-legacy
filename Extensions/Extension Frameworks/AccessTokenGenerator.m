//
//  Authorization.m
//  SiriPrime
//
//  Created by Hamlet on 11/6/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import "AccessTokenGenerator.h"
#import <RestKit/RestKit.h>
#import <RestKit/Search/RKManagedObjectStore+RKSearchAdditions.h>
#import "Constants.h"
#import "XNTKeychainStore.h"
#import "NSObject+Keychain.h"
#import "AESCrypt.h"
#import "Config.h"

@interface AccessTokenGenerator ()
@property (strong, nonatomic) NSUserDefaults* extensionsDefault;
@property (strong, nonatomic) NSUserDefaults* siriDefault;

@end

@implementation AccessTokenGenerator


- (id)init
{
    self = [super init];
    if (self) {
        self.extensionsDefault = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
        self.siriDefault = [[NSUserDefaults alloc] initWithSuiteName:kSiriUserDefaultsSuiteName];
    }
    return self;
}
- (void)setupObjectManagerForAuthorization
{
    // Initialize RestKit Object Manager.
    NSURL* url = [NSURL URLWithString:Config.crmEndpoint];

    AFOAuth2Client* oauthClient = [AFOAuth2Client clientWithBaseURL:url clientID:kClientID secret:kClientSecret];

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

- (void)authorizeWithUsername:(NSString*)username
                      success:(void (^)(AFOAuthCredential* credential))success
                      failure:(void (^)())failure
{
    NSString* password = [self decryptedPassword];
    [self generateAccessTokenForUsername:username
                                password:password
                                 success:^(AFOAuthCredential* credential) {
                                     [XNTKeychainStore setDefaultIdentifier:username];
                                     [XNTKeychainStore setDefaultKeyPrefix:username];

                                     BOOL b = [credential storeToKeychainWithKey:kCredentialKeyPath];
                                     success(credential);
                                     NSAssert(b, @"Credentials are not saved");
                                 }
                                 failure:^(NSInteger statusCode, NSError* error){

                                 }];
}

- (void)generateAccessTokenForUsername:(NSString*)username
                              password:(NSString*)password
                               success:(void (^)(AFOAuthCredential* credential))success
                               failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    [self setupObjectManagerForAuthorization];

    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSAssert([manager.HTTPClient isKindOfClass:[AFOAuth2Client class]],
        @"manager.HTTPClient should be instance of AFOAuth2Client class!");

    AFOAuth2Client* oauthClient = (AFOAuth2Client*)[manager HTTPClient];

    [oauthClient authenticateUsingOAuthWithPath:kAuthorizationPath
                                       username:username
                                       password:password
                                          scope:@"private"
                                        success:^(AFOAuthCredential* credential) {
                                            [oauthClient setAuthorizationHeaderWithToken:credential.accessToken];
                                            success(credential);
                                        }
                                        failure:^(NSError* error) {
                                        }];
}

- (void)refreshAccessTokenWithSuccess:(void (^)())success
                              failure:(void (^)())failure
{
    AFOAuthCredential* credential = [AFOAuthCredential objectFromKeychainWithKey:kCredentialKeyPath];
    if (!credential) {
        [self generateAccessTokenWithAuthorize:^{
            success();
        }
            failure:^{
                NSMutableDictionary* errorDetail = [NSMutableDictionary dictionary];
                [errorDetail setValue:@"Failed to get credentials" forKey:NSLocalizedDescriptionKey];
                NSError* error = [NSError errorWithDomain:@"world" code:405 userInfo:errorDetail];
                failure(405, error);
            }];
        return;
    }

    if (!credential.isExpired) {
        success();
        return;
    }

    [self refreshAccessToken:credential.refreshToken
                     success:^(AFOAuthCredential* credential) {
                         BOOL b = [credential storeToKeychainWithKey:kCredentialKeyPath];
                         [self.extensionsDefault setObject:credential.accessToken forKey:kAccessTokenKey];
                         [self.siriDefault setObject:credential.accessToken forKey:kAccessTokenKey];

                         NSAssert(b, @"Credentials are not saved");
                         success();
                     }
                     failure:failure];
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
                                        failure:^(NSError* error){
                                        }];
}

- (NSString*)decryptedPassword
{
    NSString* phone = [self.extensionsDefault objectForKey:kUserPhoneNumber];
    NSString* customerId = [self.extensionsDefault objectForKey:kCustomerId];

    if (!phone && !customerId) {
        phone = [self.siriDefault objectForKey:kUserPhoneNumber];
        customerId = [self.siriDefault objectForKey:kCustomerId];
    }

    NSString* keychainPrefix = customerId ? customerId : phone;

    NSString* storedPassword = [XNTKeychainStore stringForKey:[keychainPrefix stringByAppendingString:kPasscodeKey]
                                                   identifier:kOwnerIdentifier
                                                      service:kServiceNameForExtensions
                                                  accessGroup:kSiriUserDefaultsSuiteName];

    if (!storedPassword) {
        storedPassword = [XNTKeychainStore stringForKey:[keychainPrefix stringByAppendingString:kPasscodeKey]
                                             identifier:kOwnerIdentifier
                                                service:kServiceNameForExtensions
                                            accessGroup:kUserDefaultsSuiteName];
    }

    NSString* result = storedPassword.length == 4 ? storedPassword : [AESCrypt decrypt:storedPassword password:kClientSecret];
    return result;
}

- (void)generateAccessTokenWithAuthorize:(void (^)(void))success
                                 failure:(void (^)(void))failure
{
    NSString* userName = [self.extensionsDefault valueForKey:kCustomerId];
    if (!userName) {
        userName = [self.siriDefault valueForKey:kCustomerId];
    }
    [self authorizeWithUsername:userName
        success:^(AFOAuthCredential* credential) {
            NSString* newAccessToken = credential.accessToken;
            [self.extensionsDefault setObject:newAccessToken forKey:kAccessTokenKey];
            [self.siriDefault setObject:newAccessToken forKey:kAccessTokenKey];
            success();
        }
        failure:^{
            failure();
        }];
}
@end
