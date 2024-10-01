//
//  Interactor.m
//  PRIME
//
//  Created by Admin on 2/11/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "Interactor.h"
#import "RegistrationStepOneViewController.h"
#import "PRUINavigationController.h"

@interface Interactor () <UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate, UIViewControllerInteractiveTransitioning>

@property (nonatomic, assign, getter=isInteractive) BOOL interactive;
@property (nonatomic, assign, getter=isPresenting) BOOL presenting;
@property (nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;

@end

@implementation Interactor

#pragma mark - Public Methods

- (instancetype)initWithParentViewController:(UIViewController*)viewController
{
    if (!(self = [super init]))
        return nil;

    _parentViewController = viewController;

    return self;
}

- (void)userDidPan:(UIScreenEdgePanGestureRecognizer*)recognizer
{
    CGPoint location = [recognizer locationInView:self.parentViewController.view];
    CGPoint velocity = [recognizer velocityInView:self.parentViewController.view];

    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.interactive = YES;

        if (location.x > CGRectGetMidX(recognizer.view.bounds)) {
            self.presenting = YES;

            NSString* identifier;

#if defined(Otkritie)
            identifier = @"PRRegistrationWithCardViewController";
#elif defined(PrimeRRClub)
            identifier = @"PRRRClubRegistrationWithCardViewController";
#else
            identifier = @"RegistrationStepOneViewController";
#endif

            BaseViewController* baseViewController = [_parentViewController.storyboard instantiateViewControllerWithIdentifier:identifier];
            UINavigationController* navigationController = [[PRUINavigationController alloc] initWithRootViewController:baseViewController];
            navigationController.modalPresentationStyle = UIModalPresentationCustom;
            navigationController.transitioningDelegate = self;
            [self.parentViewController presentViewController:navigationController animated:YES completion:nil];
        } else {
            [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
        }
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat ratio = location.x / CGRectGetWidth(self.parentViewController.view.bounds);
        [self updateInteractiveTransition:ratio];
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (self.presenting) {
            if (velocity.x < 0) {
                [self finishInteractiveTransition];
            } else {
                [self cancelInteractiveTransition];
            }
        } else {
            if (velocity.x > 0) {
                [self finishInteractiveTransition];
            } else {
                [self cancelInteractiveTransition];
            }
        }
    }
}

#pragma mark - UIViewControllerTransitioningDelegate Methods

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController*)presented presentingController:(UIViewController*)presenting sourceController:(UIViewController*)source
{
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController*)dismissed
{
    return self;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator
{
    if (self.interactive) {
        return self;
    }

    return nil;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator
{
    if (self.interactive) {
        return self;
    }

    return nil;
}

#pragma mark - UIViewControllerAnimatedTransitioning Methods

- (void)animationEnded:(BOOL)transitionCompleted
{
    self.interactive = NO;
    self.presenting = NO;
    self.transitionContext = nil;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return .05f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    if (self.interactive) {
    } else {
        UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

        CGRect endFrame = [[transitionContext containerView] bounds];

        if (self.presenting) {
            [transitionContext.containerView addSubview:toViewController.view];
            [transitionContext.containerView addSubview:fromViewController.view];

            CGRect startFrame = endFrame;
            startFrame.origin.x = CGRectGetWidth([[transitionContext containerView] bounds]);

            toViewController.view.frame = startFrame;

            [UIView animateWithDuration:[self transitionDuration:transitionContext]
                animations:^{
                    toViewController.view.frame = endFrame;
                }
                completion:^(BOOL finished) {
                    [transitionContext completeTransition:YES];
                }];
        } else {
            [transitionContext.containerView addSubview:toViewController.view];
            [transitionContext.containerView addSubview:fromViewController.view];

            endFrame.origin.x -= CGRectGetWidth([[transitionContext containerView] bounds]);

            [UIView animateWithDuration:[self transitionDuration:transitionContext]
                animations:^{
                    fromViewController.view.frame = endFrame;
                }
                completion:^(BOOL finished) {
                    [transitionContext completeTransition:YES];
                }];
        }
    }
}

#pragma mark - UIViewControllerInteractiveTransitioning Methods

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    self.transitionContext = transitionContext;

    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    CGRect endFrame = [[transitionContext containerView] bounds];

    if (self.presenting) {
        [transitionContext.containerView addSubview:fromViewController.view];
        [transitionContext.containerView addSubview:toViewController.view];

        endFrame.origin.x -= CGRectGetWidth([[transitionContext containerView] bounds]);
    } else {
        [transitionContext.containerView addSubview:toViewController.view];
        [transitionContext.containerView addSubview:fromViewController.view];
    }

    toViewController.view.frame = endFrame;
}

#pragma mark - UIPercentDrivenInteractiveTransition Overridden Methods

- (void)updateInteractiveTransition:(CGFloat)percentComplete
{
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;

    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    CGRect frame = CGRectOffset([[transitionContext containerView] bounds], CGRectGetWidth([[transitionContext containerView] bounds]) * (percentComplete), 0);

    if (self.presenting) {
        toViewController.view.frame = frame;
    } else {
        fromViewController.view.frame = frame;
    }
}

- (void)finishInteractiveTransition
{
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;

    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    if (self.presenting) {
        CGRect endFrame = [[transitionContext containerView] bounds];

        [UIView animateWithDuration:0.5f
            animations:^{
                toViewController.view.frame = endFrame;
            }
            completion:^(BOOL finished) {
                [transitionContext completeTransition:YES];
            }];
    } else {
        CGRect endFrame = CGRectOffset([[transitionContext containerView] bounds], -CGRectGetWidth([[self.transitionContext containerView] bounds]), 0);

        [UIView animateWithDuration:0.5f
            animations:^{
                fromViewController.view.frame = endFrame;
            }
            completion:^(BOOL finished) {
                [transitionContext completeTransition:YES];
            }];
    }
}

- (void)cancelInteractiveTransition
{
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;

    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    if (self.presenting) {
        CGRect endFrame = CGRectOffset([[transitionContext containerView] bounds], CGRectGetWidth([[transitionContext containerView] bounds]), 0);

        [UIView animateWithDuration:0.5f
            animations:^{
                toViewController.view.frame = endFrame;
            }
            completion:^(BOOL finished) {
                [transitionContext completeTransition:NO];

                // It seems to be a bug in iOS8. A workaround that fixes the issue is to add the destination view controller's view to the key window manually.
                [[UIApplication sharedApplication].keyWindow addSubview:fromViewController.view];
            }];
    } else {
        CGRect endFrame = [[transitionContext containerView] bounds];

        [UIView animateWithDuration:0.5f
            animations:^{
                fromViewController.view.frame = endFrame;
            }
            completion:^(BOOL finished) {
                [transitionContext completeTransition:NO];
            }];
    }
}

@end
