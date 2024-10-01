//
//  MyProfileTableHeaderView.m
//  PRIME
//
//  Created by Mariam on 1/19/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRMyProfileTableHeaderView.h"
#import "PRDatabase.h"
#import "XNAvatar.h"
#import "FDTakeController.h"

@interface PRMyProfileTableHeaderView () <FDTakeDelegate,UIGestureRecognizerDelegate>

@property (strong, nonatomic) FDTakeController* takeController;

@property (weak, nonatomic) IBOutlet UIImageView* imageViewProfile;
@property (weak, nonatomic) IBOutlet UILabel* labelName;
@property (weak, nonatomic) IBOutlet UIButton* buttonCorrection;

@end

@implementation PRMyProfileTableHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self configureView];
    [self setupTakeController];
}

- (void)dealloc
{
    [_takeController dismiss];
}

- (void)updateProfileAvatar:(UIImage*)image
{
    _imageViewProfile.image = image;
}

#pragma mark - FDTakeDelegate

- (void)takeController:(FDTakeController*)controller
              gotPhoto:(UIImage*)photo
              withInfo:(NSDictionary*)info
{
    photo = [self thumbnailFromImage:photo];
    _imageViewProfile.image = photo;
    [XNAvatar setImage:photo];
}

#pragma mark - Actions

- (IBAction)correctionAction:(UIButton*)sender
{
    [PRGoogleAnalyticsManager sendEventWithName:kMyProfileImageCorrectionButtonClicked parameters:nil];
    [_takeController takePhotoOrChooseFromLibrary];
}

#pragma mark - Private Methods

- (UIImage*)thumbnailFromImage:(UIImage*)image
{

    CGFloat aspectRatio = image.size.width / image.size.height;
    CGRect imageRect = CGRectMake(0, 0, 800 * aspectRatio, 800);

    UIGraphicsBeginImageContext(imageRect.size);

    [image drawInRect:imageRect];

    UIImage* thumbnail = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return thumbnail;
}

- (void)setupTakeController
{
    _takeController = [[FDTakeController alloc] init];
    _takeController.delegate = self;
}

- (void)configureView
{

    PRUserProfileModel* userProfile = [PRDatabase getUserProfile];

    _imageViewProfile.layer.cornerRadius = CGRectGetWidth(_imageViewProfile.frame) / 2;
    _imageViewProfile.layer.masksToBounds = YES;
#if defined(Platinum) || defined(PrivateBankingPRIMEClub)
    _imageViewProfile.tintColor = kTypingContainerViewColor;
#else
    _imageViewProfile.tintColor = kIconsColor;
#endif

    _imageViewProfile.contentMode = UIViewContentModeScaleAspectFill;

    [_buttonCorrection setTitle:NSLocalizedString(@"correction", nil) forState:UIControlStateNormal];

    _labelName.text = [NSString stringWithFormat:@"%@ %@", userProfile.firstName ?: NSLocalizedString(@"Name", ),
                                userProfile.lastName ?: NSLocalizedString(@"Surname", )];

#if defined(PrimeClubConcierge)
    [self updateProfileAvatar:[XNAvatar image] ?: [UIImage imageNamed:@"profile_Image"]];
#else
    [self updateProfileAvatar:[XNAvatar image] ?: [[UIImage imageNamed:@"profileImage"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
#endif

#if defined(Otkritie)
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(correctionAction:)];
    _imageViewProfile.userInteractionEnabled = YES;
    gesture.delegate = self;
    [_imageViewProfile addGestureRecognizer:gesture];
#endif
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint  touchPoint = [touch locationInView:_imageViewProfile];
    if (CGRectContainsPoint(_imageViewProfile.bounds, touchPoint))
    {
        CGFloat centerX = CGRectGetMidX(_imageViewProfile.bounds);
        CGFloat centerY = CGRectGetMidY(_imageViewProfile.bounds);
        CGFloat maxPow = pow((touchPoint.x -centerX),2)+ pow((touchPoint.y - centerY), 2);
        if (maxPow < pow(CGRectGetWidth(_imageViewProfile.frame)/2, 2))
        {
            return YES;
        }
    }
    return NO;
}

@end
