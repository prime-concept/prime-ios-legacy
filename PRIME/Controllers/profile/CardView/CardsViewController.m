//
//  CardsViewController.m
//  PRIME
//
//  Created by Artak Tsatinyan on 6/22/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "CardTypeViewController.h"
#import "CardsViewController.h"
#import "DiscountCardViewController.h"
#import "LoyaltyCardView.h"
#import "PRCardData.h"
#import "PRCreditCardValidator.h"
#import "PRLoyalCardModel.h"
#import "PaymentCardTableViewCell.h"
#import "ProfileViewController.h"
#import "SynchManager.h"
#import "TextTableViewCell.h"
#import "Utils.h"
#import "XNTKeychainStore.h"

#if defined(Prime)
#import "_Art_Of_Life_-Swift.h"
#elif defined(PrimeClubConcierge)
#import "PrimeClubConcierge-Swift.h"
#elif defined(Imperia)
#import "IMPERIA-Swift.h"
#elif defined(PondMobile)
#import "Pond Mobile-Swift.h"
#elif defined(Raiffeisen)
#import "Raiffeisen-Swift.h"
#elif defined(VTB24)
#import "PrimeConcierge-Swift.h"
#elif defined(Ginza)
#import "Ginza-Swift.h"
#elif defined(FormulaKino)
#import "Formula Kino-Swift.h"
#elif defined(Platinum)
#import "Platinum-Swift.h"
#elif defined(Skolkovo)
#import "Skolkovo-Swift.h"
#elif defined(PrimeConciergeClub)
#import "Tinkoff-Swift.h"
#elif defined(PrivateBankingPRIMEClub)
#import "PrivateBankingPRIMEClub-Swift.h"
#elif defined(PrimeRRClub)
#import "PRIME RRClub-Swift.h"
#elif defined(Davidoff)
#import "Davidoff-Swift.h"
#endif

typedef NS_ENUM(NSInteger, CardsSection) {
    CardsSection_PaymentCards,
    CardsSection_BonusCards
};

static const NSUInteger loyaltyCardViewHeight = 215;
static const NSUInteger loyaltyCardCellHeight = 55;
static const NSUInteger distanceBetweenViews = 15;

@interface CardsViewController ()

@property (weak, nonatomic) IBOutlet UITableView* tableView;
@property (weak, nonatomic) IBOutlet UIScrollView* loyaltyCardScrollView;
@property (weak, nonatomic) IBOutlet UISegmentedControl* paymentOrLoyaltyCardSegmentedControl;
@property (strong, nonatomic) UIView* footerView;
@property (strong, nonatomic) UILabel* footerLabel;
@property (strong, nonatomic) NSMutableArray<PRCardData*>* paymentCardSections;
@property (strong, nonatomic) NSArray<PRLoyalCardModel*>* bonusCardSections;
@property (strong, nonatomic) NSMutableArray<LoyaltyCardView*>* loyaltyCardViews;
@property (strong, nonatomic) LoyaltyCardView* selectedLoyaltyCardView;
@property (assign, nonatomic) NSUInteger indexOfSelectedLoyaltyCard;
@property (strong, nonatomic) SSPullToRefreshView* pullToRefreshViewForScrollView;
@property (weak, nonatomic) IBOutlet UIView *segmentBackgroundView;

@end

@implementation CardsViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                 target:self
                                 action:@selector(addNewCard)];

    //TODO: it's not secure, change cardSection !!!
    [self setKeychainStoreDefaultIdentifierIfNeeded];

    _paymentCardSections = [NSMutableArray objectFromKeychainWithKey:kCardDataKeyPath forClass:PRCardData.class];

    [_paymentOrLoyaltyCardSegmentedControl setSelectedSegmentIndex:CardsSection_PaymentCards];
    [_paymentOrLoyaltyCardSegmentedControl addTarget:self action:@selector(changeCardSection:) forControlEvents:UIControlEventValueChanged];
    [_paymentOrLoyaltyCardSegmentedControl setTitle:NSLocalizedString(@"PAYMENT CARDS", nil) forSegmentAtIndex:CardsSection_PaymentCards];
    [_paymentOrLoyaltyCardSegmentedControl setTitle:NSLocalizedString(@"LOYALTY CARDS", nil) forSegmentAtIndex:CardsSection_BonusCards];
    _paymentOrLoyaltyCardSegmentedControl.tintColor = kTaskSegmentColor;
    _paymentOrLoyaltyCardSegmentedControl.backgroundColor = [self getNavigationBarColor];
