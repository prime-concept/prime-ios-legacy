//
//  XNDocuments.m
//  PRIME
//
//  Created by Simon on 6/8/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "DocumentImage.h"
#import "XNDocuments.h"
#import "XNLocalFileStorage.h"

typedef NS_ENUM(NSInteger, StorageType) {
    StorageType_Uploaded = 0,
    StorageType_Pending
};

const static NSString* pendingDictionary = @"pending";
const static NSString* uploadedDictionary = @"uploaded";

NSMutableArray<NSString*>* imagesInUploading;

@implementation XNDocuments

#pragma mark File
#pragma mark -

+ (void)saveToFile:(UIImage*)image
        documentId:(NSNumber*)documentId
               uid:(NSString*)uid
       storageType:(StorageType)storageType
{

    [XNLocalFileStorage createDirectoryRecursivly:[self.class pathForDocument:documentId
                                                               andStorageType:storageType]];

    [XNLocalFileStorage saveImage:image
                         withName:[self.class filePathForDocument:documentId
                                                              uid:uid
                                                      storageType:storageType]];
}

+ (void)moveFileFromPendingToUploadedForDocument:(NSNumber*)documentId
                                         fromUid:(NSString*)fromUid
                                           toUid:(NSString*)toUid
{
    [XNLocalFileStorage moveFileFromSource:[self.class filePathForDocument:documentId
                                                                       uid:fromUid
                                                               storageType:StorageType_Pending]
                             toDestination:[self.class filePathForDocument:documentId
                                                                       uid:toUid
                                                               storageType:StorageType_Uploaded]];
}

+ (void)moveTemporaryFilesToPendingFromTemporaryDocument:(NSNumber*)temporaryDocumentId
                                              ToDocument:(NSNumber*)documentId
                                                 fromUid:(NSString*)fromUid
                                                   toUid:(NSString*)toUid
{
    [XNLocalFileStorage moveFileFromSource:[self.class filePathForDocument:temporaryDocumentId
                                                                       uid:fromUid
                                                               storageType:StorageType_Pending]
                             toDestination:[self.class filePathForDocument:documentId
                                                                       uid:toUid
                                                               storageType:StorageType_Pending]];
}

+ (NSString*)pathForDocument:(NSNumber*)documentId
              andStorageType:(StorageType)storageType
{
    NSString* path = nil;
    switch (storageType) {

    case StorageType_Pending:
        path = [NSString stringWithFormat:@"%@/pending", documentId];
        break;

    case StorageType_Uploaded:
        path = [NSString stringWithFormat:@"%@/uploaded", documentId];
        break;
    default:
        break;
    }

    return path;
}

+ (NSArray*)listPhotosFromFileForDocument:(NSNumber*)documentId
                              storageType:(StorageType)storageType
{

    return [XNLocalFileStorage filesListForPath:[self.class pathForDocument:documentId
                                                             andStorageType:storageType]];
}

+ (NSString*)filePathForDocument:(NSNumber*)documentId
                             uid:(NSString*)uid
                     storageType:(StorageType)storageType
{
    NSString* path = [self.class pathForDocument:documentId andStorageType:storageType];

    return [NSString stringWithFormat:@"%@/%@", path, uid];
}

+ (NSDate*)fileCreationDateForDocument:(NSNumber*)documentId
                                   uid:(NSString*)uid
                           storageType:(StorageType)storageType
{
    return [XNLocalFileStorage creationDate:[self.class filePathForDocument:documentId
                                                                        uid:uid
                                                                storageType:storageType]];
}

+ (UIImage*)imageFromFileForDocument:(NSNumber*)documentId
                                 uid:(NSString*)uid
                         storageType:(StorageType)storageType
{

    return [XNLocalFileStorage loadImage:[self.class filePathForDocument:documentId
                                                                     uid:uid
                                                             storageType:storageType]];
}

+ (void)deleteForDocument:(NSNumber*)documentId
                      uid:(NSString*)uid
              storageType:(StorageType)storageType
{

    [XNLocalFileStorage deleteFileFromPath:[self.class filePathForDocument:documentId
                                                                       uid:uid
                                                               storageType:storageType]];
}

+ (void)deleteImageFromServerForDocument:(NSNumber*)documentId
                                     uid:(NSString*)uid
                                    view:(UIView*)view
                                    mode:(PRRequestMode)mode
{
    [PRRequestManager deleteImageByUID:uid
                                  view:view
                                  mode:mode
                               success:^() {
                                   [XNLocalFileStorage deleteFileFromPath:[self.class filePathForDocument:documentId
                                                                                                      uid:uid
                                                                                              storageType:StorageType_Pending]];
                               }
                               failure:nil];
}
#pragma mark Server
#pragma mark -

