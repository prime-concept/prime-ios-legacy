//
//  NSTextView.m
//  PRIME
//
//  Created by Aram on 1/5/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRChatTextView.h"
#import "ChatViewController.h"

@implementation PRChatTextView

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (_disableEditMenu) {
        return NO;
    }

    UITextRange* selectedRange = [self selectedTextRange];
    NSString* selectedText = [self textInRange:selectedRange];

    if (action == @selector(_promptForReplace:)) {
        return NO;
    } else if (action == @selector(copy:)) {
        if ([self.text isEqualToString:@""] || [selectedText isEqualToString:@""]) {
            return NO;
        }
    } else if (action == @selector(paste:)) {
        UIPasteboard* pboard = [UIPasteboard generalPasteboard];
        if ([pboard.string isEqualToString:@""]) {
            return NO;
        }
    }

    return [super canPerformAction:action withSender:sender];
}

- (void)_promptForReplace:(id)sender
{
    // Replace action will be disabled.
}

@end
