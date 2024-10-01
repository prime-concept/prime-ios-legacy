//
//  DocumentsViewController.m
//  PRIME
//
//  Created by Artak on 7/2/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "AddDocumentViewController.h"
#import "DocumentTableViewCell.h"
#import "DocumentsViewController.h"
#import "PRUserProfileModel.h"
#import "TextTableViewCell.h"

typedef NS_ENUM(NSInteger, DocumentsSection) {
    DocumentsSection_Passport = 0,
    DocumentsSection_Visa,
    DocumentsSection_Count
};

static const CGFloat kDocumentCellHeight = 44;

@interface DocumentsViewController ()

@property (strong, nonatomic) NSArray<PRDocumentModel*>* passportSections;
@property (strong, nonatomic) NSArray<PRDocumentModel*>* visaSections;
@property (weak, nonatomic) IBOutlet UITableView* tableView;

@end

@implementation DocumentsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = kTableViewBackgroundColor;

    self.title = NSLocalizedString(@"Documents", nil);

    _visaSections = [PRDatabase getVisas];
    _passportSections = [PRDatabase getPassports];
    [self initPullToRefreshForScrollView:_tableView];
}

- (void)didMoveToParentViewController:(UIViewController*)parent
{
    if (parent == nil) {
        [_reloadDelegate reload];
    }
}

- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView*)view
{

    [self.pullToRefreshView startLoading];

    [self.lazyManager shouldBeRefreshedWithDate:[NSDate date]
        relativeToDate:nil
        then:^(PRRequestMode mode) {
            //TODO updated single document.
            [PRRequestManager getDocumentsWithView:self.view
                mode:PRRequestMode_ShowNothing
                success:^{

                    [self.pullToRefreshView finishLoading];
                    [_tableView reloadData];

                }
                failure:^{

                    [self.pullToRefreshView finishLoading];

                }];

            [self.pullToRefreshView finishLoading];
        }
        otherwise:^{
            [self.pullToRefreshView finishLoading];
        }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    BOOL isDataExist = (_passportSections.count + _visaSections.count) > 0;

    [self.lazyManager shouldBeUpdatedIfViewDidAppearWithDate:[NSDate date]
        relativeToDate:nil
        then:^(PRRequestMode mode) {
            [PRRequestManager getDocumentsWithView:self.view
                mode:isDataExist ? PRRequestMode_ShowNothing : PRRequestMode_ShowErrorMessagesAndProgress
                success:^{

                    [self reload];

                }
                failure:^{

                }];
        }
        otherwiseIfFirstTime:^{

            [_tableView reloadData];

        }
        otherwise:^{

        }];
}

- (void)reload
{

    _visaSections = [PRDatabase getVisas];
    _passportSections = [PRDatabase getPassports];

    [_tableView reloadData];
}

#pragma mark delete action

- (void)deleteDocumentWithId:(NSNumber*)documentId
{

    PRDocumentModel* model = [PRDatabase getDocumentById:documentId];

    if (!model) {
        return;
    }

    [PRRequestManager deleteDocument:model
        view:self.view
        mode:PRRequestMode_ShowErrorMessagesAndProgress
        success:^{

            [self reload];

        }
        failure:^{

        }];
}
- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == DocumentsSection_Passport && indexPath.row == _passportSections.count) {
        return NO;
    }

    if (indexPath.section == DocumentsSection_Visa && indexPath.row == _visaSections.count) {
        return NO;
    }

    return YES;
}

- (void)tableView:(UITableView*)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath*)indexPath
{
    PRDocumentModel* model = [self dataForSection:indexPath.section][indexPath.row];
    [self deleteDocumentWithId:model.documentId];
}

#pragma mark table view datasource

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return kDocumentCellHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return DocumentsSection_Count;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == DocumentsSection_Passport && _passportSections.count > 0) {

        return _passportSections.count + 1; // Add.
    }
    if (section == DocumentsSection_Visa && _visaSections.count > 0) {

        return _visaSections.count + 1; // Add.
    }
    return 1;
}

- (TextTableViewCell*)createAddCellForType:(NSInteger)type
{
    TextTableViewCell* cell = [_tableView dequeueReusableCellWithIdentifier:@"TextTableViewCell"];

    cell.labelText.text = type == 0 ? NSLocalizedString(@"Add Passport ...", ) : NSLocalizedString(@"Add Visa ...", );
    cell.labelText.textColor = kBlueTextColor;
    cell.accessoryType = UITableViewCellAccessoryNone;

    return cell;
}

- (NSArray<PRDocumentModel*>*)dataForSection:(NSUInteger)section
{
    if (section == DocumentsSection_Passport && _passportSections.count > 0) {

        return _passportSections;
    }
    if (section == DocumentsSection_Visa && _visaSections.count > 0) {

        return _visaSections;
    }
    return nil;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{

    NSArray<PRDocumentModel*>* items = [self dataForSection:indexPath.section];

    if (indexPath.section == DocumentsSection_Passport && _passportSections.count == indexPath.row) {
        return [self createAddCellForType:DocumentsSection_Passport];
    }

    if (indexPath.section == DocumentsSection_Visa && _visaSections.count == indexPath.row) {
        return [self createAddCellForType:DocumentsSection_Visa];
    }

    DocumentTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"DocumentTableViewCell"];

    NSUInteger index = indexPath.row;
    PRDocumentModel* data = items[index];
    if ([data.documentType integerValue] == 1) {
        [cell setLabelsValuesForLabelName:NSLocalizedString(@"Passport", )
                          labelItemsCount:data.documentNumber
                                textColor:[UIColor blackColor]];
    }
    else {
        [cell setLabelsValuesForLabelName:NSLocalizedString(@"Visa", )
                          labelItemsCount:data.documentNumber
                                textColor:[UIColor blackColor]];
    }

    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    AddDocumentViewController* viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddDocumentViewController"];
    viewController.parentView = self;
    viewController.userProfile = _userProfile;

    NSArray<PRDocumentModel*>* items = [self dataForSection:indexPath.section];

    if (indexPath.section == DocumentsSection_Passport) {

        viewController.type = @1;
    }
    else if (indexPath.section == DocumentsSection_Visa) {

        viewController.type = @2;
    }

    if (items != nil && indexPath.row < [items count]) {
        PRDocumentModel* model = ((PRDocumentModel*)items[indexPath.row]);
        viewController.documentId = model.documentId;

        if (model.documentType != nil) {
            if (model.documentType.intValue == 1) { // Passport.

                viewController.title = NSLocalizedString(@"Passport", );
            }
            else if (model.documentType.intValue == 2) { // Visa.

                if (model.visaTypeName != nil) {
                    viewController.title = [NSString stringWithFormat:@"%@ - %@", NSLocalizedString(@"Visa", ), model.visaTypeName];
                }
                else {
                    viewController.title = NSLocalizedString(@"Visa", );
                }
            }
        }
    }

    [self.navigationController pushViewController:viewController animated:YES];
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{

    if (section == DocumentsSection_Passport) {
        return NSLocalizedString(@"Passports", );
    }

    if (section == DocumentsSection_Visa) {
        return NSLocalizedString(@"Visas", );
    }

    return nil;
}

@end
