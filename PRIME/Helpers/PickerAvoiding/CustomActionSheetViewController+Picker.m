//
//  CustomActionSheetViewController+Picker.m
//  PRIME
//
//  Created by Admin on 3/29/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "CustomActionSheetViewController+Picker.h"

@implementation CustomActionSheetViewController (Picker)

- (void)showForField: (UIPickerTextField*) pickerTextField {
    [pickerTextField setCurrent: YES];
    [self show];
    [pickerTextField setCurrent: NO];
}

@end
