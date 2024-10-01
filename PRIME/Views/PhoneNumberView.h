//
//  PhoneNumberView.h
//  PRIME
//
//  Created by Admin on 6/1/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BackspaceTextField.h"

@protocol CountryNameTouched <NSObject>

@optional
- (void) countryNameTouched;

@end

@interface PhoneNumberView : UIView

@property BOOL needToFill;

@property (nonatomic, strong) UIImageView *imageViewArrorw;
@property (nonatomic, strong) UILabel *labelCountryName;
@property (nonatomic, strong) UITextField *textFieldIsoCode;
@property (nonatomic, strong) BackspaceTextField *textFieldPhoneNumber;

@property (nonatomic, weak) id<CountryNameTouched> touchDelegate;

@property (nonatomic, strong) NSString *phoneNumberWihtCode;
@end
