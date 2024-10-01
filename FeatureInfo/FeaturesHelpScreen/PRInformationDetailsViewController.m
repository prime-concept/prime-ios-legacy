//
//  FeaturesHelpScreenItemViewController.m
//  PRIME
//
//  Created by Sargis Terteryan on 6/25/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import "PRInformationDetailsViewController.h"
#import "FeatureHeaderTableViewCell.h"
#import "FeatureImageTableViewCell.h"
#import "FeatureTextTableViewCell.h"

@interface PRInformationDetailsViewController () <UITableViewDataSource, UITableViewDelegate, FeatureImageDelegate>

@property (weak, nonatomic) IBOutlet UITableView* helpScreenItemTableView;
@property (strong, nonatomic) NSArray* itemsData;

@end

static NSString* const kHeaderCell = @"headerTableViewCell";
static NSString* const kTextCell = @"textTableViewCell";
static NSString* const kImageCell = @"imageTableViewCell";
static CGFloat const kRowEstimatedHeight = 44.0f;

@implementation PRInformationDetailsViewController

#pragma mark - ViewController life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.helpScreenItemTableView.backgroundColor = kInformationBackgroundColor;
    self.helpScreenItemTableView.delegate = self;
    self.helpScreenItemTableView.dataSource = self;
    self.navigationController.navigationBar.backgroundColor = kInformationBackgroundColor;
    self.navigationController.navigationBar.tintColor = kInformationBackgroundColor;
    UIImage* imageBack = [[UIImage imageNamed:@"info_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imageBack
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(backButtonClick)];
}

#pragma mark - Help Screen Items

- (void)setHelpScreenItemData:(NSArray*)data
{
    self.itemsData = [data copy];
}

#pragma mark - FeatureImageDelegate

- (void)imageHasBeenDownloaded
{
    [self.helpScreenItemTableView reloadData];
}

#pragma mark - Actions

- (void)backButtonClick
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(nonnull UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.itemsData.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath;
{
    NSDictionary* dictionary = self.itemsData[indexPath.row];
    if ([[dictionary valueForKey:kInformationType] isEqualToString:kInformationHeader]) {
        FeatureHeaderTableViewCell* headerCell = [tableView dequeueReusableCellWithIdentifier:kHeaderCell];
        if (headerCell == nil) {
            headerCell = [[FeatureHeaderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kHeaderCell];
        }

        [headerCell setFeatureInfoHeader:[dictionary valueForKey:kInformationValue] withBoldText:YES];
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
