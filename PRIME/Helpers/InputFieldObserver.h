//
//  InputFieldObserver.h
//  PRIME
//
//  Created by Admin on 4/6/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef BOOL (^InputFieldValidator)(NSString* text);

@interface InputFieldObserver : NSObject

@property (strong, nonatomic) InputFieldValidator inputFieldValidator;
@property (strong, nonatomic) CALayer *oldLayer;
@property (weak, nonatomic) UIView *view;

+(InputFieldObserver *) observInputFieldForValidation:(UITextField*) textField withValidator:(InputFieldValidator) validator;
+(void) removeObserverFromInputField:(UITextField*) textField;
@end
