//
//  PREditProfileInfoViewController.h
//  PRIME
//
//  Created by Mariam on 2/16/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "ProfileBaseViewController.h"
#import "PRPersonalDataViewController.h"

typedef NS_ENUM(NSInteger, EditingModelType) {
    EditingModelType_Phone = 0,
    EditingModelType_Email,
};

@interface PREditProfileInfoViewController : ProfileBaseViewController

- (void)setEditingType:(EditingModelType)type
                 model:(PRModel*)model
               context:(NSManagedObjectContext*)context
                parent:(UIViewController*)parentController;

@end
