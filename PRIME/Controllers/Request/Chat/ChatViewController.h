//
//  ChatViewController.h
//  PRIME
//
//  Created by Artak on 8/13/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "BaseViewController.h"
#import "PRUITabBarController.h"
#import "PRChatServicesView.h"

@protocol ChatViewControllerProtocol <NSObject>

@required

- (void)addMessage:(PRMessageModel*)messageModel;
- (NSString*)currentChatIdWithPrefix;

@end

@interface ChatViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, TabBarItemChanged, UIGestureRecognizerDelegate, UIActionSheetDelegate, UITextViewDelegate, CLLocationManagerDelegate, PRChatServicesViewDelegate, ChatViewControllerProtocol>

@property (nonatomic, strong) NSMutableArray<__kindof PRMessageModel*>* messages;
@property (strong, nonatomic) NSString* initialString;
@property (strong, nonatomic) NSString* chatId;

- (IBAction)sendAction:(UIButton*)sender;
- (void)changeTypingTextViewTextWith:(NSString*)message;
- (void)openServiceWithID:(NSString*)serviceID;
- (void)initLocationManager;
- (void)moreButtonClickFromWidget;
- (NSString*)currentChatIdWithPrefix;

@end
