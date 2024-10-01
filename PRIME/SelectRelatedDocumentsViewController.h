//
//  SelectRelatedDocumentsViewController.h
//  PRIME
//
//  Created by Hamlet on 2/27/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileBaseViewController.h"
#import "AddDocumentViewController.h"

@protocol SelectRelatedDocumentsViewControllerDelegate <NSObject>

- (void)setRelatedDocuments:(NSArray*)relatedDocuments;

@end

@interface SelectRelatedDocumentsViewController : ProfileBaseViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) id<ReloadTable> parentView;
@property (assign, nonatomic) BOOL isContactDocument;
@property (assign, nonatomic) BOOL isPassport;
@property (nullable, nonatomic, retain) NSNumber* contactId;
@property (strong, nonatomic) NSManagedObjectContext* mainContext;
@property (weak, nonatomic) id<SelectRelatedDocumentsViewControllerDelegate> delegate;
@property (strong, nonatomic) NSArray<NSNumber*>* relatedDocumentsId;

@end
