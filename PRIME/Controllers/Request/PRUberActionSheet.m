//
//  PRUberActionSheet.m
//  PRIME
//
//  Created by Nerses Hakobyan on 4/10/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "PRUberActionSheet.h"
#import "PRUberCell.h"
#import "PRUberView.h"
#import "UberManager.h"

@interface PRUberActionSheet ()

@property (strong, nonatomic) CustomActionSheetViewController* customActionSheet;
@property (strong, nonatomic) UITableView* uberServicesTableView;
@property (strong, nonatomic) UIView* popupView;
@property (strong, nonatomic) UIImageView* blurredImageView;
@property (strong, nonatomic) UIImage* blurredImage;

@end

const CGFloat kMaximumHeightForPopupMenu = 232;
const CGFloat kPopupMenuCornerRadius = 13;
const CGFloat kPopupMenuTopPartHeight = 58;
const CGFloat kPopupMenuBottomPartHeight = 58;
const CGFloat kUberCellHeight = 58;

static NSString* const kUberServiceCellReuseIdentifier = @"kUberServiceCell";

@implementation PRUberActionSheet

#pragma mark - Initializers

- (instancetype)initWithSourceArray:(NSMutableArray<PRUberEstimates*>*)sourceArray andRootViewController:(__kindof UIViewController*)viewController
{
    self = [super init];
    if (self) {
        _sourceArray = sourceArray.mutableCopy;
        [self.view setBackgroundColor:[UIColor clearColor]];
        [self createUberServicesTableView];
        [self createPopupMenu];
        [self constructViewControllerControls];
        _rootViewController = viewController;
        [self createBlurEffect];
    }
    return self;
}

#pragma mark - Blur Effect

