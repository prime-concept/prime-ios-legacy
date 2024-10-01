//
//  ProfileImageCell.m
//  PRIME
//
//  Created by Artak on 2/2/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "Constants.h"
#import "NBPhoneNumberUtil.h"
#import "ProfileImageCell.h"
#import "XNAvatar.h"
#import "Utils.h"

@interface ProfileImageCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint* profileImageLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* profileNameLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* profileImageTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* profileImageHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* profileValidThruLabelLeftConstraint;

@property (strong, nonatomic) UIImageView* aClubProfileImageView;
@property (strong, nonatomic) UILabel* aClubProfileNameLabel;
@property (strong, nonatomic) UILabel* aClubClubNumber;
@property (strong, nonatomic) UILabel* aClubProfileValidThruLabel;
@property (strong, nonatomic) UILabel* aClubProfileExpiryDateLabel;
@property (strong, nonatomic) UILabel* aClubPhoneLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint* cardImageViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* receiveButtonTopConstraint;
@property (strong, nonatomic) void (^displayWeb)(void);

@end

@implementation ProfileImageCell

#if defined(PrimeClubConcierge)
static CGFloat const kProfileNameLabelFontSize = 16;
static CGFloat const kProfileExpiryDateLabelFontSize = 14;
static CGFloat const KProfileValidThruLabelFontSize = 4;
#else
static CGFloat const kProfileNameLabelFontSize = 17.5;
static CGFloat const kProfileExpiryDateLabelFontSize = 13.5;
static CGFloat const KProfileValidThruLabelFontSize = 5;
#endif

static CGFloat const kReceiveVirtualCardButtonTitleTextFontSize = 15;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)updateConstraints
{
    static dispatch_once_t once;

    dispatch_once(&once, ^{

        const CGFloat kScreenWidthInStoryBoard = 375;
        CGFloat screenCurrentWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]);

        CGFloat kCoefficent = screenCurrentWidth / kScreenWidthInStoryBoard;
        CGFloat imageSize = kCoefficent * 75;

#if defined(Raiffeisen) || defined(VTB24)
        _profileImageTopConstraint.constant = 40;
#elif defined(PrivateBankingPRIMEClub)
        _profileImageTopConstraint.constant = 50;
#elif defined(PrimeClubConcierge)
        _profileImageTopConstraint.constant = 80;
        imageSize = kCoefficent * 53;
#endif

        _profileImageView.layer.cornerRadius = imageSize / 2;

        _profileImageHeightConstraint.constant = imageSize;
        _profileImageLeftConstraint.constant = kCoefficent * _profileImageLeftConstraint.constant;
        _profileImageTopConstraint.constant = kCoefficent * _profileImageTopConstraint.constant;
        _profileNameLabelTopConstraint.constant = (kCoefficent * _profileNameLabelTopConstraint.constant) - 10;
    });

    [super updateConstraints];
}

