//
//  AFOAuth2Client+BasicAuthentication.m
//  PRIME
//
//  Created by Admin on 14/01/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "AFOAuth2Client+BasicAuthentication.h"
#import "AuthError.h"

@implementation AFOAuth2Client (BasicAuthentication)

+ (instancetype)clientWithBaseURL:(NSURL *)url
                         clientID:(NSString *)clientID
                           secret:(NSString *)secret
{
    AFOAuth2Client *client = [[self alloc] initWithBaseURL:url clientID:@"" secret:@""];
    
    [client setAuthorizationHeaderWithUsername:clientID password:secret];
    
    return client;
}

- (void)authenticateUsingOAuthWithPath:(NSString *)path
                            parameters:(NSDictionary *)parameters
                               success:(void (^)(AFOAuthCredential *credential))success
                               failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSMutableURLRequest *mutableRequest = [self requestWithMethod:@"POST" path:path parameters:parameters];
    [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    AFHTTPRequestOperation *requestOperation = [self HTTPRequestOperationWithRequest:mutableRequest success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject valueForKey:@"error"]) {
            if (failure) {
                // TODO: Resolve the `error` field into a proper NSError object
                // http://tools.ietf.org/html/rfc6749#section-5.2
                failure(nil);
            }
            
            return;
        }
        
        NSString *refreshToken = [responseObject valueForKey:@"refresh_token"];
        if (refreshToken == nil || [refreshToken isEqual:[NSNull null]]) {
            refreshToken = [parameters valueForKey:@"refresh_token"];
        }
        
        AFOAuthCredential *credential = [AFOAuthCredential credentialWithOAuthToken:[responseObject valueForKey:@"access_token"] tokenType:[responseObject valueForKey:@"token_type"]];
        
        NSDate *expireDate = nil;
        id expiresIn = [responseObject valueForKey:@"expires_in"];
        if (expiresIn != nil && ![expiresIn isEqual:[NSNull null]]) {
            expireDate = [NSDate dateWithTimeIntervalSinceNow:[expiresIn doubleValue]];
        }
        
        [credential setRefreshToken:refreshToken expiration:expireDate];
        
        [self setAuthorizationHeaderWithCredential:credential];
        
        if (success) {
            success(credential);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            PRAuthError * authErro = [[PRAuthError alloc] initWithError:error operation:operation];
            
            failure(authErro);
        }
    }];
    
    [self enqueueHTTPRequestOperation:requestOperation];
}

@end