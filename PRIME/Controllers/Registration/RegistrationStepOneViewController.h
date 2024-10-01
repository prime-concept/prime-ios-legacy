//
//  RegistrationStepOneViewController.h
//  PRIME
//
//  Created by Artak on 1/29/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "BackspaceTextField.h"
#import "BaseViewController.h"
#import "CountriesCodesViewController.h"
#import "PRPhoneTextField.h"
#import "PhoneNumberView.h"

@interface RegistrationStepOneViewController : BaseViewController <UITextFieldDelegate, CountryNameTouched, SelectCountry, BackspasePressed>

@property (weak, nonatomic) UIPageViewController* parentController;

@property (weak, nonatomic) IBOutlet UILabel* labelPhone;
@property (weak, nonatomic) IBOutlet UILabel* labelNote;
@property (weak, nonatomic) IBOutlet PhoneNumberView* phoneNumberView;

@end
