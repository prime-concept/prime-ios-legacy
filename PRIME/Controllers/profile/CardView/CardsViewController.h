//
//  CardsViewController.h
//  PRIME
//
//  Created by Artak on 6/22/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "AddCardViewController.h"
#import "ProfileBaseViewController.h"
#import <UIKit/UIKit.h>

@interface CardsViewController : ProfileBaseViewController <UITableViewDataSource, UITableViewDelegate, ReloadTable>

@property (strong, nonatomic) id<ReloadTable> reloadDelegate;
@end
