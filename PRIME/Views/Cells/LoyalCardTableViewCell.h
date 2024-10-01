//
//  LoyalCardTableViewCell.h
//  PRIME
//
//  Created by Admin on 7/20/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "DiscountCardViewController.h"
#import <UIKit/UIKit.h>

@interface LoyalCardTableViewCell : UITableViewCell <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint* textViewConstraintHeigth;
@property (weak, nonatomic) IBOutlet UILabel* labelName;
@property (weak, nonatomic) IBOutlet UITextField* textFieldValue;
@property (weak, nonatomic) IBOutlet UITextView* textViewValue;

@property (weak, nonatomic) DiscountCardViewController* parentViewController;

- (void)configureCellWithFieldName:(NSString*)fieldName
                        fieldValue:(NSString*)fieldValue
                            parent:(id)parent
                   isTextViewShown:(BOOL)isTextViewShown
                               tag:(NSInteger)tag;

@end