#if defined(VTB24) || defined(Raiffeisen) || defined(PrivateBankingPRIMEClub)
    [_paymentOrLoyaltyCardSegmentedControl ensureiOS12Style];
#endif

    _tableView.delegate = self;
    _tableView.dataSource = self;

    [self createTableViewFooter];

    self.title = NSLocalizedString(@"My cards", nil);

    [self getLoyalityCards];

    _loyaltyCardViews = [NSMutableArray new];

    _pullToRefreshViewForScrollView = [[SSPullToRefreshView alloc] initWithScrollView:_loyaltyCardScrollView
                                                                             delegate:self];
    SSPullToRefreshView* pullToRefreshViewForTableView = [[SSPullToRefreshView alloc] initWithScrollView:_tableView
                                                                                                delegate:self];
    (void)pullToRefreshViewForTableView;
}

- (void)viewWillAppear:(BOOL)animated
{
#if defined(VTB24)
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self setNeedsStatusBarAppearanceUpdate];
    _segmentBackgroundView.backgroundColor = kVTBBlackColor;
    [self.navigationController.navigationBar setBarTintColor:kVTBBlackColor];
#elif defined(PrivateBankingPRIMEClub)
    _segmentBackgroundView.backgroundColor = kGazprombankMainColor;
    _paymentOrLoyaltyCardSegmentedControl.tintColor = kWhiteColor;
    self.navigationItem.rightBarButtonItem.tintColor = kIconsColor;
    [self.navigationController.navigationBar hideBottomHairline];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
#endif
    if (_paymentOrLoyaltyCardSegmentedControl.selectedSegmentIndex != CardsSection_BonusCards) {
        _tableView.hidden = _paymentCardSections.count == 0;
        _loyaltyCardScrollView.hidden = YES;
        return;
    }
    _tableView.hidden = YES;
    _loyaltyCardScrollView.hidden = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self getLoyalityCards];
    for (int i = 0; i < _bonusCardSections.count; i++) {
        if ([_selectedLoyaltyCardView.cardId isEqual:_bonusCardSections[i].cardId]) {
            _indexOfSelectedLoyaltyCard = i;
            break;
        }
    }

    NSUInteger scrollViewContentHeight = (_bonusCardSections.count - 1) * loyaltyCardCellHeight + loyaltyCardViewHeight + distanceBetweenViews;
    [self changeContentSizeOfScrollView:scrollViewContentHeight];

    [self removeCardViews];
    [self drawLoyaltyCardView];

    __weak id weakSelf = self;
    [self.lazyManager shouldBeUpdatedIfViewDidAppearWithDate:[NSDate date]
        relativeToDate:nil
        then:^(PRRequestMode mode) {
            CardsViewController* strongSelf = weakSelf;
            if (!strongSelf) {

                return;
            }
            [PRRequestManager getDiscountsWithView:strongSelf.view
                                              mode:PRRequestMode_ShowNothing
                                           success:^(NSArray<PRLoyalCardModel*>* result) {
                                               CardsViewController* strongSelf = weakSelf;
                                               if (!strongSelf) {

                                                   return;
                                               }

                                               [strongSelf getLoyalityCards];
                                               NSUInteger scrollViewContentHeight = (_bonusCardSections.count - 1) * loyaltyCardCellHeight + loyaltyCardViewHeight + distanceBetweenViews;
                                               [strongSelf changeContentSizeOfScrollView:scrollViewContentHeight];
                                               [strongSelf removeCardViews];
                                               [strongSelf drawLoyaltyCardView];
                                           }
                                           failure:^{

                                           }];
        }
        otherwiseIfFirstTime:^{

        }
        otherwise:^{

        }];
}

