//
//  SelectRelatedDocumentsViewController.m
//  PRIME
//
//  Created by Hamlet on 2/27/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import "SelectRelatedDocumentsViewController.h"
#import "PRInfoTableViewCell.h"

@interface SelectRelatedDocumentsViewController()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray<PRDocumentModel*>* documents;
@property (strong, nonatomic) NSArray<PRProfileContactDocumentModel*>* contactDocuments;
@property (strong, nonatomic) NSMutableArray* selectedDocuments;

@end

@implementation SelectRelatedDocumentsViewController

static NSString* const kCellIdentifier = @"PassportVisaInfoCell";

- (void)viewDidLoad {
    [super viewDidLoad];

    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = kTableViewBackgroundColor;
    _tableView.allowsMultipleSelection = _isPassport;
    _selectedDocuments = [NSMutableArray new];
    _contactDocuments = [NSArray new];
    _documents = [NSArray new];
    [self prepareNavigationBar];

    if (_isPassport) {
        if (_isContactDocument) {
            _contactDocuments = [PRDatabase profileContactNonDeletedVisasForContactId:_contactId inContext:_mainContext];
        } else {
            _documents = [PRDatabase getVisas];
        }
    } else {
        if (_isContactDocument) {
            _contactDocuments = [PRDatabase profileContactNonDeletedPassportsForContactId:_contactId inContext:_mainContext];
        } else {
            _documents = [PRDatabase getPassports];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_isContactDocument) {
        return _contactDocuments.count;
    }
    return _documents.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    PRInfoTableViewCell* cell = [_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (_isPassport) {
        if (_isContactDocument) {
            PRProfileContactDocumentModel* data = (PRProfileContactDocumentModel*)[_contactDocuments objectAtIndex:indexPath.row];
            NSString* country = [Utils countryNameFromCode:data.countryCode ?: COUNTRY_CODE_RUSSIA];
            UIImage* flag = [Utils countryFlagFromCode:data.countryCode ?: COUNTRY_CODE_RUSSIA];
            NSString* localizedDetail;
            if (!data.expiryDate || [data.expiryDate isEqualToString:@""]) {
                localizedDetail = @"";
            } else {
                NSString* detail;
                if ([data.expiryDate containsString:@"-"]) {
                    detail = data.expiryDate;
                } else {
                    detail = [Utils fromMillisecondsToFormattedDate:data.expiryDate];
                }
                localizedDetail = [NSLocalizedString(@"until: ", nil) stringByAppendingString:detail];
            }

            [cell configureCellWithInfo:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Visa", nil), NSLocalizedString(country, nil)] detail:localizedDetail andImage:flag];
        } else {
            PRDocumentModel* data = (PRDocumentModel*)[_documents objectAtIndex:indexPath.row];
            NSString* country = [Utils countryNameFromCode:data.countryCode ?: COUNTRY_CODE_RUSSIA];
            UIImage* flag = [Utils countryFlagFromCode:data.countryCode ?: COUNTRY_CODE_RUSSIA];

            NSString* localizedDetail;
            if (!data.expiryDate || [data.expiryDate isEqualToString:@""]) {
                localizedDetail = @"";
            } else {
                NSString* detail;
                if ([data.expiryDate containsString:@"-"]) {
                    detail = data.expiryDate;
                } else {
                    detail = [Utils fromMillisecondsToFormattedDate:data.expiryDate];
                }
                localizedDetail = [NSLocalizedString(@"until: ", nil) stringByAppendingString:detail];
            }
            [cell configureCellWithInfo:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Visa", nil), NSLocalizedString(country, nil)] detail:localizedDetail andImage:flag];
        }
    } else {
        if (_isContactDocument) {
            PRProfileContactDocumentModel* data = (PRProfileContactDocumentModel*)[_contactDocuments objectAtIndex:indexPath.row];
            NSString* country = [Utils countryNameFromCode:data.countryCode ?: COUNTRY_CODE_RUSSIA];
            UIImage* flag = [Utils countryFlagFromCode:data.countryCode ?: COUNTRY_CODE_RUSSIA];
            [cell configureCellWithInfo:data.documentNumber placeholder:NSLocalizedString(@"Passport Number", nil) detail:country andImage:flag];
        } else {
            PRDocumentModel* data = (PRDocumentModel*)[_documents objectAtIndex:indexPath.row];
            NSString* country = [Utils countryNameFromCode:data.countryCode ?: COUNTRY_CODE_RUSSIA];
            UIImage* flag = [Utils countryFlagFromCode:data.countryCode ?: COUNTRY_CODE_RUSSIA];
            [cell configureCellWithInfo:data.documentNumber placeholder:NSLocalizedString(@"Passport Number", nil) detail:country andImage:flag];
        }
    }

    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    return cell;
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isContactDocument) {
        PRProfileContactDocumentModel* data = (PRProfileContactDocumentModel*)[_contactDocuments objectAtIndex:indexPath.row];
        if ([_relatedDocumentsId containsObject:data.documentId]) {
            [cell setSelected:YES];
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    } else {
        PRDocumentModel* data = (PRDocumentModel*)[_documents objectAtIndex:indexPath.row];
        if ([_relatedDocumentsId containsObject:data.documentId]) {
            [cell setSelected:YES];
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isSelected]) {
        [cell setSelected:NO];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];

        return nil;
    }

    return indexPath;
}

- (void)prepareNavigationBar
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", )
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(done)];
}

- (void)done
{
    NSArray<NSIndexPath*>* selectedCells = [_tableView indexPathsForSelectedRows];
    if (_isContactDocument) {
        for (NSIndexPath* indexPath in selectedCells) {
            [_selectedDocuments addObject:_contactDocuments[indexPath.row]];
        }
    } else {
        for (NSIndexPath* indexPath in selectedCells) {
            [_selectedDocuments addObject:_documents[indexPath.row]];
        }
    }

    [self.delegate setRelatedDocuments:_selectedDocuments];
    [_parentView reload];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

@end
