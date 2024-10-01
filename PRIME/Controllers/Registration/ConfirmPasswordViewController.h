//
//  ConfirmPasswordViewController.h
//  PRIME
//
//  Created by Artak on 1/29/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "BaseViewController.h"
#import "PRPasswordField.h"

@class ConfirmPasswordViewController;

@protocol ConfirmPasswordViewControllerDelegate <NSObject>
- (void)resetPassword;
@end

@interface ConfirmPasswordViewController : BaseViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel* labelInfo;
@property (weak, nonatomic) IBOutlet PRPasswordField* textFieldPassword;
@property (weak, nonatomic) IBOutlet UILabel* labelNote;

@property (strong, nonatomic) NSString* firstEnteredPassword;
@property (strong, nonatomic) NSString* phoneNumber;
@property (assign, nonatomic) BOOL isPasswordChangeRequested;

@property (nonatomic, weak) id<ConfirmPasswordViewControllerDelegate> delegate;

@end
