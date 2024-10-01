//
//  PREditInfoTableViewCell.m
//  PRIME
//
//  Created by Mariam on 1/20/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PREditInfoTableViewCell.h"
#import "PRPhoneNumberFormatter.h"

@interface PREditInfoTableViewCell ()

@end

@implementation PREditInfoTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];

    _phoneTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    [_phoneTextField.formatter setDefaultOutputPattern:@"###################" imagePath:nil];
    [_phoneTextField.formatter addOutputPattern:[NSString stringWithFormat:@"+%@", DEFAULT_PHONE_FORMAT] forRegExp:@"^\\d\\d\\d\\d[0-9]\\d*$" imagePath:nil];
    _phoneTextField.keyboardType = UIKeyboardTypePhonePad;
}

- (void)configureCellWithTextfieldText:(NSString*)text andPlaceholder:(NSString*)placeholder
{
    _phoneTextField.hidden = YES;
    _textField.hidden = NO;

    _textField.text = text;
    _textField.placeholder = placeholder;
}

- (void)configureCellWithTextfieldText:(NSString*)text andPlaceholder:(NSString*)placeholder tag:(NSInteger)tag delegate:(id)delegate
{
    [self configureCellWithTextfieldText:text andPlaceholder:placeholder];
    _textField.tag = tag;
    _textField.delegate = delegate;
}

- (void)configurePhoneCellWithTextfieldText:(NSString*)text andPlaceholder:(NSString*)placeholder
{
    _phoneTextField.hidden = NO;
    _textField.hidden = YES;

    _phoneTextField.text = text;
    _phoneTextField.placeholder = placeholder;

    [_phoneTextField.formatter setDefaultOutputPattern:[PRPhoneNumberFormatter formatWithPrefixForPhoneNumber:text]];
    [_phoneTextField.formatter addOutputPattern:[PRPhoneNumberFormatter formatWithPrefixForPhoneNumber:text] forRegExp:@"^\\d\\d\\d\\d[0-9]\\d*$" imagePath:nil];
    [_phoneTextField.formatter setPrefix:@""];
}

- (void)configurePhoneCellWithTextfieldText:(NSString*)text andPlaceholder:(NSString*)placeholder tag:(NSInteger)tag delegate:(id)delegate
{
    [self configurePhoneCellWithTextfieldText:text andPlaceholder:placeholder];
    _phoneTextField.tag = tag;
    _phoneTextField.delegate = delegate;
}

- (NSString*)currentTextValue
{
    if (!_textField.hidden) {
        return _textField.text.length > 0 ? _textField.text : @"";
    }
    return _phoneTextField.text.length > 0 ? _phoneTextField.phoneNumber : @"";
}

@end
