//
//  VideoPlayer.h
//  PRIME
//
//  Created by Armen on 6/11/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoPlayer : UIViewController

@property(strong, nonatomic) UIImage* previewImage;
@property(strong, nonatomic) NSString* videoDownloadingPath;

- (void)setFilePathWithGuid:(NSString*)guid;

@end

NS_ASSUME_NONNULL_END
