//
//  PRAeroflotProfileCardCell.m
//  Aeroflot
//
//  Created by Aram on 10/10/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRAeroflotProfileCardCell.h"
#import "XNAvatar.h"
#import "Utils.h"

@interface PRAeroflotProfileCardCell ()
@property (weak, nonatomic) IBOutlet UIImageView* cardImageView;
@property (weak, nonatomic) IBOutlet UILabel* profileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel* clubNumber;
@property (weak, nonatomic) IBOutlet UILabel* profileValidThruLabel;
@property (weak, nonatomic) IBOutlet UILabel* profileExpiryDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint* validThruLabelLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* validThruLabelBottomConstraint;

@end

static CGFloat const kProfileNameLabelTextFontSize = 16;
static CGFloat const kProfileCardNumberTextFontSize = 20;
static CGFloat const kProfileExpiryDateLabelTextFontSize = 17;
static CGFloat const KProfileValidThruLabelTextFontSize = 6;
static NSString* const kExpiryDateLabelTextFontName = @"PFDinTextCondPro-Medium";
static NSString* const kValidThruLabelTextFontName = @"SanFranciscoDisplay-Regular";
static NSString* const kClubNumberLabelTextFontName = @"OCRA";
static NSString* const kCardImageName = @"profile_card";
static NSString* const kValidThruLabelText = @"VALID\nTHRU";

@implementation PRAeroflotProfileCardCell

- (void)updateConstraints
{
    static dispatch_once_t once;

    dispatch_once(&once, ^{

        const CGFloat kScreenWidthInStoryBoard = 400;
        const CGFloat kScreenHeightInStoryBoard = 752;
        CGFloat screenCurrentWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]);
        CGFloat screenCurrentHeight = CGRectGetHeight([[UIScreen mainScreen] bounds]);

        CGFloat kCoefficentForWidth = screenCurrentWidth / kScreenWidthInStoryBoard;
        CGFloat kCoefficentForHeight = screenCurrentHeight / kScreenHeightInStoryBoard;

        _validThruLabelLeftConstraint.constant *= (kCoefficentForWidth * 2 / 3);
        _validThruLabelBottomConstraint.constant *= (kCoefficentForHeight * 3 / 4);
    });

    [super updateConstraints];
}

- (UITableViewCell<PRProfileCardDataSource>*)configureCellForUserProfile:(PRUserProfileModel*)userProfile withWidth:(CGFloat)width isWalletFeatureEnabled:(BOOL)isWalletEnabled _:(void (^)(void))onDisplayWeb
{
    NSString* firstName = userProfile.firstName;
    NSString* lastName = userProfile.lastName;
    NSString* nameSurname = [NSString stringWithFormat:@"%@ %@", firstName ?: NSLocalizedString(@"Name", ), lastName ?: NSLocalizedString(@"Surname", )];
    NSString* expiryDate = [Utils changeDateStringFormat:userProfile.expiryDate toFormat:EXPIRY_DATE_FORMAT] ?: @"";
    NSString* validThruLabelText = kValidThruLabelText;

#if defined(Otkritie)
    nameSurname = [NSString stringWithFormat:@"%@ %@", firstName ?: @"", lastName ?: @""];
    if ((!firstName || [firstName isEqualToString:@""]) || (!lastName || [lastName isEqualToString:@""])) {
        nameSurname = [nameSurname stringByReplacingOccurrencesOfString:@" " withString:@""];
    }

    if ([expiryDate isEqualToString:@""]) {
        validThruLabelText = @"";
    }
#endif

    _cardImageView.image = [UIImage imageNamed:kCardImageName];
    self.separatorInset = UIEdgeInsetsMake(0.f, width, 0.f, width);

    _profileNameLabel.font = [UIFont fontWithName:kExpiryDateLabelTextFontName size:kProfileNameLabelTextFontSize];
    _profileNameLabel.text = nameSurname;

    _clubNumber.font = [UIFont fontWithName:kClubNumberLabelTextFontName size:kProfileCardNumberTextFontSize];
    _clubNumber.text = userProfile.clubCard ? [NSMutableString stringWithString:userProfile.clubCard] : @"";

    _profileExpiryDateLabel.font = [UIFont fontWithName:kExpiryDateLabelTextFontName size:kProfileExpiryDateLabelTextFontSize];
    _profileExpiryDateLabel.text = expiryDate;

    _profileValidThruLabel.font = [UIFont fontWithName:kValidThruLabelTextFontName size:KProfileValidThruLabelTextFontSize];
    _profileValidThruLabel.numberOfLines = 2;
    _profileValidThruLabel.text = validThruLabelText;

    NSString* phone = [Utils applyFormatForFormattedString:userProfile.phone];
    _phoneLabel.font = [UIFont fontWithName:kExpiryDateLabelTextFontName size:kProfileNameLabelTextFontSize];
    _phoneLabel.text = userProfile.phone ? phone : @"";

    return self;
}

@end
