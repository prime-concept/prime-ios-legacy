//
//  DefaultHandler.h
//  PRIME
//
//  Created by Admin on 31/01/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#ifndef PRIME_DefaultHandler_h
#define PRIME_DefaultHandler_h

typedef void (^Request)(id, PRRequestOption mode);

@interface DefaultHandler : NSObject

+ (void (^)())success:(void (^)())success
                 view:(UIView*)view
                 mode:(PRRequestOption)mode;

+ (void (^)(NSArray* objects))successWithArrayResult:(void (^)(NSArray* objects))success
                                                view:(UIView*)view
                                                mode:(PRRequestOption)mode;

+ (void (^)(NSOrderedSet* objects))successWithOrderedSetResult:(void (^)(NSOrderedSet* objects))success
                                                          view:(UIView*)view
                                                          mode:(PRRequestOption)mode;

+ (void (^)(NSObject* object))successWithObjectResult:(void (^)(id object))success
                                                 view:(UIView*)view
                                                 mode:(PRRequestOption)mode;

+ (void (^)(NSInteger statusCode, NSError* error))failure:(void (^)())failure
                                                     view:(UIView*)view
                                                     mode:(PRRequestOption)mode
                                                   repeat:(Request)repeat;

+ (void (^)(NSInteger statusCode, NSError* error))failure:(void (^)())failure
                                                  offline:(void (^)())offline
                                              unknownUser:(void (^)())unknownUser
                                                     view:(UIView*)view
                                                     mode:(PRRequestOption)mode
                                                   repeat:(Request)repeat
                                   incorrectPasswordBlock:(void (^)())incorrectPasswordBlock;

+ (void (^)(NSInteger statusCode, NSError* error))failure:(void (^)())failure
                                                  offline:(void (^)())offline
                                              unknownCard:(void (^)())unknownUser
                                                     view:(UIView*)view
                                                     mode:(PRRequestOption)mode
                                                   repeat:(Request)repeat;
@end

#endif
