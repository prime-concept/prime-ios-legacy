//
//  PRWGChatViewController.m
//  PRWidgetPrime
//
//  Created by Armen on 4/4/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import "PRWGChatViewController.h"
#import "PRWGTextMessageCell.h"
#import "PRWGVoiceMessageCell.h"
#import "PRWGPhotoMessageCell.h"
#import "PRWGContactMessageCell.h"
#import "PRWGDocumentMessageCell.h"
#import "PRWGChatTaskCell.h"
#import "PRWGServicesCell.h"
#import "Constants.h"
#import "PRURLSessionRequestManager.h"
#import "AccessTokenGenerator.h"
#import "NSObject+Keychain.h"
#import "PRWGCacheManager.h"
#import "Config.h"
@import Contacts;
@import ContactsUI;

static NSString* const kLeftCellIdentifier = @"PRWGReceivedMessageCell";
static NSString* const kRightCellIdentifier = @"PRWGSentMessageCell";
static NSString* const kTaskCellIdentifier = @"PRWGChatTaskCell";
static NSString* const kSentVoiceMessageCellIdentifier = @"PRWGSentVoiceMessageCell";
static NSString* const kReceivedVoiceMessageCellIdentifier = @"PRWGReceivedVoiceMessageCell";
static NSString* const kSentPhotoMessageCellIdentifier = @"PRWGSentPhotoMessageCell";
static NSString* const kReceivedPhotoMessageCellIdentifier = @"PRWGReceivedPhotoMessageCell";
static NSString* const kSentContactMessageCellIdentifier = @"PRWGSentContactMessageCell";
static NSString* const kReceivedContactMessageCellIdentifier = @"PRWGReceivedContactMessageCell";
static NSString* const kSentLocationMessageCellIdentifier = @"PRWGSentLocationMessageCell";
static NSString* const kReceivedLocationMessageCellIdentifier = @"PRWGReceivedLocationMessageCell";
static NSString* const kSentDocumentMessageCellIdentifier = @"PRWGSentDocumentMessageCell";
static NSString* const kReceivedDocumentMessageCellIdentifier = @"PRWGReceivedDocumentMessageCell";
static NSString* const kSentVideoMessageCellIdentifier = @"PRWGSentVideoMessageCell";
static NSString* const kReceivedVideoMessageCellIdentifier = @"PRWGReceivedVideoMessageCell";
static NSString* const kServicesCellIdentifier = @"PRWGServicesCell";
static NSString* const kOpenService = @"OpenServiceWithServiceID";
static NSString* const activeDisplayModeCompact = @"NCWidgetDisplayModeCompact";
static NSString* const kTypeMessageClick = @"TypeMessageIsClicked";
static NSString* const kMoreButtonClick = @"MoreButtonIsClicked";
static NSString* const kMoreButtonImageName = @"more";
static NSString* const kMainChatPrefix = @"N";
static CGFloat const kMessageCellHeight = 75.0f;
static CGFloat const kServiceItemHeight = 70.0f;
static NSInteger const kMaxItemsCountInRowOnSmalDevice = 6;
static NSInteger const kMaxItemsCountInRowOnLargeDevice = 8;
static const NSUInteger kWidgetMaxMessagesCount = 9;

@interface PRWGChatViewController () <UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) NSMutableArray* messages;
@property (strong, nonatomic) NSMutableArray* compactModeMessages;
@property (strong, nonatomic) NSMutableArray* expandedModeMessages;
@property (strong, nonatomic) NSMutableArray* services;
@property (strong, nonatomic) NSUserDefaults* defaults;
@property (strong, nonatomic) NSString* displayMode;
@property (assign, nonatomic) NSInteger maxItemsCountInRow;
@property (assign, nonatomic) NSInteger sectionsCount;
@property (weak, nonatomic) IBOutlet UITableView* tableView;
@property (weak, nonatomic) IBOutlet UICollectionView* collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* servicesViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* typingTextVIewHeightConstraint;
@property (weak, nonatomic) IBOutlet UITextField* typingTextField;
@property (weak, nonatomic) IBOutlet UIButton* microphoneButton;
@property (strong, nonatomic) PRURLSessionRequestManager* sessionManager;

