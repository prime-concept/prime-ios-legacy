//
//  SHSPhoneTextField+DeleteBackward.m
//  PRIME
//
//  Created by Admin on 2/16/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "SHSPhoneTextField+DeleteBackward.h"

@implementation SHSPhoneTextField (DeleteBackward)

- (BOOL)keyboardInputShouldDelete:(UITextField *)textField {
    BOOL shouldDelete = YES;
    
    unsigned long length = [textField.text length];
    
    if ([UITextField instancesRespondToSelector:_cmd]) {
        BOOL (*keyboardInputShouldDelete)(id, SEL, UITextField *) = (BOOL (*)(id, SEL, UITextField *))[UITextField instanceMethodForSelector:_cmd];
        
        if (keyboardInputShouldDelete) {
            shouldDelete = keyboardInputShouldDelete(self, _cmd, textField);
        }
    }
    
    if (!length && [[[UIDevice currentDevice] systemVersion] intValue] >= 8) {
        [self deleteBackward];
    }
    
    return shouldDelete;
}


- (void)deleteBackward {
    BOOL shouldDismiss = [self.text length] == 0;
    
    [super deleteBackward];
    
    if (shouldDismiss) {
        if ([self.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
            [self.delegate textField:self shouldChangeCharactersInRange:NSMakeRange(0, 0) replacementString:@""];
        }
    }
}

@end
