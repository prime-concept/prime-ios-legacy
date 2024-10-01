//
//  PRPersonalDataViewController.h
//  PRIME
//
//  Created by Mariam on 1/26/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PRMyProfileViewController.h"

typedef NS_ENUM(NSInteger, ProfileContactType) {
    ProfileContactType_AddFamily = 0,
    ProfileContactType_AddPartner,
    ProfileContactType_Update,
};

@interface PRPersonalDataViewController : ProfileBaseViewController

@property (assign, nonatomic) ProfileContactType profileContactType;
@property (strong, nonatomic) PRProfileContactModel* contactModel;
@property (strong, nonatomic) NSManagedObjectContext* mainContext;
@property (strong, nonatomic) PRMyProfileViewController* myProfileViewController;

- (void)addContactPhone:(PRProfileContactPhoneModel*)phone;
- (void)addContactEmail:(PRProfileContactEmailModel*)email;
- (void)addContactDocument:(PRProfileContactDocumentModel*)document;

- (void)reload;

@end
