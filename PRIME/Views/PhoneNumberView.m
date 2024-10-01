//
//  PhoneNumberView.m
//  PRIME
//
//  Created by Admin on 6/1/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PhoneNumberView.h"

@interface PhoneNumberView ()

@property (nonatomic, assign) BOOL didSetupConstraints;

@end

static CGFloat leftMargin = 10;
static CGFloat isoCodeFieldWidth = 80;
static CGFloat arrowSize = 9;
static CGFloat padding = 10;
static CGFloat verticalPadding = 2;
static CGFloat lineHeight;

@implementation PhoneNumberView

+ (void)initialize
{
    if (self == [PhoneNumberView class]) {
        lineHeight = 1.0 / [UIScreen mainScreen].scale;
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    _labelCountryName = [UILabel newAutoLayoutView];
    _textFieldIsoCode = [UITextField newAutoLayoutView];
    _textFieldPhoneNumber = [BackspaceTextField newAutoLayoutView];
    _imageViewArrorw = [UIImageView newAutoLayoutView];

    _imageViewArrorw.image = [UIImage imageNamed:@"row-arrow"];

    _textFieldIsoCode.textAlignment = NSTextAlignmentCenter;
    _textFieldIsoCode.keyboardType = UIKeyboardTypePhonePad;
    _textFieldPhoneNumber.keyboardType = UIKeyboardTypePhonePad;
    _textFieldPhoneNumber.placeholder = NSLocalizedString(@"Your phone number", nil);
    _textFieldPhoneNumber.adjustsFontSizeToFitWidth = YES;
    _textFieldPhoneNumber.minimumFontSize = 0.8;

    [_labelCountryName setIsAccessibilityElement:YES];
    [_textFieldIsoCode setIsAccessibilityElement:YES];
    [_textFieldPhoneNumber setIsAccessibilityElement:YES];
    [_labelCountryName setAccessibilityIdentifier:@"country_name_label"];
    [_textFieldIsoCode setAccessibilityIdentifier:@"iso_code_text_field"];
    [_textFieldPhoneNumber setAccessibilityIdentifier:@"phone_number_label"];

    NSInteger fontSize = 19;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 8.0) {
        _labelCountryName.font = [UIFont systemFontOfSize:fontSize weight:UIFontWeightMedium];
        _textFieldIsoCode.font = [UIFont systemFontOfSize:fontSize weight:UIFontWeightMedium];
        _textFieldPhoneNumber.font = [UIFont systemFontOfSize:fontSize weight:UIFontWeightMedium];
    }
    else {
        _labelCountryName.font = [UIFont systemFontOfSize:fontSize];
        _textFieldIsoCode.font = [UIFont systemFontOfSize:fontSize];
        _textFieldPhoneNumber.font = [UIFont systemFontOfSize:fontSize];
    }

    [self addSubview:_labelCountryName];
    [self addSubview:_textFieldIsoCode];
    [self addSubview:_textFieldPhoneNumber];
    [self addSubview:_imageViewArrorw];

    _labelCountryName.backgroundColor = [UIColor clearColor];
    _textFieldIsoCode.backgroundColor = [UIColor clearColor];
    _textFieldPhoneNumber.backgroundColor = [UIColor clearColor];
}

- (NSString*)phoneNumberWihtCode
{
    return [[_textFieldIsoCode.text stringByAppendingString:_textFieldPhoneNumber.text] substringFromIndex:1]; //remove +
}

