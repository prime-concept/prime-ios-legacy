//
//  XNAvatar.m
//  PRIME
//
//  Created by Admin on 6/5/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "XNAvatar.h"

#import "XNLocalFileStorage.h"
#import "PRListFileInfoModel.h"

#define AVATAR_IMAGE_FILE_NAME @"profileImage.png"

@implementation XNAvatar


#pragma mark File
#pragma mark -

+ (UIImage *) loadFromFile
{
    return [XNLocalFileStorage loadImage: AVATAR_IMAGE_FILE_NAME];
}

+ (void) saveToFile: (UIImage *) image
{
    [XNLocalFileStorage saveImage: image
                         withName: AVATAR_IMAGE_FILE_NAME];
}

+ (NSDate *) fileCreationDate
{
    return [XNLocalFileStorage creationDate: AVATAR_IMAGE_FILE_NAME];
}

+ (BOOL) isFileAvailable
{
    return ([self.class fileCreationDate] != nil);
}

#pragma mark Core Data
#pragma mark -

+ (void) storeToDB: (PRListFileInfoModel *) fileInfo
{
    PRUploadFileInfoModel * uFileInfo = [self.class getFromDB];
    
    if (uFileInfo == nil) {
        uFileInfo = [PRUploadFileInfoModel entityFromFileInfo: fileInfo];
    }
    
    [uFileInfo save];
}

+ (PRUploadFileInfoModel *) getFromDB
{
    NSArray *filesInfo = [PRDatabase getFilesInfoForDocument: nil];
    
    if ( [filesInfo count] != 0 ) {
        return filesInfo[0];
    }
    
    return nil;
}

+ (BOOL) isFileInfoAvailableInDB
{
    return ([self.class getFromDB] != nil);
}


#pragma mark Server
#pragma mark -

+ (void) downloadFromServer: (PRListFileInfoModel *) fileInfo
                 downloaded: (void (^)(UIImage * image)) downloaded
{
    [PRRequestManager downloadAvatarByUID: fileInfo.uid
                                     view: nil
                                     mode: PRRequestMode_ShowNothing
                                  success:^(UIImage *image) {
                                      
                                      //- Save to the file to have creation date
                                      [self.class saveToFile: image];
                                      
                                      //- Get stored image creation date
                                      NSDate * createdAt = [self.class fileCreationDate];

                                      if (fileInfo.createdAt == nil) {
                                          fileInfo.createdAt = createdAt;
                                      }
                                      
                                      //- Store to Core Data
                                      [self.class storeToDB: fileInfo];
                                      
                                      downloaded(image);
                                      
                                  }
                                  failure: nil];
}

+ (void) uploadToServer
{
    UIImage * image = [self.class loadFromFile];
    
    NSDate * createdAt = [self.class fileCreationDate];
    
    [PRRequestManager uploadAvatar: image
                         createdAt: createdAt
                              view: nil
                              mode: PRRequestMode_ShowNothing
                           success: nil
                           failure: nil];
}

+ (void) synchronizeWithServer: (void (^)(UIImage * image)) update
{
    [PRRequestManager listAvatarWithView: nil
                                    mode: PRRequestMode_ShowNothing
                                 success: ^(NSArray *filesInfo) {
                                     [self.class updateAvatarWithFilesInfo: filesInfo
                                                                downloaded: update];
                                 } failure: nil];
}

#pragma mark Logic
#pragma mark -

+ (PRListFileInfoModel *) theMostRecentFromFilesInfo: (NSArray *) filesInfo
{
    NSDate *theMostRecentDate = [NSDate dateWithTimeIntervalSince1970: 0];
    PRListFileInfoModel *theMostRecentFileInfo = nil;
    
    for (PRListFileInfoModel *fileInfo in filesInfo) {
        if ([fileInfo.createdAt mt_isOnOrAfter: theMostRecentDate]) {
            theMostRecentDate = fileInfo.createdAt;
            theMostRecentFileInfo = fileInfo;
        }
    }
    
    return theMostRecentFileInfo;
}

+ (void) updateAvatarWithFilesInfo: (NSArray *) filesInfo
                        downloaded: (void (^)(UIImage * image)) downloaded
{
    PRListFileInfoModel *theMostRecentFileInfo =
    [self.class theMostRecentFromFilesInfo: filesInfo];
    
    if (theMostRecentFileInfo == nil) { //- Nothing to download
        
        NSLog(@"Avatar: Nothing to download");
        
        if ([self.class isFileAvailable]) { //- Available avatar image, it should be uploaded to the server
            
            NSLog(@"Avatar: Available image, it should be uploaded to the server");
            [self.class uploadToServer];
        }
        
        return;
    }
    
    if ( ! [self.class isFileAvailable]) { //- Nothing to upload
        
        NSLog(@"Avatar: Nothing to upload");
        
        [self.class downloadFromServer: theMostRecentFileInfo
                            downloaded: downloaded];
        
        return;
    }
    
    if ( [self.class isFileInfoAvailableInDB] ) { //- Avatar file info is available in CoreData, but it can be not actual if last upload is not succeed
        
        NSLog(@"Avatar: File info is available in Core Data, but it can be not actual if last upload is not succeed");
        
        PRUploadFileInfoModel * fileInfo = [self.class getFromDB];
        
        if ([theMostRecentFileInfo.createdAt mt_isAfter: fileInfo.createdAt]) { //- Last upload was not succeed or Avatar image was updated from another device
            
            NSLog(@"Avatar: Image is updated from another device");
            
            [self.class downloadFromServer: theMostRecentFileInfo
                                downloaded: downloaded];
            
            return;
        }
        
        if ([[self.class fileCreationDate] mt_isAfter: fileInfo.createdAt]) {
            NSLog(@"Avatar: Last upload was not succeed");
            
            [self.class uploadToServer];
            
            return;
        }
        
        NSLog(@"Avatar: Image up to date");
        
        return;
    }
    
    NSLog(@"Avatar: File info is NOT available in Core Data, it's possible Core Data was reset with app new version.");
    
    [self.class downloadFromServer: theMostRecentFileInfo
                        downloaded: downloaded];
}

#pragma mark Accessors
#pragma mark -

+ (UIImage *) image
{
    return [self.class loadFromFile];
}

+ (void) setImage: (UIImage *) image
{
    [self.class saveToFile: image];
    
    [self.class uploadToServer];
}

@end
