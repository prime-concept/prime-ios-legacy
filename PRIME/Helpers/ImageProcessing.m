//
//  ImageProcessing.m
//  PRIME
//
//  Created by Armen on 6/26/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import "ImageProcessing.h"
#import <AVFoundation/AVFoundation.h>

@implementation ImageProcessing

+ (UIImage*)miniImageFromOriginal:(UIImage*)originalImage sideMaxSize:(NSInteger) sideMaxSize
{
    if (!originalImage)
    {
        return nil;
    }
    if (originalImage.size.height <=sideMaxSize && originalImage.size.width <=sideMaxSize)
    {
        return originalImage;
    }
    CGFloat imageAspectRatio = originalImage.size.width / originalImage.size.height;
    CGSize size;
    if(imageAspectRatio >= 1)
    {
        size.width = sideMaxSize;
        size.height = sideMaxSize / imageAspectRatio;
    }
    else
    {
        size.height = sideMaxSize;
        size.width = sideMaxSize * imageAspectRatio;
    }
    UIGraphicsBeginImageContext(size);
    [originalImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *minImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return minImage;
}

+ (UIImage*)previewFromVideoWithFilePath:(NSString*)videoFilePath
{
    AVAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:videoFilePath]];
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    [imageGenerator setAppliesPreferredTrackTransform:YES];
    double duration = CMTimeGetSeconds([asset duration]);
    CGImageRef previewImageRef = [imageGenerator copyCGImageAtTime:CMTimeMake(0, duration) actualTime:nil error:nil];

    return [UIImage imageWithCGImage:previewImageRef];
}

@end
