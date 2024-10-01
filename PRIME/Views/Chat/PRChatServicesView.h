//
//  PRChatServicesView.h
//  PRIME
//
//  Created by Taron on 4/27/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PRChatServicesViewState) {
    PRChatServicesViewState_Normal,
    PRChatServicesViewState_Expanded
};

@protocol PRChatServicesViewDelegate <NSObject>

@required
- (void)didSelectMenuItem:(PRServicesModel*)menuItemData;
- (void)didPressMoreButton;

@end

@interface PRChatServicesView : UIView <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) id<PRChatServicesViewDelegate> delegate;
@property (assign, nonatomic) PRChatServicesViewState state;

- (void)updateCollectionViewForItems;
- (NSInteger)heightForExpandedState;

@end
