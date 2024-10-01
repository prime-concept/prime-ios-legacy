//
//  PRChatContactMessageViewCell.h
//  PRIME
//
//  Created by Armen on 5/16/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import "PRChatMessageBaseViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface PRChatContactMessageViewCell : PRChatMessageBaseViewCell

@property (strong, nonatomic) UIViewController* presenter;

- (void)setContactWithPath:(NSString*)path;
- (CNContact*)getContact;

@end

NS_ASSUME_NONNULL_END
