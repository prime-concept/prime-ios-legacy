//
//  LoyalCardTableViewCell.m
//  PRIME
//
//  Created by Artak on 7/20/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "LoyalCardTableViewCell.h"

@implementation LoyalCardTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
    return YES;
}

- (void)configureCellWithFieldName:(NSString*)fieldName
                        fieldValue:(NSString*)fieldValue
                            parent:(id)parent
                   isTextViewShown:(BOOL)isTextViewShown
                               tag:(NSInteger)tag
{

    _labelName.text = fieldName;
    _parentViewController = parent;

    _textFieldValue.hidden = isTextViewShown;
    _textViewValue.hidden = !isTextViewShown;

    if (isTextViewShown) {
        _textViewValue.text = fieldValue;
        _textViewValue.delegate = parent;
        _textViewValue.tag = tag;
        _textViewValue.scrollEnabled = isTextViewShown;
        _textViewValue.font = [UIFont systemFontOfSize:16];
        _textViewValue.textContainer.lineFragmentPadding = 0;
        _textViewConstraintHeigth.constant = MAX(30, [_textViewValue sizeThatFits:_textViewValue.bounds.size].height);
    } else {
        _textFieldValue.text = fieldValue;
        _textFieldValue.delegate = parent;
        _textFieldValue.tag = tag;
        _textFieldValue.borderStyle = UITextBorderStyleNone;
        _textFieldValue.font = [UIFont systemFontOfSize:16];
    }
}

@end
