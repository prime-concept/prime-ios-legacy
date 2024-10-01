//
//  ContactPreSendViewController.h
//  PRIME
//
//  Created by Armen on 5/16/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatViewController.h"
@import Contacts;

NS_ASSUME_NONNULL_BEGIN

@interface ContactPreSendViewController : UIViewController

@property (nonatomic, weak, nullable) id <ChatViewControllerProtocol> chatViewControllerProtocolResponder;

- (void)setContact:(CNContact * _Nonnull)contact;

@end

NS_ASSUME_NONNULL_END
