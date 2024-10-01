//
//  PRMessageProcessingManager.m
//  PRIME
//
//  Created by Aram on 11/20/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRMessageProcessingManager.h"
#import "ChatUtility.h"
#import "PRAudioPlayer.h"
#import "ImageProcessing.h"

@interface PRMessageProcessingManager ()
@property (nonatomic, strong) NSTimer* timer;

@end

@implementation PRMessageProcessingManager

+ (PRMessageProcessingManager*)sharedInstance
{
    static PRMessageProcessingManager* sender = nil;

    pr_dispatch_once({
        sender = [PRMessageProcessingManager new];

        sender.timer = [NSTimer scheduledTimerWithTimeInterval:kResendMessagesTimerInterval
                                                        target:sender
                                                      selector:@selector(resendMessages)
                                                      userInfo:nil
                                                       repeats:YES];
    });

    return sender;
}

+ (void)getMessagesForChannelId:(NSString*)channelId
                           guid:(NSString*)guid
                          limit:(NSNumber*)limit
                         toDate:(NSNumber*)toDate
                       fromDate:(NSNumber*)fromDate
                        success:(void (^)(NSArray<PRMessageModel*>* messages))success
                        failure:(void (^)())failure
{
    [PRRequestManager getMessagesForChannelId:channelId
                                         guid:guid
                                        limit:limit
                                       toDate:toDate
                                     fromDate:fromDate
                                      success:^(NSArray<PRMessageModel*>* messages) {

                                          success(messages);

                                          if ([messages count]) {
                                              for (PRMessageModel* model in messages) {
                                                  model.isReceivedFromServer = YES;
                                                  [model save];
                                              }

                                              [self getFilesForMediaMessages:messages];
                                              [self getAudioFilesForVoiceMessages:messages];
                                              NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
                                              [notificationCenter postNotificationName:kMessageReceived object:channelId];
                                          }

                                      }
                                      failure:failure];
}

+ (void)updateMessageStatus:(NSString*)status
                       guid:(NSString*)guid
{
    PRMessageStatusModel* statusUpdate = [self.class statusUpdateModelForMessageWithGuid:guid status:status];

    [self.class updateMessageStatus:statusUpdate];
}

+ (void)updateMessageStatus:(PRMessageStatusModel*)statusUpdateModel
{
    [PRRequestManager updateMessageStatus:statusUpdateModel
        success:^{
            [self.class finishedToUpdateStatusForModel:statusUpdateModel isDelivered:YES];
        }
        failure:^{
            [self.class finishedToUpdateStatusForModel:statusUpdateModel isDelivered:NO];
        }];
}

+ (void)updateMessagesStatusForCompletedTasks
{
    NSManagedObjectContext* mainContext = [NSManagedObjectContext MR_contextForCurrentThread];
    NSArray<PRMessageModel*>* unseenMessagesForComplatedTasks = [PRDatabase getUnseenMessagesForComplatedTasks:mainContext];

    [mainContext MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError* _Nullable error) {
        for (PRMessageModel* messageModel in unseenMessagesForComplatedTasks) {
            [self.class updateMessageStatus:kMessageStatus_Seen guid:messageModel.guid];
            messageModel.status = kMessageStatus_Seen;
        }
    }];
}

+ (PRMessageModel*)sendMessage:(NSString*)messageText toChannelWithID:(NSString*)channelId
{
    PRMessageModel* message = [self.class messageWithContent:messageText type:kMessageType_Text mimeType:@"" andChannelId:channelId];
    [self.class sendMessage:message];

    return message;
}

+ (void)sendMessage:(NSString*)messageText toChannelWithID:(NSString*)channelId withBackgroundTask:(UIBackgroundTaskIdentifier)task
{
    PRMessageModel* message = [self.class messageWithContent:messageText type:kMessageType_Text mimeType:@"" andChannelId:channelId];

    __block UIBackgroundTaskIdentifier blockTask = task;

    [PRRequestManager sendMessageFromReplyAction:message
        success:^{
             [self.class setMessageStatus:kMessageStatus_Sent state:MessageState_FinishedSending isSent:YES message:message];
            if (blockTask != UIBackgroundTaskInvalid) {
                [[UIApplication sharedApplication] endBackgroundTask:blockTask];
                blockTask = UIBackgroundTaskInvalid;
            }
        }
        failure:^(NSInteger statusCode, NSError* error) {
            MessageState messageState = (message.state == MessageState_Sending) ? MessageState_FinishedSending : message.state;
            [self.class setMessageStatus:message.status state:messageState isSent:NO message:message];
        }];
}

