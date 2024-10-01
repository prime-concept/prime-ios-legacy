//
//  PROverviewSliderViewController.m
//  PRIME
//
//  Created by Davit on 8/25/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "PRInitialOverviewViewController.h"
#import "PROverviewScreenLoader.h"
#import "PROverviewSliderViewController.h"

@interface PROverviewSliderViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, OverviewScreenLoaderDelegate, InitialOverviewViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIPageControl* pageControl;

@property (nonatomic, strong) UIPageViewController* pageViewController;
@property (nonatomic, strong) NSMutableArray<UIViewController*>* slides;

@end

static const CGFloat kInterPageSpacingKey = 30.0;

@implementation PROverviewSliderViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options:@{ UIPageViewControllerOptionInterPageSpacingKey : @(kInterPageSpacingKey) }];
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self loadOverviewScreens];

    _pageViewController.delegate = self;
    _pageViewController.dataSource = self;
    _pageViewController.view.backgroundColor = [UIColor clearColor];

    _pageControl.numberOfPages = _slides.count;

    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(pageControlTapDetected:)];
    [_pageControl addGestureRecognizer:tapGesture];
}

#pragma mark - Status Bar Appearance

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Load Screens

- (void)loadOverviewScreens
{
    PROverviewScreenLoader* overviewScreenLoader = [[PROverviewScreenLoader alloc] init];
    [overviewScreenLoader loadScreensWithDelegate:self];
}

#pragma mark - OverviewScreenLoaderDelegate

- (void)onScreenLoaded:(UIViewController*)viewController
{
    if (!_slides) {
        _slides = [NSMutableArray array];
    }

    if ([viewController isKindOfClass:[PRInitialOverviewViewController class]]) {
        PRInitialOverviewViewController* initialOverviewViewController = (PRInitialOverviewViewController*)viewController;
        initialOverviewViewController.delegate = self;
    }

    [_slides addObject:viewController];
    [_pageViewController setViewControllers:@[ _slides[0] ]
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:YES
                                 completion:nil];
}

#pragma mark - InitialOverviewViewControllerDelegate

- (void)registerPrimeSegmentDidSelect
{
    [_pageViewController setViewControllers:@[ [_slides lastObject] ]
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:YES
                                 completion:nil];

    _pageControl.currentPage = _slides.count - 1;
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController*)pageViewController:(UIPageViewController*)pageViewController
      viewControllerAfterViewController:(UIViewController*)viewController
{
    [PRGoogleAnalyticsManager sendEventWithName:kOverviewScreenSwiped parameters:nil];
    NSInteger index = [_slides indexOfObject:viewController];

    if (index == _slides.count - 1) {
        return _slides[0];
    }

    index++;
    if (index < _slides.count) {
        return _slides[index];
    }
    return nil;
}

- (UIViewController*)pageViewController:(UIPageViewController*)pageViewController
     viewControllerBeforeViewController:(UIViewController*)viewController
{
    [PRGoogleAnalyticsManager sendEventWithName:kOverviewScreenSwiped parameters:nil];
    NSInteger index = [_slides indexOfObject:viewController];

    if (index == 0) {
        return _slides[_slides.count - 1];
    }

    index--;
    if (index >= 0) {
        return _slides[index];
    }
    return nil;
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController*)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray<UIViewController*>*)previousViewControllers
       transitionCompleted:(BOOL)completed
{
    if (!completed) {
        return;
    }
    _pageControl.currentPage = [_slides indexOfObject:[pageViewController.viewControllers lastObject]];
}

#pragma mark - Gesture

- (void)pageControlTapDetected:(UITapGestureRecognizer*)gestureRecognizer
{
    CGPoint tappedPoint = [gestureRecognizer locationInView:_pageControl];

    UIViewController* currentViewController = _pageViewController.viewControllers.firstObject;

    if (tappedPoint.x >= CGRectGetWidth(_pageControl.frame) / 2) {

        UIViewController* previousViewController = [self pageViewController:_pageViewController viewControllerAfterViewController:currentViewController];
        [_pageViewController setViewControllers:@[ previousViewController ]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:YES
                                     completion:nil];
    }
    else {

        UIViewController* previousViewController = [self pageViewController:_pageViewController viewControllerBeforeViewController:currentViewController];
        [_pageViewController setViewControllers:@[ previousViewController ]
                                      direction:UIPageViewControllerNavigationDirectionReverse
                                       animated:YES
                                     completion:nil];
    }
    _pageControl.currentPage = [_slides indexOfObject:[_pageViewController.viewControllers lastObject]];
}

@end
