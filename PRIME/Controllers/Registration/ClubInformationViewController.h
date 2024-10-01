//
//  ClubInformationViewController.h
//  PRIME
//
//  Created by Artak on 20/08/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "BaseViewController.h"

@interface ClubInformationViewController : BaseViewController

// Please note that only one of these properties('phoneNumber' and 'cardNumber') must be initialized, otherwise will be used 'cardNumber'.
@property (strong, nonatomic) NSString* phoneNumber;
@property (strong, nonatomic) NSString* cardNumber;

@property (weak, nonatomic) IBOutlet UIView* phoneNumberBackground;
@property (weak, nonatomic) IBOutlet UILabel* informatinoLabel;

@property (weak, nonatomic) IBOutlet UIButton* buttonCall;
@property (weak, nonatomic) IBOutlet UIButton* buttonCallBack;
@property (weak, nonatomic) IBOutlet UIButton* buttonOpenSite;

@property (weak, nonatomic) IBOutlet UIView* view1;
@property (weak, nonatomic) IBOutlet UIView* view2;
@property (weak, nonatomic) IBOutlet UIView* view3;

@property (weak, nonatomic) IBOutlet UILabel* line1Label;
@property (weak, nonatomic) IBOutlet UILabel* line2Label;
@property (weak, nonatomic) IBOutlet UILabel* line3Label;

- (IBAction)callAction:(UIButton*)sender;
- (IBAction)callBackAction:(UIButton*)sender;
- (IBAction)opeenSiteAction:(UIButton*)sender;
@end