+ (void)sendMessageGuid:(NSString*)guid
{
    PRMessageModel* messageModel = [PRDatabase messageByGuid:guid];
    if (messageModel) {
        [self.class sendMessage:messageModel];
    }
}

+ (void)sendMessage:(PRMessageModel*)message
{
    [PRRequestManager sendMessage:message
        success:^{
            [self.class setMessageStatus:kMessageStatus_Sent state:MessageState_FinishedSending isSent:YES message:message];
        }
        failure:^(NSInteger statusCode, NSError* error) {
            MessageState messageState = (message.state == MessageState_Sending) ? MessageState_FinishedSending : message.state;
            [self.class setMessageStatus:message.status state:messageState isSent:NO message:message];
        }];
}

+ (PRMessageModel*)sendVoiceMessage:(NSData*)audioData toChannelWithID:(NSString*)channelId
{
    PRMessageModel* messageModel = [self.class messageWithContent:audioData type:kMessageType_VoiceMessage mimeType:@"" andChannelId:channelId];
    [self sendAudioData:audioData forMessageWithGuid:messageModel.guid];

    return messageModel;
}

+ (void)sendAudioData:(NSData*)audioData forMessageWithGuid:(NSString*)guid
{
    NSManagedObjectContext* mainContext = [NSManagedObjectContext MR_contextForCurrentThread];

    [PRRequestManager sendAudioFile:audioData
        success:^(PRVoiceMessageModel* voiceMessageModel) {

            PRMessageModel* messageModel = [PRDatabase messageByGuid:guid inContext:mainContext];

            messageModel.text = voiceMessageModel.path;
            messageModel.audioData = nil;

            [mainContext MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError* _Nullable error) {
                [self.class sendMessageGuid:guid];
            }];
        }
        failure:^(NSInteger statusCode, NSError* error) {

            PRMessageModel* messageModel = [PRDatabase messageByGuid:guid inContext:mainContext];

            messageModel.audioData = audioData;
            messageModel.state = MessageState_Aborted;
            messageModel.isSent = NO;

            [mainContext MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError* _Nullable error) {
                NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
                [notificationCenter postNotificationName:kMessageStatusUpdated object:messageModel];
            }];
        }];
}

+ (PRMessageModel*)sendMediaMessage:(NSData*)mediaData
                           mimeType:(NSString*)mimeType
                        messageType:(NSString*)messageType
                    toChannelWithID:(NSString*)channelId
                            success:(void (^)(PRMediaMessageModel *))success
                            failure:(void (^)(NSInteger, NSError *))failure
{
    PRMessageModel* messageModel = [self.class messageWithContent:mediaData type:messageType mimeType:mimeType andChannelId:channelId];
    [self sendMediaData:mediaData
               mimeType:mimeType
     forMessageWithGuid:messageModel.guid
                success:success
                failure:failure];

    return messageModel;
}

+ (void)sendMediaData:(NSData*)mediaData
             mimeType:(NSString*)mimeType
   forMessageWithGuid:(NSString*)guid
              success:(void (^)(PRMediaMessageModel *))success
              failure:(void (^)(NSInteger, NSError *))failure
{
    NSManagedObjectContext* mainContext = [NSManagedObjectContext MR_contextForCurrentThread];

    [PRRequestManager sendMediaFile:mediaData
                           mimeType:mimeType
                            success:^(PRMediaMessageModel* mediaMessageModel) {

                                PRMessageModel* messageModel = [PRDatabase messageByGuid:guid inContext:mainContext];

                                messageModel.text = mediaMessageModel.path;
                                messageModel.mediaData = nil;

                                [mainContext MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError* _Nullable error) {
                                    [self.class sendMessageGuid:guid];
                                }];

                                success(mediaMessageModel);
                            }
                            failure:^(NSInteger statusCode, NSError* error) {

                                PRMessageModel* messageModel = [PRDatabase messageByGuid:guid inContext:mainContext];

                                messageModel.state = MessageState_Aborted;
                                messageModel.isSent = NO;
                                messageModel.mediaData = mediaData;

                                [mainContext MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError* _Nullable error) {
                                    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
                                    [notificationCenter postNotificationName:kMessageStatusUpdated object:messageModel];
                                }];

                                failure(statusCode, error);
                            }];
}

