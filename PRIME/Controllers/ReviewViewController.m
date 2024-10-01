//
//  ReviewViewController.m
//  PRIME
//
//  Created by Artak on 9/23/15.
//  Copyright © 2015 XNTrends. All rights reserved.
//

#import "PRFeedbackModel.h"
#import "ReviewViewController.h"

@interface ReviewViewController ()
@property (strong, nonatomic) UIVisualEffectView* viewWithBlurredBackground;
@end

@implementation ReviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    CGFloat cornerRadius = 5;
    _starsView.strokeColor = kStarStrokeColor;
    _starsView.unfilledColor = kReviewBackgroundColor;
    _starsView.backgroundColor = kReviewBackgroundColor;
    _starsView.fillColor = kStarFillColor;

    _starsView.allowsHalfIntegralRatings = NO;

    _containerView.backgroundColor = kReviewBackgroundColor;

    _buttonNotNow.backgroundColor = kButtonNotNowColor;
    [_buttonNotNow setTintColor:kButtonNotNowTextColor];
    _buttonNotNow.layer.cornerRadius = cornerRadius;

    _buttonSubmit.backgroundColor = kButtonSendColor;
    [_buttonSubmit setTintColor:kButtonSendTextColor];
    _buttonSubmit.layer.cornerRadius = cornerRadius;

    [_textFieldMessage setBackgroundColor:kTextFieldColor];
    _textFieldMessage.placeholder = NSLocalizedString(@"Tell us more", nil);
    _textFieldMessage.placeholderTextColor = kButtonNotNowColor;
    _textFieldMessage.textColor = kButtonNotNowColor;
    _textFieldMessage.delegate = self;

    _infoLabel.textColor = kStarStrokeColor;
    _labelRaiting.textColor = kStarStrokeColor;

    _infoLabel.text = NSLocalizedString(@"Rate the quality of your call", nil);
}

- (void)djwStarRatingChangedValue:(DJWStarRatingView*)view
{
    _buttonSubmit.backgroundColor = kButtonNotNowColor;

    switch ((int)view.rating) {
    case 1:
        _labelRaiting.text = NSLocalizedString(@"Very bad", nil);
        break;

    case 2:
        _labelRaiting.text = NSLocalizedString(@"Bad", nil);
        break;

    case 3:
        _labelRaiting.text = NSLocalizedString(@"Normal", nil);
        break;

    case 4:
        _labelRaiting.text = NSLocalizedString(@"Good", nil);
        break;

    case 5:
        _labelRaiting.text = NSLocalizedString(@"Very good", nil);
        break;
    default:
        break;
    }
}

- (IBAction)closeAction:(UIButton*)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{

    }];
}

- (IBAction)submitAction:(UIButton*)sender
{
    if (_starsView.rating > 0) {
        PRFeedbackModel* feedback = [PRFeedbackModel MR_createEntity];
        feedback.comment = _textFieldMessage.text;
        feedback.objectId = [_taskId stringValue];
        feedback.objectType = @"task";
        feedback.stars = @(_starsView.rating);

        [PRRequestManager sendFeedbackWithView:self.view
            mode:PRRequestMode_ShowOnlyProgress
            message:feedback
            success:^{

                [self closeAction:nil];

            }
            failure:^{
                //TODO
            }];
    }
}

- (BOOL)textView:(UITextView*)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text
{
    NSString* finalString = [textView.text stringByReplacingCharactersInRange:range withString:text];

    if (finalString.length < 100) {

        UITextView* tmptextView = [[UITextView alloc] initWithFrame:textView.frame];
        tmptextView.text = finalString;
        tmptextView.font = textView.font;

        _constraintTextFieldHeight.constant = [tmptextView sizeThatFits:CGSizeMake(textView.frame.size.width, _constraintTextFieldHeight.constant)].height;

        [UIView animateWithDuration:0.3 animations:^{
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
        }];

        return YES;
    }

    return NO;
}
@end
