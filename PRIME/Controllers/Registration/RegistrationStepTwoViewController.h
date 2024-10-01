//
//  RegistrationStepTwoViewController.h
//  PRIME
//
//  Created by Artak on 1/28/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "BaseViewController.h"

@interface RegistrationStepTwoViewController : BaseViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel* labelPhoneNumber;
@property (weak, nonatomic) IBOutlet UILabel* labelNote;
@property (weak, nonatomic) IBOutlet UITextField* textFieldCode;

@property (strong, nonatomic) NSString* phoneNumber;
@end
