//
//  ReviewViewController.h
//  PRIME
//
//  Created by Artak on 9/23/15.
//  Copyright © 2015 XNTrends. All rights reserved.
//

#import "BaseViewController.h"
#import "DJWStarRatingView.h"
#import "SZTextView.h"
#import "TPKeyboardAvoidingScrollView.h"
#import <UIKit/UIKit.h>

@interface ReviewViewController : BaseViewController

@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView* backgroundScrollView;
@property (weak, nonatomic) IBOutlet UILabel* infoLabel;
@property (weak, nonatomic) IBOutlet DJWStarRatingView* starsView;
@property (weak, nonatomic) IBOutlet UILabel* labelRaiting;
@property (weak, nonatomic) IBOutlet UIButton* buttonNotNow;
@property (weak, nonatomic) IBOutlet UIButton* buttonSubmit;
@property (weak, nonatomic) IBOutlet SZTextView* textFieldMessage;
@property (weak, nonatomic) IBOutlet UIView* containerView;

@property (strong, nonatomic) NSNumber* taskId;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* constraintTextFieldHeight;

- (IBAction)closeAction:(UIButton*)sender;
- (IBAction)submitAction:(UIButton*)sender;
@end
