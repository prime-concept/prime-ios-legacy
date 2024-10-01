//
//  AFOAuth2Client+BasicAutohorization.h
//  SiriPrime
//
//  Created by Hamlet on 11/6/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import "AFOAuth2Client.h"

@interface AFOAuth2Client (BasicAutohorization)

+ (instancetype)clientWithBaseURL:(NSURL *)url
                         clientID:(NSString *)clientID
                           secret:(NSString *)secret;

- (void)authenticateUsingOAuthWithPath:(NSString *)path
                            parameters:(NSDictionary *)parameters
                               success:(void (^)(AFOAuthCredential *credential))success
                               failure:(void (^)(NSError *error))failure;

@end
