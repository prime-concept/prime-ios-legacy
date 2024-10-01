//
//  PRVoiceMessageCell.h
//  PRIME
//
//  Created by Aram on 12/26/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PRChatMessageBaseViewCell.h"

@interface PRVoiceMessageCell : PRChatMessageBaseViewCell

/** In debug mode, on cell will also be presented message "guid" */
- (void)setGuid:(NSString*)guid;
- (void)setAudioFileName:(NSString*)audioFileName;

@end