- (void)setKeychainStoreDefaultIdentifierIfNeeded
{
    if (![XNTKeychainStore defaultIdentifier]) {
        NSString* username = [PRDatabase getUserProfile].username;
        [XNTKeychainStore setDefaultIdentifier:username];
        [XNTKeychainStore setDefaultKeyPrefix:username];
    }
}

- (void)showCardViewInformation
{
    [PRGoogleAnalyticsManager sendEventWithName:kMyCardsEditLoyaltyCardButtonClicked parameters:nil];
    [self openInfoForCardWithId:_selectedLoyaltyCardView.cardId];
}

- (void)showBigLoyaltyCardInformation
{
    [self openInfoForCardWithId:_bonusCardSections.lastObject.cardId];
}

- (void)openInfoForCardWithId:(NSNumber*)cardId
{
    DiscountCardViewController* discountCardViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DiscountCardViewController"];
    discountCardViewController.dataSource = self;
    discountCardViewController.cardId = cardId;
    [self.navigationController pushViewController:discountCardViewController animated:YES];
}

- (void)addNewCard
{
    if (_paymentOrLoyaltyCardSegmentedControl.selectedSegmentIndex == CardsSection_PaymentCards) {
        [PRGoogleAnalyticsManager sendEventWithName:kMyCardsAddPaymentCardButtonClicked parameters:nil];
        AddCardViewController* addCardViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddCardViewController"];
        addCardViewController.reloadDelegate = self;
        addCardViewController.cardData = _paymentCardSections;
        addCardViewController.selectedCardIndex = -1;
        [self.navigationController pushViewController:addCardViewController animated:YES];
        return;
    }

    [PRGoogleAnalyticsManager sendEventWithName:kMyCardsAddLoyaltyCardButtonClicked parameters:nil];
    CardTypeViewController* cardTypeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CardTypeViewController"];
    cardTypeViewController.dataSource = self;
    cardTypeViewController.cardData = _paymentCardSections;
    [self.navigationController pushViewController:cardTypeViewController animated:YES];
}

- (IBAction)changeCardSection:(UISegmentedControl*)sender
{
    if (_paymentOrLoyaltyCardSegmentedControl.selectedSegmentIndex == CardsSection_PaymentCards) {
        [PRGoogleAnalyticsManager sendEventWithName:kMyCardsPaymentCardsSegmentClicked parameters:nil];
        _tableView.backgroundColor = kTableViewBackgroundColor;
        _loyaltyCardScrollView.hidden = YES;
        if (_paymentCardSections.count == 0) {
            _tableView.hidden = YES;
            return;
        }
        _tableView.hidden = NO;
        [_tableView reloadData];
        return;
    }
    [PRGoogleAnalyticsManager sendEventWithName:kMyCardsLoyaltyCardsSegmentClicked parameters:nil];
    _tableView.hidden = YES;
    _loyaltyCardScrollView.hidden = NO;
}

- (void)changeContentSizeOfScrollView:(NSUInteger)contentSizeHeight
{
    _loyaltyCardScrollView.contentSize = CGSizeMake(_loyaltyCardScrollView.frame.size.width, contentSizeHeight);

    if (_loyaltyCardScrollView.contentSize.height < _loyaltyCardScrollView.frame.size.height) {
        _loyaltyCardScrollView.contentSize = CGSizeMake(_loyaltyCardScrollView.frame.size.width, contentSizeHeight + (_loyaltyCardScrollView.frame.size.height - _loyaltyCardScrollView.contentSize.height) + 5);
    }
}

