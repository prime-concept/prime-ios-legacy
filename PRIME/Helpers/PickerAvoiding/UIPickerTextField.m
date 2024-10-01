//
//  UIPickerTextField.m
//  PRIME
//
//  Created by Admin on 3/29/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "UIPickerTextField.h"

@implementation UIPickerTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (BOOL)isFirstResponder
{
    return _current;
}

@end
