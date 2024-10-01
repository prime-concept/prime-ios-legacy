//
//  JTCircleView.h
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import "JTCircleView.h"

// http://stackoverflow.com/questions/17038017/ios-draw-filled-circles

@implementation JTCircleView

- (instancetype)init
{
    self = [super init];
    if(!self){
        return nil;
    }
    
    self.filled = YES;
    
    self.backgroundColor = [UIColor clearColor];
    self.color = [UIColor whiteColor];
    
    return self;
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(ctx, [self.backgroundColor CGColor]);
    CGContextFillRect(ctx, rect);

    rect = CGRectInset(rect, .5, .5);
    
    CGContextSetStrokeColorWithColor(ctx, [self.color CGColor]);
    CGContextSetFillColorWithColor(ctx, [self.color CGColor]);
    
    if (self.filled) {
        CGContextAddEllipseInRect(ctx, rect);
        CGContextFillEllipseInRect(ctx, rect);
        CGContextFillPath(ctx);
    } else {
        CGContextAddRect(ctx, CGRectInset(rect, 3, 3));
        CGContextDrawPath(ctx, kCGPathStroke);
    }
}

- (void)setColor:(UIColor *)color
{
    self->_color = color;
    
    [self setNeedsDisplay];
}

@end
