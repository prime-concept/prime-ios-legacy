//
//  AuthError.m
//  PRIME
//
//  Created by Admin on 2/4/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "AuthError.h"
#import "PRStatusModel.h"

@implementation PRAuthError

+ (NSDictionary*) userInfoFromOperation: (AFHTTPRequestOperation*)operation
                                 error: (NSError*) error
{
    @try {
        NSError *jsonError;
        // It ensures that application won't crash in the case when responseString is null
        NSData *objectData = [operation.responseString ?: @"" dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];

        PRStatusModel *model = [[PRStatusModel alloc] init];
        model.error = json[@"error"];
        model.errorDescription = json[@"error_description"];

        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:error.userInfo];
        userInfo[RKObjectMapperErrorObjectsKey] = @[model];
        return userInfo;
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }

    return error.userInfo;
}

-(instancetype) initWithError:(NSError*)error operation:(AFHTTPRequestOperation*)operation
{
    self = [super initWithDomain:error.domain code:error.code userInfo: [PRAuthError userInfoFromOperation: operation
                                                                                                     error: error]];
    if (self) {
        _operation = operation;
    }

    return  self;
}
@end
