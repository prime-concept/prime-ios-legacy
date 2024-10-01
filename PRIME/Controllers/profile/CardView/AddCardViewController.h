//
//  AddCardViewController.h
//  PRIME
//
//  Created by Artak Tsatinyan on 2/1/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "CardIO.h"
#import "PRCardData.h"
#import "ProfileBaseViewController.h"
#import <SHSPhoneComponent/SHSPhoneTextField.h>
#import <UIKit/UIKit.h>

@interface AddCardViewController : ProfileBaseViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, CardIOPaymentViewControllerDelegate>

@property (strong, nonatomic) NSMutableArray<PRCardData*>* cardData;
@property (nonatomic) NSInteger selectedCardIndex;

@property (weak, nonatomic) id<ReloadTable> reloadDelegate;

- (IBAction)actionDelete:(UIButton*)sender;
- (IBAction)actionScanCard:(UIButton*)sender;

@end
