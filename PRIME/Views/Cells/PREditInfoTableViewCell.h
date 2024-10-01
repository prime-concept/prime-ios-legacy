//
//  PREditInfoTableViewCell.h
//  PRIME
//
//  Created by Mariam on 1/20/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHSPhoneTextField+DeleteBackward.h"

@interface PREditInfoTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet SHSPhoneTextField* phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField* textField;

- (void)configureCellWithTextfieldText:(NSString*)text andPlaceholder:(NSString*)placeholder;
- (void)configureCellWithTextfieldText:(NSString*)text andPlaceholder:(NSString*)placeholder tag:(NSInteger)tag delegate:(id)delegate;

- (void)configurePhoneCellWithTextfieldText:(NSString*)text andPlaceholder:(NSString*)placeholder;
- (void)configurePhoneCellWithTextfieldText:(NSString*)text andPlaceholder:(NSString*)placeholder tag:(NSInteger)tag delegate:(id)delegate;

- (NSString*)currentTextValue;

@end