- (void)createBlurEffect
{
    UIGraphicsBeginImageContext(_rootViewController.view.window.frame.size);
    [_rootViewController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    // Blur the UIImage.
    CIImage* imageToBlur = [CIImage imageWithCGImage:viewImage.CGImage];
    CIContext* context = [CIContext contextWithOptions:nil];
    CIFilter* gaussianBlurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [gaussianBlurFilter setValue:imageToBlur forKey:@"inputImage"];
    [gaussianBlurFilter setValue:[NSNumber numberWithFloat:5] forKey:@"inputRadius"];
    CIImage* resultImage = [gaussianBlurFilter valueForKey:@"outputImage"];
    CGRect frame = _rootViewController.view.frame;
    frame.origin.y += 44;
    CGImageRef cgImage = [context createCGImage:resultImage fromRect:frame];
    _blurredImage = [[UIImage alloc] initWithCGImage:cgImage];
    _blurredImageView = [[UIImageView alloc] initWithFrame:_rootViewController.view.frame];
    _blurredImageView.image = _blurredImage;

    [self.view insertSubview:_blurredImageView belowSubview:_popupView];
    _blurredImageView.alpha = 0;
}

#pragma mark - Popup Menu

- (void)createPopupMenu
{
    UIColor* const kTopLabelBackgroundColor = kUberActionSheetTopPartColor;

    // Blur effect.
    UIBlurEffect* blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView* blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [blurEffectView setFrame:self.view.bounds];
    [self.view addSubview:blurEffectView];

    self.view.alpha = 0;

    const CGFloat kPopupLeftSpace = (IS_IPHONE_4 || IS_IPHONE_5) ? 30 : 45;
    const CGFloat kPopupTopSpace = IS_IPHONE_4 ? 60 : IS_IPHONE_5 ? 100 : 155;

    _popupView = [UIView newAutoLayoutView];
    [self.view addSubview:_popupView];
    _popupView.layer.cornerRadius = kPopupMenuCornerRadius;
    _popupView.layer.masksToBounds = YES;
    [_popupView setFrame:CGRectMake(kPopupLeftSpace, kPopupTopSpace, CGRectGetWidth(self.view.frame) - 2 * kPopupLeftSpace, kMaximumHeightForPopupMenu)];
    [_popupView setBackgroundColor:[UIColor whiteColor]];

    UILabel* topLabelForPopup = [UILabel newAutoLayoutView];
    [_popupView addSubview:topLabelForPopup];
    [topLabelForPopup autoSetDimension:ALDimensionWidth toSize:CGRectGetWidth(_popupView.frame)];
    [topLabelForPopup autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    [topLabelForPopup setBackgroundColor:kTopLabelBackgroundColor];
    [topLabelForPopup autoSetDimension:ALDimensionHeight toSize:kPopupMenuTopPartHeight];
    topLabelForPopup.textAlignment = NSTextAlignmentCenter;
    topLabelForPopup.text = NSLocalizedString(@"Choose car", nil);
    topLabelForPopup.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    topLabelForPopup.textColor = [UIColor whiteColor];

    [_popupView addSubview:_uberServicesTableView];
    [_uberServicesTableView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kPopupMenuTopPartHeight];
    [_uberServicesTableView autoSetDimension:ALDimensionHeight toSize:_sourceArray.count * kUberCellHeight];
    [_uberServicesTableView autoSetDimension:ALDimensionWidth toSize:CGRectGetWidth(_popupView.frame)];

    UIView* bottomViewForPopup = [UIView newAutoLayoutView];
    [_popupView addSubview:bottomViewForPopup];
    [bottomViewForPopup autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_uberServicesTableView withOffset:0];
    [bottomViewForPopup autoSetDimension:ALDimensionHeight toSize:kPopupMenuBottomPartHeight];
    [bottomViewForPopup setBackgroundColor:[UIColor whiteColor]];
    [bottomViewForPopup autoSetDimension:ALDimensionWidth toSize:CGRectGetWidth(_popupView.frame)];
    UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(openUberSite)];
    [bottomViewForPopup addGestureRecognizer:tapGestureRecognizer];

    const CGFloat kUberIconLeftSpace = IS_IPHONE_6P ? 20 : 15;

    UIImageView* uberIconImageView = [UIImageView newAutoLayoutView];
    uberIconImageView.image = [UIImage imageNamed:@"uberIcon"];
    [bottomViewForPopup addSubview:uberIconImageView];
    [uberIconImageView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [uberIconImageView autoSetDimensionsToSize:CGSizeMake(20, 20)];
    [uberIconImageView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kUberIconLeftSpace];

    UILabel* uberDetailsLabel = [UILabel newAutoLayoutView];
    [bottomViewForPopup addSubview:uberDetailsLabel];
    [uberDetailsLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [uberDetailsLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:uberIconImageView withOffset:15];
    uberDetailsLabel.text = NSLocalizedString(@"See more on UBER", nil);
    uberDetailsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:17];
    [uberDetailsLabel autoSetDimension:ALDimensionWidth toSize:200];

    UIImageView* uberDetailsImageView = [UIImageView newAutoLayoutView];
    [bottomViewForPopup addSubview:uberDetailsImageView];
    [uberDetailsImageView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    uberDetailsImageView.image = [[UIImage imageNamed:@"arrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [uberDetailsImageView setTintColor:[UIColor blackColor]];
    [uberDetailsImageView autoSetDimensionsToSize:CGSizeMake(15, 15)];
    [uberDetailsImageView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:15];
}

- (void)reload
{
    [_uberServicesTableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return _sourceArray.count;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return kUberCellHeight;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    PRUberCell* uberCell = [_uberServicesTableView dequeueReusableCellWithIdentifier:kUberServiceCellReuseIdentifier];
    NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"PRUberCell"
                                                 owner:self
                                               options:nil];

    PRUberEstimates* uberEstimate = [_sourceArray objectAtIndex:indexPath.row];

    NSString* estimate = [[UberManager sharedManager] getEstimateForUber:uberEstimate];
    NSString* currencySign = [[UberManager sharedManager] getCurrencySignForCode:uberEstimate.currencyCode];

    uberCell = [nib objectAtIndex:0];
    [uberCell.uberServiceNameLabel setText:uberEstimate.displayName];
    [uberCell.servicePriceLabel setText:estimate];
    [uberCell.currencyLabel setText:currencySign];
    if ([uberEstimate.estimatedPickupTime integerValue] > 0) {
        [uberCell.estimatedPickupTimeLabel setText:[NSString stringWithFormat:@"%@ %@", @([uberEstimate.estimatedPickupTime integerValue] / 60), NSLocalizedString(@"mins", nil)]]; // Minutes
    }
    else {
        [uberCell.estimatedPickupTimeLabel setText:@""];
    }
    uberCell.carImageView.image = uberEstimate.carImage;
    uberCell.shouldShowSurge = [uberEstimate.surgeMultiplier integerValue] > 1;
    uberCell.selectionStyle = UITableViewCellSelectionStyleNone;

    return uberCell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    [(PRUberCell*)cell willAppear];
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    PRUberEstimates* source = _sourceArray[indexPath.row];
    [[UberManager sharedManager] openUrlForProductId:source.productId
                                       startLatitude:source.startLatitude
                                      startLongitude:source.startLongitude
                                         endLatitude:source.endLatitude
                                        endLongitude:source.endLongitude
                                      dropoffAddress:source.dropoffAddress];
}

#pragma mark - Uber Services

- (void)createUberServicesTableView
{
    _uberServicesTableView = [UITableView newAutoLayoutView];

    _uberServicesTableView.delegate = self;
    _uberServicesTableView.dataSource = self;
    [_uberServicesTableView registerClass:[PRUberCell class]
                   forCellReuseIdentifier:kUberServiceCellReuseIdentifier];
    _uberServicesTableView.tableFooterView = [UIView new];
}

- (void)showAnimated
{
    CGRect frame = _popupView.frame;
    frame.size.height = 0;
    frame.size.width = 0;
    frame.origin.x = self.view.center.x - CGRectGetMidX(frame);
    frame.origin.y = self.view.center.y - CGRectGetMidY(frame);
    _popupView.frame = frame;
    [_rootViewController.tabBarController.tabBar setHidden:YES];
    [UIView animateWithDuration:0.3f animations:^{
        _blurredImageView.alpha = 0.5;
        self.view.alpha = 1;
    }];
    [UIView animateWithDuration:0.1f delay:0.1f options:0 animations:^{
        CGRect frame = _popupView.frame;
        const CGFloat kPopupLeftSpace = (IS_IPHONE_4 || IS_IPHONE_5) ? 30 : 45;
        const CGFloat kPopupTopSpace = IS_IPHONE_4 ? 60 : IS_IPHONE_5 ? 100 : 155;

        frame.size.height += [self heightForPopupMenu];
        frame.size.width += CGRectGetWidth(self.view.frame) - 2 * kPopupLeftSpace;
        frame.origin.x = CGRectGetMinX(self.view.frame) + kPopupLeftSpace;
        frame.origin.y = CGRectGetMinY(self.view.frame) + kPopupTopSpace;
        _blurredImageView.frame = self.view.frame;
        _popupView.frame = frame;
    }

        completion:^(BOOL finished){

        }];
}

- (CGFloat)heightForPopupMenu
{
    if (_sourceArray.count > 2) {
        return kMaximumHeightForPopupMenu;
    }
    return kPopupMenuTopPartHeight + kPopupMenuBottomPartHeight + _sourceArray.count * kUberCellHeight;
}

- (void)constructViewControllerControls
{
    const CGFloat kCloseViewBottomSpace = (IS_IPHONE_4 || IS_IPHONE_5) ? 60 : 80;

    UIView* closeControlView = [UIView newAutoLayoutView];
    [self.view addSubview:closeControlView];
    [closeControlView autoSetDimensionsToSize:CGSizeMake(150, 40)];
    [closeControlView autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [closeControlView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kCloseViewBottomSpace];
    [closeControlView setBackgroundColor:[UIColor clearColor]];

    UIImageView* crossImageView = [UIImageView newAutoLayoutView];
    [closeControlView addSubview:crossImageView];
    [crossImageView autoSetDimensionsToSize:CGSizeMake(25, 25)];
    [crossImageView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:25];
    [crossImageView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [crossImageView setImage:[UIImage imageNamed:@"close_cross_icon"]];

    UILabel* closeButtonTitleLabel = [UILabel newAutoLayoutView];
    [closeControlView addSubview:closeButtonTitleLabel];
    [closeButtonTitleLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [closeButtonTitleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:crossImageView withOffset:8];
    closeButtonTitleLabel.text = NSLocalizedString(@"Cancel", nil);
    closeButtonTitleLabel.textColor = [UIColor whiteColor];

    UITapGestureRecognizer* closeGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                             action:@selector(close)];

    [closeControlView addGestureRecognizer:closeGestureRecognizer];
}

- (void)close
{
    [UIView animateWithDuration:0.2f animations:^{
        self.view.alpha = 0;
    }
        completion:^(BOOL finished) {
            [self dismissViewControllerAnimated:NO
                                     completion:^{
                                         [_rootViewController.tabBarController.tabBar setHidden:NO];
                                         if ([self.delegate respondsToSelector:@selector(uberActionSheetDidClose)]) {
                                             [self.delegate uberActionSheetDidClose];
                                         }
                                     }];
        }];
}

#pragma mark - Open Uber

- (void)openUberSite
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"uber://"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"uber://"]];
        return;
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://m.uber.com"]];
}

@end
