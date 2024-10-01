//
//  PhotoPreSendViewController.h
//  PRIME
//
//  Created by armens on 4/16/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface PhotoPreSendViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *previewPhotoView;
@property (weak, nonatomic) IBOutlet UIImageView *photoBackground;
@property (strong, nonatomic) UIImagePickerController* picker;
@property (strong, nonatomic) ChatViewController* chatViewController;
@property (strong, nonatomic) UIImage* selectedPhoto;
@property (assign, nonatomic, setter=setVideoMode:) BOOL isVideoMode;
@property (strong, nonatomic) NSURL* selectedVideoURL;

- (IBAction)sendAcion:(id)sender;
- (IBAction)backToGaleryAction:(id)sender;

@end

NS_ASSUME_NONNULL_END
