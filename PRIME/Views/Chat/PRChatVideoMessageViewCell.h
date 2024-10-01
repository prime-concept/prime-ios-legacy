//
//  PRChatVideoMessageViewCell.h
//  PRIME
//
//  Created by Armen on 6/7/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import "PRChatMessageBaseViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface PRChatVideoMessageViewCell : PRChatMessageBaseViewCell

@property (assign, nonatomic, readonly) BOOL hasImage;

- (UIImage*)getMessageImage;
- (void)setMessageImageWithPath:(NSString*)messageImagePath;

@end

NS_ASSUME_NONNULL_END
