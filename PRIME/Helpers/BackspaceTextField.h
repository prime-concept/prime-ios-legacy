//
//  BackspaceTextField.h
//  PRIME
//
//  Created by Artak on 10/12/15.
//  Copyright © 2015 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BackspasePressed <NSObject>

@required
- (void) backspasePressedForTextView:(UITextField *)textField;

@end

@interface BackspaceTextField : UITextField

@property (weak, nonatomic) id<BackspasePressed> backspaceDelegate;
@end
