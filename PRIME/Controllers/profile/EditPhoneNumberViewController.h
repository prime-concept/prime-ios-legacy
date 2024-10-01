//
//  EditPhoneNumberViewController.h
//  PRIME
//
//  Created by Artak on 4/5/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "BaseViewController.h"
#import "PRPhoneTextField.h"
#import <UIKit/UIKit.h>

@protocol UpdatePhoneNumber <NSObject>

@required
- (void)phoneNumberDidUpdateTo:(NSString*)phoneNumber;

@end

@interface EditPhoneNumberViewController : BaseViewController

@property (weak, nonatomic) IBOutlet PRPhoneTextField* textFieldPhoneNumber;
@property (weak, nonatomic) id<UpdatePhoneNumber> updateDelegate;
@property (strong, nonatomic) NSString* phoneNumberString;

@end
