//
//  AddDocumentViewController.h
//  PRIME
//
//  Created by Artak on 2/8/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "CustomActionSheetViewController+Picker.h"
#import "FDTakeController.h"
#import "PRDocumentModel.h"
#import <TPKeyboardAvoiding/TPKeyboardAvoidingScrollView.h>

#import "ProfileBaseViewController.h"
#import <CountryPicker/CountryPicker.h>
#import <UIKit/UIKit.h>
#import "PRPersonalDataViewController.h"

@interface AddDocumentViewController : ProfileBaseViewController <UITextFieldDelegate, SelectionViewControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, FDTakeDelegate, UITableViewDelegate, UITableViewDataSource, ReloadTable, UIGestureRecognizerDelegate, UIActionSheetDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CountryPickerDelegate>

@property (strong, nonatomic) PRUserProfileModel* userProfile;
@property (strong, nonatomic) NSNumber* documentId;
@property (strong, nonatomic) NSNumber* type;
@property (weak, nonatomic) id<ReloadTable> parentView;

@property (strong, nonatomic) PRProfileContactModel* contactModel;
@property (strong, nonatomic) PRProfileContactDocumentModel* contactDocumentModel;
@property (strong, nonatomic) NSManagedObjectContext* mainContext;
@property (assign, nonatomic) BOOL isContactDocument;

@end
