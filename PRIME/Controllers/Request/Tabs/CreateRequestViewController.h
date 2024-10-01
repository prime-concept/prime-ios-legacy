//
//  CreateRequestViewController.h
//  PRIME
//
//  Created by Artak on 3/19/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "BaseViewController.h"
#import "ContainerViewController.h"
#import <UIKit/UIKit.h>

@interface CreateRequestViewController : BaseViewController

@property (nonatomic, weak) ContainerViewController* containerViewController;

@property (strong, nonatomic) UIButton* activeButton;

@property (weak, nonatomic) IBOutlet UIButton* buttonAvia;
@property (weak, nonatomic) IBOutlet UIButton* buttonVipHall;
@property (weak, nonatomic) IBOutlet UIButton* buttonTransfer;
@property (weak, nonatomic) IBOutlet UIButton* buttonHotel;
@property (weak, nonatomic) IBOutlet UIButton* buttonRestoran;
@property (weak, nonatomic) IBOutlet UIButton* buttonOther;

@property (weak, nonatomic) IBOutlet UIView* tabBarContainer;

- (IBAction)changeTabAction:(UIButton*)sender;
@end
