//
//  PRMyProfileViewController.h
//  PRIME
//
//  Created by Mariam on 1/19/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileViewController.h"

@interface PRMyProfileViewController : ProfileBaseViewController

@property (strong, nonatomic) NSManagedObjectContext* mainContext;
@property (assign, nonatomic) BOOL isSynchedFromOffline;

- (void)reload;

@end
