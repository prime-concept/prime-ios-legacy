//
//  JTCalendarMonthWeekDaysView.m
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import "JTCalendarMonthWeekDaysView.h"
#import "XNLine.h"

@interface JTCalendarMonthWeekDaysView () {
    XNLine* lineView;
}

@end

@implementation JTCalendarMonthWeekDaysView

static NSArray* cacheDaysOfWeeks;

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
        lineView = [[XNLine alloc] init];
        [self addSubview:lineView];
    }

    for (NSString* day in [self daysOfWeek]) {
        UILabel* view = [UILabel new];

        view.font = self.calendarManager.calendarAppearance.weekDayTextFont;
        view.textColor = self.calendarManager.calendarAppearance.weekDayTextColor;

        view.textAlignment = NSTextAlignmentCenter;
        view.text = day;

        [self addSubview:view];
    }
}

- (NSArray*)daysOfWeek
{
    if (cacheDaysOfWeeks) {
        return cacheDaysOfWeeks;
    }

    NSDateFormatter* dateFormatter = [NSDateFormatter new];
    NSMutableArray* days = nil;

    switch (self.calendarManager.calendarAppearance.weekDayFormat) {
    case JTCalendarWeekDayFormat_Single:
        days = [[dateFormatter veryShortStandaloneWeekdaySymbols] mutableCopy];
        break;
    case JTCalendarWeekDayFormat_Short:
        days = [[dateFormatter shortStandaloneWeekdaySymbols] mutableCopy];
        break;
    case JTCalendarWeekDayFormat_Full:
        days = [[dateFormatter standaloneWeekdaySymbols] mutableCopy];
        break;
    }

    for (NSInteger i = 0; i < days.count; ++i) {
        NSString* day = days[i];
        days[i] = [day uppercaseString];
    }

    // Redorder days for be conform to calendar
    {
        NSCalendar* calendar = self.calendarManager.calendarAppearance.calendar;
        NSUInteger firstWeekday = (calendar.firstWeekday + 6) % 7; // Sunday == 1, Saturday == 7

        for (int i = 0; i < firstWeekday; ++i) {
            id day = [days firstObject];
            [days removeObjectAtIndex:0];
            [days addObject:day];
        }
    }

    cacheDaysOfWeeks = days;
    return cacheDaysOfWeeks;
}

- (void)layoutSubviews
{
    CGFloat x = 0;
    CGFloat width = self.frame.size.width / 7.;
    CGFloat height = self.frame.size.height;

    for (UIView* view in self.subviews) {

        if ([[view class] isSubclassOfClass:[UILabel class]]) {
            view.frame = CGRectMake(x, 0, width, height * 0.7);
            x = CGRectGetMaxX(view.frame);
        }
    }

    [lineView setBackgroundColor:self.calendarManager.calendarAppearance.weekDayBackgroundColor];

    [lineView setHeight:height];

    [lineView setBackgroundColor:self.calendarManager.calendarAppearance.lineColor];
    [lineView setY:height];

    // No need to call [super layoutSubviews]
}

+ (void)beforeReloadAppearance
{
    cacheDaysOfWeeks = nil;
}

- (void)reloadAppearance
{
    for (int i = 0; i < self.subviews.count; ++i) {
        UILabel* view = (self.subviews)[i];

        if ([[view class] isSubclassOfClass:[UILabel class]]) {

            view.font = self.calendarManager.calendarAppearance.weekDayTextFont;
            view.textColor = self.calendarManager.calendarAppearance.weekDayTextColor;

            view.text = [self daysOfWeek][i - 1];
        }
    }
}

@end
