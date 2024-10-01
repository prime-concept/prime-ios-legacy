//
//  EditContactEmailCell.h
//  PRIME
//
//  Created by Taron on 3/23/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "EditContactCell.h"
#import "UIPickerTextField.h"
#import <PRTableViewCell.h>
#import <UIKit/UIKit.h>

@interface EditContactEmailCell : EditContactCell <PRTableViewCell>

@property (weak, nonatomic) IBOutlet UITextField* textFieldInfoValue;

@end
