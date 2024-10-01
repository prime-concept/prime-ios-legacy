//
//  ProfileMainDataSource.h
//  PRIME
//
//  Created by Artak on 2/3/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ProfileImageCell.h>

#define isEnableCarFeature [PRDatabase isUserProfileFeatureEnabled:ProfileFeature_Car]
#define isEnableWalletFeature [PRDatabase isUserProfileFeatureEnabled:ProfileFeature_Wallet]

NS_ENUM(NSInteger, ProfileMainSectionRow){
    ProfileMainSectionRow_ProfileCard,
    ProfileMainSectionRow_MyProfile,
    ProfileMainSectionRow_MyCards,
    ProfileMainSectionRow_MyCars,
    ProfileMainSectionRow_Finances,
    ProfileMainSectionRow_Count,
};

NS_ENUM(NSInteger, ProfileAdditionalSectionRow){
    ProfileAdditionalSectionRow_Club,
    ProfileAdditionalSectionRow_Reference,
    ProfileAdditionalSectionRow_Delete,
    ProfileAdditionalSectionRow_Password,
    ProfileAdditionalSectionRow_Count,
};

NS_ENUM(NSInteger, ProfileInfoSections){
    ProfileInfoSections_Main,
    ProfileInfoSections_Additional,
    ProfileInfoSections_PondMobile,
    ProfileInfoSections_Count,
};

@interface ProfileMainDataSource : NSObject <UITableViewDataSource>
@property (strong, nonatomic) PRUserProfileModel* userProfile;
@property void (^displayWeb)(void);
@end
