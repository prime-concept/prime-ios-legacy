//
//  DocumentPreviewViewController.h
//  PRIME
//
//  Created by Armen on 6/13/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface DocumentPreviewViewController : UIViewController

@property (strong, nonatomic) NSURL* fileURL;
@property(strong, nonatomic) NSString* documentDownloadingPath;
@property (nonatomic, weak, nullable) id <ChatViewControllerProtocol> chatViewControllerProtocolResponder;
@property (assign, nonatomic, setter = setSendingMode:) BOOL isSendingMode;

- (void)setFilePathWithGuid:(NSString*)guid fileName:(NSString*)fileName;

@end

NS_ASSUME_NONNULL_END