+ (void)downloadFromServerForDocument:(NSNumber*)documentId
                                  uid:(NSString*)uid
                           downloaded:(void (^)(DocumentImage* image))downloaded
{
    [PRRequestManager downloadImageForDocumentByUID:uid
                                               view:nil
                                               mode:PRRequestMode_ShowNothing
                                            success:^(DocumentImage* image) {

                                                [self.class saveToFile:image.image documentId:documentId uid:uid storageType:StorageType_Uploaded];

                                                if (downloaded) {
                                                    downloaded(image);
                                                }
                                            }
                                            failure:nil];
}

+ (void)uploadImage:(UIImage*)image
    ToServerForDocument:(NSNumber*)documentId
                    uid:(NSString*)uid
            withSuccess:(void (^)(PRUploadFileInfoModel* imageInfo))success
{
    [self.class addImageToUploadingList:uid];
    [PRRequestManager uploadImageForDocument:documentId
                                       image:image
                                   createdAt:[NSDate new]
                                        view:nil
                                        mode:PRRequestMode_ShowNothing
                                     success:^(PRUploadFileInfoModel* imageInfo) {

                                         if (success) {
                                             success(imageInfo);
                                         }

                                     }
                                     failure:nil];
}

#pragma mark Public methods
#pragma mark -

+ (void)imagesForDocument:(NSNumber*)documentId
                withBlock:(void (^)(NSArray* photos))block
{
    NSArray* photosPath = [self.class listPhotosFromFileForDocument:documentId storageType:StorageType_Uploaded];

    NSMutableArray* photos = [NSMutableArray arrayWithCapacity:[photosPath count]];
    for (NSString* uid in photosPath) {
        DocumentImage* docImage = [[DocumentImage alloc] init];
        docImage.image = [self.class imageFromFileForDocument:documentId uid:uid storageType:StorageType_Uploaded];
        docImage.uid = uid;
        [photos addObject:docImage];
    }

    photosPath = [self.class listPhotosFromFileForDocument:documentId storageType:StorageType_Pending];

    for (NSString* uid in photosPath) {
        DocumentImage* docImage = [[DocumentImage alloc] init];
        docImage.image = [self.class imageFromFileForDocument:documentId uid:uid storageType:StorageType_Pending];
        docImage.uid = uid;
        [photos addObject:docImage];
    }

    block(photos);
}

+ (void)attachImages:(NSMutableArray*)uids ForDocument:(NSNumber*)documentId
{
    for (int i = 0; i < uids.count; i++) {
        [self.class moveTemporaryFilesToPendingFromTemporaryDocument:@(INT_MAX) ToDocument:documentId fromUid:uids[i] toUid:uids[i]];
        ;
    }
    [self.class uploadPendingImagesForDocumentId:documentId];
}

+ (void)deletePendingImage:(NSString*)uid
{
    [self deleteLocalImageForDocument:@(INT_MAX) WithUID:uid];
}

+ (void)deleteImage:(NSString*)uid
        ForDocument:(NSNumber*)documentId
               view:(UIView*)view
{
    [self.class deleteImage:uid
                ForDocument:documentId
                       view:view
                       mode:PRRequestMode_ShowErrorMessagesAndProgress];
}

+ (void)deleteImage:(NSString*)uid
        ForDocument:(NSNumber*)documentId
               view:(UIView*)view
               mode:(PRRequestMode)mode
{
    [XNDocuments deleteImageFromServerForDocument:documentId uid:uid view:view mode:mode];
    [XNDocuments deleteLocalImageForDocument:documentId WithUID:uid];
}

+ (NSString*)addImage:(UIImage*)image
          ForDocument:(NSNumber*)documentId
{
    NSString* uid = [[NSUUID UUID] UUIDString];

    [self.class saveToFile:image documentId:documentId uid:uid storageType:StorageType_Pending];

    [self.class uploadImage:image
        ToServerForDocument:documentId
                        uid:uid
                withSuccess:^(PRUploadFileInfoModel* imageInfo) {

                    [self.class moveFileFromPendingToUploadedForDocument:documentId
                                                                 fromUid:uid
                                                                   toUid:[imageInfo uid]];
                }];

    return uid;
}

+ (void)addLocalImage:(DocumentImage*)documentImage ForDocument:(NSNumber*)documentId
{
    [self.class saveToFile:documentImage.image documentId:documentId uid:documentImage.uid storageType:StorageType_Pending];
}

+ (void)deleteLocalImageForDocument:(NSNumber*)documentId WithUID:(NSString*)uid
{
    [XNLocalFileStorage deleteFileFromPath:[self.class filePathForDocument:documentId
                                                                       uid:uid
                                                               storageType:StorageType_Pending]];
}

+ (void)deleteDirectoryForDocument:(NSNumber*)directoryName
{
    [XNLocalFileStorage deleteDirectoryWithName:[NSString stringWithFormat:@"%@", directoryName]];
}