+ (void)getMediaUploadProgress:(NSString*)uuid currentPercent:(void (^)(NSNumber* percent))currentPercent
{
    [PRRequestManager getMediaUploadStatus:uuid
                                   success:^(NSNumber* percent){
                                       currentPercent(percent);
                                   }
                                   failure:^(NSInteger statusCode, NSError* error){
                                       currentPercent(@(-1));
                                   }];
}

+ (void)resendMediaData:(NSData*)mediaData forMessageWithGuid:(NSString*)guid
{
    NSManagedObjectContext* mainContext = [NSManagedObjectContext MR_contextForCurrentThread];
    PRMessageModel* messageModel = [PRDatabase messageByGuid:guid inContext:mainContext];

    messageModel.state = MessageState_Sending;
    [mainContext MR_saveToPersistentStoreAndWait];

    [self.class sendMediaData:messageModel.mediaData mimeType:messageModel.mimeType forMessageWithGuid:messageModel.guid success:^(PRMediaMessageModel *) {} failure:^(NSInteger, NSError *) {}];
}

+ (void)resendAudioData:(NSData*)audioData forMessageWithGuid:(NSString*)guid
{
    NSManagedObjectContext* mainContext = [NSManagedObjectContext MR_contextForCurrentThread];
    PRMessageModel* messageModel = [PRDatabase messageByGuid:guid inContext:mainContext];

    messageModel.state = MessageState_Sending;
    [mainContext MR_saveToPersistentStoreAndWait];

    [self.class sendAudioData:messageModel.audioData forMessageWithGuid:messageModel.guid];
}

+ (PRMessageStatusModel*)statusUpdateModelForMessageWithGuid:(NSString*)guid status:(NSString*)status
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"guid = %@", guid];
    NSArray<PRMessageStatusModel*>* objects = [PRMessageStatusModel MR_findAllWithPredicate:predicate];
    NSAssert([objects count] <= 1, @"In database can not be two object with same guid.");

    PRMessageStatusModel* model = [objects lastObject];

    if (!model) {
        model = [PRMessageStatusModel MR_createEntity];
        model.delivered = NO;
        model.state = MessageState_Sending;
        model.guid = guid;
        model.status = status;
    }

    return model;
}

