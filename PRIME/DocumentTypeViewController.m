//
//  DocumentTypeViewController.m
//  PRIME
//
//  Created by Hamlet on 2/20/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import "DocumentTypeViewController.h"
#import "AddDocumentViewController.h"
#import "PRDocumentTypeModel.h"

@interface DocumentTypeViewController ()
@property (strong, nonatomic) NSArray* documentTypes;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

static const CGFloat kTableViewHeaderHeight = 56.0f;
static const CGFloat kTableViewHeaderFontSize = 16.0f;
static NSString* const kHeaderFooterViewIdentifier = @"HeaderFooterView";

@implementation DocumentTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = kTableViewBackgroundColor;

    self.title = NSLocalizedString(@"Documents", nil);

    _documentTypes = [PRDatabase getDocumentTypes];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    BOOL isDataExist = _documentTypes && _documentTypes.count > 0;

     __weak DocumentTypeViewController* weakSelf = self;
    [self.lazyManager shouldBeUpdatedIfViewDidAppearWithDate:[NSDate date]
                                              relativeToDate:nil
                                                        then:^(PRRequestMode mode) {
                                                            [PRRequestManager getDocumentTypesWithView:self.view
                                                                                                  mode:isDataExist ? PRRequestMode_ShowNothing : PRRequestMode_ShowErrorMessagesAndProgress
                                                                                               success:^(NSArray* result) {
                                                                                                   DocumentTypeViewController * strongSelf = weakSelf;
                                                                                                   if (!strongSelf) {
                                                                                                       return ;
                                                                                                   }

                                                                                                   [strongSelf reload];
                                                                                               }
                                                                                               failure:^{}];
                                                        }
                                        otherwiseIfFirstTime:^{
                                            [_tableView reloadData];
                                        }
                                                   otherwise:^{}];
}

#pragma mark - Helpers

- (void)reload
{
    _documentTypes = [PRDatabase getDocumentTypes];
    [_tableView reloadData];
}

- (UITableViewHeaderFooterView*)headerFooterViewForTableView:(UITableView*)tableView
{
    UITableViewHeaderFooterView* headerFooterView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kHeaderFooterViewIdentifier];
    if (!headerFooterView) {
        headerFooterView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:kHeaderFooterViewIdentifier];
    }

    return headerFooterView;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return _documentTypes.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"documentTypeCell"];
    NSString* typeName = nil;

    typeName = ((PRDocumentTypeModel*)_documentTypes[indexPath.row]).name;

    cell.textLabel.text = typeName;

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableViewHeaderHeight;
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    AddDocumentViewController* viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddDocumentViewController"];
    viewController.parentView = _dataSource;
    viewController.userProfile = [PRDatabase getUserProfile];
    viewController.contactModel = _contactModel;
    viewController.mainContext = _mainContext;
    viewController.isContactDocument = _isContactDocument;
    viewController.type = ((PRDocumentTypeModel*)_documentTypes[indexPath.row]).typeId;
    viewController.title = NSLocalizedString(((PRDocumentTypeModel*)_documentTypes[indexPath.row]).name, );

    [self.navigationController pushViewController:viewController animated:YES];
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self headerFooterViewForTableView:tableView];
}

- (void)tableView:(UITableView*)tableView willDisplayHeaderView:(UIView*)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView* headerView = (UITableViewHeaderFooterView*)view;

    headerView.textLabel.font = [UIFont systemFontOfSize:kTableViewHeaderFontSize];
    [headerView.textLabel setText:[NSLocalizedString(@"Document types", ) uppercaseString]];
}

@end
