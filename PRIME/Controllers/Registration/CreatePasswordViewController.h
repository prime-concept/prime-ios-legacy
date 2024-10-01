//
//  CreatePasswordViewController.h
//  PRIME
//
//  Created by Artak on 1/29/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "BaseViewController.h"
#import "ConfirmPasswordViewController.h"
#import "PRPasswordField.h"

@interface CreatePasswordViewController : BaseViewController <ConfirmPasswordViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel* labelInfo;
@property (weak, nonatomic) IBOutlet PRPasswordField* textFieldPassword;

@property (weak, nonatomic) IBOutlet UILabel* labelNote;

@property (nonatomic, strong) NSString* phoneNumber;
@property (nonatomic, assign) BOOL isPasswordChangeRequested;

- (void)resetPassword;

@end