- (UITableViewCell<PRProfileCardDataSource>*)configureCellForUserProfile:(PRUserProfileModel*)userProfile
															   withWidth:(CGFloat)width
												  isWalletFeatureEnabled:(BOOL)isWalletEnabled
																	   _:(void (^)(void))onDisplayWeb
{
    _cardImageView.image = [UIImage imageNamed:@"profile_card"];
    self.separatorInset = UIEdgeInsetsMake(0.f, width, 0.f, width);

#if defined(PrivateBankingPRIMEClub) || defined(PrimeRRClub) || defined(Davidoff)
    [_profileImageView setHidden:YES];
#else
    UIImage* profileImage = [XNAvatar image];
    [_profileImageView setImage:profileImage ? profileImage : [UIImage imageNamed:@"profileImage"]];
    _profileImageView.clipsToBounds = YES;
    _profileImageView.contentMode = UIViewContentModeScaleAspectFill;
#endif

    [_profileNameLabel setTextColor:kProfileImageTextColor];
    _profileNameLabel.text = [NSString stringWithFormat:@"%@ %@", userProfile.firstName ?: NSLocalizedString(@"Name", ), userProfile.lastName ?: NSLocalizedString(@"Surname", )];

    [_clubNumber setTextColor:kProfileImageTextColor];
    _clubNumber.text = userProfile.clubCard ? [NSMutableString stringWithString:userProfile.clubCard] : @"";

    [_profileExpiryDateLabel setTextColor:kProfileImageTextColor];
	_profileExpiryDateLabel.text = [Utils changeDateStringFormat:userProfile.expiryDate toFormat:EXPIRY_DATE_FORMAT];

    _profileValidThruLabel.numberOfLines = 2;
	[_profileValidThruLabel setTextColor:kProfileImageTextColor];
    _profileValidThruLabel.text = @"VALID\nTHRU";

	_profileValidThruLabel.hidden = _profileExpiryDateLabel.text.length == 0;
	_profileExpiryDateLabel.hidden = _profileValidThruLabel.hidden;

	NSString* phone = [Utils applyFormatForFormattedString:userProfile.phone];
	[_phoneLabel setTextColor:kProfileImageTextColor];
	_phoneLabel.text = userProfile.phone ? phone : @"";

	if ([_clubNumber.text isEqualToString:@""]) {
		_profileValidThruLabelLeftConstraint.constant = 0;
	}

#if defined(PrimeClubConcierge)
	_profileNameLabel.font = [UIFont systemFontOfSize:kProfileNameLabelFontSize];
	_profileExpiryDateLabel.font = [UIFont systemFontOfSize:kProfileExpiryDateLabelFontSize weight:UIFontWeightLight];
	_clubNumber.font = [UIFont systemFontOfSize:kProfileExpiryDateLabelFontSize weight:UIFontWeightLight];
	_profileValidThruLabel.font = [UIFont systemFontOfSize:KProfileValidThruLabelFontSize weight:UIFontWeightLight];
	_phoneLabel.font = [UIFont systemFontOfSize:kProfileExpiryDateLabelFontSize weight:UIFontWeightLight];
#else
	_profileNameLabel.font = [UIFont systemFontOfSize:kProfileNameLabelFontSize];
	_profileExpiryDateLabel.font = [UIFont systemFontOfSize:kProfileExpiryDateLabelFontSize weight:UIFontWeightUltraLight];
	_clubNumber.font = [UIFont systemFontOfSize:kProfileExpiryDateLabelFontSize weight:UIFontWeightUltraLight];
	_profileValidThruLabel.font = [UIFont systemFontOfSize:KProfileValidThruLabelFontSize weight:UIFontWeightUltraLight];
	_phoneLabel.font = [UIFont systemFontOfSize:kProfileExpiryDateLabelFontSize weight:UIFontWeightUltraLight];
#endif

#if defined(Prime) || defined(PrimeClubConcierge)
    if (isWalletEnabled) {
        [_receiveVirtualCardButton setHidden:NO];
        [_receiveButtonTopConstraint setActive:YES];
        [_cardImageViewBottomConstraint setActive:NO];
        [_receiveVirtualCardButton.titleLabel setFont:[UIFont systemFontOfSize:kReceiveVirtualCardButtonTitleTextFontSize weight:UIFontWeightMedium]];
        [_receiveVirtualCardButton setTitle:NSLocalizedString(@"Get a virtual card", nil) forState:UIControlStateNormal];
        _receiveVirtualCardButton.layer.cornerRadius = 10;
        [_receiveVirtualCardButton setBackgroundColor:kReceiveVirtualCardBackgroundColor];
        [_receiveVirtualCardButton setTitleColor:kReceiveVirtualCardTitleTextColor forState:UIControlStateNormal];
        _displayWeb = onDisplayWeb;
    }
#endif

#if defined(PrimeClubConcierge)
    [_profileValidThruLabel setHidden:YES];
	[self switchToAClubViews];
#endif

    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];

	#if defined(PrimeClubConcierge)
	[self layoutAClub];
	#endif
}

