//
//  LocationPreviewViewController.m
//  PRIME
//
//  Created by Armen on 5/20/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import "LocationPreviewViewController.h"
#import "PRMessageProcessingManager.h"
@import MapKit;

@interface LocationPreviewViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapKitBottomLayout;

@property (assign, nonatomic) BOOL isMapViewMode;

@end

@implementation LocationPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [_backButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [_sendButton setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];
    [_mapView setCenterCoordinate:_coordinate];
    [_mapView setRegion:MKCoordinateRegionMakeWithDistance(_coordinate, 200, 100)];
    MKPointAnnotation *annotation = [MKPointAnnotation new];
    [annotation setCoordinate:_coordinate];
    [_mapView addAnnotation:annotation];
    if(_isMapViewMode)
    {
        [_backButton setHidden:YES];
        [_sendButton setHidden:YES];
        [_mapKitBottomLayout setConstant:0];
        [_mapView updateConstraintsIfNeeded];
    }
}

- (IBAction)backAction:(UIButton *)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)sendAction:(UIButton *)sender
{
    MKMapSnapshotOptions *snapshotOptions = [MKMapSnapshotOptions new];
    [snapshotOptions setRegion:MKCoordinateRegionMakeWithDistance(_coordinate, 200, 100)];
    [snapshotOptions setSize:CGSizeMake(450, 225)];
    MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:snapshotOptions];
    __weak LocationPreviewViewController *weekSelf = self;
    [snapshotter startWithCompletionHandler:^(MKMapSnapshot * _Nullable snapshot, NSError * _Nullable error) {
        LocationPreviewViewController *strongSelf = weekSelf;
        if(!strongSelf)
        {
            return;
        }
        if([snapshot image])
        {
            UIImage *snapshotImage = [snapshot image];
            MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:nil];
            UIGraphicsBeginImageContext([snapshotImage size]);
            [snapshotImage drawAtPoint:CGPointZero];
            CGPoint point = [snapshot pointForCoordinate:[strongSelf coordinate]];
            point.x = point.x + [pin centerOffset].x - [pin bounds].size.width / 2;
            point.y = point.y + [pin centerOffset].y - [pin bounds].size.height / 2;
            [[pin image] drawAtPoint:point];
            UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            NSMutableDictionary* messageDictionary = [NSMutableDictionary new];
            CLLocationCoordinate2D coords = [strongSelf coordinate];

            [messageDictionary setValue:[NSNumber numberWithDouble:coords.longitude] forKey:kLocationMessageLongitudeKey];
            [messageDictionary setValue:[NSNumber numberWithDouble:coords.latitude] forKey:kLocationMessageLatitudeKey];

            NSString* base64Image =  UIImageJPEGRepresentation(finalImage, 0.6).base64Encoding;
            [messageDictionary setValue:base64Image forKey:kLocationMessageSnapshotKey];

            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:messageDictionary options:(NSJSONWritingOptions) 0 error:nil];

            if(_chatViewControllerProtocolResponder && [_chatViewControllerProtocolResponder respondsToSelector:@selector(currentChatIdWithPrefix)] && [_chatViewControllerProtocolResponder respondsToSelector:@selector(addMessage:)])
            {
                PRMessageModel* messageModel = [PRMessageProcessingManager sendMediaMessage:jsonData
                                                                                   mimeType:kLocationMessageMimeType
                                                                                messageType:kMessageType_Location
                                                                            toChannelWithID:[_chatViewControllerProtocolResponder currentChatIdWithPrefix]
                                                                                    success:^(PRMediaMessageModel *mediaMessageModel) {}
                                                                                    failure:^(NSInteger statusCode, NSError *error) {}];
                messageModel = [messageModel MR_inThreadContext];
                [strongSelf.chatViewControllerProtocolResponder addMessage:messageModel];
            }
            [strongSelf dismissModalViewControllerAnimated:YES];
        }
    }];
}

- (void)setMapViewMode:(BOOL)isMapViewMode;
{
    _isMapViewMode = isMapViewMode;
}

@end
