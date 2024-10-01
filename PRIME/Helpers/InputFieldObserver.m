//
//  InputFieldObserver.m
//  PRIME
//
//  Created by Admin on 4/6/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "InputFieldObserver.h"

@implementation InputFieldObserver

static NSMutableDictionary *observers = nil;

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"text"]) {
        NSString *newText = [change objectForKey:@"new"];
        if (!_inputFieldValidator(newText)) {
            _view.layer.borderColor = [UIColor redColor].CGColor;
            _view.layer.borderWidth = 1;
            _view.layer.cornerRadius = 5;
            
        } else {
            [InputFieldObserver setLayerProperties:_view.layer fromLayer:_oldLayer];
        }
    }
    
}

+(void) setLayerProperties:(CALayer*) toLayer fromLayer:(CALayer*) fromLayer
{
    toLayer.borderColor = fromLayer.borderColor;
    toLayer.borderWidth = fromLayer.borderWidth;
    toLayer.cornerRadius = fromLayer.cornerRadius;
}

+(InputFieldObserver *) observInputFieldForValidation:(UITextField*) textField withValidator:(InputFieldValidator) validator
{

    
    pr_dispatch_once({
        observers = [NSMutableDictionary dictionary];
    });
    
   
    InputFieldObserver *observer = [[InputFieldObserver alloc] init];
    observer.inputFieldValidator = validator;
    observer.view = textField;
    observer.oldLayer = [CALayer layer];
    
    [InputFieldObserver setLayerProperties:observer.oldLayer fromLayer:textField.layer];
    
    observer.oldLayer.borderColor = textField.layer.borderColor;
    observer.oldLayer.borderWidth = textField.layer.borderWidth;
    observer.oldLayer.cornerRadius = textField.layer.cornerRadius;
    
    [textField addObserver:observer forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
    
    NSValue *textFieldKey = [NSValue valueWithNonretainedObject:textField];
    [observers setValue:observer forKey:[NSString stringWithFormat:@"%@", textFieldKey]];
    
    return observer;
}

+(void) removeObserverFromInputField:(UITextField*) textField
{
    NSValue *textFieldKey = [NSValue valueWithNonretainedObject:textField];
    NSObject *view = [observers objectForKey:[NSString stringWithFormat:@"%@", textFieldKey]];
    [textField removeObserver:view forKeyPath:@"text"];
    [observers removeObjectForKey:[NSString stringWithFormat:@"%@", textFieldKey]];
}

@end
