//
//  TPKeyboardAvoidingTableView.h
//  TPKeyboardAvoiding
//
//  Created by Michael Tyson on 30/09/2013.
//  Copyright 2015 A Tasty Pixel. All rights reserved.
//

#import "UIScrollView+TPKeyboardAvoidingAdditions.h"
#import <UIKit/UIKit.h>

@interface TPKeyboardAvoidingTableView : UITableView <UITextFieldDelegate, UITextViewDelegate>

- (BOOL)focusNextTextField;
- (void)scrollToActiveTextField;

@property (nonatomic) BOOL closeKeyboardOnTouch;

@end
