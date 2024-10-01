//
//  WelcomeViewController.h
//  PRIME
//
//  Created by Artak on 1/28/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "BaseViewController.h"

@protocol WelcomeViewControllerPanTarget <NSObject>

- (void)userDidPan:(UIScreenEdgePanGestureRecognizer*)gestureRecognizer;

@end

@interface WelcomeViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UITextView* labelDescryption;
@property (weak, nonatomic) IBOutlet UIImageView* welcomeTitleImage;
@property (weak, nonatomic) IBOutlet UIImageView* imageNext;
@property (weak, nonatomic) IBOutlet UIButton* buttonNext;

- (void)hideButtons;
@end