@end

static const CGFloat kIconCellWidth = 44.0f;
static const CGFloat kMinInteritemSpacing = 4.0f;

@implementation PRWGChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _defaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];

    NSString* userName = [self.defaults valueForKey:kCustomerId];
    if (!userName) {
        [self refreshAccessTokenForGetUserProfile];
    } else {
        [self setupTimer];
    }

    _typingTextField.delegate = self;
    _typingTextField.placeholder = NSLocalizedString(kChatTypingTextViewPlaceholderText, nil);
    _typingTextField.tintColor = kChatTextViewTintColor;
    _services = [_defaults valueForKey:kWidgetServices];
    self.messages = [_defaults valueForKey:kMessagesForWidget];
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openChatPage)];
    [_tableView addGestureRecognizer:tapGesture];

    [self setupMicrophoneButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _displayMode = [[NSUserDefaults standardUserDefaults] valueForKey:kDisplayMode];

    if ([_displayMode isEqualToString:activeDisplayModeCompact]) {
        _typingTextVIewHeightConstraint.constant = 0;
        _servicesViewHeightConstraint.constant = 0;
    }
    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLessOrMoreButtonSelected:) name:kShowMoreOrLessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsDidChange:) name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidDisappear:animated];
}

- (void)refreshAccessTokenForMessages
{
    NSString* userName = [self.defaults valueForKey:kCustomerId];
    NSString* accessToken = [self.defaults valueForKey:kAccessTokenKey];

    AccessTokenGenerator* tokenGenerator = [AccessTokenGenerator new];
    __weak PRWGChatViewController* weakSelf = self;
    if (accessToken) {
        [tokenGenerator refreshAccessTokenWithSuccess:^{
            PRWGChatViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            [strongSelf getMessagesWithHttpRequest];
        }
            failure:^{
            }];
    } else {
        [tokenGenerator authorizeWithUsername:userName
            success:^(AFOAuthCredential* credential) {
                PRWGChatViewController* strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                NSString* newAccessToken = credential.accessToken;
                [self.defaults setObject:newAccessToken forKey:kAccessTokenKey];
                [strongSelf getMessagesWithHttpRequest];
            }
            failure:^{
            }];
    }
}

