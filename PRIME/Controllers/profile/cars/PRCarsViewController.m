//
//  PRCarsViewController.m
//  PRIME
//
//  Created by Mariam on 6/16/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRCarsViewController.h"
#import "PRInfoTableViewCell.h"
#import "PRRequestManager.h"
#import "PRCarDetailsViewController.h"
#import "PRAddNewDataTableViewCell.h"
#import "SynchManager.h"

@interface PRCarsViewController () <UITableViewDelegate, UITableViewDataSource, ReloadTable>

@property (weak, nonatomic) IBOutlet UITableView* tableView;

@property (strong, nonatomic) NSArray<PRCarModel*>* sourceArray;
@property (strong, nonatomic) NSManagedObjectContext* mainContext;

@end

@implementation PRCarsViewController

static NSString* const kInfoCellIdentifier = @"PRInfoTableViewCell";
static NSString* const kAddInfoCellIdentifier = @"PRAddNewDataTableViewCell";
static NSString* const kCarDetailsViewController = @"PRCarDetailsViewController";

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"My cars", );
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    _mainContext = [[RKManagedObjectStore defaultStore] newChildManagedObjectContextWithConcurrencyType:NSMainQueueConcurrencyType];
    _sourceArray = [PRDatabase profileCarsWithContext:_mainContext];

    _tableView.delegate = self;
    _tableView.dataSource = self;

    [self initPullToRefreshForScrollView:_tableView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.lazyManager shouldBeUpdatedIfViewDidAppearWithDate:[NSDate date]
        relativeToDate:nil
        then:^(PRRequestMode mode) {
            [self getCars];
            [self.pullToRefreshView finishLoading];
        }
        otherwiseIfFirstTime:^{
            [_tableView reloadData];
        }
        otherwise:^{

        }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return _sourceArray.count + 1;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if ([self isLastIndexPath:indexPath]) {
        PRAddNewDataTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kAddInfoCellIdentifier];
        [cell configureCellWithText:NSLocalizedString(@"add car", )];
        return cell;
    }

    PRInfoTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kInfoCellIdentifier];
    PRCarModel* car = [_sourceArray objectAtIndex:indexPath.row];
    [cell configureCellWithInfo:[self displayingTextForCar:car] andDetail:car.registrationPlate];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    PRCarDetailsViewController* carDetailsVC = [self.storyboard instantiateViewControllerWithIdentifier:kCarDetailsViewController];

    [carDetailsVC setCurrentCar:[self isLastIndexPath:indexPath] ? nil : [_sourceArray objectAtIndex:indexPath.row]
                        context:_mainContext
           parentViewController:self];
    [PRGoogleAnalyticsManager sendEventWithName:[self isLastIndexPath:indexPath] ? kMyCarsAddCarButtonClicked : kMyCarsEditCarButtonClicked parameters:nil];

    [self.navigationController pushViewController:carDetailsVC animated:YES];
}

#pragma mark - Pull To Refresh

- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView*)view
{
    [self.pullToRefreshView startLoading];

    [self.lazyManager shouldBeRefreshedWithDate:[NSDate date]
        relativeToDate:nil
        then:^(PRRequestMode mode) {
            [self getCars];
        }
        otherwise:^{
            [self.pullToRefreshView finishLoading];
        }];
}

- (void)reachabilityChanged:(NSNotification*)note
{
    if (![PRRequestManager connectionRequired] && !_isSynchedFromOffline) {

        for (PRCarModel* car in [PRDatabase profileCarsForModifyInContext:_mainContext]) {
            if ([car.carId isEqualToNumber:@0] && [car.state isEqualToNumber:@(ModelStatus_Updated)]) {
                car.state = @(ModelStatus_Added);
            }
        }

        [[SynchManager sharedClient] synchProfileCarsInContext:_mainContext
                                                          view:nil
                                                          mode:PRRequestMode_ShowNothing
                                                    completion:^{
                                                    }];
        _isSynchedFromOffline = YES;
    }

    [self.lazyManager shouldBeUpdatedIfReachabilityChangedWithNotification:note
                                                                      date:[NSDate date]
                                                            relativeToDate:nil
                                                                      then:^(PRRequestMode mode) {
                                                                          [self getCars];
                                                                      }];
}

#pragma mark - Private Methods

- (void)getCars
{
    __weak PRCarsViewController* weakSelf = self;
    [PRRequestManager getProfileCarsWithView:self.view
        mode:PRRequestMode_ShowErrorMessagesAndProgress
        success:^(NSArray<PRCarModel*>* profileCars) {
            PRCarsViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            strongSelf.sourceArray = profileCars;

            [strongSelf.pullToRefreshView finishLoading];

            [strongSelf.tableView reloadData];
        }
        failure:^{
            PRCarsViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            [strongSelf.pullToRefreshView finishLoading];

        }];
}

- (BOOL)isLastIndexPath:(NSIndexPath*)indexPath
{
    return indexPath.row == [_tableView numberOfRowsInSection:indexPath.section] - 1;
}

- (NSString*)displayingTextForCar:(PRCarModel*)car
{
    NSString* carBrand = car.brand ?: @"";
    NSString* space = carBrand.length > 0 ? @" " : @"";
    NSString* carModel = car.model ?: @"";
    return [NSString stringWithFormat:@"%@%@%@", carBrand, space, carModel];
}

- (void)reloadData
{
    _sourceArray = [PRDatabase profileCarsWithContext:_mainContext];
    [_tableView reloadData];
}
@end
