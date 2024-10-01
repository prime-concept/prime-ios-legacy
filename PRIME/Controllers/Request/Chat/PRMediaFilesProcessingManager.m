//
//  PRMediaFilesProcessingManager.m
//  PRIME
//
//  Created by armens on 4/9/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import "PRMediaFilesProcessingManager.h"
#import "ChatViewController.h"
#import "mobilecoreservices/mobilecoreservices.h"
#import "PhotoPreSendViewController.h"
#import "LocationPreviewViewController.h"
#import "ContactPreSendViewController.h"
#import "InformationAlertController.h"
#import "DocumentPreviewViewController.h"
@import Contacts;
@import ContactsUI;

@interface PRMediaFilesProcessingManager() <UIImagePickerControllerDelegate, UINavigationControllerDelegate, CNContactPickerDelegate, CLLocationManagerDelegate, UIDocumentPickerDelegate>

@property (strong, nonatomic) UIImagePickerController* picker;
@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) UIViewController* presenter;

@end

@implementation PRMediaFilesProcessingManager

-(instancetype)initWithPresenter:(UIViewController*)presenter
{
    self = [super init];
    if(self){
        _presenter = presenter;
        _picker = [UIImagePickerController new];
        _picker.delegate = self;
    }
    return self;
}

#pragma mark - Camera,Photo & Video handling

-(void)handleCameraAction
{
    _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    NSArray *types = @[(NSString*)kUTTypeImage, (NSString*)kUTTypeMovie];
    _picker.mediaTypes = types;
    _picker.modalPresentationStyle = UIModalPresentationFullScreen;
    [_presenter presentViewController:_picker
                             animated:YES
                           completion:nil];
}

-(void)handlePhotoVideoAction
{
    _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    NSArray *types = @[(NSString*)kUTTypeMovie, (NSString*)kUTTypeVideo, (NSString*)kUTTypeImage];
    _picker.mediaTypes = types;
    _picker.modalPresentationStyle = UIModalPresentationFullScreen;
    [_presenter presentViewController:_picker
                             animated:YES
                           completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];

    PhotoPreSendViewController* photoPreview = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"PhotoPreSendViewController"];
    [photoPreview setPicker:_picker];
    [photoPreview setChatViewController:(ChatViewController*)_presenter];
    if(CFStringCompare((CFStringRef)mediaType, kUTTypeImage, 0) == kCFCompareEqualTo)
    {
        [photoPreview setVideoMode:NO];
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        [photoPreview setSelectedPhoto:image];
        _picker.modalPresentationStyle = UIModalPresentationFullScreen;
        if(_picker.sourceType == UIImagePickerControllerSourceTypeCamera)
        {
            [_picker presentModalViewController:photoPreview animated:NO];
        }
        else
            [_picker presentViewController:photoPreview animated:YES completion:nil];
    }
    else
    {
        [photoPreview setVideoMode:YES];
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        [photoPreview setSelectedVideoURL:videoURL];
        [_picker presentModalViewController:photoPreview animated:NO];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
}

#pragma mark - Document handling

-(void)handleDocumentAction
{
    NSArray *types = @[(NSString*)kUTTypeMovie, (NSString*)kUTTypeImage, (NSString*)kUTTypeSpreadsheet, (NSString*)kUTTypePDF, (NSString*)kUTTypePlainText, (NSString*)kUTTypeZipArchive, (NSString*)kUTTypeRTF, (NSString*)kUTTypeAudio, @"com.microsoft.word.doc", @"org.openxmlformats.wordprocessingml.document"];
    UIDocumentPickerViewController* documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:types
                                                                                                    inMode:UIDocumentPickerModeImport];
    [documentPicker setDelegate:self];
    documentPicker.modalPresentationStyle = UIModalPresentationFullScreen;
    [_presenter presentViewController:documentPicker
                             animated:YES
                           completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url
{
    DocumentPreviewViewController *documentPresendContoller = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"DocumentPreviewViewController"];
    [documentPresendContoller setFileURL:url];
    [documentPresendContoller setSendingMode:YES];
    [documentPresendContoller setChatViewControllerProtocolResponder:(ChatViewController*)_presenter];
    documentPresendContoller.modalPresentationStyle = UIModalPresentationFullScreen;
    [_presenter presentViewController:documentPresendContoller
                             animated:YES
                           completion:nil];
}

#pragma mark - Location handling

-(void)handleLocationAction
{
    _locationManager = [CLLocationManager new];
    [_locationManager setDelegate:self];
    [_locationManager setDistanceFilter:kCLDistanceFilterNone];
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [_locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(nonnull CLLocation *)newLocation fromLocation:(nonnull CLLocation *)oldLocation
{
    [manager stopUpdatingLocation];
    LocationPreviewViewController* locationPreview = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"LocationPreviewViewController"];
    [locationPreview setCoordinate:[newLocation coordinate]];
    [locationPreview setMapViewMode:NO];
    [locationPreview setChatViewControllerProtocolResponder:(ChatViewController*)_presenter];
    _presenter.modalPresentationStyle = UIModalPresentationFullScreen;
    [_presenter presentViewController:locationPreview
                             animated:YES
                           completion:nil];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [manager stopUpdatingLocation];
    [InformationAlertController presentAlert:_presenter
                                  alertTitle:NSLocalizedString(@"Failed to update location", nil)
                                     message:@""
                                    okAction:nil];
}

#pragma mark - Contacts handling

-(void)handleContactsAction
{
    CNContactPickerViewController* contactPickerViewController = [CNContactPickerViewController new];
    contactPickerViewController.delegate = self;
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setTintColor:kNavigationBarTintColor];
    _presenter.modalPresentationStyle = UIModalPresentationFullScreen;
    [_presenter presentViewController:contactPickerViewController
                             animated:YES
                           completion:nil];
}

- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact
{
    [picker dismissModalViewControllerAnimated:YES];
    ContactPreSendViewController* contactPreview = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ContactPreSendViewControllerIdentifier"];
    [contactPreview setContact:contact];
    [contactPreview setChatViewControllerProtocolResponder:(ChatViewController*)_presenter];
    _presenter.modalPresentationStyle = UIModalPresentationFullScreen;
    [_presenter presentViewController:contactPreview
                             animated:YES
                           completion:nil];
}

@end
