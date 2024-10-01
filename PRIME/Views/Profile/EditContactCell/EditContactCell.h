//
//  EditContactCell.h
//  PRIME
//
//  Created by Taron on 3/30/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "UIPickerTextField.h"
#import <UIKit/UIKit.h>

static const int kTextFieldTextFontSize = 16;

@interface EditContactCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel* labelInfoName;
@property (weak, nonatomic) IBOutlet UIButton* buttonAction;
@property (weak, nonatomic) IBOutlet UIImageView* imageViewArrow;
@property (strong, nonatomic) UIPickerTextField* textFieldForPicker;

@property (nonatomic) BOOL needToShowSeperator;
- (UITextField*)getTextField;

@end
