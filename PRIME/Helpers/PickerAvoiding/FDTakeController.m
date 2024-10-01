
//
//  FDTakeController.m
//  FDTakeExample
//
//  Created by Will Entriken on 8/9/12.
//  Copyright (c) 2012 William Entriken. All rights reserved.
//

#import "FDTakeController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "Photos/Photos.h"

static NSString* const kTakePhotoKey = @"takePhoto";
static NSString* const kChooseFromLibraryKey = @"chooseFromLibrary";
static NSString* const kChooseFromPhotoRollKey = @"chooseFromPhotoRoll";
static NSString* const kCancelKey = @"cancel";
static NSString* const kNoSourcesKey = @"noSources";
static NSString* const kStringsTableName = @"Localizable";

@interface FDTakeController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) NSMutableArray* sources;
@property (strong, nonatomic) NSMutableArray* buttonTitles;
@property (strong, nonatomic) UIPopoverController* popover;
@property (strong, nonatomic) UIAlertController* alertController;
@property (strong, nonatomic) UIImagePickerController* imagePicker;

@end

@implementation FDTakeController

- (NSMutableArray*)sources
{
    if (!_sources) {
        _sources = [[NSMutableArray alloc] init];
    }
    return _sources;
}

- (NSMutableArray*)buttonTitles
{
    if (!_buttonTitles) {
        _buttonTitles = [[NSMutableArray alloc] init];
    }
    return _buttonTitles;
}

- (UIImagePickerController*)imagePicker
{
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
        _imagePicker.allowsEditing = YES;
    }
    return _imagePicker;
}

- (UIPopoverController*)popover
{
    if (!_popover) {
        _popover = [[UIPopoverController alloc] initWithContentViewController:self.imagePicker];
    }
    return _popover;
}