- (void)handleLoyaltyCardTap:(UIGestureRecognizer*)recognizer
{

    CGPoint touchPoint = [recognizer locationInView:_loyaltyCardScrollView];

    LoyaltyCardView* selectedCardView = (LoyaltyCardView*)recognizer.view;

    for (NSUInteger i = 0; i < _loyaltyCardViews.count; ++i) {
        if (_loyaltyCardViews[i].frame.origin.y == selectedCardView.frame.origin.y && _loyaltyCardViews[i].frame.size.height != CGFLOAT_MIN) {
            _indexOfSelectedLoyaltyCard = i;
            break;
        }
    }

    __block NSUInteger indexForNextCards = _indexOfSelectedLoyaltyCard + 1;
    __block NSUInteger indexForPreviousCards = 0;

    if (_selectedLoyaltyCardView.cardId && touchPoint.y >= 0 && touchPoint.y <= loyaltyCardViewHeight) {
        //Opened view is selected.

        //Creates piano effect.
        NSUInteger animationDelay = 0;
        for (; indexForNextCards < _loyaltyCardViews.count; ++indexForNextCards) {
            [self animateSelectedCardNextCards:indexForNextCards animationDuration:0.3 + 0.02 * animationDelay andYPosition:0];
            ++animationDelay;
        }

        //Changes selected card's previous cards height.
        for (; indexForPreviousCards < _indexOfSelectedLoyaltyCard; ++indexForPreviousCards) {
            [self changeSelectedViewPreviousViewsHeight:indexForPreviousCards animationDuration:0.4 andPreviousViewsHeight:loyaltyCardViewHeight];
        }

        //Set all cards right y position.
        for (int i = 0; i < _loyaltyCardViews.count; ++i) {
            [UIView animateWithDuration:0.35
                             animations:^{
                                 CGRect cardNewFrame = _loyaltyCardViews[i].frame;
                                 cardNewFrame.origin.y = loyaltyCardCellHeight * i;
                                 [_loyaltyCardViews[i] setFrame:cardNewFrame];
                             }
                             completion:^(BOOL finished){

                             }];
        }

        _selectedLoyaltyCardView = nil;

        NSUInteger scrollViewContentHeight = (_bonusCardSections.count - 1) * loyaltyCardCellHeight + loyaltyCardViewHeight + distanceBetweenViews;
        [self changeContentSizeOfScrollView:scrollViewContentHeight];

        return;
    }

    _selectedLoyaltyCardView = _loyaltyCardViews[_indexOfSelectedLoyaltyCard];

    NSInteger previousViewIndex = _indexOfSelectedLoyaltyCard - 1;
    NSInteger yPosForPreviousViews = -loyaltyCardCellHeight;

    // Set selected view's previous views minus y positions.
    while (previousViewIndex >= 0) {
        [UIView animateWithDuration:0.2
                         animations:^{
                             CGRect cardNewFrame = _loyaltyCardViews[previousViewIndex].frame;
                             cardNewFrame.origin.y = yPosForPreviousViews;
                             [_loyaltyCardViews[previousViewIndex] setFrame:cardNewFrame];

                         }
                         completion:^(BOOL finished){

                         }];
        yPosForPreviousViews -= loyaltyCardCellHeight;
        --previousViewIndex;
    }

    //Set selected veiw's previous views height equal to CGFLOAT_MIN.
    for (; indexForPreviousCards < _indexOfSelectedLoyaltyCard; ++indexForPreviousCards) {
        [self changeSelectedViewPreviousViewsHeight:indexForPreviousCards animationDuration:0.4 andPreviousViewsHeight:CGFLOAT_MIN];
    }

    //Move selected view to the top.
    [UIView animateWithDuration:0.3
                     animations:^{
                         CGRect cardNewFrame = _loyaltyCardViews[_indexOfSelectedLoyaltyCard].frame;
                         cardNewFrame.origin.y = 0;
                         [_loyaltyCardViews[_indexOfSelectedLoyaltyCard] setFrame:cardNewFrame];
                     }
                     completion:^(BOOL finished){

                     }];

    //Piano effect for selected view's next views.
    NSUInteger yPosition = loyaltyCardViewHeight + distanceBetweenViews;
    NSUInteger animationDelay = 0;
    for (; indexForNextCards < _loyaltyCardViews.count; ++indexForNextCards) {
        [self animateSelectedCardNextCards:indexForNextCards animationDuration:0.3 + 0.02 * animationDelay andYPosition:yPosition];
        ++animationDelay;
        yPosition += loyaltyCardCellHeight;
    }

    CGFloat scrollViewContentSizeHeight = (_bonusCardSections.count - 2 - _indexOfSelectedLoyaltyCard) * loyaltyCardCellHeight + 2 * loyaltyCardViewHeight + 2 * distanceBetweenViews;
    [self changeContentSizeOfScrollView:scrollViewContentSizeHeight];

    if (_pullToRefreshViewForScrollView.state == SSPullToRefreshViewStateLoading) {
        [_loyaltyCardScrollView setContentOffset:CGPointMake(0, -50)];
    } else {
        [_loyaltyCardScrollView setContentOffset:CGPointZero animated:YES];
    }
}

