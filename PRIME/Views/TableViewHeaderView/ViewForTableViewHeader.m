//
//  ViewForTableViewHeader.m
//  PRIME
//
//  Created by Taron Sahakyan on 12/8/15.
//  Copyright © 2015 XNTrends. All rights reserved.
//

#import "ViewForTableViewHeader.h"

static const NSInteger lablesInsets = 15;
static const CGFloat adjustedLabelHight = 60.f;
static NSString* const kCloseButtonKey = @"closeHeader1";
static const CGFloat noBalancesLabelHight = 50.f;

@implementation ViewForTableViewHeader

- (id)initWithNewAutoLayoutView:(NSArray*)balances
{
    self = [super init];
    if (self) {

        _labels = [NSMutableArray array];
        _topView = [UIView newAutoLayoutView];
        _topView.backgroundColor = [UIColor whiteColor];
        _lablesView = [UIView newAutoLayoutView];
        [_topView addSubview:_lablesView];
        [_lablesView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(lablesInsets, 0, lablesInsets, lablesInsets) excludingEdge:ALEdgeLeft];
        [self addSubview:_topView];
        [_topView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];

        [self createCurrentBalancesLable];

        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        BOOL isClosed = [defaults boolForKey:kCloseButtonKey];
        if (!isClosed) {
            [self createBottomView];
        }
        [self addLables:balances];

        [self setCurrencyLablesLayouts:_labels];

        if ([_labels count] == 0) {
            [self createNoBalancesLabel];
        }
    }
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    BOOL isClosed = [defaults boolForKey:kCloseButtonKey];
    if (isClosed) {
        [_topView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        [self resizeHeadrView];
    }
    return self;
}

- (void)addLables:(NSArray*)balances
{
    for (PRBalanceModel* balance in balances) {
        UILabel* label = [UILabel newAutoLayoutView];

        NSString* remaining = [NSString stringWithFormat:@"%.f ", [balance.closingBalance floatValue]];
        NSMutableAttributedString* balanceRemaining = [[NSMutableAttributedString alloc] initWithString:remaining
                                                                                             attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:16] }];

        NSMutableAttributedString* balanceCurrency = [[NSMutableAttributedString alloc] initWithString:balance.currency
                                                                                            attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:16] }];

        [balanceRemaining appendAttributedString:balanceCurrency];

        label.attributedText = balanceRemaining;
        label.textAlignment = NSTextAlignmentRight;
        [_lablesView addSubview:label];
        [_labels addObject:label];
    }
}

- (void)setCurrencyLablesLayouts:(NSMutableArray*)labels
{
    UILabel* firstLabel = [labels firstObject];
    [firstLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [firstLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    if (labels.count == 1) {
        [firstLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    }
    if (labels.count > 1) {
        [[labels lastObject] autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
        [labels autoMatchViewsDimension:ALDimensionHeight];
        [labels autoMatchViewsDimension:ALDimensionWidth];
        [labels autoDistributeViewsAlongAxis:ALAxisVertical alignedTo:ALAttributeLeft withFixedSpacing:3 insetSpacing:1];
    }
}

- (void)resizeHeadrView
{
    CGFloat height = [self systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;

    _tableView.tableHeaderView.frame = ({
        CGRect headerFrame = self.frame;
        headerFrame.size.height = height;
        headerFrame;
    });

    [self setNeedsLayout];
    [self layoutIfNeeded];
    _tableView.tableHeaderView = self;
}

- (void)actionCloseButton:(UIButton*)sender
{
    [PRGoogleAnalyticsManager sendEventWithName:kFinancesCloseButtonClicked parameters:nil];
    [_bottomView removeFromSuperview];
    [_topView autoPinEdgesToSuperviewEdges];
    [self resizeHeadrView];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:kCloseButtonKey];
    [defaults synchronize];
}
- (UILabel*)createCurrentBalancesLable
{

    UILabel* currentBalances = [UILabel newAutoLayoutView];
    [_topView addSubview:currentBalances];
    currentBalances.text = NSLocalizedString(@"Current balances", );
    currentBalances.font = [UIFont systemFontOfSize:18];
    [currentBalances autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:lablesInsets];
    [currentBalances autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:lablesInsets];
    return currentBalances;
}
- (void)createNoBalancesLabel
{
    UILabel* noBalancesLabel = [UILabel newAutoLayoutView];
    [_topView addSubview:noBalancesLabel];
    noBalancesLabel.text = NSLocalizedString(@"No balances information for current month", );
    noBalancesLabel.numberOfLines = 3;
    [noBalancesLabel autoSetDimension:ALDimensionHeight toSize:noBalancesLabelHight];
    [noBalancesLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(2, 15, 4, 4) excludingEdge:ALEdgeTop];
    [noBalancesLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:[self createCurrentBalancesLable]];
}
- (void)createBottomView
{
    _bottomView = [UIView newAutoLayoutView];
    UIButton* closeButton = [UIButton newAutoLayoutView];
    UILabel* adjustedLabel = [UILabel newAutoLayoutView];
    [_bottomView addSubview:closeButton];

    [_bottomView addSubview:adjustedLabel];
    adjustedLabel.text = NSLocalizedString(@"Data on transactions made in the last 10 days, can be adjusted", );
    adjustedLabel.textColor = kAppLabelColor;
    adjustedLabel.font = [UIFont systemFontOfSize:14];
    adjustedLabel.numberOfLines = 3;
    [adjustedLabel autoSetDimension:ALDimensionHeight toSize:adjustedLabelHight];
    [adjustedLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(2, lablesInsets, 2, 2) excludingEdge:ALEdgeRight];
    [closeButton addTarget:self action:@selector(actionCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    [closeButton autoSetDimensionsToSize:CGSizeMake(33, 33)];
    [closeButton setImage:[UIImage imageNamed:@"close_icon"] forState:UIControlStateNormal];
    [closeButton autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(4, 2, 4, lablesInsets) excludingEdge:ALEdgeLeft];
    [adjustedLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:closeButton];
    [self addSubview:_bottomView];
    [_bottomView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self];
    [_bottomView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    [_bottomView autoSetDimension:ALDimensionHeight toSize:adjustedLabelHight];
    _bottomView.backgroundColor = kTableViewHeaderColor;
    [_bottomView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_topView withOffset:0];
}

@end
