//
//  PRProfileRegistrationCell.m
//  PRIME
//
//  Created by Aram on 8/8/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRProfileRegistrationCell.h"

static const CGFloat kSeparatorHeightOnSelectedMode = 2.0f;
static const CGFloat kSeparatorHeightOnNoneSelectedMode = 1.0f;
static const CGFloat kSelectionAnimationDuration = 0.2f;
static NSString* const kArrowDownImageName = @"arrow_down";
static NSString* const kPhoneNumberTemplate = @"+7 (XXX) XXX-XX-XX";

@interface PRProfileRegistrationCell ()
@property (weak, nonatomic) IBOutlet UITextField* textField;
@property (weak, nonatomic) IBOutlet UIImageView* arrowImageView;
@property (weak, nonatomic) IBOutlet UIView* seperatorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* seperatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UITextField *placeholderTextField;

@end

@implementation PRProfileRegistrationCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [_arrowImageView setImage:[[UIImage imageNamed:kArrowDownImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [_arrowImageView setTintColor:[UIColor blackColor]];
    _arrowImageView.hidden = YES;
}

- (void)configureCellWithTextfieldText:(NSString*)text placeholder:(NSString*)placeholder tag:(NSInteger)tag delegate:(id)delegate arrowImageHidden:(BOOL)hidden
{
    NSString *subPlaceholder = NSLocalizedString(placeholder, nil);
    if ([placeholder isEqualToString:@"Phone"]) {
        [_placeholderTextField setText:kPhoneNumberTemplate];
        subPlaceholder = @"";
    }
    _textField.text = NSLocalizedString(text, nil);
    _textField.placeholder = subPlaceholder;
    _textField.tag = tag;
    _textField.delegate = delegate;
    _arrowImageView.hidden = hidden;

    [_seperatorView setBackgroundColor:kCalendarLineColor];
    [_seperatorViewHeightConstraint setConstant:kSeparatorHeightOnNoneSelectedMode];
}

-(void)disableTextfield
{
    [_textField setEnabled:NO];
}

- (void)setSelection:(BOOL)selection
{
    UIColor* color = selection ? kSegmentedControlTaskStatusColor : kCalendarLineColor;
    CGFloat constant = selection ? kSeparatorHeightOnSelectedMode : kSeparatorHeightOnNoneSelectedMode;

    [UIView animateWithDuration:kSelectionAnimationDuration
                     animations:^{
                         [_seperatorView setBackgroundColor:color];
                         [_seperatorViewHeightConstraint setConstant:constant];
                         [self layoutIfNeeded];
                     }];
}
- (void)changePlaceholderText:(NSString*)text
{
    if (text.length > 19) {
        [_placeholderTextField setText:@""];
    } else {
        NSMutableAttributedString* string = [[NSMutableAttributedString alloc] initWithString:kPhoneNumberTemplate];
        [string addAttribute:NSForegroundColorAttributeName value:[UIColor clearColor] range:NSMakeRange(0,text.length)];
        [_placeholderTextField setAttributedText:string];
    }
}

@end
