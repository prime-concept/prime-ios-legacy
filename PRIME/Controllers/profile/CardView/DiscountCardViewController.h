//
//  DiscountCardViewController.h
//  PRIME
//
//  Created by Artak Tsatinyan on 7/17/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "BaseViewController.h"
#import "CustomActionSheetViewController.h"
#import "ProfileBaseViewController.h"
#import "ProfileBaseViewController.h"
#import <UIKit/UIKit.h>

@interface DiscountCardViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, SelectionViewControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView* tableView;
@property (weak, nonatomic) id<ReloadTable> dataSource;
@property (strong, nonatomic) NSNumber* cardId;
@property (strong, nonatomic) PRCardTypeModel* type;

@end
