//
//  PRChatPhotoMessageViewCell.h
//  PRIME
//
//  Created by armens on 4/11/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PRChatMessageBaseViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface PRChatPhotoMessageViewCell : PRChatMessageBaseViewCell

@property (assign, nonatomic, readonly) BOOL hasImage;
@property (assign, nonatomic, readonly) BOOL isLocation;
@property (assign, nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (UIImage*)getMessageImage;
- (void)setMessageImageWithPath:(NSString*)messageImagePath isLocation:(BOOL)isLocation;

@end

NS_ASSUME_NONNULL_END