- (void)takePhotoOrChooseFromLibrary
{
    self.sources = nil;
    self.buttonTitles = nil;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self.sources addObject:[NSNumber numberWithInteger:UIImagePickerControllerSourceTypeCamera]];
        [self.buttonTitles addObject:[self textForButtonWithTitle:kTakePhotoKey]];
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [self.sources addObject:[NSNumber numberWithInteger:UIImagePickerControllerSourceTypePhotoLibrary]];
        [self.buttonTitles addObject:[self textForButtonWithTitle:kChooseFromLibraryKey]];
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        [self.sources addObject:[NSNumber numberWithInteger:UIImagePickerControllerSourceTypeSavedPhotosAlbum]];
        [self.buttonTitles addObject:[self textForButtonWithTitle:kChooseFromPhotoRollKey]];
    }
    [self setUpAlertController];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{

    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;

    // Handle a still image capture.
    if (CFStringCompare((CFStringRef)mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {

        editedImage = (UIImage*)[info objectForKey:
                                          UIImagePickerControllerEditedImage];
        originalImage = (UIImage*)[info objectForKey:
                                            UIImagePickerControllerOriginalImage];

        if (editedImage) {
            imageToSave = editedImage;
        } else if (originalImage) {
            imageToSave = originalImage;
        } else {
            if ([self.delegate respondsToSelector:@selector(takeController:didFailAfterAttempting:)]) {
                [self.delegate takeController:self didFailAfterAttempting:YES];
            }
            return;
        }

        if ([self.delegate respondsToSelector:@selector(takeController:gotPhoto:withInfo:)]) {
            [self.delegate takeController:self gotPhoto:imageToSave withInfo:info];
        }
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [self.popover dismissPopoverAnimated:YES];
        }
    }

    [picker dismissViewControllerAnimated:YES completion:nil];
    self.imagePicker = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController*)picker
{

    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.imagePicker = nil;

    if ([self.delegate respondsToSelector:@selector(takeController:didCancelAfterAttempting:)]) {
        [self.delegate takeController:self didCancelAfterAttempting:YES];
    }
}

#pragma mark - Private methods

- (UIViewController*)presentingViewController
{
    // Use optional view controller for presenting the image picker if set.
    UIViewController* presentingViewController = nil;
    if (self.viewControllerForPresentingImagePickerController != nil) {
        presentingViewController = self.viewControllerForPresentingImagePickerController;
    } else {
        // Otherwise do this stuff (like in original source code).
        presentingViewController = [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
    }
    return presentingViewController;
}

//Added by me
- (UIViewController*)topViewController:(UIViewController*)rootViewController
{
    if (rootViewController.presentedViewController == nil) {
        return rootViewController;
    }

    if ([rootViewController.presentedViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController.presentedViewController;
        UIViewController* lastViewController = [[navigationController viewControllers] lastObject];
        return [self topViewController:lastViewController];
    }

    UIViewController* presentedViewController = (UIViewController*)rootViewController.presentedViewController;
    return [self topViewController:presentedViewController];
}

- (void)dismiss
{
    if (self.alertController) {
        [self.alertController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)setUpAlertController
{
    if ([self.sources count]) {
        self.alertController = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
        [self.alertController addAction:[UIAlertAction actionWithTitle:[self textForButtonWithTitle:kCancelKey]
                                                                 style:UIAlertActionStyleCancel
                                                               handler:^(UIAlertAction* action) {
                                                                   [self cancelButtonTapped];
                                                               }]];
        for (NSInteger index = 0; index < self.buttonTitles.count; index++) {
            NSString* title = [self.buttonTitles objectAtIndex:index];
            NSNumber* sourceType = [self.sources objectAtIndex:index];
            [self.alertController addAction:[UIAlertAction actionWithTitle:title
                                                                     style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction* action) {
                                                                       [self sourceTypeButtonTapped:sourceType];
                                                                   }]];
        }
    } else {
        self.alertController = [UIAlertController alertControllerWithTitle:nil
                                                                   message:[self textForButtonWithTitle:kNoSourcesKey]
                                                            preferredStyle:UIAlertControllerStyleAlert];

        [self.alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction* action) {
                                                                   [self cancelButtonTapped];
                                                               }]];
    }
    [[self presentingViewController] presentViewController:self.alertController animated:YES completion:nil];
}

- (void)sourceTypeButtonTapped:(NSNumber*)sourceType
{
    self.imagePicker.sourceType = [sourceType integerValue];

    if (![self checkAuthorizationStatusForMediaType:self.imagePicker.sourceType]) {
        return;
    }

    if ((self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera)) {
        if (self.defaultToFrontCamera && [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            [self.imagePicker setCameraDevice:UIImagePickerControllerCameraDeviceFront];
        }
    }

    self.imagePicker.allowsEditing = self.allowsEditingPhoto;
    self.imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString*)kUTTypeImage, nil];
    self.imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
    [[self presentingViewController] presentViewController:self.imagePicker animated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)cancelButtonTapped
{
    if ([self.delegate respondsToSelector:@selector(takeController:didCancelAfterAttempting:)]) {
        [self.delegate takeController:self didCancelAfterAttempting:NO];
    }
}

// This is a hack required on iPad if you want to select a photo and you already have a popup on the screen
// see: http://stackoverflow.com/questions/11748845/present-more-than-one-modalview-in-appdelegate
- (UIViewController*)_topViewController:(UIViewController*)rootViewController
{
    if (rootViewController.presentedViewController == nil) {
        return rootViewController;
    }

    if ([rootViewController.presentedViewController isMemberOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController.presentedViewController;
        UIViewController* lastViewController = [[navigationController viewControllers] lastObject];
        return [self _topViewController:lastViewController];
    }

    UIViewController* presentedViewController = (UIViewController*)rootViewController.presentedViewController;
    return [self _topViewController:presentedViewController];
}

- (NSString*)textForButtonWithTitle:(NSString*)title
{
    if ([title isEqualToString:kTakePhotoKey]) {
        return NSLocalizedString(@"Take photo", nil);
    } else if ([title isEqualToString:kChooseFromLibraryKey]) {
        return NSLocalizedString(@"Choose from library", nil);
    } else if ([title isEqualToString:kChooseFromPhotoRollKey]) {
        return self.chooseFromPhotoRollText ?: NSLocalizedStringFromTable(kChooseFromPhotoRollKey, kStringsTableName, @"Option to select photo from photo roll");
    } else if ([title isEqualToString:kCancelKey]) {
        return NSLocalizedString(@"Cancel", nil);
    } else if ([title isEqualToString:kNoSourcesKey]) {
        return self.noSourcesText ?: NSLocalizedStringFromTable(kNoSourcesKey, kStringsTableName, @"There are no sources available to select a photo");
    }

    NSAssert(NO, @"Invalid title passed to textForButtonWithTitle:");

    return nil;
}

- (BOOL)checkAuthorizationStatusForMediaType:(NSInteger)sourceType
{
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
            [self presentAlertDoesNotHaveAccessTo:@"camera"];
            return NO;
        } else if (authStatus == AVAuthorizationStatusNotDetermined) {
            __weak FDTakeController* weakSelf = self;
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                                     completionHandler:^(BOOL granted) {
                                         if (!granted) { // Don't allow access.
                                             [PRGoogleAnalyticsManager sendEventWithName:kCameraPermissionDoNotAllowButtonClicked parameters:nil];
                                             [weakSelf dismissViewControllerWithName:@"CAMImagePickerCameraViewController"];
                                         }
                                         [PRGoogleAnalyticsManager sendEventWithName:kCameraPermissionAllowButtonClicked parameters:nil];
                                     }];
        }
    } else if (sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
        if (authStatus == PHAuthorizationStatusRestricted || authStatus == PHAuthorizationStatusDenied) {
            [self presentAlertDoesNotHaveAccessTo:@"photo library"];
            return NO;
        } else if (authStatus == PHAuthorizationStatusNotDetermined) {
            __weak FDTakeController* weakSelf = self;
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus authorizationStatus) {
                if (authorizationStatus == PHAuthorizationStatusDenied) { // Don't allow access.
                    [PRGoogleAnalyticsManager sendEventWithName:kPhotoLibraryPermissionDoNotAllowButtonClicked parameters:nil];
                    [weakSelf dismissViewControllerWithName:@"PLUIPrivacyViewController"];
                    return;
                }
                [PRGoogleAnalyticsManager sendEventWithName:kPhotoLibraryPermissionAllowButtonClicked parameters:nil];
            }];
        }
    }

    return YES;
}

- (void)presentAlertDoesNotHaveAccessTo:(NSString*)title
{
    NSString* alertTitle = [NSString stringWithFormat:@"This application does not have access to your %@", title];
    UIAlertController* alert = [UIAlertController
        alertControllerWithTitle:NSLocalizedString(alertTitle, nil)
                         message:NSLocalizedString(@"You can enable access in Privacy Settings", nil)
                  preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* cancelButton = [UIAlertAction
        actionWithTitle:NSLocalizedString(@"OK", nil)
                  style:UIAlertActionStyleCancel
                handler:nil];

    [alert addAction:cancelButton];
    [[self presentingViewController] presentViewController:alert animated:YES completion:nil];
}

- (void)dismissViewControllerWithName:(NSString*)name
{
    UIViewController* presentedView = [self presentingViewController];
    if ([presentedView.description containsString:name]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [presentedView dismissViewControllerAnimated:YES completion:nil];
        });
    }
}

@end
