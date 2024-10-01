//
//  PRMessageProcessingManager.h
//  PRIME
//
//  Created by Aram on 11/20/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PRMessageProcessingManager : NSObject

+ (PRMessageProcessingManager*)sharedInstance;

+ (void)getMessagesForChannelId:(NSString*)channelId
                           guid:(NSString*)guid
                          limit:(NSNumber*)limit
                         toDate:toDate
                       fromDate:fromDate
                        success:(void (^)(NSArray<PRMessageModel*>* messages))success
                        failure:(void (^)())failure;

+ (void)updateMessageStatus:(NSString*)status
                       guid:(NSString*)guid;

+ (void)updateMessagesStatusForCompletedTasks;

+ (PRMessageModel*)sendMessage:(NSString*)message toChannelWithID:(NSString*)ChannelID;
+ (void)sendMessage:(NSString*)messageText toChannelWithID:(NSString*)channelId withBackgroundTask:(UIBackgroundTaskIdentifier)task;
+ (PRMessageModel*)sendVoiceMessage:(NSData*)message toChannelWithID:(NSString*)channelId;
+ (PRMessageModel*)sendMediaMessage:(NSData*)mediaData
                           mimeType:(NSString*)mimeType
                        messageType:(NSString*)messageType
                    toChannelWithID:(NSString*)channelId
                            success:(void (^)(PRMediaMessageModel* mediaMessageModel))success
                            failure:(void (^)(NSInteger statusCode, NSError* error))failure;
+ (void)resetMessageState:(PRMessageModel*)modelToSend;
+ (void)getAudioFileForVoiceMessage:(PRMessageModel*)messageModel;
+ (void)getFileForMediaMessage:(PRMessageModel*)messageModel;
+ (void)getMediaFileFromPath:(NSString*)path
                     success:(void (^)(NSData* mediaFile))success
                     failure:(void (^)(NSInteger statusCode, NSError* error))failure;
+ (void)getMediaInfoWithUUID:(NSString*)uuid
                     success:(void (^)(NSData* documentInfoData))success
                     failure:(void (^)(NSInteger statusCode, NSError* error))failure;
+ (void)getMediaUploadProgress:(NSString*)uuid currentPercent:(void (^)(NSNumber* percent))currentPercent;
+ (NSArray<PRMessageModel*>*)filterMessages:(NSArray<PRMessageModel*>*)messages withTimestamp:(NSNumber*)timestamp;
+ (NSArray<PRMessageModel*>*)getMessagesInRange:(NSInteger)messagesCount forChannelId:(NSString*)channelId;
+ (BOOL)hasExpiredMessages:(NSArray<PRMessageModel*>*)messages;

@end
