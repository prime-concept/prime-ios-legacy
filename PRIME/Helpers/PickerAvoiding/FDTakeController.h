//
//  FDTakeController.h
//  FDTakeExample
//
//  Created by Will Entriken on 8/9/12.
//  Copyright (c) 2012 William Entriken. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FDTakeController;

@protocol FDTakeDelegate <NSObject>

@optional
/**
 * Delegate method after the user has started a take operation but cancelled it.
 */
- (void)takeController:(FDTakeController*)controller didCancelAfterAttempting:(BOOL)madeAttempt;

/**
 * Delegate method after the user has started a take operation but it failed.
 */
- (void)takeController:(FDTakeController*)controller didFailAfterAttempting:(BOOL)madeAttempt;

/**
 * Delegate method after the user has successfully taken or selected a photo.
 */
- (void)takeController:(FDTakeController*)controller gotPhoto:(UIImage*)photo withInfo:(NSDictionary*)info;
@end

@interface FDTakeController : NSObject <UIImagePickerControllerDelegate>

/**
 * The delegate to receive updates from FDTake.
 */
@property (nonatomic, weak) id<FDTakeDelegate> delegate;

/**
 * Parent View Controller which is used to present UIImagePickerController in it.
 * Default value is [UIApplication sharedApplication].keyWindow.rootViewController.
 */
@property (nonatomic, weak) UIViewController* viewControllerForPresentingImagePickerController;

/**
 * Whether to allow editing the photo.
 */
@property (nonatomic, assign) BOOL allowsEditingPhoto;

/**
 * Selfie mode.
 */
@property (nonatomic, assign) BOOL defaultToFrontCamera;

// Set these strings for custom action sheet button titles.
/**
 * Custom UI text (skips localization).
 */
@property (nonatomic, copy) NSString* takePhotoText;

/**
 * Custom UI text (skips localization).
 */
@property (nonatomic, copy) NSString* chooseFromLibraryText;

/**
 * Custom UI text (skips localization).
 */
@property (nonatomic, copy) NSString* chooseFromPhotoRollText;

/**
 * Custom UI text (skips localization).
 */
@property (nonatomic, copy) NSString* cancelText;

/**
 * Custom UI text (skips localization).
 */
@property (nonatomic, copy) NSString* noSourcesText;

/**
 * Presents the user with an option to take a photo or choose a photo from the library.
 */
- (void)takePhotoOrChooseFromLibrary;

/**
 * Dismiss at any moment.
 */
- (void)dismiss;

@end
