//
//  BackspaceTextField.m
//  PRIME
//
//  Created by Artak on 10/12/15.
//  Copyright © 2015 XNTrends. All rights reserved.
//

#import "BackspaceTextField.h"

@implementation BackspaceTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)deleteBackward
{
    [_backspaceDelegate backspasePressedForTextView:self];
    [super deleteBackward];
}

@end
