//
//  PRChatDocumentMessageViewCell.h
//  PRIME
//
//  Created by Armen on 6/13/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import "PRChatMessageBaseViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface PRChatDocumentMessageViewCell : PRChatMessageBaseViewCell

- (void)setMessageFileInfoWithPath:(NSString*)messageFileInfoPath;

@end

NS_ASSUME_NONNULL_END
