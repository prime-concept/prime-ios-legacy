//
//  PRCarDetailsViewController.m
//  PRIME
//
//  Created by Mariam on 6/16/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRCarDetailsViewController.h"
#import "PREditInfoTableViewCell.h"
#import "SynchManager.h"
#import "TPKeyboardAvoidingTableView.h"

typedef NS_ENUM(NSInteger, CarInfo) {
    CarInfo_Brand = 0,
    CarInfo_Model,
    CarInfo_RegistrationPlate,
    CarInfo_Color,
    CarInfo_Vin,
    CarInfo_ReleaseDate
};

typedef NS_ENUM(NSInteger, CarDetailsTableViewSection) {
    CarDetailsTableViewSection_Info = 0,
    CarDetailsTableViewSection_Delete
};

@interface PRCarDetailsViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingTableView* tableView;
@property (strong, nonatomic) NSArray<NSString*>* sourceArray;
@property (strong, nonatomic) NSArray<NSString*>* infosArray;

@property (nonatomic, strong) PRCarModel* carModel;
@property (nonatomic, strong) NSNumber* carModelStatus;
@property (nonatomic, strong) PRCarsViewController* carsViewController;
@property (strong, nonatomic) NSManagedObjectContext* mainContext;

@end

@implementation PRCarDetailsViewController

static NSString* const kEditInfoCellIdentifier = @"PREditInfoTableViewCell";
static NSString* const kDeleteCellIdentifier = @"DeleteTableViewCell";

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = _carModel ? [NSString stringWithFormat:@"%@ %@", _carModel.brand ?: @"", _carModel.model ?: @""] : @"";
    [self createSourceArraysForTableView];
    _tableView.dataSource = self;
    _tableView.delegate = self;
}

#pragma mark Public Methods

- (void)setCurrentCar:(PRCarModel*)car
                 context:(NSManagedObjectContext*)context
    parentViewController:(PRCarsViewController*)parentViewController
{
    _carModel = car;
    _mainContext = context;
    _carsViewController = parentViewController;
}

#pragma mark - Private Methods

- (void)showSaveButton:(BOOL)show
{
    if ((self.navigationItem.rightBarButtonItem && show) || (!self.navigationItem.rightBarButtonItem && !show)) {
        return;
    }
    self.navigationItem.rightBarButtonItem = show ? [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil)
                                                                                     style:UIBarButtonItemStylePlain
                                                                                    target:self
                                                                                    action:@selector(saveAction)]
                                                  : nil;
}

- (void)createSourceArraysForTableView
{
    _carModelStatus = _carModel ? @(ModelStatus_Updated) : @(ModelStatus_Added);

    _sourceArray = @[
        _carModel.brand ?: @"",
        _carModel.model ?: @"",
        _carModel.registrationPlate ?: @"",
        _carModel.color ?: @"",
        _carModel.vin ?: @"",
        _carModel.releaseDate ?: @""
    ];

    _infosArray = @[
        NSLocalizedString(@"Brand", ),
        NSLocalizedString(@"Model", ),
        NSLocalizedString(@"Registration Plate", ),
        NSLocalizedString(@"Color", ),
        NSLocalizedString(@"VIN", ),
        NSLocalizedString(@"Release Year", )
    ];
}

- (void)carDetailsFromTableView
{
    _carModel.vin = [self textFieldValueForRow:CarInfo_Vin];
    _carModel.registrationPlate = [self textFieldValueForRow:CarInfo_RegistrationPlate];
    _carModel.brand = [self textFieldValueForRow:CarInfo_Brand];
    _carModel.model = [self textFieldValueForRow:CarInfo_Model];
    _carModel.releaseDate = [self textFieldValueForRow:CarInfo_ReleaseDate];
    _carModel.color = [self textFieldValueForRow:CarInfo_Color];
    _carModel.state = _carModelStatus;
}

- (NSString*)textFieldValueForRow:(NSInteger)row
{
    PREditInfoTableViewCell* cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:CarDetailsTableViewSection_Info]];
    return [cell currentTextValue];
}

- (void)saveToPersistentStore
{
    [_mainContext MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError* error) {

        if (error) {
            [PRMessageAlert showToastWithMessage:Message_SaveContactFailed];
            return;
        }

        if (!contextDidSave) {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }

        if (![PRRequestManager connectionRequired]) {
            [[SynchManager sharedClient] synchProfileCarsInContext:_mainContext
                                                              view:self.view
                                                              mode:PRRequestMode_ShowErrorMessagesAndProgress
                                                        completion:^{
                                                            [self popViewController];
                                                        }];
        } else {
            _carsViewController.isSynchedFromOffline = NO;
            [self popViewController];
        }
    }];
}

- (void)popViewController
{
    [_carsViewController reloadData];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return [_carModelStatus isEqual:@(ModelStatus_Added)] ? 1 : 2;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == CarDetailsTableViewSection_Info ? _sourceArray.count : 1;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == CarDetailsTableViewSection_Delete) {
        UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDeleteCellIdentifier];
        cell.textLabel.text = NSLocalizedString(@"Delete car", nil);
        cell.textLabel.textColor = kDeleteButtonColor;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        return cell;
    }

    PREditInfoTableViewCell* cell = [_tableView dequeueReusableCellWithIdentifier:kEditInfoCellIdentifier];
    [cell configureCellWithTextfieldText:[_sourceArray objectAtIndex:indexPath.row]
                          andPlaceholder:[_infosArray objectAtIndex:indexPath.row]
                                     tag:indexPath.row
                                delegate:self];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == CarDetailsTableViewSection_Delete) {
        [PRGoogleAnalyticsManager sendEventWithName:kMyCarsDeleteCarButtonClicked parameters:nil];
        _carModelStatus = @(ModelStatus_Deleted);
        [self saveAction];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
    [self showSaveButton:YES];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Actions

- (void)saveAction
{
    [PRGoogleAnalyticsManager sendEventWithName:kMyCarsSaveCarButtonClicked parameters:nil];
    [self.view endEditing:YES];
    self.navigationItem.rightBarButtonItem.enabled = NO;

    _carModel = _carModel ? [_carModel MR_inContext:_mainContext] : [PRCarModel MR_createEntityInContext:_mainContext];
    [self carDetailsFromTableView];

    [_mainContext refreshObject:_carModel mergeChanges:YES];
    [self saveToPersistentStore];
}

@end
