//
//  TodayViewController.m
//  PRWidgetPrime
//
//  Created by Armen on 4/4/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "Constants.h"

static const CGFloat kWidgetCompactModeMaxHeight = 110.0f;
static const CGFloat kWidgetExtraHeightSize = 126.0f;

@interface TodayViewController () <NCWidgetProviding>

@property (strong, nonatomic) NSArray* buttonNames;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
@property (assign, nonatomic) NSInteger selectedButtonIndex;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *containerViews;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(iOS 10.0, *)) {
        [self.extensionContext setWidgetLargestAvailableDisplayMode:NCWidgetDisplayModeExpanded];
    }

    [self setSettings];
}

- (void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize NS_AVAILABLE_IOS(10_0)
{
    if (@available(iOS 10.0, *)) {
        NSString* displayMode;

        if (activeDisplayMode == NCWidgetDisplayModeCompact) {
            self.preferredContentSize = CGSizeMake(0, kWidgetCompactModeMaxHeight);
            displayMode = @"NCWidgetDisplayModeCompact";
        } else {
            CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
            CGFloat widgetExpandedModeMaxHeight = screenHeight - kWidgetExtraHeightSize;

            self.preferredContentSize = CGSizeMake(0, widgetExpandedModeMaxHeight);
            displayMode = @"NCWidgetDisplayModeExpanded";
        }

        [[NSUserDefaults standardUserDefaults] setValue:displayMode forKey:kDisplayMode];
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowMoreOrLessNotification object:displayMode];
    }
}

#pragma mark - Private Functions

- (void)setSettings {
    _selectedButtonIndex = 0;
    [self setupButtons];
}

- (void)setupButtons {
    NSString *calendar = NSLocalizedString(@"Calendar", nil);
    NSString *requests = NSLocalizedString(@"Requests", nil);
    NSString *cityguide = NSLocalizedString(@"Guide", nil);
    NSString *chat = NSLocalizedString(@"Chat", nil);

    _buttonNames = @[calendar, requests, cityguide, chat];

    for (NSInteger i = 0; i < _buttonNames.count; i++) {
        UIButton *currentButton = _buttons[i];
        [currentButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
        [currentButton setTitle:_buttonNames[i] forState:UIControlStateNormal];
        currentButton.layer.masksToBounds = NO;
        currentButton.layer.cornerRadius = currentButton.frame.size.height/2;
    }
    [self newControllerButtonsAction:_buttons[_selectedButtonIndex]];
}

- (void)selectButtonWithIndex:(NSInteger)index {
    for (NSInteger i = 0; i < _buttonNames.count; i++) {
        UIButton *currentButton = _buttons[i];
        if (i == _selectedButtonIndex) {
            [currentButton setTitleColor:kWhiteColor forState:UIControlStateNormal];
            [currentButton setBackgroundColor:kIconsColor];
        } else {
            [currentButton setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.5]];
            [currentButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
    }
}

- (IBAction)newControllerButtonsAction:(UIButton *)sender {

    _selectedButtonIndex = sender.tag;
    [self selectButtonWithIndex:_selectedButtonIndex];

    for (NSInteger i = 0; i < _buttons.count; i++) {
        UIView *containerView = _containerViews[i];
        if (i == _selectedButtonIndex) {
            containerView.hidden = NO;
        } else {
            containerView.hidden = YES;
        }
    }
}


@end
