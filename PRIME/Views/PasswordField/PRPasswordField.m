//
//  PRPasswordField.m
//  PRIME
//
//  Created by Admin on 01/02/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRPasswordField.h"

@implementation PRPasswordField

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self __initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self __initialize];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self __initialize];
    }
    return self;
}

- (void)__initialize
{
    self.keyboardType = UIKeyboardTypeNumberPad;
    self.maximumLength = 4;
    self.dotColor = kAppPassCodeColor;
    self.dotSize = CGSizeMake(19.0f, 19.0f);
    self.lineHeight = 1.2;
    self.dotSpacing = 16;
}

@end
