//
//  XNDocuments.h
//  PRIME
//
//  Created by Simon on 6/8/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XNDocuments : NSObject

/** Returns all stored images. */
+ (void)imagesForDocument:(NSNumber*)documentId
                withBlock:(void (^)(NSArray* photos))block;

/** Add image to local storage and upload. */
+ (NSString*)addImage:(UIImage*)image
          ForDocument:(NSNumber*)documentId;

/** Synchronize with server for download, delete or upload images. */
+ (void)synchronizeWithServerForDocument:(NSNumber*)documentId
                                   added:(void (^)(DocumentImage* photo))added
                                 deleted:(void (^)(NSString* uid))deleted;

/** Add image to local storage without uploading. */
+ (void)addLocalImage:(DocumentImage*)documentImage ForDocument:(NSNumber*)documentId;

/** Attach images for upload to server from local storage. */
+ (void)attachImages:(NSMutableArray*)uids ForDocument:(NSNumber*)documentId;

/** Delete image from server. */
+ (void)deleteImage:(NSString*)uid
        ForDocument:(NSNumber*)documentId
               view:(UIView*)view;

+ (void)deleteImage:(NSString*)uid
        ForDocument:(NSNumber*)documentId
               view:(UIView*)view
               mode:(PRRequestMode)mode;

/** Delete image from pending storage of temporary directory. */
+ (void)deletePendingImage:(NSString*)uid;

@end
