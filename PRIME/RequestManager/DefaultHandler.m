//
//  DefaultHandler.m
//  PRIME
//
//  Created by Admin on 31/01/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "DefaultHandler.h"
#import "PRStatusModel.h"

@interface DefaultHandler ()

@end

@implementation DefaultHandler

+ (void (^)())success:(void (^)())success
                 view:(UIView*)view
                 mode:(PRRequestOption)mode
{
    return ^() {
        [self.class hideProgressIfNedded:view mode:mode];

        if (success) {
            success();
        }
    };
}

+ (void (^)(NSArray* objects))successWithArrayResult:(void (^)(NSArray* objects))success
                                                view:(UIView*)view
                                                mode:(PRRequestOption)mode
{
    return ^(NSArray* objects) {
        [self.class hideProgressIfNedded:view mode:mode];

        if (success) {
            success(objects);
        }
    };
}

+ (void (^)(NSOrderedSet* objects))successWithOrderedSetResult:(void (^)(NSOrderedSet* objects))success
                                                          view:(UIView*)view
                                                          mode:(PRRequestOption)mode
{
    return ^(NSOrderedSet* objects) {
        [self.class hideProgressIfNedded:view mode:mode];

        if (success) {
            success(objects);
        }
    };
}

+ (void (^)(NSObject* object))successWithObjectResult:(void (^)(id object))success
                                                 view:(UIView*)view
                                                 mode:(PRRequestOption)mode
{
    return ^(NSObject* object) {
        [self.class hideProgressIfNedded:view mode:mode];

        if (success) {
            success(object);
        }
    };
}

+ (void (^)(NSInteger statusCode, NSError* error))failure:(void (^)())failure
                                                     view:(UIView*)view
                                                     mode:(PRRequestOption)mode
                                                   repeat:(Request)repeat
{
    return [self.class failure:failure offline:nil unknownUser:nil view:view mode:mode repeat:repeat incorrectPasswordBlock:nil];
}

+ (void (^)(NSInteger statusCode, NSError* error))failure:(void (^)())failure
                                                  offline:(void (^)())offline
                                              unknownUser:(void (^)())unknownUser
                                                     view:(UIView*)view
                                                     mode:(PRRequestOption)mode
                                                   repeat:(Request)repeat
                                   incorrectPasswordBlock:(void (^)())incorrectPasswordBlock
{
    return ^(NSInteger statusCode, NSError* error) {

        void (^failBlock)() = ^{
            if (failure) {
                if (![self.class isErrorCodeOfflineCode:error.code] || !offline) {
                    failure(statusCode,error);
                    if (incorrectPasswordBlock && error.code == kCFURLErrorBadServerResponse) {
                        incorrectPasswordBlock();
                    }
                    return;
                }
            }

            if (offline && [self.class isErrorCodeOfflineCode:error.code]) {
                offline();
                return;
            }
        };

        NSString* errorMessage = ((PRStatusModel*)[error.userInfo[RKObjectMapperErrorObjectsKey] firstObject]).error;

        if ([errorMessage isEqualToString:@"customer_not_found"]) {

            if (unknownUser) {
                unknownUser();
            }

            [self.class hideProgressIfNedded:view mode:mode];
            return;
        }

        // Repeat the same request only in case when device has no internet connection or when the request timed out.
        if (repeat && (mode & PRRequestOption_Repeat) && ([self.class isErrorCodeOfflineCode:error.code] || error.code == kCFURLErrorTimedOut || incorrectPasswordBlock)) {
            repeat(repeat, mode);
            return;
        }

        [self.class hideProgressIfNedded:view mode:mode];

        if (repeat && ![self.class isErrorCodeOfflineCode:error.code] && (mode & (PRRequestMode_ShowErrorMessagesAndProgress | PRRequestMode_ShowOnlyErrorMessages))) {

            [PRMessageAlert showMessageWithStatus:statusCode
                                                error:error
                                                   ok:failBlock
                                               repeat:repeat];
        } else {
            failBlock();
        }
    };
}

+ (void (^)(NSInteger statusCode, NSError* error))failure:(void (^)())failure
                                                  offline:(void (^)())offline
                                              unknownCard:(void (^)())unknownCard
                                                     view:(UIView*)view
                                                     mode:(PRRequestOption)mode
                                                   repeat:(Request)repeat
{
    return ^(NSInteger statusCode, NSError* error) {

        void (^failBlock)() = ^{
            if (failure) {
                if (![self.class isErrorCodeOfflineCode:error.code] || !offline) {
                    failure(statusCode, error);
                    return;
                }
            }

            if (offline && [self.class isErrorCodeOfflineCode:error.code]) {
                offline();
                return;
            }
        };

        // If the status code is equal to 404 it means that the card number is not found in the list of valid cards.
        if (statusCode == 404) {
            if (unknownCard) {
                unknownCard();
            }

            [self.class hideProgressIfNedded:view mode:mode];
            return;
        }

        // Repeat the same request only in case when device has no internet connection or when the request timed out.
        if (repeat && (mode & PRRequestOption_Repeat) && ([self.class isErrorCodeOfflineCode:error.code] || error.code == kCFURLErrorTimedOut)) {
            repeat(repeat, mode);
            return;
        }

        [self.class hideProgressIfNedded:view mode:mode];

        if (repeat && ![self.class isErrorCodeOfflineCode:error.code] && (mode & (PRRequestMode_ShowErrorMessagesAndProgress | PRRequestMode_ShowOnlyErrorMessages))) {

            [PRMessageAlert showMessageWithStatus:statusCode
                                                error:error
                                                   ok:failBlock
                                               repeat:repeat];
        } else {
            failBlock();
        }
    };
}

#pragma mark Private Functions
#pragma mark -

+ (void)hideProgressIfNedded:(UIView*)view
                        mode:(PRRequestOption)mode
{
    if ((mode & PRRequestMode_ShowErrorMessagesAndProgress) || (mode & PRRequestMode_ShowOnlyProgress)) {
        [MBProgressHUD hideHUDForView:view
                             animated:YES];
    }
}

+ (BOOL)isErrorCodeOfflineCode:(NSInteger)code
{
    if (code == kCFURLErrorNotConnectedToInternet || code == kCFURLErrorInternationalRoamingOff || code == kCFURLErrorNetworkConnectionLost) {
        return YES;
    }
    return NO;
}

@end
