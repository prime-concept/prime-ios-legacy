//
//  PRFeatureInfoViewController.m
//  PRIME
//
//  Created by Sargis Terteryan on 5/25/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import "PRFeatureInfoViewController.h"
#import "FeatureHeaderTableViewCell.h"
#import "FeatureImageTableViewCell.h"
#import "FeatureTextTableViewCell.h"

@interface PRFeatureInfoViewController () <UITableViewDataSource, UITableViewDelegate, FeatureImageDelegate>

@property (strong, nonatomic) NSMutableArray* featureInfoData;
@property (weak, nonatomic) IBOutlet UITableView* featuresTableView;
@property (strong, nonatomic) NSString* featureBoolKey;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* tableViewTopConstraint;

@end

static NSString* const kHeaderCell = @"headerTableViewCell";
static NSString* const kTextCell = @"textTableViewCell";
static NSString* const kImageCell = @"imageTableViewCell";
static CGFloat const kRowEstimatedHeight = 44.0f;
static CGFloat const kTableViewDefaultTopConstraint = 64.0f;
static CGFloat const kTableViewTopConstraintForIphoneX = 84.0f;

@implementation PRFeatureInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = kFeatureInfoBackgroundColor;
    self.featuresTableView.backgroundColor = kFeatureInfoBackgroundColor;
    self.featuresTableView.delegate = self;
    self.featuresTableView.dataSource = self;
    self.featuresTableView.allowsSelection = NO;
    self.tableViewTopConstraint.constant = IS_IPHONE_X ? kTableViewTopConstraintForIphoneX : kTableViewDefaultTopConstraint;
}

- (void)setFeatureInfoData:(NSArray*)data withFeatureBoolKey:(NSString*)boolKey
{
    self.featureInfoData = [data mutableCopy];
    self.featureBoolKey = boolKey;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:self.featureBoolKey];
}

- (void)imageHasBeenDownloaded
{
    [self.featuresTableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(nonnull UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.featureInfoData.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath;
{
    NSDictionary* dictionary = self.featureInfoData[indexPath.row];
    if ([[dictionary valueForKey:kInformationType] isEqualToString:kInformationHeader]) {
        FeatureHeaderTableViewCell* headerCell = [tableView dequeueReusableCellWithIdentifier:kHeaderCell];
        if (headerCell == nil) {
            headerCell = [[FeatureHeaderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kHeaderCell];
        }

        [headerCell setFeatureInfoHeader:[dictionary valueForKey:kInformationValue] withBoldText:NO];
        return headerCell;
    }

    if ([[dictionary valueForKey:kInformationType] isEqualToString:kInformationImage]) {
        FeatureImageTableViewCell* imageCell = [tableView dequeueReusableCellWithIdentifier:kImageCell];
        if (imageCell == nil) {
            imageCell = [[FeatureImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kImageCell];
        }

        NSString* imageURL = [dictionary valueForKey:kInformationUrl];
        imageCell.delegate = self;
        [imageCell setFeatureImage:imageURL];

        return imageCell;
    }

    FeatureTextTableViewCell* textCell = [tableView dequeueReusableCellWithIdentifier:kTextCell];
    if (textCell == nil) {
        textCell = [[FeatureTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTextCell];
    }

    [textCell setFeatureText:[dictionary valueForKey:kInformationValue]];

    return textCell;
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

@end
