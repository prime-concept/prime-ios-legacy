//
//  ContainerButton.m
//  PRIME
//
//  Created by Admin on 2/19/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "ContainerButton.h"

@implementation ContainerButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void) setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        self.backgroundColor = [self lighterColor];
    }
    else {
        self.backgroundColor = _backColor;
    }
}

- (UIColor *)lighterColor
{
    CGFloat h, s, b, a;
    if ([_backColor getHue:&h saturation:&s brightness:&b alpha:&a]) {
        return [UIColor colorWithHue:h
                          saturation:s
                          brightness:MIN(b * 1.3, 1.0)
                               alpha:a];
    }
    
    CGFloat white, alpha;
    if ([_backColor getWhite:&white alpha:&alpha]) {
        white = MIN(1.3*white, 1.0);
        return [UIColor colorWithWhite:white alpha:alpha];
    }
    
    return nil;
}
@end
