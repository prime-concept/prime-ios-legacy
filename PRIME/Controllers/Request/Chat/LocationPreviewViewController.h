//
//  LocationPreviewViewController.h
//  PRIME
//
//  Created by Armen on 5/20/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface LocationPreviewViewController : UIViewController

@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, weak, nullable) id <ChatViewControllerProtocol> chatViewControllerProtocolResponder;

- (void)setMapViewMode:(BOOL)isMapViewMode;

@end

NS_ASSUME_NONNULL_END
