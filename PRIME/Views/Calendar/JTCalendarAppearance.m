//
//  JTCalendarAppearance.m
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import "JTCalendarAppearance.h"

#import "JTCalendar.h"

@implementation JTCalendarAppearance

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }

    [self setDefaultValues];

    return self;
}

- (void)setDefaultValues
{
    self.isWeekMode = NO;

    self.weekDayFormat = JTCalendarWeekDayFormat_Short;
    self.useCacheSystem = YES;
    self.focusSelectedDayChangeMode = NO;

    self.ratioContentMenu = 2.;
    self.autoChangeMonth = YES;

    self.dayCircleRatio = 1.;
    self.dayDotRatio = 1. / 9.;

    self.menuMonthTextFont = [UIFont systemFontOfSize:17.];
    self.weekDayTextFont = [UIFont systemFontOfSize:11];
    self.dayTextFont = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    self.dayTextFontToday = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    self.dayTextFontSelected = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];

    self.menuMonthTextColor = [UIColor blackColor];
    self.weekDayTextColor = [UIColor colorWithRed:152. / 256. green:147. / 256. blue:157. / 256. alpha:1.];

    [self setDayDotColorForAll:[UIColor colorWithRed:43. / 256. green:88. / 256. blue:134. / 256. alpha:1.]];
    [self setDayTextColorForAll:[UIColor blackColor]];

    self.dayTextColorOtherMonth = [UIColor colorWithRed:152. / 256. green:147. / 256. blue:157. / 256. alpha:1.];

    self.dayCircleColorSelected = [UIColor redColor];
    self.dayTextColorSelected = [UIColor whiteColor];
    self.dayDotColorSelected = [UIColor whiteColor];

    self.dayCircleColorSelectedOtherMonth = self.dayCircleColorSelected;
    self.dayTextColorSelectedOtherMonth = self.dayTextColorSelected;
    self.dayDotColorSelectedOtherMonth = self.dayDotColorSelected;

    self.dayCircleColorToday = [UIColor colorWithRed:0x33 / 256. green:0xB3 / 256. blue:0xEC / 256. alpha:.5];
    self.dayTextColorToday = [UIColor whiteColor];
    self.dayDotColorToday = [UIColor whiteColor];

    self.dayCircleColorTodayOtherMonth = self.dayCircleColorToday;
    self.dayTextColorTodayOtherMonth = self.dayTextColorToday;
    self.dayDotColorTodayOtherMonth = self.dayDotColorToday;

    self.monthBlock = ^NSString*(NSDate* date, JTCalendar* jt_calendar)
    {
        NSCalendar* calendar = jt_calendar.calendarAppearance.calendar;
        NSDateComponents* comps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:date];
        NSInteger currentMonthIndex = comps.month;

        static NSDateFormatter* dateFormatter;
        if (!dateFormatter) {
            dateFormatter = [NSDateFormatter new];
            dateFormatter.timeZone = jt_calendar.calendarAppearance.calendar.timeZone;
        }

        while (currentMonthIndex <= 0) {
            currentMonthIndex += 12;
        }

        [dateFormatter setDateFormat:@"yyyy"];
        NSString* stringFromDate = [dateFormatter stringFromDate:date];
        stringFromDate = [NSString stringWithFormat:@"%@ %@", [[dateFormatter standaloneMonthSymbols][currentMonthIndex - 1] capitalizedString], stringFromDate];
        return stringFromDate;
    };
}

- (NSCalendar*)calendar
{
    static NSCalendar* calendar;
    static dispatch_once_t once;

    dispatch_once(&once, ^{
#ifdef __IPHONE_8_0
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
#else
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
#endif
        calendar.timeZone = [NSTimeZone localTimeZone];
    });

    return calendar;
}

- (void)setDayDotColorForAll:(UIColor*)dotColor
{
    self.dayDotColor = dotColor;
    self.dayDotColorSelected = dotColor;

    self.dayDotColorOtherMonth = dotColor;
    self.dayDotColorSelectedOtherMonth = dotColor;

    self.dayDotColorToday = dotColor;
    self.dayDotColorTodayOtherMonth = dotColor;
}

- (void)setDayTextColorForAll:(UIColor*)textColor
{
    self.dayTextColor = textColor;
    self.dayTextColorSelected = textColor;

    self.dayTextColorOtherMonth = textColor;
    self.dayTextColorSelectedOtherMonth = textColor;

    self.dayTextColorToday = textColor;
    self.dayTextColorTodayOtherMonth = textColor;
}

@end
