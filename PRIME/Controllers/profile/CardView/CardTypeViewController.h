//
//  CardTypeViewController.h
//  PRIME
//
//  Created by Artak on 7/16/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "ProfileBaseViewController.h"
#import <UIKit/UIKit.h>

@interface CardTypeViewController : ProfileBaseViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray* cardData;
@property (weak, nonatomic) id<ReloadTable> dataSource;

@end