- (void)updateConstraints
{
    if (!self.didSetupConstraints) {
        [_labelCountryName autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, leftMargin, 0, 0) excludingEdge:ALEdgeBottom];
        [_textFieldPhoneNumber autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_labelCountryName withOffset:verticalPadding];

        [_textFieldPhoneNumber autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self];
        [_textFieldPhoneNumber autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self];
        [_textFieldPhoneNumber autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:_textFieldIsoCode withOffset:padding];
        [@[ _labelCountryName, _textFieldPhoneNumber, _textFieldIsoCode ] autoMatchViewsDimension:ALDimensionHeight];

        [_textFieldIsoCode autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self];
        [_textFieldIsoCode autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self withOffset:leftMargin];
        [_textFieldIsoCode autoSetDimension:ALDimensionWidth toSize:isoCodeFieldWidth - leftMargin];

        [_imageViewArrorw autoSetDimensionsToSize:CGSizeMake(18, 18)];
        [@[ _labelCountryName, _imageViewArrorw ] autoAlignViewsToAxis:ALAxisHorizontal];
        [_imageViewArrorw autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:15];

        self.didSetupConstraints = YES;
    }

    [super updateConstraints];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, NO);
    CGContextSetStrokeColorWithColor(context, kCalendarLineColor.CGColor);

    [self drawMiddleLine:rect];

    [self drawVerticalLine:rect];

    [self drawBottomLine:rect];

    CGContextStrokePath(context);
}

- (void)drawBottomLine:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetLineWidth(context, lineHeight);
    CGContextMoveToPoint(context, leftMargin, CGRectGetMaxY(rect) - lineHeight);
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect) - lineHeight);
}

- (void)drawMiddleLine:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat centerX = floorf(leftMargin + (isoCodeFieldWidth - leftMargin) / 2);
    CGContextMoveToPoint(context, leftMargin, CGRectGetMaxY(rect) / 2 - lineHeight);
    CGContextAddLineToPoint(context, centerX - arrowSize,
        CGRectGetMaxY(rect) / 2 - lineHeight);

    CGContextMoveToPoint(context, centerX - arrowSize + lineHeight,
        CGRectGetMaxY(rect) / 2 - lineHeight);

    CGContextAddLineToPoint(context, centerX + lineHeight, CGRectGetMaxY(rect) / 2 + arrowSize - lineHeight);
    CGContextAddLineToPoint(context, centerX + arrowSize + lineHeight,
        CGRectGetMaxY(rect) / 2 - lineHeight);

    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect) / 2 - lineHeight);

    if (_needToFill) {
        [self fillPath:rect];
    }
}

- (void)fillPath:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, kAppLabelColor.CGColor);

    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), 0);
    CGContextAddLineToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, 0, CGRectGetMaxY(rect) / 2 - lineHeight);
    CGContextAddLineToPoint(context, 0, CGRectGetMaxY(rect) / 2 - lineHeight);
    CGContextAddLineToPoint(context, leftMargin, CGRectGetMaxY(rect) / 2 - lineHeight);

    CGContextFillPath(context);
}

- (void)drawVerticalLine:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextMoveToPoint(context, isoCodeFieldWidth, CGRectGetMaxY(rect) / 2 - lineHeight);
    CGContextAddLineToPoint(context, isoCodeFieldWidth,
        CGRectGetMaxY(rect) - lineHeight);
}

- (BOOL)needToFillTouchedArea:(NSSet*)touches
{
    UITouch* aTouch = [touches anyObject];
    CGPoint currentTouchPosition = [aTouch locationInView:self];
    CGRect rectToFill = CGRectMake(0, 0, self.bounds.size.width, CGRectGetHeight(self.bounds) / 2);
    if (CGRectContainsPoint(rectToFill, currentTouchPosition)) {
        return YES;
    }

    return NO;
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    if ([self needToFillTouchedArea:touches] && _needToFill != YES) {
        _needToFill = YES;
        [self setNeedsDisplay];
    }
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    if ([self needToFillTouchedArea:touches] && _needToFill != YES) {
        _needToFill = YES;
        [self setNeedsDisplay];
    }
    else if (![self needToFillTouchedArea:touches] && _needToFill != NO) {
        _needToFill = NO;
        [self setNeedsDisplay];
    }
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    if (_needToFill) {
        [_touchDelegate countryNameTouched];
    }
    _needToFill = NO;
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event
{
    _needToFill = NO;
    [self setNeedsDisplay];
}

@end
