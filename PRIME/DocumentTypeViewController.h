//
//  DocumentTypeViewController.h
//  PRIME
//
//  Created by Hamlet on 2/20/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import "ProfileBaseViewController.h"
#import <UIKit/UIKit.h>

@interface DocumentTypeViewController : ProfileBaseViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray* documentData;
@property (weak, nonatomic) id<ReloadTable> dataSource;
@property (assign, nonatomic) BOOL isContactDocument;
@property (strong, nonatomic) PRProfileContactModel* contactModel;
@property (strong, nonatomic) NSManagedObjectContext* mainContext;
@property (strong, nonatomic) PRUserProfileModel* userProfile;

@end
