//
//  FeaturesHelpScreenViewController.m
//  PRIME
//
//  Created by Sargis Terteryan on 6/21/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import "PRInformationViewController.h"
#import "FeatureHeaderTableViewCell.h"
#import "PRInformationDetailsTableViewCell.h"
#import "PRInformationDetailsViewController.h"

@interface PRInformationViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView* featuresHelpScreenTableView;
@property (strong, nonatomic) NSMutableArray* helpScreenData;
@property (strong, nonatomic) NSMutableArray* helpScreenItemsData;
@property (weak, nonatomic) IBOutlet UIView* nextButtonView;
@property (weak, nonatomic) IBOutlet UIButton* nextButton;

@end

static NSString* const kHeaderCell = @"headerTableViewCell";
static NSString* const kFeatureHelpScreenItemsTableViewCell = @"featureHelpScreenItemsTableViewCell";
static NSString* const kInformationDetailsViewController = @"PRInformationDetailsViewController";
static CGFloat const kRowEstimatedHeight = 44.0f;
static CGFloat const kFooterHeight = 80.0f;

@implementation PRInformationViewController

#pragma mark - ViewController life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.featuresHelpScreenTableView.backgroundColor = kInformationBackgroundColor;
    self.nextButtonView.backgroundColor = kInformationBackgroundColor;
    UIImage* imageClose = [[UIImage imageNamed:@"info_close"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imageClose
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(closeButtonClick)];

    self.featuresHelpScreenTableView.delegate = self;
    self.featuresHelpScreenTableView.dataSource = self;

    [self.nextButton setTitle:NSLocalizedString(@"Continue", nil) forState:UIControlStateNormal];
}

#pragma mark - Help screen data

- (void)setInformation:(NSArray*)data
{
    self.helpScreenData = [data copy];
}

#pragma mark - Actions

- (IBAction)closeButtonAction:(id)sender
{
    [self closeButtonClick];
}

- (void)closeButtonClick
{
    [PRGoogleAnalyticsManager sendEventWithName:kReferenceCloseOrContinueButtonClicked parameters:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(nonnull UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.helpScreenData.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{

    NSDictionary* listItems = self.helpScreenData[indexPath.row];

    FeatureHeaderTableViewCell* headerCell = [tableView dequeueReusableCellWithIdentifier:kHeaderCell];
    if ([[listItems valueForKey:kInformationType] isEqualToString:kInformationHeader]) {

        if (headerCell == nil) {
            headerCell = [[FeatureHeaderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kHeaderCell];
        }

        headerCell.selectionStyle = UITableViewCellSelectionStyleNone;
        [headerCell setFeatureInfoHeader:[listItems valueForKey:kInformationValue] withBoldText:YES];
        return headerCell;
    }

    PRInformationDetailsTableViewCell* itemsCell = [tableView dequeueReusableCellWithIdentifier:kFeatureHelpScreenItemsTableViewCell];
    if (itemsCell == nil) {
        itemsCell = [[PRInformationDetailsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kFeatureHelpScreenItemsTableViewCell];
    }

    UIView* backgroundView = [[UIView alloc] init];
    backgroundView.backgroundColor = [UIColor clearColor];
    itemsCell.selectedBackgroundView = backgroundView;
    [itemsCell setInformationDetails:listItems];

    return itemsCell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView*)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return kRowEstimatedHeight;
}

- (UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section
{
    return self.nextButtonView;
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return kFooterHeight;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if (![cell isKindOfClass:[FeatureHeaderTableViewCell class]]) {
        [PRGoogleAnalyticsManager sendEventWithName:kReferenceChildPageOpened parameters:nil];
        [self.featuresHelpScreenTableView deselectRowAtIndexPath:indexPath animated:YES];
        NSDictionary* listItems = self.helpScreenData[indexPath.row];

        PRInformationDetailsViewController* informationDetails = [self.storyboard instantiateViewControllerWithIdentifier:kInformationDetailsViewController];
        NSArray* items = [listItems valueForKey:kInformationItems];
        [informationDetails setHelpScreenItemData:items];
        [self.navigationController pushViewController:informationDetails
                                             animated:YES];
    }
}

@end
