//
//  CustomActionSheetViewController.h
//  PRIME
//
//  Created by Artak on 2/14/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomActionSheetViewController;

@protocol SelectionViewControllerDelegate <NSObject>

@optional
- (void)selectionViewControllerDidDoneFor:(CustomActionSheetViewController*)sheet;
- (void)selectionViewControllerDidCancelFor:(CustomActionSheetViewController*)sheet;

@end

@interface CustomActionSheetViewController : UIViewController

@property (nonatomic, strong) UIView* picker;

@property (nonatomic, assign) BOOL shouldDisableSelectButton;

@property (nonatomic, strong, readonly) UILabel* titleLabel;

@property (assign, nonatomic) BOOL backgroundTapsDisabled;

@property (nonatomic, strong) NSLayoutConstraint* pickerHeightConstraint;

@property (nonatomic, assign, readwrite) UIStatusBarStyle preferredStatusBarStyle;

@property (strong, nonatomic) UIColor* tintColor;

@property (strong, nonatomic) UIColor* backgroundColor;

@property (strong, nonatomic) UIColor* selectedBackgroundColor;

@property (assign, nonatomic) BOOL disableMotionEffects;

@property (assign, nonatomic) BOOL disableBouncingWhenShowing;

@property (assign, nonatomic) BOOL disableBlurEffects;

@property (assign, nonatomic) UIBlurEffectStyle blurEffectStyle;

- (void)show;

- (void)dismiss;

+ (void)setLocalizedTitleForCancelButton:(NSString*)newLocalizedTitle;

+ (void)setLocalizedTitleForSelectButton:(NSString*)newLocalizedTitle;

@property (weak) id<SelectionViewControllerDelegate> delegate;
@end
