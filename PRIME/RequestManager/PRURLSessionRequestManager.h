//
//  PRURLSessionRequestManager.h
//  PRIME
//
//  Created by Sargis Terteryan on 7/23/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PRURLSessionRequestManager : NSObject

- (void)makeURLSessionRequest:(NSString*)path success:(void (^)(NSArray* response))success
                                             failure:(void (^)(void))failure;
- (void)saveMessagesForWidgetWithURLSession:(NSArray*)messages;
- (void)createDataForCityGuideInWIdgetWithURLSession:(NSArray*)data;
- (void)setWidgetRequestsWithURLSession:(NSArray*)array;
- (void)setWidgetEventsWithURLSession:(NSArray*)data;
- (void)sendMessage:(NSDictionary*)message
          toChannel:(NSString*)channelId
    withAccessToken:(NSString*)accessToken
       withDeviceID:(NSString *)deviceID
            success:(void (^)(void))success
            failure:(void (^)(NSInteger statusCode, NSError* error))failure;
- (void)downloadFileWithPath:(NSString*)path
                     success:(void (^)(NSData* fileData))success
                     failure:(void (^)(NSInteger statusCode, NSError* error))failure;
- (void)getMediaInfoWithUUID:(NSString *)uuid
                     success:(void (^)(NSData *))success
                     failure:(void (^)(NSInteger, NSError *))failure;

@end
