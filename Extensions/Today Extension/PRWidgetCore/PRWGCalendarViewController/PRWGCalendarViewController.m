//
//  PRWGCalendarViewController.m
//  PRWidgetPrime
//
//  Created by Armen on 4/4/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import "PRWGCalendarViewController.h"
#import "PRWGRequestTableViewCell.h"
#import "Constants.h"

static NSInteger const kMaximumHeadersCountFor5Cells = 3;
static NSString* const kPRWGRequestTableViewCell = @"PRWGRequestTableViewCell";
static const CGFloat kSmallDeviceScreenHeight = 568.0f;
static const NSInteger kSmallDeviceTasksMaxCount = 6;
static const CGFloat kMediumDeviceScreenHeight = 667.0f;
static const CGFloat kLargeDeviceScreenHeight = 736.0f;
static const NSInteger kMediumDeviceCityGuideMaxCount = 7;
static const NSInteger kLargeDeviceCityGuideMaxCount = 8;

@interface PRWGCalendarViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray* dataArray;
@property (assign, nonatomic) NSInteger headersCount;
@property (weak, nonatomic) IBOutlet UITableView* tableView;
@property (weak, nonatomic) IBOutlet UILabel* noDataLabel;

@end

@implementation PRWGCalendarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.dataArray = [[[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName] valueForKey:kWidgetEvents];
    [_noDataLabel setText:NSLocalizedString(@"No events", )];
    _noDataLabel.hidden = _dataArray.count ? YES : NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDefaultsDidChange:)
                                                 name:NSUserDefaultsDidChangeNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidDisappear:animated];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if (screenHeight == kSmallDeviceScreenHeight && _dataArray.count > kSmallDeviceTasksMaxCount) {
        return kSmallDeviceTasksMaxCount;
    } else if (screenHeight == kMediumDeviceScreenHeight && _dataArray.count > kMediumDeviceCityGuideMaxCount) {
        return kMediumDeviceCityGuideMaxCount;
    }
    return _dataArray.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    PRWGRequestTableViewCell* cell = (PRWGRequestTableViewCell*)[tableView dequeueReusableCellWithIdentifier:kPRWGRequestTableViewCell];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:kPRWGRequestTableViewCell owner:self options:nil] objectAtIndex:0];
    }
    [cell updateCellWithData:_dataArray[indexPath.row]];
    [cell setDate:_dataArray[indexPath.row]];
    [cell setRequestStatus:_dataArray[indexPath.row]];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSString* taskId = [_dataArray[indexPath.row] valueForKey:kWidgetRequestID];
    NSURL* URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@taskinfo/%@", kURLSchemesPrefix, taskId]];
    [self.extensionContext openURL:URL completionHandler:nil];
}

- (void)userDefaultsDidChange:(NSNotification*)notification
{
    NSMutableArray* array = [[[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName] valueForKey:kWidgetEvents];
    if (![_dataArray isEqual:array]) {
        self.dataArray = array;
        _noDataLabel.hidden = self.dataArray.count ? YES : NO;
        [_tableView reloadData];
    }
}

- (void)setDataArray:(NSMutableArray*)dataArray
{
    NSMutableArray* array = [NSMutableArray new];
    _headersCount = 1;
    for (NSInteger i = 0; i < dataArray.count; i++) {
        NSMutableDictionary* currentData = [dataArray[i] mutableCopy];
        NSDate* currentDate = [currentData valueForKey:kWidgetRequestDate];
        currentDate = [self dateWithComponentsFromDate:currentDate units:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)];
        BOOL haveNewHeader = ![self hasEqualDate:currentDate inDataArray:dataArray beforeCurrentIndex:i];
        if (haveNewHeader) {
            _headersCount++;
        } else {
            [currentData setValue:nil forKey:kWidgetRequestDate];
        }

        [array addObject:currentData];
    }
    _dataArray = array;
}

- (BOOL)hasEqualDate:(NSDate*)previewDate inDataArray:(NSArray*)array beforeCurrentIndex:(NSInteger)index
{
    for (NSInteger i = index - 1; i >= 0; i--) {
        NSDate* date = [array[i] valueForKey:kWidgetRequestDate];
        date = [self dateWithComponentsFromDate:previewDate units:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)];
        if ([previewDate isEqualToDate:date]) {
            return YES;
        }
    }
    return NO;
}

- (NSDate*)dateWithComponentsFromDate:(NSDate*)date units:(NSCalendarUnit)units
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:units fromDate:date];

    return [calendar dateFromComponents:components];
}

@end
