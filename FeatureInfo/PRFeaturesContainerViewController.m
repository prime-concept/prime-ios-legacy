//
//  PRFeaturesContainerViewController.m
//  PRIME
//
//  Created by Sargis Terteryan on 5/30/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import "PRFeaturesContainerViewController.h"
#import "UIView+PRCategory.h"

@interface PRFeaturesContainerViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (strong, nonatomic) UIPageViewController* pageViewController;
@property (strong, nonatomic) NSMutableArray<UIViewController*>* pages;
@property (weak, nonatomic) IBOutlet UIPageControl* pageControl;
@property (weak, nonatomic) IBOutlet UIView* footerView;
@property (weak, nonatomic) IBOutlet UIButton* nextButton;
@property (weak, nonatomic) IBOutlet UIView* containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* containerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton* closeButton;
@property (weak, nonatomic) IBOutlet UIButton* closeXButton;

@end

static const CGFloat kPageSpacingKey = 30.0;
static const CGFloat kContainerViewDefaultHeightConstraint = 64.0f;
static const CGFloat kContainerViewHeightConstraintForIphoneX = 84.0f;

@implementation PRFeaturesContainerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupPageViewController];
    [self setupPageControl];
    self.view.backgroundColor = kFeatureInfoBackgroundColor;
    [self.closeXButton setImage:[UIImage imageNamed:@"feature_close_X"] forState:UIControlStateNormal];
    [self.view bringSubviewToFront:self.footerView];
    [self.view bringSubviewToFront:self.containerView];
    self.containerViewHeightConstraint.constant = IS_IPHONE_X ? kContainerViewHeightConstraintForIphoneX : kContainerViewDefaultHeightConstraint;

    NSInteger currentIndex = [self.pages indexOfObject:[self.pageViewController.viewControllers lastObject]];
    [self updateNextButtonTitleBasedOnPageIndex:currentIndex];
    [PRGoogleAnalyticsManager sendEventWithName:kFeaturesScreenOpened parameters:nil];
}

- (void)setViewControllers:(NSArray<UIViewController*>*)viewControllers
{
    self.pages = [viewControllers mutableCopy];
}

#pragma mark - Private Functions

- (IBAction)closeButton:(id)sender
{
    [PRGoogleAnalyticsManager sendEventWithName:kFeaturesScreenCloseButtonClicked parameters:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)nextButtonClick:(id)sender
{
    UIViewController* currentViewController = self.pageViewController.viewControllers.firstObject;
    UIViewController* previousViewController = [self pageViewController:self.pageViewController viewControllerAfterViewController:currentViewController];
    NSUInteger index = [self.pages indexOfObject:previousViewController];

    if ([self.pages indexOfObject:[self.pageViewController.viewControllers lastObject]] == self.pages.count - 1) {
        [PRGoogleAnalyticsManager sendEventWithName:kFeaturesScreenCloseButtonClicked parameters:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }

    [PRGoogleAnalyticsManager sendEventWithName:kFeaturesScreenNextButtonClicked parameters:nil];
    [self updateNextButtonTitleBasedOnPageIndex:index];
    [self.pageViewController setViewControllers:@[ previousViewController ]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:YES
                                     completion:nil];

    self.pageControl.currentPage = index;
}

- (void)updateNextButtonTitleBasedOnPageIndex:(NSInteger)currentIndex
{
    [self.nextButton setTitleColor:kFeatureInfoNextButtonColor forState:UIControlStateNormal];

    if (currentIndex != self.pages.count - 1) {
        [self.nextButton setTitle:NSLocalizedString(@"Next", nil) forState:UIControlStateNormal];
    } else {
        [self.nextButton setTitle:NSLocalizedString(@"Close", nil) forState:UIControlStateNormal];
    }
}

- (void)setupPageViewController
{
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:@{ UIPageViewControllerOptionInterPageSpacingKey : @(kPageSpacingKey) }];

    [UIView addSubviewToViewWithConstraints:self.view
                                    subview:self.pageViewController.view
                                        top:0
                                     bottom:0
                                    leading:0
                                   trailing:0];

    [self addChildViewController:self.pageViewController];
    [self.pageViewController didMoveToParentViewController:self];

    [self.pageViewController setViewControllers:@[ self.pages[0] ]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:YES
                                     completion:nil];

    self.pageViewController.delegate = self;
    self.pageViewController.dataSource = self;
}

- (void)setupPageControl
{
    if (self.pages.count == 1) {
        [self.closeButton setBackgroundImage:[UIImage imageNamed:@"feature_closed_icon"] forState:UIControlStateNormal];
        self.nextButton.hidden = YES;
        self.pageControl.hidden = YES;
        return;
    }
    self.pageControl.numberOfPages = self.pages.count;
    self.nextButton.hidden = NO;
    self.closeButton.hidden = YES;

    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(pageControlTapDetected:)];
    [self.pageControl addGestureRecognizer:tapGesture];
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController*)pageViewController:(UIPageViewController*)pageViewController
      viewControllerAfterViewController:(UIViewController*)viewController
{
    NSInteger index = [self.pages indexOfObject:viewController];

    if (self.pages.count == 1) {
        return nil;
    }

    [PRGoogleAnalyticsManager sendEventWithName:kFeaturesScreenSwiped parameters:nil];
    if (index == self.pages.count - 1) {
        return self.pages[0];
    }

    index++;
    if (index < self.pages.count) {
        return self.pages[index];
    }
    return nil;
}

- (UIViewController*)pageViewController:(UIPageViewController*)pageViewController
     viewControllerBeforeViewController:(UIViewController*)viewController
{
    NSInteger index = [self.pages indexOfObject:viewController];

    if (self.pages.count == 1) {
        return nil;
    }

    [PRGoogleAnalyticsManager sendEventWithName:kFeaturesScreenSwiped parameters:nil];
    if (index == 0) {
        return self.pages[self.pages.count - 1];
    }

    index--;
    if (index >= 0) {
        return self.pages[index];
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

    NSInteger currentIndex = [self.pages indexOfObject:[pageViewController.viewControllers lastObject]];
    [self updateNextButtonTitleBasedOnPageIndex:currentIndex];
    self.pageControl.currentPage = currentIndex;
}

#pragma mark - Gesture

- (void)pageControlTapDetected:(UITapGestureRecognizer*)gestureRecognizer
{
    const CGPoint tappedPoint = [gestureRecognizer locationInView:self.pageControl];
    UIViewController* currentViewController = self.pageViewController.viewControllers.firstObject;

    if (tappedPoint.x >= CGRectGetWidth(self.pageControl.frame) / 2) {

        UIViewController* previousViewController = [self pageViewController:self.pageViewController viewControllerAfterViewController:currentViewController];
        [self.pageViewController setViewControllers:@[ previousViewController ]
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:YES
                                         completion:nil];
    } else {

        UIViewController* previousViewController = [self pageViewController:self.pageViewController viewControllerBeforeViewController:currentViewController];
        [self.pageViewController setViewControllers:@[ previousViewController ]
                                          direction:UIPageViewControllerNavigationDirectionReverse
                                           animated:YES
                                         completion:nil];
    }

    NSInteger currentIndex = [self.pages indexOfObject:[self.pageViewController.viewControllers lastObject]];
    [self updateNextButtonTitleBasedOnPageIndex:currentIndex];
    self.pageControl.currentPage = currentIndex;
}

@end
