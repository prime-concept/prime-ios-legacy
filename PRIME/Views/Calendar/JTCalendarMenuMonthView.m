//
//  JTCalendarMenuMonthView.m
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import "JTCalendarMenuMonthView.h"

@interface JTCalendarMenuMonthView ()

@property (strong, nonatomic) UILabel* textLabel;

@end

@implementation JTCalendarMenuMonthView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }

    [self commonInit];

    return self;
}

- (instancetype)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return nil;
    }

    [self commonInit];

    return self;
}

- (void)commonInit
{
    {
        _textLabel = [UILabel new];
        [self addSubview:_textLabel];

        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.numberOfLines = 0;
    }
}

- (void)setCurrentDate:(NSDate*)currentDate
{
    _textLabel.text = self.calendarManager.calendarAppearance.monthBlock(currentDate, self.calendarManager);
    _textLabel.textColor = kPhoneLabelTextColor;
}

- (void)layoutSubviews
{
    _textLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));

    // No need to call [super layoutSubviews].
}

- (void)reloadAppearance
{
    _textLabel.textColor = self.calendarManager.calendarAppearance.menuMonthTextColor;
    _textLabel.font = self.calendarManager.calendarAppearance.menuMonthTextFont;
}

@end