- (void)getMessagesWithHttpRequest
{
    NSString* userName = [self.defaults valueForKey:kCustomerId];
    NSString* channelId = [kMainChatPrefix stringByAppendingString:userName];

    NSString* accessToken = [self.defaults valueForKey:kAccessTokenKey];
    NSMutableString* urlParams = [[NSMutableString alloc] initWithString:@"?"];
    NSNumber* timeStamp = @((long)[[NSDate new] timeIntervalSince1970]);
    [urlParams appendFormat:@"access_token=%@&channelId=%@&t=%@&limit=10", accessToken, channelId, timeStamp];


    NSString* directionsURL = [[NSString alloc] initWithFormat:@"%@/chat-server/v3_1/messages%@", Config.chatEndpoint, urlParams];

    if (!self.sessionManager) {
        self.sessionManager = [[PRURLSessionRequestManager alloc] init];
    }

    __weak PRWGChatViewController* weakSelf = self;
    [self.sessionManager makeURLSessionRequest:directionsURL
        success:^(NSArray* response) {
            PRWGChatViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            NSArray* messages = [response valueForKey:@"items"];
            NSMutableArray* messagesForWidget = [NSMutableArray new];

            for (NSInteger i = 0; i < messages.count; i++) {
                if([messages[i] valueForKey:@"content"])
                    [messagesForWidget addObject:messages[i]];
                if([messagesForWidget count] == kWidgetMaxMessagesCount)
                    break;
            }

            for (NSInteger i = 0; i < messagesForWidget.count; i++) {
                if([[messagesForWidget[i] valueForKey:@"type"] isEqualToString:kMessageType_Image])
                {
                    [strongSelf getPhotoMessageContent:messagesForWidget[i]];
                }
                if([[messagesForWidget[i] valueForKey:@"type"] isEqualToString:kMessageType_Contact])
                {
                    [strongSelf getContactMessageContent:messagesForWidget[i]];
                }
                if([[messagesForWidget[i] valueForKey:@"type"] isEqualToString:kMessageType_Location])
                {
                    [strongSelf getLocationMessageContent:messagesForWidget[i]];
                }
                if([[messagesForWidget[i] valueForKey:@"type"] isEqualToString:kMessageType_Document])
                {
                    [strongSelf getDocumentMessageContent:messagesForWidget[i]];
                }
            }

            NSMutableArray<NSString*> *oldFileNames = [NSMutableArray new];
            for(int i = 0; i < [[strongSelf messages] count]; ++i)
            {
                NSString *oldFileName = [(NSString*)[[strongSelf messages][i] valueForKey:@"text"] stringByReplacingOccurrencesOfString:@"/chat.private/" withString:@""];
                if(oldFileName)
                {
                    [oldFileNames addObject:oldFileName];
                }
            }
            NSMutableArray<NSString*> *newFileNames = [NSMutableArray new];
            for(int i = 0; i < [messagesForWidget count]; ++i)
            {
                if(![[messagesForWidget[i] valueForKey:@"type"] isEqualToString:kMessageType_TaskLink])
                {
                    [newFileNames addObject:[[messagesForWidget[i] valueForKey:@"content"] stringByReplacingOccurrencesOfString:@"/chat.private/" withString:@""]];
                }
            }

            for (int i = 0; i < [oldFileNames count]; ++i) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", oldFileNames[i]];
                NSArray *filteredArray = [newFileNames filteredArrayUsingPredicate:predicate];
                if(!filteredArray)
                {
                    [PRWGCacheManager removeFileFromCache:oldFileNames[i]];
                }
            }

            [strongSelf.sessionManager saveMessagesForWidgetWithURLSession:messagesForWidget];
            [strongSelf.tableView reloadData];
        }
        failure:^{
            PRWGChatViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            [strongSelf.tableView reloadData];
        }];
}

- (void)refreshAccessTokenForGetUserProfile
{
    NSString* accessToken = [self.defaults valueForKey:kAccessTokenKey];

    AccessTokenGenerator* tokenGenerator = [AccessTokenGenerator new];
    AFOAuthCredential* credential = [AFOAuthCredential objectFromKeychainWithKey:kCredentialKeyPath];

    __weak PRWGChatViewController* weakSelf = self;
    if (accessToken || credential) {
        [tokenGenerator refreshAccessTokenWithSuccess:^{
            PRWGChatViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            [strongSelf getUserProfile];
        }
            failure:^{
            }];
    }
}

- (void)getUserProfile
{
    if (!self.sessionManager) {
        self.sessionManager = [[PRURLSessionRequestManager alloc] init];
    }

	NSString* urlString = [NSString stringWithFormat:@"%@/me?lang=en", Config.crmEndpoint];

    __weak PRWGChatViewController* weakSelf = self;
    [self.sessionManager makeURLSessionRequest:urlString
                                       success:^(NSArray* response) {
                                           PRWGChatViewController* strongSelf = weakSelf;
                                           if (!strongSelf) {
                                               return;
                                           }

                                           [strongSelf.defaults setValue:[response valueForKey:@"username"] forKey:kCustomerId];
                                           [strongSelf setupTimer];
                                       }
                                       failure:^{
                                       }];
}

- (void)setupTimer
{
    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:kMessagesUpdateTimeout
                                                      target:self
                                                    selector:@selector(refreshAccessTokenForMessages)
                                                    userInfo:nil
                                                     repeats:YES];

    [timer fire];
}

- (void)showLessOrMoreButtonSelected:(NSNotification*)notification
{
    [_tableView updateConstraintsIfNeeded];
    _displayMode = notification.object;
    if ([_displayMode isEqualToString:activeDisplayModeCompact]) {
        _messages = _compactModeMessages;
        _typingTextVIewHeightConstraint.constant = 0;
        _servicesViewHeightConstraint.constant = 0;
    } else {
        _messages = _expandedModeMessages;
        _typingTextVIewHeightConstraint.constant = 40;
        _servicesViewHeightConstraint.constant = 54;
    }

    [_tableView reloadData];
}