- (void)animateSelectedCardNextCards:(NSUInteger)index animationDuration:(CGFloat)duration andYPosition:(NSUInteger)yPosition
{

    [UIView animateWithDuration:duration
                     animations:^{
                         CGRect cardNewFrame = _loyaltyCardViews[index].frame;
                         if (yPosition == 0) {
                             cardNewFrame.origin.y -= 175;
                         } else {
                             cardNewFrame.origin.y = yPosition;
                         }
                         [_loyaltyCardViews[index] setFrame:cardNewFrame];

                     }
                     completion:^(BOOL finished){

                     }];
}

- (void)changeSelectedViewPreviousViewsHeight:(NSUInteger)index animationDuration:(CGFloat)duration andPreviousViewsHeight:(NSUInteger)height
{
    [UIView animateWithDuration:duration
                     animations:^{
                         CGRect cardNewFrame = _loyaltyCardViews[index].frame;
                         cardNewFrame.size.height = height;
                         [_loyaltyCardViews[index] setFrame:cardNewFrame];

                     }
                     completion:^(BOOL finished){

                     }];
}

- (void)drawLoyaltyCardView
{
    NSUInteger nextViewYPos = 0;
    for (int i = 0; i < _bonusCardSections.count; ++i) {

        LoyaltyCardView* loyaltyCardView = nil;
        if (_selectedLoyaltyCardView.cardId) {
            if (i < _indexOfSelectedLoyaltyCard) {
                loyaltyCardView = [[LoyaltyCardView alloc] initWithFrame:CGRectMake(0, 0, _loyaltyCardScrollView.frame.size.width, CGFLOAT_MIN)];
            } else if ([_bonusCardSections[i].cardId isEqual:_selectedLoyaltyCardView.cardId]) {
                loyaltyCardView = [[LoyaltyCardView alloc] initWithFrame:CGRectMake(0, 0, _loyaltyCardScrollView.frame.size.width, loyaltyCardViewHeight)];
            } else {
                loyaltyCardView = [[LoyaltyCardView alloc] initWithFrame:CGRectMake(0, 230 + nextViewYPos, _loyaltyCardScrollView.frame.size.width, loyaltyCardViewHeight)];
                nextViewYPos += loyaltyCardCellHeight;
            }
        } else {
            loyaltyCardView = [[LoyaltyCardView alloc] initWithFrame:CGRectMake(0, i * loyaltyCardCellHeight, _loyaltyCardScrollView.frame.size.width, loyaltyCardViewHeight)];
        }

        PRLoyalCardModel* loyaltyCard = _bonusCardSections[i];
        loyaltyCardView.layer.cornerRadius = 10;

        loyaltyCardView.loyaltyCardNumber.text = loyaltyCard.cardNumber;
        loyaltyCardView.loyaltyCardExpirationDate.text = [self getDateWithRightFormat:loyaltyCard.expiryDate];
        loyaltyCardView.cardId = loyaltyCard.cardId;

        if (!loyaltyCard.type.color) {
            loyaltyCardView.backgroundColor = kWhiteColor;
        } else {
            loyaltyCardView.backgroundColor = [self colorFromHexString:loyaltyCard.type.color];
        }

        UIColor* colorForCurrentBackgroundColor = [self getTextColorForGivenBackgroundColor:loyaltyCardView.backgroundColor];

        loyaltyCardView.loyaltyCardExpirationDate.textColor = colorForCurrentBackgroundColor;
        loyaltyCardView.loyaltyCardNumber.textColor = colorForCurrentBackgroundColor;
        loyaltyCardView.informationButton.tintColor = colorForCurrentBackgroundColor;

        if (!loyaltyCard.type.logoUrl) {
            loyaltyCardView.loyaltyCardLogoImageView.hidden = YES;
            loyaltyCardView.loyaltyCardLogoImageView.image = nil;
            loyaltyCardView.loyaltyCardName.text = loyaltyCard.type.name ? loyaltyCard.type.name : @"";
            loyaltyCardView.loyaltyCardName.textColor = colorForCurrentBackgroundColor;
        } else {
            loyaltyCardView.loyaltyCardName.text = nil;
            loyaltyCardView.loyaltyCardLogoImageView.hidden = NO;
            [loyaltyCardView.loyaltyCardLogoImageView setImageWithURL:[NSURL URLWithString:loyaltyCard.type.logoUrl]];
        }

        UITapGestureRecognizer* tapOnLoyaltyCard =
            [[UITapGestureRecognizer alloc] initWithTarget:self
                                                    action:@selector(handleLoyaltyCardTap:)];
        [loyaltyCardView addGestureRecognizer:tapOnLoyaltyCard];

        if (i == _bonusCardSections.count - 1) {
            [loyaltyCardView.informationButton addTarget:self action:@selector(showBigLoyaltyCardInformation) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [loyaltyCardView.informationButton addTarget:self action:@selector(showCardViewInformation) forControlEvents:UIControlEventTouchUpInside];
        }

        if (_selectedLoyaltyCardView.cardId) {

            CGFloat scrollViewContentSizeHeight = (_bonusCardSections.count - 2 - _indexOfSelectedLoyaltyCard) * loyaltyCardCellHeight + 2 * loyaltyCardViewHeight + 2 * distanceBetweenViews;
            [self changeContentSizeOfScrollView:scrollViewContentSizeHeight];
        }

        [_loyaltyCardScrollView addSubview:loyaltyCardView];
        [_loyaltyCardViews addObject:loyaltyCardView];
    }
}

- (void)removeCardViews
{
    for (UIView* subview in [_loyaltyCardScrollView subviews]) {
        if ([subview isKindOfClass:[LoyaltyCardView class]]) {
            [subview removeFromSuperview];
        }
    }

    [_loyaltyCardViews removeAllObjects];
}

- (void)getLoyalityCards
{
    _bonusCardSections = [PRDatabase getDiscounts];
}

- (void)didMoveToParentViewController:(UIViewController*)parent
{
    if (!parent) {
        [_reloadDelegate reload];
    }
}

- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView*)view
{

    [view startLoading];

    _paymentCardSections = [NSMutableArray objectFromKeychainWithKey:kCardDataKeyPath forClass:PRCardData.class];

    __weak id weakSelf = self;
    [PRRequestManager getDiscountsWithView:self.view
        mode:PRRequestMode_ShowNothing
        success:^(NSArray<PRLoyalCardModel*>* result) {
            CardsViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            [strongSelf getLoyalityCards];

            [view finishLoading];

        }
        failure:^{
            CardsViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            [view finishLoading];
        }];
}