+ (PRMessageModel*)messageWithContent:(NSObject*)content type:(NSString*)type mimeType:(NSString*)mimeType andChannelId:(NSString*)channelId;
{
    NSString* guid = [[NSUUID UUID] UUIDString];

    if ([content isKindOfClass:[NSData class]]) {
        if([type isEqualToString:kMessageType_Image])
        {
            UIImage* originalImage = [UIImage imageWithData:(NSData*)content];
            UIImage *minImage = [ImageProcessing miniImageFromOriginal:originalImage sideMaxSize:200];
            [PRAudioPlayer saveAudioDataInFile:UIImageJPEGRepresentation(minImage, 0.5) withIdentifier:[NSString stringWithFormat:@"%@_min", guid]];
            [PRAudioPlayer saveAudioDataInFile:(NSData*)content withIdentifier:guid];
        }
        else if([type isEqualToString:kMessageType_Contact])
        {
            NSArray<CNContact*> *contacts = [CNContactVCardSerialization contactsWithData:(NSData*)content error:nil];
            NSData* contactData = [NSKeyedArchiver archivedDataWithRootObject:[contacts firstObject]];
            [PRAudioPlayer saveAudioDataInFile:contactData withIdentifier:guid];
        }
        else if([type isEqualToString:kMessageType_Location])
        {
            NSDictionary* locationDictionary = [NSJSONSerialization JSONObjectWithData:(NSData*)content options:kNilOptions error:nil];
            NSData *snapshotData = [[NSData alloc] initWithBase64EncodedString:[locationDictionary valueForKey:kLocationMessageSnapshotKey]
                                                                       options:NSDataBase64DecodingIgnoreUnknownCharacters];
            NSMutableDictionary* finalLocationDictionary = [NSMutableDictionary new];
            [finalLocationDictionary setValue:snapshotData forKey:kLocationMessageSnapshotKey];
            [finalLocationDictionary setValue:[locationDictionary valueForKey:kLocationMessageLongitudeKey] forKey:kLocationMessageLongitudeKey];
            [finalLocationDictionary setValue:[locationDictionary valueForKey:kLocationMessageLatitudeKey] forKey:kLocationMessageLatitudeKey];
            NSData *locationData = [NSKeyedArchiver archivedDataWithRootObject:finalLocationDictionary];
            [PRAudioPlayer saveAudioDataInFile:locationData withIdentifier:guid];
        }
        else if([type isEqualToString:kMessageType_Document])
        {
            NSMutableDictionary *documentInfoDicitonary = [NSMutableDictionary new];
            NSString *fileExtension = @"";
            NSArray *fileNameSeperated = [mimeType componentsSeparatedByString:@"."];
            if([fileNameSeperated count] > 1)
            {
                fileExtension = [fileNameSeperated lastObject];
            }
            [documentInfoDicitonary setValue:mimeType forKey:kDocumentMessageFileNameKey];
            [documentInfoDicitonary setValue:fileExtension forKey:kDocumentMessageFileExtensionKey];
            [documentInfoDicitonary setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[(NSData*)content length]]  forKey:kDocumentMessageFileSizeKey];
            NSData *documetInfoData = [NSKeyedArchiver archivedDataWithRootObject:documentInfoDicitonary];

            [PRAudioPlayer createDirectoryInDocumentsWithName:guid];
            [PRAudioPlayer saveAudioDataInFile:documetInfoData withIdentifier:[NSString stringWithFormat:@"%@/%@_info", guid, guid]];
            [PRAudioPlayer saveAudioDataInFile:(NSData*)content withIdentifier:[NSString stringWithFormat:@"%@/%@", guid, mimeType]];
        }
        else if([type isEqualToString:kMessageType_Video])
        {
            [PRAudioPlayer saveAudioDataInFile:(NSData*)content withIdentifier:[NSString stringWithFormat:@"%@.mp4", guid]];

            NSURL* directory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                       inDomains:NSUserDomainMask] lastObject];
            NSString* docDirPath = [directory path];
            NSString* filePath = [NSString stringWithFormat:@"%@/%@.mp4", docDirPath, guid];
            UIImage *previewImage = [ImageProcessing previewFromVideoWithFilePath:filePath];
            UIImage *minImage = [ImageProcessing miniImageFromOriginal:previewImage sideMaxSize:200];
            [PRAudioPlayer saveAudioDataInFile:UIImageJPEGRepresentation(minImage, 0.5) withIdentifier:[NSString stringWithFormat:@"%@_min", guid]];
        }
        else
        {
            [PRAudioPlayer saveAudioDataInFile:(NSData*)content withIdentifier:guid];
        }
    }

    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext* localContext) {

        PRMessageModel* message = [PRMessageModel MR_createEntityInContext:localContext];

        message.guid = guid;
        message.clientId = [ChatUtility clientIdWithPrefix];
        message.channelId = channelId;
        message.timestamp = @((long)[[NSDate new] timeIntervalSince1970]);
        message.status = @"NEW";
        message.source = @"CHAT";
        message.type = type;
        message.mimeType = mimeType;
        message.isSent = NO;
        message.isReceivedFromServer = NO;

        // In case of text messages.
        if ([content isKindOfClass:[NSString class]]) {
            message.text = (NSString*)content;
        }

        // In case of voice messages or media messages.
        if ([content isKindOfClass:[NSData class]]) {
            message.audioFileName = guid;
            message.mediaFileName = guid;
        }
    }];

    return [PRDatabase messageByGuid:guid];
}

+ (void)setMessageStatus:(NSString*)status state:(MessageState)state isSent:(BOOL)isSent message:(PRMessageModel*)message
{
    NSManagedObjectContext* mainContext = [NSManagedObjectContext MR_contextForCurrentThread];
    PRMessageModel* tmpMessage = [PRDatabase messageByGuid:message.guid inContext:mainContext];

    tmpMessage.state = state;
    tmpMessage.status = status;
    tmpMessage.isSent = isSent;

    [mainContext MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError* _Nullable error) {

        NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter postNotificationName:kMessageStatusUpdated object:tmpMessage];
    }];
}

