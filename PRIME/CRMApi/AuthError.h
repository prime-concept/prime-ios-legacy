//
//  AuthError.h
//  PRIME
//
//  Created by Admin on 2/4/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperation.h"

@interface PRAuthError : NSError

-(instancetype) initWithError:(NSError*)error operation:(AFHTTPRequestOperation*)operation;

@property (strong, nonatomic) AFHTTPRequestOperation *operation;

@end
