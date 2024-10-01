//
//  ContainerViewController.m
//  PRIME
//
//  Created by Artak on 3/19/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "ContainerViewController.h"
#import "RequestOtherViewController.h"
#import "RequestTransferViewController.h"
#import "RequestVipHallViewController.h"

@interface ContainerViewController ()

@property (strong, nonatomic) NSString* currentSegueIdentifier;
@property (assign, nonatomic) BOOL isTransitionInProgress;
@property (strong, nonatomic) NSMutableDictionary* segueViewControllerMaping;

@end

@implementation ContainerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _isTransitionInProgress = NO;
    _currentSegueIdentifier = SegueTransactionView;
    _segueViewControllerMaping = [NSMutableDictionary dictionary];
}

- (void)viewDidAppear:(BOOL)animated
{
    if ([self.childViewControllers count] == 0) {
        [self performSegueWithIdentifier:_currentSegueIdentifier sender:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    (_segueViewControllerMaping)[segue.identifier] = segue.destinationViewController;

    if ([self.childViewControllers count] == 0) {
        [self addChildViewController:segue.destinationViewController];
        UIView* destView = ((UIViewController*)segue.destinationViewController).view;
        destView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        destView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        [self.view addSubview:destView];
        _currentViewController = segue.destinationViewController;
        [segue.destinationViewController didMoveToParentViewController:self];
        _isTransitionInProgress = NO;
    }
    else {
        [self swapFromViewController:(_segueViewControllerMaping)[_currentSegueIdentifier]
                    toViewController:segue.destinationViewController];
        _currentViewController = segue.destinationViewController;
    }
}

- (void)swapFromViewController:(UIViewController*)fromViewController toViewController:(UIViewController<FilterViewControllerDelegate>*)toViewController
{
    toViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);

    [fromViewController willMoveToParentViewController:nil];
    [self addChildViewController:toViewController];
    _currentViewController = toViewController;
    [self transitionFromViewController:fromViewController
                      toViewController:toViewController
                              duration:0.3
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:nil
                            completion:^(BOOL finished) {
                                [fromViewController removeFromParentViewController];
                                [toViewController didMoveToParentViewController:self];
                                _isTransitionInProgress = NO;
                            }];
}

- (void)swapToViewControllers:(NSString*)segueName
{
    if (_isTransitionInProgress || [segueName isEqualToString:_currentSegueIdentifier]) {
        return;
    }

    _isTransitionInProgress = YES;
    UIViewController<FilterViewControllerDelegate>* toViewController = (_segueViewControllerMaping)[segueName];
    UIViewController* fromViewController = (_segueViewControllerMaping)[_currentSegueIdentifier];

    if (toViewController != nil) {
        [self swapFromViewController:fromViewController toViewController:toViewController];
        _currentSegueIdentifier = segueName;
        return;
    }

    [self performSegueWithIdentifier:segueName sender:nil];

    _currentSegueIdentifier = segueName;
}

@end
