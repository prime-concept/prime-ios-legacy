//
//  DateTableViewSectionHeader.m
//  PRIME
//
//  Created by Taron Sahakyan on 12/8/15.
//  Copyright © 2015 XNTrends. All rights reserved.
//

#import "DateTableViewSectionHeader.h"

@implementation DateTableViewSectionHeader

- (instancetype)init:(UITableView*)tableView withSectionTitle:(NSString*)sectionTitle
{
    self = [super init];
    if (self) {
        [self commonInit:tableView sectionTitle:sectionTitle titlePositionFromLeft:CGFLOAT_MIN];
    }
    return self;
}

- (instancetype)init:(UITableView*)tableView withSectionTitle:(NSString*)sectionTitle andTitlePositionFromLeft:(CGFloat)position
{
    self = [super init];
    if (self) {
        [self commonInit:tableView sectionTitle:sectionTitle titlePositionFromLeft:position];
    }
    return self;
}

- (void)commonInit:(UITableView*)tableView sectionTitle:(NSString*)sectionTitle titlePositionFromLeft:(CGFloat)position
{
    const CGFloat height = 18;
    self.frame = CGRectMake(0, 0, tableView.frame.size.width, height);

    self.backgroundColor = kTableViewHeaderColor;

    UILabel* headerLabel = [[UILabel alloc] init];
    [self addSubview:headerLabel];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor colorWithWhite:0.1f alpha:0.9];
    headerLabel.font = [UIFont systemFontOfSize:12.0];
    headerLabel.text = sectionTitle;

    if (position == CGFLOAT_MIN) {
        headerLabel.textAlignment = NSTextAlignmentCenter;
        [headerLabel autoPinEdgesToSuperviewEdges];
        [headerLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
    } else {
        [headerLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:position];
        [headerLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0.f];
    }
}

@end
