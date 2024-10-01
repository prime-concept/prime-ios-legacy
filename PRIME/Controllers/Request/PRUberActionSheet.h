//
//  PRUberActionSheet.h
//  PRIME
//
//  Created by Nerses Hakobyan on 4/10/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "CustomActionSheetViewController.h"
#import "PRUberEstimates.h"
#import <UIKit/UIKit.h>

@protocol PRUberActionSheetDelegate <NSObject>

@optional
- (void)uberActionSheetDidClose;

@end

@interface PRUberActionSheet : UIViewController <UITableViewDataSource, UITableViewDelegate, SelectionViewControllerDelegate>

@property (strong, nonatomic) NSMutableArray<PRUberEstimates*>* sourceArray;
@property (strong, nonatomic) __kindof UIViewController* rootViewController;

@property (weak, nonatomic) id<PRUberActionSheetDelegate> delegate;

- (instancetype)initWithSourceArray:(NSArray<PRUberEstimates*>*)sourceArray andRootViewController:(__kindof UIViewController*)viewController;
- (void)showAnimated;
- (void)reload;

@end
