//
//  ProfileImageCell.h
//  PRIME
//
//  Created by Artak on 2/2/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>
@import SafariServices;

@protocol PRProfileCardDataSource
- (UITableViewCell<PRProfileCardDataSource>*)configureCellForUserProfile:(PRUserProfileModel*)userProfile withWidth:(CGFloat)width isWalletFeatureEnabled:(BOOL)isWalletEnabled _:(void (^)(void))onDisplayWeb;

@end

@interface ProfileImageCell : UITableViewCell <PRProfileCardDataSource>

@property (weak, nonatomic) IBOutlet UIImageView* cardImageView;
@property (weak, nonatomic) IBOutlet UIImageView* profileImageView;
@property (weak, nonatomic) IBOutlet UILabel* profileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel* clubNumber;
@property (weak, nonatomic) IBOutlet UILabel* profileValidThruLabel;
@property (weak, nonatomic) IBOutlet UILabel* profileExpiryDateLabel;
@property (weak, nonatomic) IBOutlet UILabel* phoneLabel;
@property (weak, nonatomic) IBOutlet UIButton* receiveVirtualCardButton;

@end