// Called by Reachability whenever status changes.
- (void)reachabilityChanged:(NSNotification*)note
{
    [self.lazyManager shouldBeUpdatedIfReachabilityChangedWithNotification:note
                                                                      date:[NSDate date]
                                                            relativeToDate:nil
                                                                      then:^(PRRequestMode mode) {
                                                                          [PRRequestManager getDiscountsWithView:self.view
                                                                                                            mode:PRRequestMode_ShowErrorMessagesAndProgress
                                                                                                         success:^(NSArray<PRLoyalCardModel*>* result) {

                                                                                                             [self getLoyalityCards];

                                                                                                         }
                                                                                                         failure:^{

                                                                                                         }];

                                                                      }];
}

- (void)createTableViewFooter
{
    static NSString* const kFooterLableText = @"The card will be encrypted in the KeyChain and is only available on this device.";

    _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 74)];
    _footerView.backgroundColor = [UIColor clearColor];

    _footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 13, self.view.frame.size.width - 14 - 14, 34)];
    _footerLabel.numberOfLines = 2;
    _footerLabel.text = NSLocalizedString(kFooterLableText, nil);
    _footerLabel.font = [UIFont systemFontOfSize:13.f];
    _footerLabel.textColor = kAppLabelColor;

    _footerLabel.backgroundColor = [UIColor clearColor];
    _footerLabel.textAlignment = NSTextAlignmentLeft;
    [_footerLabel sizeToFit];

    [_footerView addSubview:_footerLabel];
}