+ (void)synchronizeWithServerForDocument:(NSNumber*)documentId
                                   added:(void (^)(DocumentImage* photo))added
                                 deleted:(void (^)(NSString* uid))deleted
{
    [PRRequestManager listImagesForDocument:documentId
                                       view:nil
                                       mode:PRRequestMode_ShowNothing
                                    success:^(NSArray* filesInfo) {

                                        //- Get UIDs
                                        NSMutableArray* localPhotosUids = [[self.class listPhotosFromFileForDocument:documentId
                                                                                                         storageType:StorageType_Uploaded] mutableCopy];

                                        NSMutableArray* remotePhotosUids = [NSMutableArray arrayWithCapacity:[filesInfo count]];
                                        for (PRListFileInfoModel* fileInfo in filesInfo) {
                                            [remotePhotosUids addObject:[fileInfo uid]];
                                        }

                                        //- Sort UIDs
                                        [localPhotosUids sortUsingComparator:^NSComparisonResult(NSString* obj1, NSString* obj2) {
                                            return [obj1 compare:obj2];
                                        }];

                                        [remotePhotosUids sortUsingComparator:^NSComparisonResult(NSString* obj1, NSString* obj2) {
                                            return [obj1 compare:obj2];
                                        }];

                                        //- Download image from server or delete local image
                                        NSEnumerator* enumeratorLocal = [localPhotosUids objectEnumerator];
                                        NSEnumerator* enumeratorRemote = [remotePhotosUids objectEnumerator];

                                        NSString* localUID = [enumeratorLocal nextObject];
                                        NSString* remoteUID = [enumeratorRemote nextObject];

                                        while (localUID && remoteUID) {
                                            switch ([localUID compare:remoteUID]) {
                                            case NSOrderedAscending:
                                                [self.class deleteForDocument:documentId
                                                                          uid:localUID
                                                                  storageType:StorageType_Uploaded];
                                                if (deleted) {
                                                    deleted(localUID);
                                                }
                                                localUID = [enumeratorLocal nextObject];
                                                break;
                                            case NSOrderedSame:
                                                localUID = [enumeratorLocal nextObject];
                                                remoteUID = [enumeratorRemote nextObject];
                                                break;
                                            case NSOrderedDescending:
                                                [self.class downloadFromServerForDocument:documentId
                                                                                      uid:remoteUID
                                                                               downloaded:added];
                                                remoteUID = [enumeratorRemote nextObject];
                                                break;
                                            }
                                        }

                                        while (localUID) {
                                            [self.class deleteForDocument:documentId
                                                                      uid:localUID
                                                              storageType:StorageType_Uploaded];
                                            if (deleted) {
                                                deleted(localUID);
                                            }
                                            localUID = [enumeratorLocal nextObject];
                                        }

                                        while (remoteUID) {
                                            [self.class downloadFromServerForDocument:documentId
                                                                                  uid:remoteUID
                                                                           downloaded:added];
                                            remoteUID = [enumeratorRemote nextObject];
                                        }

                                        [[NSNotificationCenter defaultCenter] postNotificationName:@"DocumentImagesAreLoaded" object:nil];
                                    }
                                    failure:nil];

    //- Upload pedning images to server.
    [self uploadPendingImagesForDocumentId:documentId];
}

+ (void)uploadPendingImagesForDocumentId:(NSNumber*)documentId
{
    NSArray* pendingLines = [self.class listPhotosFromFileForDocument:documentId storageType:StorageType_Pending];
    for (NSString* pendingUID in pendingLines) {
        UIImage* pendingImage = [self.class imageFromFileForDocument:documentId
                                                                 uid:pendingUID
                                                         storageType:StorageType_Pending];

        if ([imagesInUploading containsObject:pendingUID]) {
            continue;
        }

        else {
            [self.class addImageToUploadingList:pendingUID];
        }

        [PRRequestManager uploadImageForDocument:documentId
                                           image:pendingImage
                                       createdAt:[NSDate new]
                                            view:nil
                                            mode:PRRequestMode_ShowNothing
                                         success:^(PRUploadFileInfoModel* imageInfo) {
                                             [self.class moveFileFromPendingToUploadedForDocument:documentId
                                                                                          fromUid:pendingUID
                                                                                            toUid:[imageInfo uid]];
                                             if ([imagesInUploading containsObject:pendingUID]) {
                                                 [imagesInUploading removeObject:pendingUID];
                                             }
                                         }
                                         failure:nil];
    }
}

+ (void)addImageToUploadingList:(NSString*)uid
{
    if (imagesInUploading == nil) {
        imagesInUploading = [NSMutableArray array];
    }
    [imagesInUploading addObject:uid];
}

@end
