//
//  TestMessagesSender.h
//  PRIME
//
//  Created by Taron on 4/16/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestMessagesSender : NSObject

- (instancetype)initWithTaskIds:(NSArray<NSNumber*>*)taskIds
                      orChatIds:(NSArray<NSNumber*>*)chatIds
          andRepeatTimeInterval:(NSInteger)interval
                       needText:(BOOL)text;
- (void)startReceiveTestTaskMessages;
- (void)endReceiveTestTaskMessages;
- (void)startReceiveFeedback:(WebSoketMessageStatus)messageStatus webSoketCommandType:(WebSoketCommandType)webSoketCommandType;
- (void)endReceiveFeedback;
@end
