//
//  AFOAuth2Client+BasicAuthentication.h
//  PRIME
//
//  Created by Simon on 14/01/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#ifndef PRIME_AFOAuth2Client_BasicAuthentication_h
#define PRIME_AFOAuth2Client_BasicAuthentication_h

#import "AFOAuth2Client.h"

@interface AFOAuth2Client (BasicAuthentication)

+ (instancetype)clientWithBaseURL:(NSURL *)url
                         clientID:(NSString *)clientID
                           secret:(NSString *)secret;

- (void)authenticateUsingOAuthWithPath:(NSString *)path
                            parameters:(NSDictionary *)parameters
                               success:(void (^)(AFOAuthCredential *credential))success
                               failure:(void (^)(NSError *error))failure;

@end

#endif
