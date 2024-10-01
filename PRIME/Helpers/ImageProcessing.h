//
//  ImageProcessing.h
//  PRIME
//
//  Created by Armen on 6/26/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageProcessing : NSObject

+ (UIImage*)miniImageFromOriginal:(UIImage*)originalImage sideMaxSize:(NSInteger) sideMaxSize;
+ (UIImage*)previewFromVideoWithFilePath:(NSString*)videoFilePath;

@end

NS_ASSUME_NONNULL_END