- (NSString*)getDateWithRightFormat:(NSString*)dateString
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate* date = [dateFormatter dateFromString:dateString];
    return [date mt_stringFromDateWithFormat:@"MM/yy" localized:NO];
}

- (UIColor*)getTextColorForGivenBackgroundColor:(UIColor*)viewBackColor
{

    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
    [viewBackColor getRed:&red green:&green blue:&blue alpha:&alpha];

    CGFloat threshold = 0.5;
    CGFloat bgDelta = ((red * 0.299) + (green * 0.587) + (blue * 0.114));

    return (bgDelta < threshold ? [UIColor whiteColor] : [UIColor blackColor]);
}

- (UIColor*)colorFromHexString:(NSString*)hexString
{
    unsigned rgbValue = 0;
    NSScanner* scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // First is #.
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16) / 255.0 green:((rgbValue & 0xFF00) >> 8) / 255.0 blue:(rgbValue & 0xFF) / 255.0 alpha:1.0];
}

#pragma mark delete action

- (void)deleteCardFor:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath
{
    [_paymentCardSections removeObjectAtIndex:indexPath.row];
    [_paymentCardSections storeToKeychainWithKey:kCardDataKeyPath];
    [tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationFade];
}

- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    return YES;
}

- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
    [self deleteCardFor:tableView atIndexPath:indexPath];
}

#pragma mark table view datasource

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

- (NSInteger)bonusCardSectionRowCount
{
    return _bonusCardSections.count;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{

    return _paymentCardSections.count;
}

- (PaymentCardTableViewCell*)createPaymentCardCellForIndexPath:(NSIndexPath*)indexPath
{
    PaymentCardTableViewCell* cell = [_tableView dequeueReusableCellWithIdentifier:@"PaymentCardTableViewCell"];

    cell.labelCardNumber.textColor = kAppLabelColor;
    cell.labelCardExpDate.textColor = kAppLabelColor;

    PRCardData* cardData = _paymentCardSections[indexPath.row];

    cell.labelCardType.text = [PRCreditCardValidator getTypeForCardNumber:cardData.cardNumber];

    cell.labelCardNumber.text = [PRCreditCardValidator getHiddenCardNumber:cardData.cardNumber];

    cell.labelCardExpDate.text = cardData.expDate;

    cell.imageViewIcon.image = [Utils getImageForCardNumber:cardData.cardNumber];

    return cell;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return [self createPaymentCardCellForIndexPath:indexPath];
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [PRGoogleAnalyticsManager sendEventWithName:kMyCardsEditPaymentCardButtonClicked parameters:nil];
    AddCardViewController* addCardViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddCardViewController"];
    addCardViewController.reloadDelegate = self;
    addCardViewController.cardData = _paymentCardSections;
    addCardViewController.selectedCardIndex = indexPath.row;
    [self.navigationController pushViewController:addCardViewController animated:YES];
}

- (UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section
{

    if (_paymentOrLoyaltyCardSegmentedControl.selectedSegmentIndex == CardsSection_PaymentCards) {
        return _footerView;
    }

    return nil;
}

#pragma mark reload table

- (void)reload
{
    if (_bonusCardSections.count != [PRDatabase getDiscounts].count) {
        _selectedLoyaltyCardView = nil;
    }
    _bonusCardSections = [PRDatabase getDiscounts];

    [_tableView reloadData];
}

@end