+ (void)finishedToUpdateStatusForModel:(PRMessageStatusModel*)statusUpdatedModel isDelivered:(BOOL)delivered
{
    NSManagedObjectContext* mainContext = [NSManagedObjectContext MR_contextForCurrentThread];
    PRMessageStatusModel* model = [PRDatabase messageStatusModelByGuid:statusUpdatedModel.guid inContext:mainContext];

    model.state = MessageState_FinishedSending;
    model.delivered = delivered;

    [mainContext MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError* _Nullable error){}];
}

+ (void)resetMessageState:(PRMessageModel*)modelToSend
{
    [self.class setMessageStatus:modelToSend.status state:MessageState_FinishedSending isSent:NO message:modelToSend];
}

+ (void)getAudioFileFromPath:(NSString*)path
                     success:(void (^)(NSData* audioFile))success
                     failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    [PRRequestManager getAudioFileFromPath:path
        success:^(NSData* audioFile) {
            success(audioFile);
        }
        failure:^(NSInteger statusCode, NSError* error) {
            failure(statusCode, error);
        }];
}

+ (void)getAudioFileForVoiceMessage:(PRMessageModel*)messageModel
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (!messageModel.audioFileName && messageModel.text) {
            [self.class getAudioFileFromPath:messageModel.text
                                     success:^(NSData* audioFile) {
                                         [self.class bindAudioFileWithMessageModel:messageModel audioFile:audioFile];
                                     }
                                     failure:^(NSInteger statusCode, NSError* error){
                                     }];
        }
    });
}

+ (void)getAudioFilesForVoiceMessages:(NSArray<PRMessageModel*>*)messages
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSPredicate* voiceMessagePredicate = [NSPredicate predicateWithFormat:@"type = %@", kMessageType_VoiceMessage];
        NSArray<PRMessageModel*>* voiceMessagesArray = [[messages filteredArrayUsingPredicate:voiceMessagePredicate] copy];

        for (PRMessageModel* messageModel in voiceMessagesArray) {
            [self getAudioFileForVoiceMessage:messageModel];
        }
    });
}

+ (void)bindAudioFileWithMessageModel:(PRMessageModel*)messageModel audioFile:(NSData*)audioFile
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [PRAudioPlayer saveAudioDataInFile:audioFile withIdentifier:messageModel.guid];

        NSManagedObjectContext* mainContext = [NSManagedObjectContext MR_contextForCurrentThread];
        PRMessageModel* voiceMessage = [PRDatabase messageByGuid:messageModel.guid inContext:mainContext];
        NSString* messageGuid = messageModel.guid;

        voiceMessage.audioFileName = messageGuid;

        [mainContext MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError* _Nullable error) {
            NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter postNotificationName:kAudioFileReceived object:messageGuid];
        }];
    });
}

+ (void)getMediaFileFromPath:(NSString*)path
                     success:(void (^)(NSData* mediaFile))success
                     failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    [PRRequestManager getAudioFileFromPath:path
                                   success:^(NSData* mediaFile) {
                                       success(mediaFile);
                                   }
                                   failure:^(NSInteger statusCode, NSError* error) {
                                       failure(statusCode, error);
                                   }];
}

+ (void)getMediaInfoWithUUID:(NSString*)uuid
                     success:(void (^)(NSData* documentInfoData))success
                     failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    [PRRequestManager getMediaInfoWithUUID:uuid
                                   success:^(NSData* mediaFile) {
                                       success(mediaFile);
                                   }
                                   failure:^(NSInteger statusCode, NSError* error) {
                                       failure(statusCode, error);
                                   }];
}

+ (void)getFileForMediaMessage:(PRMessageModel*)messageModel
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (!messageModel.mediaFileName && messageModel.text) {
            if([messageModel.type isEqualToString:kMessageType_Image] || [messageModel.type isEqualToString:kMessageType_Video])
            {
                [self.class getMediaFileFromPath:[NSString stringWithFormat:@"%@_min", messageModel.text]
                                         success:^(NSData* mediaFile) {
                                             [self.class bindMediaFileWithMessageModel:messageModel mediaFile:mediaFile];
                                         }
                                         failure:^(NSInteger statusCode, NSError* error){
                                         }];
            }
            else if([messageModel.type isEqualToString:kMessageType_Document])
            {
                [self.class getMediaInfoWithUUID:[messageModel.text lastPathComponent]
                                         success:^(NSData* mediaFile) {
                                             [self.class bindMediaFileWithMessageModel:messageModel mediaFile:mediaFile];
                                         }
                                         failure:^(NSInteger statusCode, NSError* error){
                                         }];
            }
            else
            {
                [self.class getMediaFileFromPath:messageModel.text
                                         success:^(NSData* mediaFile) {
                                             [self.class bindMediaFileWithMessageModel:messageModel mediaFile:mediaFile];
                                         }
                                         failure:^(NSInteger statusCode, NSError* error){
                                         }];
            }
        }
    });
}

