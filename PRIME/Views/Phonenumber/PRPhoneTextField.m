//
//  PRPhoneTextField.m
//  PRIME
//
//  Created by Admin on 2/15/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRPhoneTextField.h"

@interface PRPhoneTextField () {
    SHSTextBlock __textDidChangeBlock;
}

@end

@implementation PRPhoneTextField


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initialize];
    }
    return self;
}

- (void)_initialize
{
    [self.formatter setDefaultOutputPattern:@"####################" imagePath:nil];
    [self.formatter addOutputPattern:@"+# (###) ###-##-##" forRegExp:@"^7[0-689]\\d*$" imagePath:@"flagRU"];
    [self.formatter addOutputPattern:@"+### (##) ###-###" forRegExp:@"^374\\d*$" imagePath:@"flagAM"];
    
    super.textDidChangeBlock = ^(UITextField *textField) {
        
        if ([self.text isEqual: @"89"]) {
            [self setFormattedText :@"79"];
        }
        
        if (__textDidChangeBlock) {
            __textDidChangeBlock(textField);
        }
    };
}

-(void) setTextDidChangeBlock: (SHSTextBlock) textDidChangeBlock
{
    __textDidChangeBlock = textDidChangeBlock;
}

@end
