//
//  UILine.m
//  PRIME
//
//  Created by Admin on 2/10/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "XNLine.h"

@implementation XNLine

- (instancetype)init
{
    self = [super init];
    if(!self){
        return nil;
    }
    
    self.backgroundColor = kCalendarLineColor;
    
    self.userInteractionEnabled = NO;
    
    return self;
}

- (void) setY: (CGFloat) y
{
    // careful, contentScaleFactor does NOT WORK in storyboard during initWithCoder.
    // example, float sortaPixel = 1.0/self.contentScaleFactor ... does not work.
    // instead, use mainScreen scale which works perfectly:
    float sortaPixel = 1.0/[UIScreen mainScreen].scale;
    
    self.frame = CGRectMake(0, (y-sortaPixel), [self superview].frame.size.width, sortaPixel);
}

- (void) setHeight: (CGFloat) height
{
    self.frame = CGRectMake(0, 0, [self superview].frame.size.width - 0, height);
}







@end
