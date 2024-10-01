//
//  SHSPhoneLogic-BugFixed.m
//  PRIME
//
//  Created by Admin on 4/1/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "SHSPhoneLogic-BugFixed.h"
#import <SHSPhoneComponent/SHSPhoneTextField.h>

@interface SHSPhoneLogic ()

+(NSInteger) pushCaretPosition:(UITextField *)textField range:(NSRange)range;
+(void) popCaretPosition:(UITextField *)textField range:(NSRange)range caretPosition:(NSInteger)caretPosition;

@end

@interface SHSPhoneNumberFormatter ()

-(NSString *) stringWithoutFormat:(NSString *)aString;

@end

@implementation SHSPhoneLogic (BugFixed)

+(NSString*) formattedDigits: (SHSPhoneTextField *)textField text: (NSString*) text
{
    NSString *nonPrefix = text;
    if ([text hasPrefix:textField.formatter.prefix]) nonPrefix = [text substringFromIndex:textField.formatter.prefix.length];
    return [textField.formatter stringWithoutFormat:nonPrefix];
}

+(BOOL)logicTextField:(SHSPhoneTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.formatter.prefix.length && range.location < textField.formatter.prefix.length) {
        return NO;
    }
    
    NSInteger caretPosition = [self pushCaretPosition:textField range:range];
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    [self applyFormat:textField forText:newString];
    
    // Fixed Bug #351 {
    NSString* s1 = [self formattedDigits: textField text:newString];
    NSString* s2 = [self formattedDigits: textField text:[textField text]];
    
    caretPosition -= [s1 length] - [s2 length];
    // Fixed Bug #351 }
    
    [self popCaretPosition:textField range:range caretPosition:caretPosition];
    
    if (textField.textDidChangeBlock) textField.textDidChangeBlock(textField);
    return NO;
}

@end
