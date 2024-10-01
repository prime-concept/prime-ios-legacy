//
//  JTCalendarDayView.m
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import "JTCalendarDayView.h"

#import "JTCircleView.h"

@interface PRDotsContainerView : UIView
@property (nonatomic) NSInteger dotsCount;
@property (nonatomic) CGFloat dotSize;

- (void)setDotsColor:(UIColor*)color;

@end

@interface JTCalendarDayView () {
    PRDotsContainerView* dotsContainerView;
    JTCircleView* circleView;
    JTCircleView* todayCircleView;
    UILabel* textLabel;

    BOOL haveEvent;
    BOOL isSelected;

    int cacheIsToday;
    NSString* cacheCurrentDateText;
}
@end

static NSString* const kJTCalendarDaySelected = @"kJTCalendarDaySelected";

@implementation JTCalendarDayView

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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)commonInit
{
    isSelected = NO;
    self.isOtherMonth = NO;

    {
        circleView = [JTCircleView new];
        [self addSubview:circleView];
    }

    {
        [self addCircleViewForToday];
    }

    {
        textLabel = [UILabel new];
        [self addSubview:textLabel];
    }

    {
        [self addDots];
    }

    {
        UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTouch)];

        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:gesture];
    }

    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDaySelected:) name:kJTCalendarDaySelected object:nil];
    }
}

- (void)layoutSubviews
{
    [self configureConstraintsForSubviews];

    // No need to call [super layoutSubviews]
}

// Avoid to calcul constraints (very expensive)
- (void)configureConstraintsForSubviews
{
    textLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height * 0.80);

    CGFloat sizeCircle = MIN(self.frame.size.width * 0.58, self.frame.size.height * 0.65);
    CGFloat sizeDot = MIN(self.frame.size.width, self.frame.size.height * 0.65);

    sizeCircle = sizeCircle * self.calendarManager.calendarAppearance.dayCircleRatio;
    sizeDot = sizeDot * self.calendarManager.calendarAppearance.dayDotRatio;

    sizeCircle = roundf(sizeCircle);
    sizeDot = roundf(sizeDot);

    circleView.frame = CGRectMake(0, 0, sizeCircle, sizeCircle);
    circleView.center = CGPointMake(self.frame.size.width / 2., self.frame.size.height * 0.80 / 2.);
    circleView.layer.cornerRadius = sizeCircle / 2.;

    todayCircleView.frame = CGRectMake(0, 0, sizeCircle, sizeCircle);
    todayCircleView.center = CGPointMake(self.frame.size.width / 2., self.frame.size.height * 0.80 / 2.);
    todayCircleView.layer.cornerRadius = sizeCircle / 2.;

    dotsContainerView.dotSize = sizeDot;
    dotsContainerView.center = CGPointMake(self.frame.size.width / 2., (self.frame.size.height * 1.2 / 2.) + sizeDot);
}

- (void)setDate:(NSDate*)date
{
    static NSDateFormatter* dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [NSDateFormatter new];
        dateFormatter.timeZone = self.calendarManager.calendarAppearance.calendar.timeZone;
        [dateFormatter setDateFormat:@"d"];
    }

    self->_date = date;

    textLabel.text = [dateFormatter stringFromDate:date];

    cacheIsToday = -1;
    cacheCurrentDateText = nil;
}

- (void)didTouch
{
    [PRGoogleAnalyticsManager sendEventWithName:kCalendarDaySelected parameters:nil];
    [self setSelected:YES animated:YES];
    [self.calendarManager setCurrentDateSelected:self.date];

    [[NSNotificationCenter defaultCenter] postNotificationName:kJTCalendarDaySelected object:self.date];

    [self.calendarManager.dataSource calendarDidDateSelected:self.calendarManager date:self.date];

    if (!self.isOtherMonth || !self.calendarManager.calendarAppearance.autoChangeMonth) {
        return;
    }

    NSInteger currentMonthIndex = [self monthIndexForDate:self.date];
    NSInteger calendarMonthIndex = [self monthIndexForDate:self.calendarManager.currentDate];

    currentMonthIndex = currentMonthIndex % 12;

    if (currentMonthIndex == (calendarMonthIndex + 1) % 12) {
        [self.calendarManager loadNextMonth];
    } else if (currentMonthIndex == (calendarMonthIndex + 12 - 1) % 12) {
        [self.calendarManager loadPreviousMonth];
    }
}