- (void)switchToAClubViews {
	self.profileImageView.hidden = YES;
	self.aClubProfileImageView = self.aClubProfileImageView ?: [UIImageView new];

	[self.aClubProfileImageView removeFromSuperview];
	self.aClubProfileImageView.image = self.profileImageView.image;
	self.aClubProfileImageView.contentMode = self.profileImageView.contentMode;
	[self.contentView addSubview:self.aClubProfileImageView];

	self.aClubProfileNameLabel = self.aClubProfileNameLabel ?: UILabel.new;
	self.aClubClubNumber = self.aClubClubNumber ?: UILabel.new;
	self.aClubProfileValidThruLabel = self.aClubProfileValidThruLabel ?: UILabel.new;
	self.aClubProfileExpiryDateLabel = self.aClubProfileExpiryDateLabel ?: UILabel.new;
	self.aClubPhoneLabel = self.aClubPhoneLabel ?:  UILabel.new;

	[self replace:self.profileNameLabel with:self.aClubProfileNameLabel];
	[self replace:self.clubNumber with:self.aClubClubNumber];
	[self replace:self.profileValidThruLabel with:self.aClubProfileValidThruLabel];
	[self replace:self.profileExpiryDateLabel with:self.aClubProfileExpiryDateLabel];
	[self replace:self.phoneLabel with:self.aClubPhoneLabel];
}

-(void)replace:(UILabel *)label with:(UILabel *)otherLabel {
	label.hidden = YES;

	if (otherLabel.superview != self.contentView) {
		[otherLabel removeFromSuperview];
		[self.contentView addSubview:otherLabel];
	}

	otherLabel.font = label.font;
	otherLabel.text = label.text;
	otherLabel.textColor = label.textColor;
	otherLabel.textAlignment = label.textAlignment;
	otherLabel.numberOfLines = label.numberOfLines;
}

-(void)layoutAClub {
	CGRect profileImageFrame = CGRectMake(36, 135, 53, 53);
	self.aClubProfileImageView.frame = profileImageFrame;

	[self.aClubProfileNameLabel sizeToFit];
	CGSize profileNameSize = self.aClubProfileNameLabel.bounds.size;
	self.aClubProfileNameLabel.frame = CGRectMake(CGRectGetMaxX(profileImageFrame) + 22,
												  profileImageFrame.origin.y + 6,
												  profileNameSize.width,
												  profileNameSize.height);

//	[self.aClubPhoneLabel sizeToFit];
//	CGSize aClubPhoneLabelSize = self.aClubPhoneLabel.bounds.size;
//	self.aClubPhoneLabel.frame = CGRectMake(CGRectGetMaxX(profileImageFrame) + 22,
//											CGRectGetMaxY(self.aClubProfileNameLabel.frame) + 6,
//										    aClubPhoneLabelSize.width,
//										    aClubPhoneLabelSize.height);

	[self.aClubClubNumber sizeToFit];
	CGSize clubNumberSize = self.aClubClubNumber.bounds.size;
	self.aClubClubNumber.frame = CGRectMake(CGRectGetMaxX(profileImageFrame) + 22,
											CGRectGetMaxY(self.aClubProfileNameLabel.frame) + 4,
											clubNumberSize.width,
											clubNumberSize.height);

	[self.aClubProfileValidThruLabel sizeToFit];
	CGSize profileValidThruSize = self.aClubProfileValidThruLabel.bounds.size;
	self.aClubProfileValidThruLabel.frame = CGRectMake(CGRectGetMaxX(self.aClubClubNumber.frame) + 22,
													   CGRectGetMaxY(self.aClubClubNumber.frame) - profileValidThruSize.height - 2,
													   profileValidThruSize.width,
													   profileValidThruSize.height);

	[self.aClubProfileExpiryDateLabel sizeToFit];
	CGSize profileExpiryDateSize = self.aClubProfileExpiryDateLabel.bounds.size;
	self.aClubProfileExpiryDateLabel.frame = CGRectMake(CGRectGetMaxX(self.aClubProfileValidThruLabel.frame) + 3,
														CGRectGetMaxY(self.aClubProfileValidThruLabel.frame) - profileExpiryDateSize.height + 2,
														profileExpiryDateSize.width,
														profileExpiryDateSize.height);

	self.aClubProfileExpiryDateLabel.hidden = self.aClubProfileExpiryDateLabel.text.length == 0;
	self.aClubProfileValidThruLabel.hidden = self.aClubProfileExpiryDateLabel.hidden;
}

- (IBAction)didTapOnReceiveCardButton:(UIButton *)sender {
    _displayWeb();
}

@end
