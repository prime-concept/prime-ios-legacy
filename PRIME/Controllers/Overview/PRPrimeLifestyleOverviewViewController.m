//
//  PRPrimeLifestyleOverviewViewController.m
//  PRIME
//
//  Created by Davit on 8/23/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "PRLifeStyleTableViewCell.h"
#import "PRPrimeLifestyleOverviewViewController.h"

typedef NS_ENUM(NSInteger, LifestyleSectionType) {
    LifestyleSectionType_RestaurantsSection = 0,
    LifestyleSectionType_PurchasesSection,
    LifestyleSectionType_Count,
};

@interface PRPrimeLifestyleOverviewViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView* lifestyleTableView;
@property (weak, nonatomic) IBOutlet UILabel* lifestylePrivilegesLabel;
@property (weak, nonatomic) IBOutlet UILabel* totalPartnersLabel;
@property (weak, nonatomic) IBOutlet UILabel* lifestyleDetailsLabel;
@property (weak, nonatomic) IBOutlet UIView* containerView;

@property (strong, nonatomic) NSMutableArray<NSDictionary*>* restaurantGroupsArray;
@property (strong, nonatomic) NSMutableArray<NSDictionary*>* purchaseGroupsArray;

@property (strong, nonatomic) NSString* firstSectionTitle;
@property (strong, nonatomic) NSString* firstSectionTitleDetails;
@property (strong, nonatomic) NSString* secondSectionTitle;

@end

static NSString* const kLifeStyleCellIdentifier = @"PrimeLifestyleTableViewCell";

@implementation PRPrimeLifestyleOverviewViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _lifestyleTableView.rowHeight = UITableViewAutomaticDimension;
    _lifestyleTableView.estimatedRowHeight = 44.0;
}

#pragma mark - Layout

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    // Apply gradient to text view bottom area.
    [self applyGradientToView:_containerView];
}

#pragma mark - Fill Screen

- (void)fillScreenWithData:(NSDictionary*)dataDict
{
    _restaurantGroupsArray = [NSMutableArray array];
    _purchaseGroupsArray = [NSMutableArray array];

    [_lifestylePrivilegesLabel setText:NSLocalizedString(dataDict[kOverviewTitleKey], nil)];
    [_lifestyleDetailsLabel setText:NSLocalizedString(dataDict[kOverviewDetailsKey], nil)];
    [_totalPartnersLabel setText:NSLocalizedString(dataDict[kOverviewPartnersCountKey], nil)];

    _firstSectionTitle = NSLocalizedString(dataDict[kOverviewRestaurantsKey], nil);
    _firstSectionTitleDetails = NSLocalizedString(dataDict[kOverviewPartnersKey], nil);
    _secondSectionTitle = NSLocalizedString(dataDict[kOverviewPurchasesKey], nil);

    NSArray<NSDictionary*>* itemsArray = dataDict[kOverviewItemsKey][kOverviewItemKey];

    for (int i = 0; i < [dataDict[kOverviewItemsKey][kOverviewCountKey] integerValue]; i++) {
        NSDictionary* itemDictionary = itemsArray[i];
        if (i < 4) {
            [_restaurantGroupsArray addObject:itemDictionary];
        }
        else {
            [_purchaseGroupsArray addObject:itemDictionary];
        }
    }
    [_lifestyleTableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return LifestyleSectionType_Count;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
    case LifestyleSectionType_RestaurantsSection:
        return _restaurantGroupsArray.count;
    case LifestyleSectionType_PurchasesSection:
        return _purchaseGroupsArray.count;
    default:
        return 0;
    }
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    PRLifeStyleTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kLifeStyleCellIdentifier];

    NSDictionary* itemDictionary = (indexPath.section == LifestyleSectionType_RestaurantsSection) ? _restaurantGroupsArray[indexPath.row] : _purchaseGroupsArray[indexPath.row];

    [cell.logoImageView setImage:[UIImage imageNamed:itemDictionary[kOverviewImageKey]]];
    [cell.groupNameLabel setText:NSLocalizedString(itemDictionary[kOverviewTitleKey], nil)];
    [cell.groupNameLabel setFont:[UIFont systemFontOfSize:12]];
    [cell.groupDescriptionLabel setText:NSLocalizedString(itemDictionary[kOverviewContentKey], nil)];
    [cell.groupDescriptionLabel setFont:[UIFont systemFontOfSize:12]];

    return cell;
}

#pragma mark - UITableViewDelegate

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    UIColor* const kSectionTitleColor = [UIColor colorWithRed:180.0f / 255.0f green:154.0f / 255.0f blue:112.0f / 255.0f alpha:1.0f];

    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
    [headerView setBackgroundColor:[UIColor clearColor]];

    UIView* separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 35, CGRectGetWidth(headerView.frame), 1)];
    [separatorView setBackgroundColor:[UIColor colorWithRed:104.0 / 255.0 green:81.0 / 255.0 blue:73.0 / 255.0 alpha:1.0]];

    if (section == LifestyleSectionType_RestaurantsSection) {
        UILabel* sectionTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, headerView.frame.size.width, 20)];
        [sectionTitle setText:_firstSectionTitle];
        [sectionTitle setFont:[UIFont systemFontOfSize:17]];
        [sectionTitle setTextColor:kSectionTitleColor];

        UILabel* sectionPartners = [[UILabel alloc] initWithFrame:CGRectMake(0, 17, headerView.frame.size.width, 15)];
        [sectionPartners setText:_firstSectionTitleDetails];
        [sectionPartners setFont:[UIFont systemFontOfSize:12]];
        [sectionPartners setTextColor:kSectionTitleColor];

        [headerView addSubview:sectionTitle];
        [headerView addSubview:sectionPartners];
        [headerView addSubview:separatorView];

        return headerView;
    }

    UILabel* sectionTitle = [[UILabel alloc] initWithFrame:headerView.frame];
    [sectionTitle setText:_secondSectionTitle];
    [sectionTitle setFont:[UIFont systemFontOfSize:17]];
    [sectionTitle setTextColor:kSectionTitleColor];

    [headerView addSubview:sectionTitle];
    [headerView addSubview:separatorView];

    return headerView;
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

@end