- (void)userDefaultsDidChange:(NSNotification*)notification
{
    NSMutableArray* messages = [_defaults valueForKey:kMessagesForWidget];
    BOOL isEqual = [_messages count] == [messages count];
    if(isEqual)
    {
        for(int i = 0; i<[_messages count]; ++i)
        {
            if([[_messages[i] valueForKey:@"timestamp"] integerValue] != [[messages[i] valueForKey:@"timestamp"] integerValue])
            {
                isEqual = NO;
                break;
            }
        }
        NSInteger messagesOldCount = [_messages count];
        if([_messages count] != messagesOldCount)
        {
            [_tableView reloadData];
        }
    }
    if (!isEqual) {
        self.messages = messages;
        [_tableView reloadData];
    }

    for(int i = 0; i < [_messages count]; ++i)
    {
        if([[_messages[i] valueForKey:@"type"] isEqualToString:kMessageType_Image])
        {
            [self getPhotoMessageContent:_messages[i]];
        }
        if([[_messages[i] valueForKey:@"type"] isEqualToString:kMessageType_Contact])
        {
            [self getContactMessageContent:_messages[i]];
        }
        if([[_messages[i] valueForKey:@"type"] isEqualToString:kMessageType_Location])
        {
            [self getLocationMessageContent:_messages[i]];
        }
        if([[_messages[i] valueForKey:@"type"] isEqualToString:kMessageType_Document])
        {
            [self getDocumentMessageContent:_messages[i]];
        }
    }

    NSMutableArray* services = [_defaults valueForKey:kWidgetServices];
    if (![_services isEqual:services]) {
        _services = services;
        [_collectionView reloadData];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return _messages.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSDictionary* message = _messages[indexPath.row];
    NSString* identifier = [self cellIdentifier:message];

    if ([identifier isEqualToString:kLeftCellIdentifier] || [identifier isEqualToString:kRightCellIdentifier]) {
        PRWGTextMessageCell* cell = [_tableView dequeueReusableCellWithIdentifier:identifier];

        [cell updateCellWithData:message];
        return cell;
    }
    if ([identifier isEqualToString:kSentVoiceMessageCellIdentifier] || [identifier isEqualToString:kReceivedVoiceMessageCellIdentifier]) {
        PRWGVoiceMessageCell* cell = [_tableView dequeueReusableCellWithIdentifier:identifier];

        [cell updateCellWithData:message];
        return cell;
    }
    if([identifier isEqualToString:kSentPhotoMessageCellIdentifier] || [identifier isEqualToString:kReceivedPhotoMessageCellIdentifier] || [identifier isEqualToString:kSentLocationMessageCellIdentifier] || [identifier isEqualToString:kReceivedLocationMessageCellIdentifier] || [identifier isEqualToString:kSentVideoMessageCellIdentifier] || [identifier isEqualToString:kReceivedVideoMessageCellIdentifier])
    {
        PRWGPhotoMessageCell* cell = [_tableView dequeueReusableCellWithIdentifier:identifier];

        [cell updateCellWithData:message];
        return cell;
    }
    if([identifier isEqualToString:kSentContactMessageCellIdentifier] || [identifier isEqualToString:kReceivedContactMessageCellIdentifier])
    {
        PRWGContactMessageCell* cell = [_tableView dequeueReusableCellWithIdentifier:identifier];

        [cell updateCellWithData:message];
        return cell;
    }
    if([identifier isEqualToString:kSentLocationMessageCellIdentifier] || [identifier isEqualToString:kReceivedLocationMessageCellIdentifier])
    {
        PRWGPhotoMessageCell* cell = [_tableView dequeueReusableCellWithIdentifier:identifier];

        [cell updateCellWithData:message];
        return cell;
    }
    if ([identifier isEqualToString:kSentDocumentMessageCellIdentifier] || [identifier isEqualToString:kReceivedDocumentMessageCellIdentifier])
    {
        PRWGDocumentMessageCell* cell = [_tableView dequeueReusableCellWithIdentifier:identifier];

        [cell updateCellWithData:message];
        return cell;
    }

    PRWGChatTaskCell* cell = [_tableView dequeueReusableCellWithIdentifier:identifier];

    [cell updateCellWithData:message];
    if ([_displayMode isEqualToString:activeDisplayModeCompact]) {
        [cell updateForCompactMode];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if ([_displayMode isEqualToString:activeDisplayModeCompact]) {
        return kMessageCellHeight;
    }
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    [self tableViewScrollToBottom];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    [self.view updateConstraints];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section
{

    if (_services.count <= 5) {
        return _services.count;
    }
    return [self maxItemCountInRow];
}

- (__kindof UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath
{

    PRWGServicesCell* cell = [_collectionView dequeueReusableCellWithReuseIdentifier:kServicesCellIdentifier forIndexPath:indexPath];
    if (indexPath.row == [self maxItemCountInRow] - 1 && indexPath.row != [_services count] - 1) {
        [cell addMoreButton:kMoreButtonImageName];
        return cell;
    }

    [cell updateCellWithData:_services[indexPath.row]];

    return cell;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView*)collectionView
                    layout:(UICollectionViewLayout*)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath*)indexPath
{
    CGFloat width;
    if ([self maxItemCountInRow] == kMaxItemsCountInRowOnSmalDevice) {
        width = self.view.bounds.size.width / 6.6;
    } else if ([self maxItemCountInRow] == kMaxItemsCountInRowOnLargeDevice) {
        width = self.view.bounds.size.width / 9;
    } else {
        width = self.view.bounds.size.width / 7.8;
    }
    return CGSizeMake(width, kServiceItemHeight);
}

- (void)collectionView:(UICollectionView*)collectionView didSelectItemAtIndexPath:(NSIndexPath*)indexPath
{

    NSNumber* serviceID = [_services[indexPath.row] valueForKey:kWidgetServiceId];

    NSURL* URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@chat/%@%@", kURLSchemesPrefix, kOpenService, serviceID]];
    if (indexPath.row == [self maxItemCountInRow] - 1) {
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@chat/%@", kURLSchemesPrefix, kMoreButtonClick]];
    }

    [self.extensionContext openURL:URL completionHandler:nil];
}

#pragma mark - Helpers

- (NSString*)cellIdentifier:(NSDictionary*)message
{
    BOOL isCellLeft = ((NSNumber*)([message valueForKey:kWidgetMessageIsLeft])).boolValue;
    NSString* messageText = [message valueForKey:kWidgetMessageText];
    NSString* audioFileName = [message valueForKey:kWidgetMessageAudioFileName];
    NSString* mediaFileName = [message valueForKey:kWidgetMessageMediaFileName];
    NSString* type = [message valueForKey:kWidgetMessageType];

    if ([type isEqualToString:kMessageType_Text] && messageText) {

        return isCellLeft ? kLeftCellIdentifier : kRightCellIdentifier;

    } else if ([type isEqualToString:kMessageType_VoiceMessage] && (audioFileName || messageText)) {

        return isCellLeft ? kReceivedVoiceMessageCellIdentifier : kSentVoiceMessageCellIdentifier;
    } else if ([type isEqualToString:kMessageType_Image] && (mediaFileName || messageText)) {

        return isCellLeft ? kReceivedPhotoMessageCellIdentifier : kSentPhotoMessageCellIdentifier;
    } else if ([type isEqualToString:kMessageType_Contact] && (mediaFileName || messageText)) {

        return isCellLeft ? kReceivedContactMessageCellIdentifier : kSentContactMessageCellIdentifier;
    } else if ([type isEqualToString:kMessageType_Location] && (mediaFileName || messageText)) {

        return isCellLeft ? kReceivedLocationMessageCellIdentifier : kSentLocationMessageCellIdentifier;
    } else if ([type isEqualToString:kMessageType_Document] && (mediaFileName || messageText)) {

        return isCellLeft ? kReceivedDocumentMessageCellIdentifier : kSentDocumentMessageCellIdentifier;
    } else if ([type isEqualToString:kMessageType_Video] && (mediaFileName || messageText)) {

        return isCellLeft ? kReceivedVideoMessageCellIdentifier : kSentVideoMessageCellIdentifier;
    }
    return kTaskCellIdentifier;
}

- (void)tableViewScrollToBottom
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:_messages.count - 1 inSection:0];
    [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

- (void)openChatPage
{
    NSURL* URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@chat", kURLSchemesPrefix]];
    [self.extensionContext openURL:URL completionHandler:nil];
}

- (void)setMessages:(NSMutableArray*)messages
{
    NSMutableArray* array = [NSMutableArray new];
    _compactModeMessages = [NSMutableArray new];
    if (messages.count > 0) {
        [_compactModeMessages addObject:[messages lastObject]];
    }
    for (NSInteger i = 0; i < messages.count; i++) {
        NSMutableDictionary* currentMessage = [messages[i] mutableCopy];
        NSString* currentHeader = [currentMessage valueForKey:kWidgetMessageFormatedDate];

        if ([self hasEqualHeader:currentHeader inDataArray:messages beforeCurrentIndex:i]) {
            [currentMessage setValue:nil forKey:kWidgetMessageFormatedDate];
        }
        [array addObject:currentMessage];
    }

    _expandedModeMessages = array;
    if ([_displayMode isEqualToString:activeDisplayModeCompact]) {
        _messages = _compactModeMessages;
    } else {
        _messages = _expandedModeMessages;
    }
}

- (BOOL)hasEqualHeader:(NSString*)previewHeader inDataArray:(NSArray*)array beforeCurrentIndex:(NSInteger)index
{

    for (NSInteger i = index - 1; i >= 0; i--) {

        NSString* header = [array[i] valueForKey:kWidgetMessageFormatedDate];
        if ([previewHeader isEqualToString:header]) {
            return YES;
        }
    }
    return NO;
}

- (NSInteger)maxItemCountInRow
{
    CGFloat collectionViewWidth = CGRectGetWidth(_collectionView.frame);
    return (NSInteger)(collectionViewWidth / (kIconCellWidth + kMinInteritemSpacing));
}

- (void)setupMicrophoneButton
{
    UIImage* image = [[UIImage imageNamed:@"microphone"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_microphoneButton setImage:image
                       forState:UIControlStateNormal];
#if defined(Imperia) || defined(Otkritie) || defined(Raiffeisen) || defined(VTB24) || defined(Skolkovo) || defined(Platinum) || defined(PrimeConciergeClub)
    [_microphoneButton.imageView setTintColor:kChatSendTextColor];
#else
    [_microphoneButton.imageView setTintColor:kIconsColor];
#endif
}

#pragma mark - Actions

- (IBAction)microphoneButtonClick:(id)sender
{
    [self openChatPage];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;
{
    NSURL* URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@chat/%@", kURLSchemesPrefix, kTypeMessageClick]];
    [self.extensionContext openURL:URL completionHandler:nil];
    return NO;
}

- (void)getPhotoMessageContent:(id)message
{
    NSString *tempFileName = [message valueForKey:@"text"];
    if(tempFileName)
    {
        NSString *fileName = [tempFileName stringByReplacingOccurrencesOfString:@"/chat.private/" withString:@""];
        if(![PRWGCacheManager isFileExistInCache:fileName])
        {
            [self refreshAccessTokenForMessages];
            NSString *minImagePath = [NSString stringWithFormat:@"%@_min", [message valueForKey:@"text"]];
            if(!self.sessionManager)
            {
                self.sessionManager = [[PRURLSessionRequestManager alloc] init];
            }
            __weak PRWGChatViewController *weakSelf = self;
            [self.sessionManager downloadFileWithPath:minImagePath
                                              success:^(NSData *fileData) {
                                                  [PRWGCacheManager addFileToCache:fileData fileName:fileName];
                                                  PRWGChatViewController *strongSelf = weakSelf;
                                                  if(strongSelf)
                                                  {
                                                      [strongSelf.tableView reloadData];
                                                  }
                                              }
                                              failure:^(NSInteger statusCode, NSError *error) {
                                              }];
        }
    }
}

- (void)getContactMessageContent:(id)message
{
    NSString *tempFileName = [message valueForKey:@"text"];
    if(tempFileName)
    {
        NSString *fileName = [tempFileName stringByReplacingOccurrencesOfString:@"/chat.private/" withString:@""];
        if(![PRWGCacheManager isFileExistInCache:fileName])
        {
            [self refreshAccessTokenForMessages];
            NSString *contactPath = [message valueForKey:@"text"];
            if(!self.sessionManager)
            {
                self.sessionManager = [[PRURLSessionRequestManager alloc] init];
            }
            __weak PRWGChatViewController *weakSelf = self;
            [self.sessionManager downloadFileWithPath:contactPath
                                              success:^(NSData *fileData) {
                                                  NSArray<CNContact*> *contacts = [CNContactVCardSerialization contactsWithData:fileData error:nil];
                                                  if(contacts && [contacts count] == 1)
                                                  {
                                                      NSData *contactData = [NSKeyedArchiver archivedDataWithRootObject:[contacts firstObject]];
                                                      [PRWGCacheManager addFileToCache:contactData fileName:fileName];
                                                      PRWGChatViewController *strongSelf = weakSelf;
                                                      if(strongSelf)
                                                      {
                                                          [strongSelf.tableView reloadData];
                                                      }
                                                  }
                                              }
                                              failure:^(NSInteger statusCode, NSError *error) {
                                              }];
        }
    }
}

- (void)getLocationMessageContent:(id)message
{
    NSString *tempFileName = [message valueForKey:@"text"];
    if(tempFileName)
    {
        NSString *fileName = [tempFileName stringByReplacingOccurrencesOfString:@"/chat.private/" withString:@""];
        if(![PRWGCacheManager isFileExistInCache:fileName])
        {
            [self refreshAccessTokenForMessages];
            NSString *locationDataPath = [message valueForKey:@"text"];
            if(!self.sessionManager)
            {
                self.sessionManager = [[PRURLSessionRequestManager alloc] init];
            }
            __weak PRWGChatViewController *weakSelf = self;
            [self.sessionManager downloadFileWithPath:locationDataPath
                                              success:^(NSData *fileData) {
                                                  NSDictionary* locationDictionary = [NSJSONSerialization JSONObjectWithData:(NSData*)fileData options:kNilOptions error:nil];
                                                  if(!locationDictionary)
                                                    return;
                                                  NSData *snapshotData = [[NSData alloc] initWithBase64EncodedString:[locationDictionary valueForKey:kLocationMessageSnapshotKey]
                                                                                                             options:NSDataBase64DecodingIgnoreUnknownCharacters];
                                                  if(snapshotData)
                                                  {

                                                      [PRWGCacheManager addFileToCache:snapshotData fileName:fileName];
                                                      PRWGChatViewController *strongSelf = weakSelf;
                                                      if(strongSelf)
                                                      {
                                                          [strongSelf.tableView reloadData];
                                                      }
                                                  }
                                              }
                                              failure:^(NSInteger statusCode, NSError *error) {
                                              }];
        }
    }
}

- (void)getDocumentMessageContent:(id)message
{
    NSString *tempFileName = [message valueForKey:@"text"];
    if(tempFileName)
    {
        NSString *fileName = [tempFileName stringByReplacingOccurrencesOfString:@"/chat.private/" withString:@""];
        if(![PRWGCacheManager isFileExistInCache:fileName])
        {
            [self refreshAccessTokenForMessages];
            if(!self.sessionManager)
            {
                self.sessionManager = [[PRURLSessionRequestManager alloc] init];
            }
            __weak PRWGChatViewController *weakSelf = self;
            [self.sessionManager getMediaInfoWithUUID:fileName
                                              success:^(NSData *fileData) {
                                                  [PRWGCacheManager addFileToCache:fileData fileName:fileName];
                                                  PRWGChatViewController *strongSelf = weakSelf;
                                                  if(strongSelf)
                                                  {
                                                      [strongSelf.tableView reloadData];
                                                  }
                                              }
                                              failure:^(NSInteger statusCode, NSError *error) {
                                              }];
        }
    }
}


@end
