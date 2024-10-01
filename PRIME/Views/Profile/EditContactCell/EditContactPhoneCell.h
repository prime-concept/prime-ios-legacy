//
//  EditContactPhoneCell.h
//  PRIME
//
//  Created by Artak on 2/2/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "EditContactCell.h"
#import "UIPickerTextField.h"
#import <PRTableViewCell.h>
#import <UIKit/UIKit.h>

@interface EditContactPhoneCell : EditContactCell <PRTableViewCell>

@property (weak, nonatomic) IBOutlet SHSPhoneTextField* textFieldInfoValue;

@end