+ (void)getFilesForMediaMessages:(NSArray<PRMessageModel*>*)messages
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSPredicate* photoMessagePredicate = [NSPredicate predicateWithFormat:@"type = %@", kMessageType_Image];
        NSPredicate* videoMessagePredicate = [NSPredicate predicateWithFormat:@"type = %@", kMessageType_Video];
        NSPredicate* documentMessagePredicate = [NSPredicate predicateWithFormat:@"type = %@", kMessageType_Document];
        NSPredicate* contactMessagePredicate = [NSPredicate predicateWithFormat:@"type = %@", kMessageType_Contact];
        NSPredicate* locationMessagePredicate = [NSPredicate predicateWithFormat:@"type = %@", kMessageType_Location];
        NSPredicate* mediaMessagePredicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[photoMessagePredicate, videoMessagePredicate, documentMessagePredicate, locationMessagePredicate, contactMessagePredicate]];
        NSArray<PRMessageModel*>* mediaMessagesArray = [[messages filteredArrayUsingPredicate:mediaMessagePredicate] copy];

        for (PRMessageModel* messageModel in mediaMessagesArray) {
            [self getFileForMediaMessage:messageModel];
        }
    });
}

+ (void)bindMediaFileWithMessageModel:(PRMessageModel*)messageModel mediaFile:(NSData*)mediaFile
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if([messageModel.type isEqualToString:kMessageType_Image] || [messageModel.type isEqualToString:kMessageType_Video])
        {
            [PRAudioPlayer saveAudioDataInFile:mediaFile withIdentifier:[NSString  stringWithFormat:@"%@_min", messageModel.guid]];
        }
        else if([messageModel.type isEqualToString:kMessageType_Contact])
        {
            NSArray<CNContact*> *contacts = [CNContactVCardSerialization contactsWithData:(NSData*)mediaFile error:nil];
            NSData* contactData = [NSKeyedArchiver archivedDataWithRootObject:[contacts firstObject]];
            [PRAudioPlayer saveAudioDataInFile:(NSData*)contactData withIdentifier:messageModel.guid];
        }
        else if([messageModel.type isEqualToString:kMessageType_Location])
        {
            NSDictionary* locationDictionary = [NSJSONSerialization JSONObjectWithData:(NSData*)mediaFile options:kNilOptions error:nil];
            NSData *snapshotData = [[NSData alloc] initWithBase64EncodedString:[locationDictionary valueForKey:kLocationMessageSnapshotKey]
                                                                       options:NSDataBase64DecodingIgnoreUnknownCharacters];
            NSMutableDictionary* finalLocationDictionary = [NSMutableDictionary new];
            [finalLocationDictionary setValue:snapshotData forKey:kLocationMessageSnapshotKey];
            [finalLocationDictionary setValue:[locationDictionary valueForKey:kLocationMessageLongitudeKey] forKey:kLocationMessageLongitudeKey];
            [finalLocationDictionary setValue:[locationDictionary valueForKey:kLocationMessageLatitudeKey] forKey:kLocationMessageLatitudeKey];
            NSData *locationData = [NSKeyedArchiver archivedDataWithRootObject:finalLocationDictionary];
            [PRAudioPlayer saveAudioDataInFile:locationData withIdentifier:messageModel.guid];
        }
        else if([messageModel.type isEqualToString:kMessageType_Document])
        {
            [PRAudioPlayer createDirectoryInDocumentsWithName:messageModel.guid];
            [PRAudioPlayer saveAudioDataInFile:mediaFile withIdentifier:[NSString stringWithFormat:@"%@/%@_info", messageModel.guid, messageModel.guid]];
        }
        else
        {
            [PRAudioPlayer saveAudioDataInFile:mediaFile withIdentifier:messageModel.guid];
        }

        NSManagedObjectContext* mainContext = [NSManagedObjectContext MR_contextForCurrentThread];
        PRMessageModel* mediaMessage = [PRDatabase messageByGuid:messageModel.guid inContext:mainContext];
        NSString* messageGuid = messageModel.guid;

        mediaMessage.mediaFileName = messageGuid;

        [mainContext MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError* _Nullable error) {
            NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter postNotificationName:kAudioFileReceived object:messageGuid];
        }];
    });
}

