//
//  Authorization.h
//  SiriPrime
//
//  Created by Hamlet on 11/6/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFOAuth2Client+BasicAuthentication.h"

@interface AccessTokenGenerator : NSObject

-(void)authorizeWithUsername:(NSString*)username
                     success:(void (^)(AFOAuthCredential *credential))success
                     failure:(void (^)())failure;

-(void)refreshAccessTokenWithSuccess:(void (^)())success
                             failure:(void (^)())failure;

@end