- (void)didDaySelected:(NSNotification*)notification
{
    NSDate* dateSelected = [notification object];

    if ([self isSameDate:dateSelected]) {
        if (!isSelected) {
            [self setSelected:YES animated:YES];
        }
    } else if (isSelected) {
        [self setSelected:NO animated:YES];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (isSelected == selected) {
        animated = NO;
    }

    isSelected = selected;

    circleView.transform = CGAffineTransformIdentity;
    CGAffineTransform tr = CGAffineTransformIdentity;
    CGFloat opacity = 1.;

    todayCircleView.layer.borderColor = [self.calendarManager.calendarAppearance dayCircleColorToday].CGColor;
    [todayCircleView setHidden:![self isToday]];
    [dotsContainerView setHidden:!haveEvent ?: (selected || [self isToday])];

    if (selected) {

        textLabel.font = self.calendarManager.calendarAppearance.dayTextFontSelected;

        //circleView.filled = YES;

        if ([self isToday]) {
            textLabel.textColor = [UIColor blackColor];
        } else {
            if (!self.isOtherMonth) {
                circleView.color = [self.calendarManager.calendarAppearance dayCircleColorSelected];
                textLabel.textColor = [self.calendarManager.calendarAppearance dayTextColorSelected];
                [self setDotsColor:[self.calendarManager.calendarAppearance dayDotColorSelected]];

            } else {
                circleView.color = [self.calendarManager.calendarAppearance dayCircleColorSelectedOtherMonth];
                textLabel.textColor = [self.calendarManager.calendarAppearance dayTextColorSelectedOtherMonth];
                [self setDotsColor:[self.calendarManager.calendarAppearance dayDotColorSelectedOtherMonth]];
            }
        }

        circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
        tr = CGAffineTransformIdentity;
    } else if ([self isToday]) {
        textLabel.textColor = [UIColor blackColor];
        textLabel.font = self.calendarManager.calendarAppearance.dayTextFontToday;

        //circleView.filled = NO;

    } else {
        textLabel.font = self.calendarManager.calendarAppearance.dayTextFont;

        //circleView.filled = YES;

        if (!self.isOtherMonth) {
            textLabel.textColor = [self.calendarManager.calendarAppearance dayTextColor];
            [self setDotsColor:[self.calendarManager.calendarAppearance dayDotColor]];
        } else {
            textLabel.textColor = [self.calendarManager.calendarAppearance dayTextColorOtherMonth];
            [self setDotsColor:[self.calendarManager.calendarAppearance dayDotColorOtherMonth]];
        }

        opacity = 0.;
    }

    if (animated) {
        [UIView animateWithDuration:.3
                         animations:^{
                             circleView.layer.opacity = opacity;
                             circleView.transform = tr;
                         }];
    } else {
        circleView.layer.opacity = opacity;
        circleView.transform = tr;
    }
}

- (void)setIsOtherMonth:(BOOL)isOtherMonth
{
    self->_isOtherMonth = isOtherMonth;
    [self setSelected:isSelected animated:NO];

    [self setHidden:isOtherMonth];
}

- (void)reloadData
{
    haveEvent = [self.calendarManager.dataCache haveEvent:self.date];
    dotsContainerView.hidden = !haveEvent;

    BOOL selected = [self isSameDate:[self.calendarManager currentDateSelected]];
    [self setSelected:selected animated:NO];
}

- (void)addDots
{
    dotsContainerView = [PRDotsContainerView new];
    dotsContainerView.backgroundColor = [UIColor clearColor];
    dotsContainerView.hidden = YES;
    dotsContainerView.dotsCount = 1;

    [self addSubview:dotsContainerView];
}

- (void)addCircleViewForToday
{
    todayCircleView = [JTCircleView new];
    todayCircleView.layer.borderWidth = 1.0f;
    todayCircleView.hidden = YES;
    [self addSubview:todayCircleView];
}

- (void)setDotsColor:(UIColor*)color
{
    [dotsContainerView setDotsColor:color];
}

- (BOOL)isToday
{
    if (cacheIsToday == 0) {
        return NO;
    } else if (cacheIsToday == 1) {
        return YES;
    } else {
        if ([self isSameDate:[NSDate date]]) {
            cacheIsToday = 1;
            return YES;
        } else {
            cacheIsToday = 0;
            return NO;
        }
    }
}

- (BOOL)isSameDate:(NSDate*)date
{
    static NSDateFormatter* dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [NSDateFormatter new];
        dateFormatter.timeZone = self.calendarManager.calendarAppearance.calendar.timeZone;
        [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    }

    if (!cacheCurrentDateText) {
        cacheCurrentDateText = [dateFormatter stringFromDate:self.date];
    }

    NSString* dateText2 = [dateFormatter stringFromDate:date];

    if ([cacheCurrentDateText isEqualToString:dateText2]) {
        return YES;
    }

    return NO;
}

- (NSInteger)monthIndexForDate:(NSDate*)date
{
    NSCalendar* calendar = self.calendarManager.calendarAppearance.calendar;
    NSDateComponents* comps = [calendar components:NSCalendarUnitMonth fromDate:date];
    return comps.month;
}

- (void)reloadAppearance
{
    textLabel.textAlignment = NSTextAlignmentCenter;

    [self configureConstraintsForSubviews];
    [self setSelected:isSelected animated:NO];
}

@end

@interface PRDotsContainerView ()
@property (strong, nonatomic) NSMutableArray<JTCircleView*>* dotsArray;

@end

@implementation PRDotsContainerView

- (void)setDotsCount:(NSInteger)dotsCount
{
    _dotsArray = [NSMutableArray new];
    for (UIView* subView in self.subviews) {
        [subView removeFromSuperview];
    }

    for (int i = 0; i < dotsCount; i++) {
        JTCircleView* dot = [JTCircleView new];
        [_dotsArray addObject:dot];
        [self addSubview:dot];
    }

    _dotsCount = dotsCount;
}

- (void)setDotSize:(CGFloat)sizeDot
{
    [self setFrame:CGRectMake(0, 0, (sizeDot * _dotsCount) + (2 * (_dotsCount - 1)), sizeDot)];

    for (int i = 0; i < _dotsArray.count; i++) {
        _dotsArray[i].layer.cornerRadius = sizeDot / 2;
        _dotsArray[i].frame = CGRectMake((sizeDot + 2) * i, 0, sizeDot, sizeDot);
    }
}

- (void)setDotsColor:(UIColor*)color
{
    for (JTCircleView* dotView in _dotsArray) {
        dotView.color = color;
    }
}

@end
