//
//  PRWGCacheManager.h
//  PRIME
//
//  Created by Armen on 5/22/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PRWGCacheManager : NSObject

+ (void)addFileToCache:(NSData*)fileData fileName:(NSString*)fileName;
+ (void)removeFileFromCache:(NSString*)fileName;
+ (NSData*)getFileDataFromCache:(NSString*)fileName;
+ (BOOL)isFileExistInCache:(NSString*)fileName;

@end

NS_ASSUME_NONNULL_END