- (void)resendMessages
{
    if ([PRRequestManager connectionRequired]) {
        return;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSArray<PRMessageModel*>* messagesToResend = [PRDatabase messagesToResend];
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];

        for (PRMessageModel* messageModel in messagesToResend) {

            if (messageModel.state == MessageState_Sending || messageModel.state == MessageState_Aborted) {
                continue;
            }

            if (messageModel.messageType == ChatMessageType_Voice && messageModel.audioData) {
                [self.class resendAudioData:messageModel.audioData forMessageWithGuid:messageModel.guid];
                continue;
            }

            if ((messageModel.messageType == ChatMessageType_Image || messageModel.messageType == ChatMessageType_Video || messageModel.messageType == ChatMessageType_Location || messageModel.messageType == ChatMessageType_Document || messageModel.messageType == ChatMessageType_Contact) && messageModel.mediaData) {
                [self.class resendMediaData:messageModel.mediaData forMessageWithGuid:messageModel.guid];
                continue;
            }

            [self.class sendMessage:messageModel];

            if (messageModel.state == MessageState_FinishedSending) {
                [self.class setMessageStatus:messageModel.status state:MessageState_Initial isSent:NO message:messageModel];
            }

            if (messageModel.state == MessageState_Initial && (now > [messageModel.timestamp longValue] + kTimeoutToShowRedButton)) {
                [self.class setMessageStatus:messageModel.status state:MessageState_Aborted isSent:NO message:messageModel];
            }
        }

        NSArray<PRMessageStatusModel*>* statusUpdatesToResend = [PRDatabase statusUpdatesToResend];

        for (PRMessageStatusModel* model in statusUpdatesToResend) {
            if ((model.state == MessageState_Sending)) {
                continue;
            }

            [self.class updateMessageStatus:model];
        }

        [PRDatabase deleteUnneededStatusUpdates];
    });
}

+ (NSArray<PRMessageModel*>*)filterMessages:(NSArray<PRMessageModel*>*)messages withTimestamp:(NSNumber*)timestamp
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"status != %@ AND timestamp.doubleValue < %@", kMessageStatus_Deleted, timestamp];
    NSArray<PRMessageModel*>* filteredMessages = [messages filteredArrayUsingPredicate:predicate];

    NSMutableArray<PRMessageModel*> *messagesWithoutStatusUpdate = [NSMutableArray new];
    for (PRMessageModel* message in filteredMessages) {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"guid = %@", message.guid];
        NSArray<PRMessageModel*>* newMessagesArray = [messagesWithoutStatusUpdate filteredArrayUsingPredicate:predicate];
        if (newMessagesArray.count > 0) {
            continue;
        }
        [messagesWithoutStatusUpdate addObject:message];
    }

    return messagesWithoutStatusUpdate;
}

+ (NSArray<PRMessageModel*>*)getMessagesInRange:(NSInteger)messagesCount forChannelId:(NSString*)channelId
{
    NSInteger preparedMessagesCount = messagesCount;
    NSInteger messagesLimit = kMessagesFetchLimit;
    NSArray<PRMessageModel*>* allMessages = [PRDatabase messagesForChannelId:channelId];
    while (messagesLimit < preparedMessagesCount) {
        messagesLimit += kMessagesFetchLimit;
    }
    messagesLimit = messagesLimit > allMessages.count ? allMessages.count : messagesLimit;
    return [allMessages subarrayWithRange:NSMakeRange(allMessages.count - messagesLimit, messagesLimit)];
}

+ (BOOL)hasExpiredMessages:(NSArray<PRMessageModel*>*)messages
{
    double expirationDateTimeInterval = [[Utils dateWithOffsetFromNow:kDataExpirationMonthOffset] timeIntervalSince1970];
    NSPredicate* predicateForExpiredMessages = [NSPredicate predicateWithFormat:@"timestamp <= %f",expirationDateTimeInterval];
    return [messages filteredArrayUsingPredicate:predicateForExpiredMessages].count > 0;
}

@end
