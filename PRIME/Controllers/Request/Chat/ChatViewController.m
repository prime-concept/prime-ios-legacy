//
//  ChatViewController.m
//  PRIME
//
//  Created by Artak on 8/13/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "ChatTaskCell.h"
#import "ChatUtility.h"
#import "ChatViewController.h"
#import "CommandBuilder.h"
#import "FontAwesomeIconView.h"
#import "PRUITabBarController.h"
#import "PRWebSocketMessageContent.h"
#import "PRWebSocketMessageContentTasklink.h"
#import "PRWebSocketMessageContentText.h"
#import "PRWebSocketMessageModel.h"
#import "Reachability.h"
#import "PRMessageProcessingManager.h"
#import "RequestsDetailViewController.h"
#import "SZTextView.h"
#import "PRChatServicesView.h"
#import "TestMessagesSender.h"
#import "WebViewController.h"
#import "XNTLazyManager.h"
#import <AVFoundation/AVFoundation.h>
#import <BABFrameObservingInputAccessoryView/BABFrameObservingInputAccessoryView.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import "PRChatTextView.h"
#import "PRAssistantInfoDataSource.h"
#import "PRChatSendMessageViewCell.h"
#import "PRChatReceiveMessageViewCell.h"
#import "PRChatMessageBaseViewCell.h"
#import "PRVoiceMessageCell.h"
#import "PRChatPhotoMessageViewCell.h"
#import "PRChatContactMessageViewCell.h"
#import "PRChatVideoMessageViewCell.h"
#import "PRChatDocumentMessageViewCell.h"
#import "PRAudioPlayer.h"
#import "PRUserDefaultsManager.h"
#import "PRUINavigationController.h"
#import "PRMediaFilesProcessingManager.h"
#import "DocumentLargeViewController.h"
#import "LocationPreviewViewController.h"
#import "DocumentPreviewViewController.h"
#import "InformationAlertController.h"
#import "Photos/Photos.h"
#import "VideoPlayer.h"
@import ContactsUI;
@import Contacts;

typedef NS_ENUM(NSInteger, PRRecordingAnimationState) {
    PRRecordingAnimationState_Recording = 1,
    PRRecordingAnimationState_Stopped
};

typedef NS_ENUM(NSInteger, MessagesFetchType) {
    MessagesFetchType_FirstLoad = 0,
    MessagesFetchType_NextLoad
};

@interface ChatViewController () <MFMessageComposeViewControllerDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate> {
    BOOL _isFirstTime;
    BOOL _isKeyboardUp;
    BOOL _hasServices;
    BOOL _didSelectFooterView;
    BOOL _isKeyboardOpenedBeforeNavigation;
    BOOL _enableKeyboardAppearance;
    BOOL _assistantViewIsShown;
    CGFloat _keyboardHeight;
    CGFloat _extraHeight;
    NSInteger _fetchedFromCoreDataCount;
    MessagesFetchType _fetchedMessageCategory;
    BOOL _hasNewMessages;
}

@property (nonatomic, strong) CLLocation* currentLocation;
@property (nonatomic, strong) CLLocationManager* locationManager;

@property (nonatomic, strong) NSDate* lastServiceRequestDate;

@property (nonatomic, strong) NSString* clientId;
@property (nonatomic, strong) NSIndexPath* currentIndexPath;
@property (nonatomic, strong) NSString* finalString;
@property (nonatomic, strong) PRChatMessageBaseViewCell* chatMessageViewCell;
@property (nonatomic, strong) XNTLazyManager* lazyManager;
@property (nonatomic, strong) PRAssistantInfoDataSource* assistantInfoDataSource;
@property (nonatomic, assign) PRChatServicesViewState state;
@property (nonatomic, strong) PRAudioPlayer* audioPlayer;
@property (nonatomic, strong) NSTimer* recordingTimer;
@property (nonatomic, assign) NSInteger recordingAnimationState;
@property (nonatomic, readonly) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) PRMediaFilesProcessingManager* mediaFileManager;

@property (weak, nonatomic) IBOutlet UIView* recordingDetailsView;
@property (weak, nonatomic) IBOutlet UILabel* recordingCancelLabel;
@property (weak, nonatomic) IBOutlet UILabel* recordingDurationLabel;
@property (weak, nonatomic) IBOutlet UIView* recordingIndicatorView;
@property (weak, nonatomic) IBOutlet PRChatServicesView* chatServicesView;
@property (weak, nonatomic) IBOutlet UIImageView* backgroundImageView;
@property (weak, nonatomic) IBOutlet UIView* typingContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* typingViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* typingViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* chatServicesViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* chatServicesViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIButton* sendButton;
@property (weak, nonatomic) IBOutlet UIButton* microphoneButton;
@property (weak, nonatomic) IBOutlet UIView* microphoneButtonBackgroundView;
@property (weak, nonatomic) IBOutlet UIView* microphoneButtonBackgroundShadowView;
@property (weak, nonatomic) IBOutlet PRChatTextView* typingTextView;
@property (weak, nonatomic) IBOutlet UITableView* messagesTableView;
@property (weak, nonatomic) IBOutlet UITableView* assistantTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* assistantInfoTableViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* assistantInfoTableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* microphoneButtonBeckgroundViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* recordingCancelViewCenterXConstraint;
@property (weak, nonatomic) IBOutlet UIView* recordingCancelView;
@property (weak, nonatomic) IBOutlet UIButton* attachButton;

@end

@implementation ChatViewController

static const NSUInteger kChatServicesViewDefaultHeight = 40;
static const NSUInteger kServiceUpdatingInterval = 10;
static const NSUInteger kIconViewHeight = 30;
static const CGFloat KServicesAnimationDuration = 0.3f;
static const CGFloat kTableViewSmallSize = 40;
static const CGFloat kRecordingTimerTimeInterval = 0.5f;
static const CGFloat kAssistantInfoTableViewInvisibleTopSpace = -16;
static const CGFloat kMicrophoneButtonBeckgroundViewDefaultWidth = 41.0f;
static const CGFloat kVoiceMessageCellEstimatedHeight = 123.0f;
static const CGFloat kTextMessageCellEstimatedHeight = 92.0f;
static const NSUInteger kWidgetMaxMessagesCount = 9;
static NSUInteger currentIndexPathForMessage;

static NSString* const kLeftCellIdentifier = @"PRChatReceiveMessageViewCell";
static NSString* const kRightCellIdentifier = @"PRChatSendMessageViewCell";
static NSString* const kTaskCellIdentifier = @"ChatTaskCell";
static NSString* const kSentVoiceMessageCellIdentifier = @"VoiceMessageCell";
static NSString* const kReceivedVoiceMessageCellIdentifier = @"ReceivedVoiceMessageCell";
static NSString* const kSentPhotoMessageCellIdentifier = @"PRChatSendPhotoMessageViewCell";
static NSString* const kReceivedPhotoMessageCellIdentifier = @"PRChatReceivePhotoMessageViewCell";
static NSString* const kSentDocumentMessageCellIdentifier = @"PRChatSendDocumentMessageViewCell";
static NSString* const kReceivedDocumentMessageCellIdentifier = @"PRChatReceiveDocumentMessageViewCell";
static NSString* const kSentVideoMessageCellIdentifier = @"PRChatSendVideoMessageViewCell";
static NSString* const kReceivedVideoMessageCellIdentifier = @"PRChatReceiveVideoMessageViewCell";
static NSString* const kSentLocationMessageCellIdentifier = @"PRChatSendLocationMessageViewCell";
static NSString* const kReceivedLocationMessageCellIdentifier = @"PRChatReceiveLocationMessageViewCell";
static NSString* const kSentContactMessageCellIdentifier = @"PRChatSendContactMessageViewCell";
static NSString* const kReceivedContactMessageCellIdentifier = @"PRChatReceiveContactMessageViewCell";
static NSString* const kMicrophoneButtonImageName = @"microphone";
static NSString* const kMicrophoneButtonImageNameInSelectedMode = @"microphone_selected";
static NSString* const kRecordingCancelLabelText = @"Slide to cancel";
static NSString* const kCallToClubButtonIconName = @"call_assistant";
static NSString* const kPhoneIconName = @"phone";
static NSInteger firstRowDisplayCount = 0;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    [_messagesTableView registerClass:[ChatTaskCell class] forCellReuseIdentifier:kTaskCellIdentifier];

    _messagesTableView.dataSource = self;
    _messagesTableView.delegate = self;
    _messagesTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    _messagesTableView.rowHeight = UITableViewAutomaticDimension;
    _messagesTableView.estimatedRowHeight = 40;
    _messagesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self setupTableViewHeader];

#if defined(PrivateBankingPRIMEClub) || defined(PrimeRRClub)
    _backgroundImageView.backgroundColor = [UIColor colorWithRed:240. / 255 green:240. / 255 blue:241. / 255 alpha:1];
#else
    UIImage* backgroundImage = [UIImage imageNamed:@"chat_back"];
    _backgroundImageView.image = backgroundImage;
    _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    _backgroundImageView.clipsToBounds = YES;
#endif

#if defined(PrivateBankingPRIMEClub)
    self.edgesForExtendedLayout = UIRectEdgeTop;
    self.extendedLayoutIncludesOpaqueBars = YES;
#endif

    _typingTextView.textContainerInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    _typingTextView.placeholder = NSLocalizedString(kChatTypingTextViewPlaceholderText, nil);
    _typingTextView.placeholderTextColor = [UIColor colorWithRed:216.0 / 255 green:216.0 / 255 blue:216.0 / 255 alpha:1];
    _typingTextView.tintColor = kChatTextViewTintColor;
    [_sendButton setImage:[_sendButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    _sendButton.tintColor = kChatSendButtonColor;

#if defined(PrimeClubConcierge)
    [_attachButton setImage:[_attachButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    _attachButton.tintColor = kChatSendButtonColor;
#endif

    _lazyManager = [[XNTLazyManager alloc] initWithObserver:self
                                                   selector:@selector(reachabilityChanged:)];

    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] init];
    tap.cancelsTouchesInView = NO;
    [tap addTarget:self action:@selector(checkNotContainsLinkAndCloseKeyboard:)];
    [_messagesTableView addGestureRecognizer:tap];

    [self prepareChatTypingViewDesign];
    [self setupRecordingAnimationComponents];

    BABFrameObservingInputAccessoryView* inputView = [[BABFrameObservingInputAccessoryView alloc]
        initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44)];
    inputView.userInteractionEnabled = NO;

    _typingTextView.inputAccessoryView = inputView;

    __weak id weakSelf = self;

    inputView.keyboardFrameChangedBlock = ^(BOOL keyboardVisible, CGRect keyboardFrame) {

        ChatViewController* strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }

        strongSelf->_keyboardHeight = CGRectGetHeight(strongSelf.view.frame) - CGRectGetMinY(keyboardFrame);
        CGFloat bottomConstraintConst = 0;
#ifdef ENABLE_INITIATION_REQUEST_BUTTONS_IN_CHAT
        if (strongSelf->_hasServices && !strongSelf->_chatId) {
            bottomConstraintConst = kChatServicesViewDefaultHeight;
            strongSelf.chatServicesView.hidden = NO;
            strongSelf.chatServicesViewBottomConstraint.constant = MAX(0, strongSelf->_keyboardHeight);
        }
#endif
        strongSelf.typingViewBottomConstraint.constant = MAX(bottomConstraintConst, strongSelf->_keyboardHeight + bottomConstraintConst);
    };

    _audioPlayer = [PRAudioPlayer new];
    _enableKeyboardAppearance = NO;
    _isFirstTime = YES;
    _hasNewMessages = YES;
    firstRowDisplayCount = 0;

    if (![PRRequestManager connectionRequired]) {
        _fetchedFromCoreDataCount = 0;
        _fetchedMessageCategory = MessagesFetchType_FirstLoad;
        [self messagesForChannelId:[self currentChatIdWithPrefix]];
    } else {
        self.messages = [[PRDatabase messagesForChannelId:[self currentChatIdWithPrefix]] mutableCopy];
        [self filterMessagesArray];
    }

    [PRMessageProcessingManager sharedInstance];

    PRUserProfileModel* profile = [[PRUserProfileModel MR_findAllInContext:[NSManagedObjectContext MR_rootSavingContext]] firstObject];
    _clientId = profile.username;

    _sendButton.hidden = YES;

    if (!_chatId) {
        [self setupAssistantInfoDataSource];
        [self createCallToClubButton];
        [self registerForNotifications];
    }
 
    UILongPressGestureRecognizer* longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc]
        initWithTarget:self
                action:@selector(handleLongPress:)];
    longPressGestureRecognizer.minimumPressDuration = 0.5; //Seconds.
    longPressGestureRecognizer.delegate = self;
    [_messagesTableView addGestureRecognizer:longPressGestureRecognizer];

    [self becomeFirstResponder];
    [[UIMenuController sharedMenuController] update];

    NSArray<PRServicesModel*>* services = [PRDatabase getServices];
    _hasServices = services.count > 0;
    if (!_chatId && !_hasServices) {
        _typingViewBottomConstraint.constant = 0;
    } else {
        _typingViewBottomConstraint.constant = kChatServicesViewDefaultHeight;
    }

    if (!_chatId) {
        _chatServicesView.delegate = self;
    }

#ifdef ENABLE_TEST_MESSAGES_SENDER
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        TestMessagesSender* test = [[TestMessagesSender alloc] initWithTaskIds:nil orChatIds:@[ @268824159, @268770517 ] andRepeatTimeInterval:5 needText:NO];
        [test startReceiveTestTaskMessages];
        [test startReceiveFeedback:WebSoketMessageStatus_Seen webSoketCommandType:WebSoketCommandType_Request];
    });
#endif
    [PRGoogleAnalyticsManager sendEventWithName: _chatId == nil ? kChatTabOpened : kRequestChatOpened parameters:nil];
}

- (void)setupAssistantInfoDataSource
{
    static const CGFloat kAssistantTitleViewWidth = 200.0f;
    static const CGFloat kAssistantTitleViewHeight = 40.0f;

    PRUserProfileModel* profile = [PRDatabase getUserProfile];

    if (!profile) {
        return;
    }

    if (_chatId) {
        return;
    }

    UIView* assistantTitleView = [PRAssistantInfoDataSource assistantTitleViewWithFram:CGRectMake(0, 0, kAssistantTitleViewWidth, kAssistantTitleViewHeight) asistentName:profile.assistant.firstName];
    NSString* phone = [profile.assistant.phones firstObject].phone;
    NSString* email = [profile.assistant.emails firstObject].email;

	self.navigationItem.titleView = assistantTitleView;

    if (!(phone || email)) {
		return;
    }

	_assistantInfoDataSource = [[PRAssistantInfoDataSource alloc] initWithAssistantPhone:phone
																				   email:email];
	_assistantTableView.delegate = _assistantInfoDataSource;
	_assistantTableView.dataSource = _assistantInfoDataSource;
	[_assistantTableView reloadData];

	UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
																				 action:@selector(assistantViewTapped:)];
	[assistantTitleView addGestureRecognizer:tapGesture];

	if (!email || !phone) {
		_assistantInfoTableViewHeightConstraint.constant = kTableViewSmallSize;
	}
}

- (void)initLocationManager
{
    if (!_locationManager) {
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [_locationManager requestWhenInUseAuthorization];
        [_locationManager startMonitoringSignificantLocationChanges];
        [_locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager*)manager didUpdateLocations:(NSArray<CLLocation*>*)locations
{
    _currentLocation = [locations objectAtIndex:0];

    [_locationManager stopUpdatingLocation];

    if (_lastServiceRequestDate && fabs([_lastServiceRequestDate timeIntervalSinceNow]) < kServiceUpdatingInterval) {
        return;
    }
    _lastServiceRequestDate = [NSDate date];
    if (_currentLocation) {

#ifdef ENABLE_INITIATION_REQUEST_BUTTONS_IN_CHAT
        [self getServiceIcons];
#endif
    }
}

- (void)locationManager:(CLLocationManager*)manager didFailWithError:(NSError*)error
{

#ifdef ENABLE_INITIATION_REQUEST_BUTTONS_IN_CHAT
    if (_lastServiceRequestDate && fabs([_lastServiceRequestDate timeIntervalSinceNow]) < kServiceUpdatingInterval) {
        return;
    }
    _lastServiceRequestDate = [NSDate date];
    [self getServiceIcons];
#endif
}

- (void)getServiceIcons
{
    NSArray<PRServicesModel*>* services = [PRDatabase getServices];
    _hasServices = services.count > 0;
    if (_hasServices) {
        [self setItemsForTaskIconsView];
    }

    __weak id weakSelf = self;
    [PRRequestManager getServicesWithLongitude:@(_currentLocation.coordinate.longitude)
                                      latitude:@(_currentLocation.coordinate.latitude)
                                      datetime:[NSDate date]
                                          view:self.view
                                          mode:PRRequestMode_ShowNothing
                                       success:^(NSArray<PRServicesModel*>* services) {

                                           ChatViewController* strongSelf = weakSelf;
                                           if (!strongSelf) {
                                               return;
                                           }

                                           strongSelf->_hasServices = services.count > 0;
                                           [strongSelf setItemsForTaskIconsView];
                                       }
                                       failure:^{
                                       }];
}

- (void)setItemsForTaskIconsView
{
    [_chatServicesView updateCollectionViewForItems];
}

- (void)openTaskIconsView
{
    if (_chatId || !_hasServices) {
        return;
    }

    _chatServicesView.hidden = NO;
}

- (NSString*)currentChatIdWithPrefix
{
    NSString* chatId = [ChatUtility chatIdWithPrefix:_chatId];
    if (!chatId) {
        chatId = [ChatUtility mainChatIdWithPrefix];
    }
    return chatId;
}

- (void)addMessage:(nonnull PRMessageModel *)messageModel {
    [self.messages addObject:messageModel];
}

- (void)createCallToClubButton
{
#if defined(Raiffeisen) || defined(VTB24) || defined(Skolkovo)
    UIImageView* iconView = [UIImageView new];
    [iconView setFrame:CGRectMake(10, 10, 24, 24)];
    iconView.image = [self imageNamed:kCallToClubButtonIconName];
    iconView.tintColor = kIconsColor;

#else
    FontAwesomeIconView* iconView = [[FontAwesomeIconView alloc] initWithIcon:kPhoneIconName
                                                                       height:kIconViewHeight];
    iconView.textColor = kIconsColor;
    iconView.frame = CGRectMake(0, 7, CGRectGetWidth(iconView.frame), kIconViewHeight);
#endif
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(callAction:) forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, 44, 44)];
    [button addSubview:iconView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)callAction:(UIButton*)sender
{
    [PRGoogleAnalyticsManager sendEventWithName:kCallButtonClicked parameters:nil];
    PRUserProfileModel* profile = [PRDatabase getUserProfile];
    if (profile.clubPhone) {
        NSString* phoneNumber = [@"telprompt://" stringByAppendingString:profile.clubPhone];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
    }
}

- (UIImage *)imageNamed:(NSString*)imageName
{
#ifdef VTB24
    imageName = [NSString stringWithFormat:@"vtb_%@",imageName];
#endif
    return [UIImage imageNamed:imageName];
}

- (void)assistantViewTapped:(UITapGestureRecognizer*)sender
{
    [PRGoogleAnalyticsManager sendEventWithName:kAssistantViewOpened parameters:nil];
    if (_assistantViewIsShown) {
        _assistantInfoTableViewTopConstraint.constant = kAssistantInfoTableViewInvisibleTopSpace;
        [UIView animateWithDuration:0.5
                         animations:^{
                             [self.view layoutIfNeeded];
                         }
                         completion:^(BOOL finished) {
                             _assistantViewIsShown = NO;
                             _assistantTableView.hidden = YES;
                         }];
        return;
    }

    CGFloat statusBarHeight = [Utils statusBarHight];
    _assistantInfoTableViewTopConstraint.constant = statusBarHeight + kNavBarHeight;

    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.view layoutIfNeeded];
                         _assistantTableView.hidden = NO;
                     }
                     completion:^(BOOL finished) {
                         _assistantViewIsShown = YES;
                     }];
}

- (void)viewDidLayoutSubviews
{
    if (_messages.count > 0 && _isFirstTime && _messagesTableView.contentSize.height > CGRectGetHeight(_messagesTableView.frame)) {
        [_messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[_messagesTableView numberOfRowsInSection:0] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
    }
    [super viewDidLayoutSubviews];
}

- (CGSize)sizeOfText:(NSString*)textToMesure widthOfTextView:(CGFloat)width withFont:(UIFont*)font
{
    CGRect textSize = [textToMesure boundingRectWithSize:CGSizeMake(width - 10, FLT_MAX)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{ NSFontAttributeName : font }
                                                 context:nil];
    return textSize.size;
}

- (void)setTextViewHeightForText
{
    const CGFloat kOriginalTextViewHeight = 20;
    const CGFloat kTopAndBottomMargins = 20;
    const CGFloat kMaxExpandingSize = 150;

    CGFloat height = [self sizeOfText:_finalString
                      widthOfTextView:CGRectGetWidth(_typingTextView.frame)
                             withFont:_typingTextView.font]
    .height;

    CGFloat newheight = MAX(kOriginalTextViewHeight, height) + kTopAndBottomMargins;

    if (_typingViewConstraint.constant != newheight) {
        _typingViewConstraint.constant = MIN(newheight, kMaxExpandingSize);
        [_typingContainerView setNeedsLayout];
        [_typingContainerView layoutIfNeeded];
    }
}

- (void)changeTypingTextViewTextWith:(NSString*)message
{
    NSRange range = NSMakeRange(0, _typingTextView.text.length ? _typingTextView.text.length : 0);
    [self textView:_typingTextView shouldChangeTextInRange:range replacementText:message];
    _typingTextView.text = _finalString;
    _sendButton.hidden = message.length == 0;
    [_typingTextView becomeFirstResponder];
}

- (void)tableView:(UITableView*)tableView didHighlightRowAtIndexPath:(NSIndexPath*)indexPath
{
    _currentIndexPath = indexPath;
}

- (void)showPhoto:(UIImage*)image
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"DocumentLarge" bundle: nil];
    DocumentLargeViewController* documentLargeViewController = (DocumentLargeViewController*)[storyboard
                                                                                              instantiateViewControllerWithIdentifier:@"DocumentLargeViewController"];

    [self.navigationController pushViewController:documentLargeViewController animated:YES];

    documentLargeViewController.image = image;
}

- (void)handleLongPress:(UILongPressGestureRecognizer*)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }

    _chatMessageViewCell = [_messagesTableView cellForRowAtIndexPath:_currentIndexPath];

    if (![_chatMessageViewCell isKindOfClass:[PRChatSendMessageViewCell class]] && ![_chatMessageViewCell isKindOfClass:[PRChatReceiveMessageViewCell class]]) {
        return;
    }

    if (![_typingTextView isFirstResponder] && ![self isFirstResponder]) {
        [self becomeFirstResponder];
    }

    _typingTextView.disableEditMenu = YES;
    [[UIMenuController sharedMenuController] setTargetRect:_chatMessageViewCell.balloonImageView.frame
                                                    inView:_chatMessageViewCell];

    [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (_typingTextView.disableEditMenu && action == @selector(copy:)) {
        return YES;
    }

    return NO;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)tableView:(UITableView*)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return YES;
}

- (void)copy:(id)sender
{
    _chatMessageViewCell = [_messagesTableView cellForRowAtIndexPath:_currentIndexPath];
    if (_chatMessageViewCell && _chatMessageViewCell.messageLabel.text) {
        UIPasteboard* pboard = [UIPasteboard generalPasteboard];
        pboard.string = _chatMessageViewCell.messageLabel.text;
    }
}

- (BOOL)textView:(UITextView*)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text
{
    _finalString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    //Todo set text size limit.
    [self setTextViewHeightForText];

    if (!_finalString || [_finalString isEqualToString:@""]) {
        [self setSendButtonHidden:YES];
        return YES;
    }

    if ([PRRequestManager connectionRequired]) {
        [self setSendButtonHidden:NO];
        _sendButton.enabled = [PRDatabase isUserProfileFeatureEnabled:ProfileFeature_SMS_Messages];
        return YES;
    }

    [self setSendButtonHidden:NO];
    _sendButton.enabled = YES;
    _sendButton.titleLabel.textColor = kChatSendTextColor;

    return YES;
}

- (void)textViewTextDidChange:(NSNotification*)notification
{
    // Scroll to bottom in case textview content size is smaller than the height of text view.
    // This is done because the text inside textview became hidden when deleting faster and textview size did not update.
    NSInteger textHeight = (NSInteger)[self sizeOfText:_finalString
                                       widthOfTextView:CGRectGetWidth(_typingTextView.frame)
                                              withFont:_typingTextView.font]
    .height;
    NSInteger textViewCurrentHeight = (NSInteger)_typingTextView.bounds.size.height;

    if (textHeight <= textViewCurrentHeight) {
        NSRange bottom = NSMakeRange(_typingTextView.text.length - 1, 1);
        [_typingTextView scrollRangeToVisible:bottom];
    }
}

- (void)prepareChatTypingViewDesign
{
    _typingTextView.textColor = kChatMessageColor;
    _typingTextView.font = [UIFont systemFontOfSize:16];
    _typingTextView.delegate = self;
}

- (void)unregisterForNotifications
{
    // Unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kFeedbackReceived
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kMessageDeletedFeedbackReceived
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kMessageReceived
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kMessageStatusUpdated
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kMessageInSending
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIMenuControllerDidHideMenuNotification
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidChangeNotification
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kProfileHasBeenLoaded
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kAudioFileReceived
                                                  object:nil];
}

- (void)registerForNotifications
{
    // Register for keyboard notifications.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateMessageStatus:)
                                                 name:kFeedbackReceived
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deleteMessage:)
                                                 name:kMessageDeletedFeedbackReceived
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(messageReceived:)
                                                 name:kMessageReceived
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateMessageStatus:)
                                                 name:kMessageStatusUpdated
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(messageInSending:)
                                                 name:kMessageInSending
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuControllerWillHide)
                                                 name:UIMenuControllerDidHideMenuNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textViewTextDidChange:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(profileHasBeenLoaded)
                                                 name:kProfileHasBeenLoaded
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textViewTextDidChange:)
                                                 name:kVoiceMessageReceived
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTableViewForVoiceMessageStatusUpdate:)
                                                 name:kAudioFileReceived
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

#if defined(PrivateBankingPRIMEClub)
    [(PRUINavigationController*)self.navigationController setNavigationBarColor:kTabBarBackgroundColor];
#endif

    // Set main color to navigation title when PRIME chat is open, otherwise set default text color.
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : (!_chatId) ? kChatTitleColor : kNavigationBarTitleTextColor };
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (_chatId) {
        [self registerForNotifications];
        if (![_typingTextView isFirstResponder]) {
            _typingViewBottomConstraint.constant = 0;
        }
    } else {
        if (![_typingTextView isFirstResponder]) {
            [self setChatServicesViewStateTo:_state];
        }

        [self getServiceIcons];
        [self openTaskIconsView];
    }

    // Get features ("PondMobile button", "Task Link", etc.) for the user.
    [self getUserProfileFeatures];

    _isFirstTime = NO;
    if (_initialString.length) {
        [self changeTypingTextViewTextWith:_initialString];
        _initialString = nil;
    }
    if (_sendButton.hidden) {
        _sendButton.titleLabel.textColor = kChatSendTextColor;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (_chatId) {
        [self unregisterForNotifications];
    }
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    if (!_chatId) {
        [self unregisterForNotifications];
    }
}

#pragma mark - Public Functions

- (void)openServiceWithID:(NSString*)serviceID
{
    PRServicesModel* service = [PRDatabase serviceWithID:serviceID];

    if (service) {
        [self didSelectMenuItem:service];
		return;
    }

	__weak id weakSelf = self;
	[PRRequestManager getServicesWithLongitude:@(_currentLocation.coordinate.longitude)
									  latitude:@(_currentLocation.coordinate.latitude)
									  datetime:[NSDate date]
										  view:self.view
										  mode:PRRequestMode_ShowOnlyProgress
									   success:^(NSArray<PRServicesModel*>* services) {
										   PRServicesModel* service = [PRDatabase serviceWithID:serviceID];
										   if (service) {
											   [weakSelf didSelectMenuItem:service];
										   }
									   }
									   failure:^{}];
}

#pragma mark - Profile Features

- (void)getUserProfileFeatures
{
	[self.lazyManager shouldBeUpdatedIfViewDidAppearWithDate:[NSDate date]
											  relativeToDate:nil
														then:^(PRRequestMode mode) {

		[PRRequestManager getProfileFeaturesWithView:self.view
												mode:PRRequestMode_ShowNothing
											 success:^(NSArray<PRUserProfileFeaturesModel*>* profileFeatures) { }
											 failure:^{ }];
	}
										otherwiseIfFirstTime:^{ }
												   otherwise:^{ }];
}

#pragma mark - Notification Handler

- (void)menuControllerWillHide
{
    _currentIndexPath = nil;
    _typingTextView.disableEditMenu = NO;
}

- (void)updateMessageStatus:(NSNotification*)notification
{
    PRMessageModel* model = [notification.object MR_inThreadContext];
    [self updateTableViewForModel:model];
}

- (void)deleteMessageWithMessageId:(id)message
{
    NSUInteger i = 0;
    BOOL isMessageFound = NO;
    for (; i < _messages.count; ++i) {
        if ([_messages[i].guid isEqualToString:message]) {
            [_messages removeObjectAtIndex:i];
            isMessageFound = YES;
            break;
        }
    }

    if (isMessageFound) {
        [_messagesTableView reloadData];
    }
}

- (void)deleteMessage:(NSNotification*)notification
{
    [self deleteMessageWithMessageId:notification.object];
}

- (void)updateTableViewForModel:(PRMessageModel*)model
{
    NSInteger indexOfObject = [_messages indexOfObjectPassingTest:^BOOL(__kindof PRMessageModel* _Nonnull obj, NSUInteger idx, BOOL* _Nonnull stop) {
        return [obj.guid isEqualToString:model.guid];
    }];

    if (indexOfObject != NSNotFound) {
        [_messagesTableView reloadData];
    }
}

- (void)messageInSending:(NSNotification*)notification
{
    [_messagesTableView reloadData];
}

- (void)messageReceived:(NSNotification*)notification
{
    NSString* channelId = [notification object];
    [self filterMessagesArray];

    if (![channelId isEqualToString:[self currentChatIdWithPrefix]]) {
        return;
    }

    PRMessageModel* lastMessage = [_messages lastObject];
    NSArray<PRMessageModel*>* messagesArray = [PRDatabase messagesForChannelId:channelId timestamp:lastMessage.timestamp];

    // In case if we got notification about change in channel, but there is no a message with timestamp, more fresh than last message that exist in local database,
    // that it means that we got status update.
    if (![messagesArray count]) {
        [_messagesTableView reloadData];
        [(PRUITabBarController*)self.tabBarController showBadge];
        return;
    }

    [self addNewMessagesFromArray:messagesArray];
}

- (void)addNewMessage:(PRMessageModel*)message
{
    BOOL isModelTaskLink = [message isTasklink];

    int i = 0;
    int oldPosition = 0;
    BOOL alreadyHaveThisTask = NO;

    if (![message isTasklink] && ([self isTextMessageWithGuidAlreadyExisted:message.guid] || ![message text])) {
        return;
    }

    for (; i < _messages.count; i++) {
        if (isModelTaskLink) {
            if ([_messages[i] isTasklink]) {
                PRMessageModel* taskLinkIterator = _messages[i];
                if ([message.content.task.taskLinkId isEqualToNumber:taskLinkIterator.content.task.taskLinkId]) {
                    alreadyHaveThisTask = YES;
                    oldPosition = i;
                }
            }
        }

        if ((![message.guid isEqualToString:_messages[i].guid])
            && (message.timestamp.longValue <= (_messages[i].timestamp.longValue))
            && (![message isTasklink])) {
            break;
        }
    }

    if (isModelTaskLink && alreadyHaveThisTask) {

        if ([message.content.task.completed boolValue]) {
            [_messagesTableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:oldPosition inSection:0] ] withRowAnimation:UITableViewRowAnimationNone];
        } else {
            int index = i < _messages.count ? i : i - 1;
            [_messages removeObjectAtIndex:oldPosition];
            [_messages insertObject:message atIndex:index];
            [self filterMessagesArray];
            [self scrollToBottomWithAnimation:YES];
        }

        return;
    }

    [_messages insertObject:message atIndex:i];
    [self filterMessagesArray];
    [self scrollToBottomWithAnimation:YES];
}

- (void)checkNotContainsLinkAndCloseKeyboard:(UITapGestureRecognizer*)tap
{
    if (!tap) {
		return;
    }

	NSArray<PRChatMessageBaseViewCell*>* cells = [(UITableView*)tap.view visibleCells];
	for (PRChatMessageBaseViewCell* cell in cells) {

		CGRect cellRectInTableView = [_messagesTableView rectForRowAtIndexPath:[_messagesTableView indexPathForCell:cell]];
		CGRect cellRectInVisibleview = [_messagesTableView convertRect:cellRectInTableView toView:[_messagesTableView superview]];

		if (CGRectContainsPoint(cellRectInVisibleview, [tap locationInView:self.view])) {
			if ([cell isKindOfClass:[ChatTaskCell class]] || [cell.messageLabel containslinkAtPoint:[tap locationInView:cell.messageLabel]]) {
				return;
			}
		}
	}

	if (_isKeyboardUp) {
		_didSelectFooterView = YES;
		[_typingTextView resignFirstResponder];
	}

	[self setChatServicesViewStateToNormalWithAnimation];
}

- (void)profileHasBeenLoaded
{
    PRUserProfileModel* userProfile = [PRDatabase getUserProfile];
    _clientId = userProfile.username;
    if (_messages.count == 0) {
        [self messagesForChannelId:[self currentChatIdWithPrefix]];
    }

    [self setupAssistantInfoDataSource];
}

#pragma mark - Functionality

- (void)startAnimationOfVoiceRecording:(void (^)())compilation
{
    static const CGFloat animationDuration = 0.3f;
    NSInteger sizeIncreasingMultiplayer = (CGRectGetHeight([UIScreen mainScreen].bounds) / 5) / kMicrophoneButtonBeckgroundViewDefaultWidth;

    _recordingAnimationState = PRRecordingAnimationState_Recording;

    [UIView animateWithDuration:animationDuration
                     animations:^{
                         [self setMicrophoneButtonBackgroundViewHidden:NO];
                         _microphoneButtonBeckgroundViewWidthConstraint.constant = CGRectGetWidth(_microphoneButtonBackgroundView.frame) * sizeIncreasingMultiplayer;
                         _microphoneButtonBackgroundView.layer.cornerRadius = CGRectGetWidth(_microphoneButtonBackgroundView.frame) * sizeIncreasingMultiplayer / 2;
                         _microphoneButtonBackgroundShadowView.layer.cornerRadius = CGRectGetWidth(_microphoneButtonBackgroundShadowView.frame) * sizeIncreasingMultiplayer / 2;
                         [_microphoneButton setImage:[UIImage imageNamed:kMicrophoneButtonImageNameInSelectedMode] forState:UIControlStateNormal];

                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         if (_recordingAnimationState == PRRecordingAnimationState_Recording) {
                             [self setRecordingDetailsViewHidden:NO cancelViewHidden:NO];
                             compilation();
                         }
                     }];
}

- (void)stopAnimationOfVoiceRecording
{
    if (_recordingAnimationState == PRRecordingAnimationState_Stopped) {
        return;
    }

    _recordingAnimationState = PRRecordingAnimationState_Stopped;
    [self setRecordingDetailsViewHidden:YES cancelViewHidden:YES];

    [_recordingTimer invalidate];
    _recordingTimer = nil;

    [self setMicrophoneButtonBackgroundViewHidden:YES];
    _microphoneButtonBeckgroundViewWidthConstraint.constant = kMicrophoneButtonBeckgroundViewDefaultWidth;

    UIImage* image = [[UIImage imageNamed:kMicrophoneButtonImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_microphoneButton setImage:image forState:UIControlStateNormal];
}

- (void)stopVoiceRecording:(NSData*)audioFile
{
    [self stopAnimationOfVoiceRecording];

    if (audioFile) {
        [self sendVoiceMessage:audioFile];
    }
}

- (void)startVoiceRecordingWithoutAnimation
{
    _recordingAnimationState = PRRecordingAnimationState_Recording;

    [self setRecordingDetailsViewHidden:NO cancelViewHidden:YES];
    [self setupRecordingDurationLabelForVoiceRecord];

    [_audioPlayer recordAudio:^(NSData* audioFile) {
        [self stopVoiceRecording:audioFile];
    }];
}

- (void)sendVoiceMessage:(NSData*)audioFile
{
    if ([PRRequestManager connectionRequired]) {
        return;
    }

    PRMessageModel* messageModel = [PRMessageProcessingManager sendVoiceMessage:audioFile toChannelWithID:[self currentChatIdWithPrefix]];
    messageModel = [messageModel MR_inThreadContext];

    [_messages addObject:messageModel];
    [self scrollToBottomWithAnimation:YES];
}

#pragma mark - Helpers

- (void)messagesForChannelId:(NSString*)channelId
{
    PRMessageModel* firstMessage = [_messages firstObject];

    if (!channelId) {
		[self finishRefreshNewData];
		return;
    }

	__weak ChatViewController* weekSelf = self;
	[PRMessageProcessingManager getMessagesForChannelId:channelId
												   guid:firstMessage.guid
												  limit:@kMessagesFetchLimit
												 toDate:firstMessage.timestamp
											   fromDate:nil
												success:^(NSArray<PRMessageModel*>* messages) {
													[weekSelf handleFetchedMessages:messages startingFrom:firstMessage];
												}
												failure:^{
													[self finishRefreshNewData];
													NSArray<PRMessageModel*>* messagesInCoreData = [PRDatabase messagesForChannelId:[self currentChatIdWithPrefix]];
													self.messages = [messagesInCoreData mutableCopy];
													[self filterMessagesArray];
													[self finishRefreshNewData];
													_fetchedMessageCategory = MessagesFetchType_NextLoad;
													_hasNewMessages = NO;
													[self removeTableViewHeaderAndReload];
													[_messagesTableView reloadData];
												}];
}

- (void)updateTableViewForVoiceMessageStatusUpdate:(NSNotification*)notification
{
    [_messagesTableView reloadData];
}

- (BOOL)isTextMessageWithGuidAlreadyExisted:(NSString*)guid
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"guid = %@ AND content = nil AND text != nil", guid];
    NSMutableArray<PRMessageModel*>* messagesArray = [[_messages filteredArrayUsingPredicate:predicate] mutableCopy];

    if ([messagesArray count]) {
        return YES;
    }

    return NO;
}

- (void)addNewMessagesFromArray:(NSArray<PRMessageModel*>*)messagesArray
{
    // This case happens only, when application runs first time after download.
    if (_messages.count == 0) {
        self.messages = [messagesArray mutableCopy];
        [self filterMessagesArray];
        [(PRUITabBarController*)self.tabBarController showBadge];

        [_messagesTableView reloadData];
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[_messages count] - 1 inSection:0];
        [_messagesTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        return;
    }

    for (PRMessageModel* message in messagesArray) {
        [self addNewMessage:message];
    }
}

- (BOOL)doesTasklinkHaveMassage:(PRTasklinkContent*)tasklink
{
    BOOL result = NO;

    if (!tasklink) {
        return result;
    } else if (tasklink.message) {
        result = YES;
    } else {
        NSArray<PRMessageModel*>* messagesForTaskLink = [PRDatabase messagesForChannelId:[ChatUtility chatIdWithPrefix:tasklink.task.taskLinkId.stringValue]];
        result = [messagesForTaskLink count];
    }

    return result;
}

- (void)filterMessagesArray
{
    [PRDatabase removeExpiredMessages];
    [self removeMessagesWithDeletedStatus];

    // Get tasklinks from all messages.
    NSPredicate* taskLinkPredicate = [NSPredicate predicateWithFormat:@"content != nil"];
    NSArray<PRMessageModel*>* taskLinksArray = [[_messages filteredArrayUsingPredicate:taskLinkPredicate] copy];

    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    NSMutableArray<PRMessageModel*>* messagesThatContainDuplicates = [NSMutableArray new];

    for (PRMessageModel* taskLinkModel in taskLinksArray) {

        // Find duplicates tasklinks. All tasklinks with same task Id.
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"content.task.taskLinkId = %@", taskLinkModel.content.task.taskLinkId];
        NSMutableArray<PRMessageModel*>* duplicateMessages = [[_messages filteredArrayUsingPredicate:predicate] mutableCopy];

        if (duplicateMessages.count > 1) {

            duplicateMessages = [[duplicateMessages sortedArrayUsingDescriptors:@[ sortDescriptor ]] mutableCopy];
            PRMessageModel* originalMessage = [duplicateMessages lastObject];

            // Find task that have message.
            for (NSInteger i = ([duplicateMessages count] - 1); i >= 0; i--) {
                if (duplicateMessages[i].content.message != nil) {
                    originalMessage = duplicateMessages[i];
                    break;
                }
            }

            [duplicateMessages removeObject:originalMessage]; // Remove original message from duplicates array.
            [_messages removeObjectsInArray:duplicateMessages]; // Remove duplicate messages from all messages.

            // In case, if status of tasklink that appear in chat not 'SEEN', there is need to remove duplicate messages only from array, not from database in order to show unseen messages count in badge.
            if ([[originalMessage status] isEqualToString:kMessageStatus_Seen]) {
                [messagesThatContainDuplicates addObject:originalMessage]; // Move duplicate messages to another array, in order to remove them from database later.
            }
        }
    }

    // Remove duplicates messages from database.
    [PRDatabase removeDuplicateTaskLinks:messagesThatContainDuplicates
                              completion:^(bool objectsDidRemoved) {
                                  if (objectsDidRemoved) {
                                      [(PRUITabBarController*)self.tabBarController showBadge];
                                  }
                              }];

    self.messages = [[_messages sortedArrayUsingDescriptors:@[ sortDescriptor ]] mutableCopy];

    // Get last four message in _messages and save for widget
    [self saveMessagesForWidget];
}

- (void)saveMessagesForWidget
{
    NSMutableArray *messagesForWidget = [NSMutableArray new];
    NSInteger i = _messages.count > kWidgetMaxMessagesCount ? kWidgetMaxMessagesCount : _messages.count;
    for ( ; i > 0; i--) {
        [messagesForWidget addObject:_messages[_messages.count - i]];
    }
    [[PRUserDefaultsManager sharedInstance] setWidgetMessages:messagesForWidget];
}

- (void)removeMessagesWithDeletedStatus
{
    NSPredicate* predicateForDeletedMessages = [NSPredicate predicateWithFormat:@"status == %@", kMessageStatus_Deleted];
    NSArray<PRMessageModel*>* messagesToRemove = [[_messages filteredArrayUsingPredicate:predicateForDeletedMessages] copy];

    if ([messagesToRemove count]) {
        [_messages removeObjectsInArray:messagesToRemove];
        [PRDatabase deleteMessageModelsFromArray:messagesToRemove];
    }
}

- (void)setupRecordingAnimationComponents
{
    static const CGFloat microphoneButtonBackgroundShadowViewTransparency = 0.5f;

    UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didPressMicrophoneButton:)];
    [_microphoneButton addGestureRecognizer:longPress];

    UIImage* image = [[UIImage imageNamed:kMicrophoneButtonImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_microphoneButton setImage:image forState:UIControlStateNormal];
#if defined(VTB24)
    [_microphoneButton.imageView setTintColor:kChatSendTextColor];
    _microphoneButtonBackgroundShadowView.backgroundColor = kChatSendTextColor;
    _microphoneButtonBackgroundView.backgroundColor = kChatSendTextColor;
#else
    [_microphoneButton.imageView setTintColor:kIconsColor];
    _microphoneButtonBackgroundShadowView.backgroundColor = kIconsColor;
    _microphoneButtonBackgroundView.backgroundColor = kIconsColor;
#endif
    [_microphoneButton setHidden:NO];
    _microphoneButtonBackgroundShadowView.alpha = microphoneButtonBackgroundShadowViewTransparency;
    [self setMicrophoneButtonBackgroundViewHidden:YES];

    _recordingCancelLabel.text = NSLocalizedString(kRecordingCancelLabelText, nil);
    _recordingCancelLabel.textColor = kRecordingCancelLabelTextColor;

    _recordingIndicatorView.layer.cornerRadius = CGRectGetWidth(_recordingIndicatorView.frame) / 2;
    _recordingIndicatorView.backgroundColor = [UIColor redColor];
    _recordingIndicatorView.alpha = 1;
    _microphoneButton.enabled = ![PRRequestManager connectionRequired];
}

- (void)setSendButtonHidden:(BOOL)hidden
{
    _sendButton.hidden = hidden;
    _microphoneButton.hidden = !hidden;
}

- (void)setRecordingDetailsViewHidden:(BOOL)hidden cancelViewHidden:(BOOL)cancelViewHidden
{
    _recordingDetailsView.hidden = hidden;
    _typingContainerView.hidden = !hidden;
    _recordingCancelView.hidden = cancelViewHidden;
}

- (void)setMicrophoneButtonBackgroundViewHidden:(BOOL)hidden
{
    _microphoneButtonBackgroundView.hidden = hidden;
    _microphoneButtonBackgroundShadowView.hidden = hidden;
}

- (void)setupRecordingDurationLabelForVoiceRecord
{
    _recordingDurationLabel.text = [_audioPlayer recordingDuration];
    _recordingTimer = [NSTimer scheduledTimerWithTimeInterval:kRecordingTimerTimeInterval target:self selector:@selector(updateRecordingTime) userInfo:nil repeats:YES];
}

#pragma mark - Actions

- (void)didPressMicrophoneButton:(UILongPressGestureRecognizer*)gesture
{
    [PRGoogleAnalyticsManager sendEventWithName:kMicrophonePressed parameters:nil];
    static BOOL doNotCnacel = NO;
    static CGPoint startLocation;
    static CGPoint previousLocation;
    static const CGFloat kAllowableTranslationInVerticalDirection = 10.0f;

    CGPoint location = [gesture locationInView:self.view];

    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: { // Start recording.

            if (_recordingAnimationState == PRRecordingAnimationState_Recording) {
                [self stopAnimationOfVoiceRecording];
                [_audioPlayer stopRecording:^(NSData* audioFile){
                }];
                break;
            }

            startLocation = location;

            [self startAnimationOfVoiceRecording:^{
                [self setupRecordingDurationLabelForVoiceRecord];
                [_audioPlayer recordAudio:^(NSData* audioFile) {
                    [self stopVoiceRecording:audioFile];
                }];
            }];

            break;
        }
        case UIGestureRecognizerStateChanged: { // Cancel recording.

            if (_recordingAnimationState != PRRecordingAnimationState_Recording) {
                break;
            }

            CGPoint translation = CGPointMake(startLocation.x - location.x, startLocation.y - location.y);
            CGSize screenSize = [UIScreen mainScreen].bounds.size;

            if (CGRectContainsPoint(_microphoneButton.frame, location)) {
                doNotCnacel = NO;
            }

            // In case of swipe left.
            if (fabs(translation.y) < kAllowableTranslationInVerticalDirection && !doNotCnacel) {

                if (translation.x >= (screenSize.width / 2)) {
                    [self stopAnimationOfVoiceRecording];
                    [_audioPlayer stopRecording:^(NSData* audioFile){
                    }];
                }

                NSInteger horizontalTranslation = (roundf(-translation.x) + kAllowableTranslationInVerticalDirection) * 2 / 3;
                _recordingCancelViewCenterXConstraint.constant = (horizontalTranslation > 0) ? 0 : horizontalTranslation;
            } else {
                doNotCnacel = YES;
                _recordingCancelViewCenterXConstraint.constant = 0;
            }

            previousLocation = location;
            break;
        }
        case UIGestureRecognizerStateEnded: { // Stop recording.

            startLocation = CGPointZero;
            previousLocation = CGPointZero;
            doNotCnacel = NO;
            _recordingCancelViewCenterXConstraint.constant = 0;

            if (_recordingAnimationState == PRRecordingAnimationState_Stopped) {
                break;
            }

            [self stopAnimationOfVoiceRecording];
            [_audioPlayer stopRecording:^(NSData* audioFile) {
                if (audioFile) {
                    [self sendVoiceMessage:audioFile];
                }
            }];

            break;
        }
        default:
            break;
    }
}

- (void)updateRecordingTime
{
    static const CGFloat animationDuration = 0.5f;

    _recordingDurationLabel.text = [_audioPlayer recordingDuration];
    [self.view layoutIfNeeded];

    [UIView animateWithDuration:animationDuration
                     animations:^{
                         CGFloat alpha = _recordingIndicatorView.alpha;
                         _recordingIndicatorView.alpha = alpha ? 0 : 1;

                         [self.view layoutIfNeeded];
                     }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section;
{
    return _messages.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView;
{
    return 1;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    PRMessageModel* messageModel = _messages[indexPath.row];
    ChatMessageType messageType = [messageModel messageType];

    if ([messageModel isTasklink]) {
        ChatTaskCell* chatCell = [tableView dequeueReusableCellWithIdentifier:kTaskCellIdentifier];
        if (chatCell == nil) {
            chatCell = [[ChatTaskCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTaskCellIdentifier];
        }
        [chatCell setSelectionStyle:UITableViewCellSelectionStyleNone];

        [chatCell setTaskInformation:messageModel.content.task];
        PRMessageModel* tasklinkLastMessage = [PRDatabase getTaskLinkLastMessage:messageModel];
        [chatCell setTaskLastMessageInfo:tasklinkLastMessage];
        [chatCell setGuid:messageModel.guid];

        return chatCell;
    }

    PRChatMessageBaseViewCell* cell;
    BOOL isLeftCell = ![messageModel.clientId isEqualToString:[NSString stringWithFormat:@"%@%@", kClientPrefix, _clientId]];
    NSInteger messageStatus = [messageModel getMessageStatus];

    if (messageType == ChatMessageType_Voice) {
        cell = [tableView dequeueReusableCellWithIdentifier:isLeftCell ? kReceivedVoiceMessageCellIdentifier : kSentVoiceMessageCellIdentifier];
        [(PRVoiceMessageCell*)cell setAudioFileName:messageModel.audioFileName];
        [(PRVoiceMessageCell*)cell setGuid:messageModel.guid];
    } else if(messageType == ChatMessageType_Image) {
        cell = [tableView dequeueReusableCellWithIdentifier:isLeftCell ? kReceivedPhotoMessageCellIdentifier : kSentPhotoMessageCellIdentifier];
        [(PRChatPhotoMessageViewCell*)cell setMessageImageWithPath:[NSString stringWithFormat:@"%@_min", messageModel.mediaFileName] isLocation:NO];
    } else if(messageType == ChatMessageType_Contact) {
        cell = [tableView dequeueReusableCellWithIdentifier:isLeftCell ? kReceivedContactMessageCellIdentifier : kSentContactMessageCellIdentifier];
        [(PRChatContactMessageViewCell*)cell setContactWithPath:messageModel.guid];
        [(PRChatContactMessageViewCell*)cell setPresenter:self];
    } else if(messageType == ChatMessageType_Location) {
        cell = [tableView dequeueReusableCellWithIdentifier:isLeftCell ? kReceivedLocationMessageCellIdentifier : kSentLocationMessageCellIdentifier];
        [(PRChatPhotoMessageViewCell*)cell setMessageImageWithPath:messageModel.mediaFileName isLocation:YES];
    } else if(messageType == ChatMessageType_Document) {
        cell = [tableView dequeueReusableCellWithIdentifier:isLeftCell ? kReceivedDocumentMessageCellIdentifier : kSentDocumentMessageCellIdentifier];
        [(PRChatDocumentMessageViewCell*)cell setMessageFileInfoWithPath:[NSString stringWithFormat:@"%@/%@_info", messageModel.mediaFileName, messageModel.mediaFileName]];
    }else if(messageType == ChatMessageType_Video) {
        cell = [tableView dequeueReusableCellWithIdentifier:isLeftCell ? kReceivedVideoMessageCellIdentifier : kSentVideoMessageCellIdentifier];
        [(PRChatVideoMessageViewCell*)cell setMessageImageWithPath:messageModel.guid];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:isLeftCell ? kLeftCellIdentifier : kRightCellIdentifier];

        [cell setMessageText:messageModel.text messageGuid:messageModel.guid];
        [cell.messageLabel sizeToFit];
    }

    if (!isLeftCell) {
        [cell deleteResendButton];

        if (messageStatus == MessageStatus_Sent) {
            [cell statusSent];
        } else if (messageStatus == MessageStatus_Reserved) {
            [cell statusReserved];
        } else if (messageStatus == MessageStatus_Seen) {
            [cell statusRead];
        } else {
            if (!messageModel.isSent && messageModel.state == (MessageState_Aborted)) {
                cell.viewDelegate = self;
                [cell statusSendingRedIndicator];
                [cell createResendButton];
                [cell setResendMessageButtonTag:indexPath.row];
            } else if (!messageModel.isSent) {
                [cell statusSendingGrayIndicator];
            }
        }
    }

    [self showHeaderIfNeeded:cell forModel:messageModel atIndexPath:indexPath];
    [cell setDate:[messageModel.timestamp longLongValue]];
    [cell updateConstraints];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return 15;
}

- (UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section
{

    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 15)];
    footerView.backgroundColor = [UIColor clearColor];

    return footerView;
}

- (CGFloat)tableView:(UITableView*)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    PRMessageModel* messageModel = _messages[indexPath.row];
    ChatMessageType messageType = [messageModel messageType];

    if (messageType == ChatMessageType_Tasklink) {

        static dispatch_once_t onceToken;
        static ChatTaskCell* cellForTask = nil;
        dispatch_once(&onceToken, ^{
            cellForTask = [tableView dequeueReusableCellWithIdentifier:kTaskCellIdentifier];
        });

        PRMessageModel* message = [PRDatabase getTaskLinkLastMessage:messageModel];

        return [cellForTask taskCellEstimatedHeightForTask:messageModel.content.task
                                                andMessage:message];
    } else if (messageType == ChatMessageType_Voice) {
        return kVoiceMessageCellEstimatedHeight;
    }

    return kTextMessageCellEstimatedHeight;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (_didSelectFooterView) {
        _didSelectFooterView = NO;
        return;
    }

    PRMessageModel* messageModel = _messages[indexPath.row];

    _chatMessageViewCell = [_messagesTableView cellForRowAtIndexPath:_currentIndexPath];
    if([_chatMessageViewCell isKindOfClass:[PRChatPhotoMessageViewCell class]]){
        PRChatPhotoMessageViewCell* cell = (PRChatPhotoMessageViewCell*)_chatMessageViewCell;
        if([cell isLocation])
        {
            LocationPreviewViewController* locationPreview = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"LocationPreviewViewController"];
            [locationPreview setCoordinate:[cell coordinate]];
            [locationPreview setMapViewMode:YES];
            [self.navigationController pushViewController:locationPreview
                                                 animated:YES];
        }
        else
        {
            NSURL* directory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                   inDomains:NSUserDomainMask] lastObject];
            NSString* docDirPath = [directory path];
            NSString* filePath = [NSString stringWithFormat:@"%@/%@", docDirPath, messageModel.guid];
            UIImage* image = [UIImage imageNamed:filePath];
            if(image)
            {
                [self showPhoto:image];
            }
            else
            {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"DocumentLarge" bundle: nil];
                DocumentLargeViewController* documentLargeViewController = (DocumentLargeViewController*)[storyboard  instantiateViewControllerWithIdentifier:@"DocumentLargeViewController"];
                filePath = [NSString stringWithFormat:@"%@/%@", docDirPath, [NSString stringWithFormat:@"%@_min", messageModel.guid]];
                image = [UIImage imageNamed:filePath];
                [documentLargeViewController setModel:messageModel];
                [self.navigationController pushViewController:documentLargeViewController animated:YES];
                [documentLargeViewController setImage:image];
            }
        }
    }
    if([_chatMessageViewCell isKindOfClass:[PRChatContactMessageViewCell class]]){
        PRChatContactMessageViewCell* cell = (PRChatContactMessageViewCell*)_chatMessageViewCell;
        CNContactViewController *contactViewController = [CNContactViewController viewControllerForUnknownContact:[cell getContact]];
        [self.navigationController pushViewController:contactViewController animated:YES];
    }
    if([_chatMessageViewCell isKindOfClass:[PRChatDocumentMessageViewCell class]]){
        DocumentPreviewViewController *documentPreviewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"DocumentPreviewViewController"];

        NSURL* directory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                   inDomains:NSUserDomainMask] lastObject];
        NSString* docDirPath = [directory path];
        NSString *documentInfoFilePath = [NSString stringWithFormat:@"%@/%@/%@_info", docDirPath, messageModel.guid, messageModel.guid];
        NSData* data = [NSData dataWithContentsOfFile:documentInfoFilePath];
        if(!data)
            return;
        NSDictionary* messageDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if(!messageDictionary)
            return;
        [documentPreviewController setFilePathWithGuid:messageModel.guid fileName:[messageDictionary valueForKey:kDocumentMessageFileNameKey]];
        [documentPreviewController setDocumentDownloadingPath:messageModel.text];
        [documentPreviewController setSendingMode:NO];
        [self.navigationController pushViewController:documentPreviewController
                                             animated:YES];
    }
    if([_chatMessageViewCell isKindOfClass:[PRChatVideoMessageViewCell class]]){
        VideoPlayer *videoPlayer = (VideoPlayer*)[self.storyboard  instantiateViewControllerWithIdentifier:@"VideoPlayerIdentifier"];

        [videoPlayer setPreviewImage:[(PRChatVideoMessageViewCell*)_chatMessageViewCell getMessageImage]];
        [videoPlayer setFilePathWithGuid:messageModel.guid];
        [videoPlayer setVideoDownloadingPath:messageModel.text];

        [self.navigationController pushViewController:videoPlayer
                                             animated:YES];
    }

    if (![messageModel isTasklink] || ([messageModel messageType] == ChatMessageType_Voice)) {
        return;
    }

    PRTasklinkContent* tasklinkMessage = messageModel.content;

    if (!tasklinkMessage.task.taskId) {
        NSAssert(tasklinkMessage.task.taskId, @"tasklinkMessage.task.taskId can't be nil.");
        return;
    }

    _state = PRChatServicesViewState_Normal;

    if ([self doesTasklinkHaveMassage:tasklinkMessage]) {
        [PRGoogleAnalyticsManager sendEventWithName:kTaskLinkClicked parameters:nil];
        [self openChatWithTask:tasklinkMessage.task];
        [_typingTextView resignFirstResponder];
        return;
    }

    [self openRequestForTask:tasklinkMessage.task];
    [_typingTextView resignFirstResponder];
}

- (void)tableView:(UITableView*)tableView willDisplayCell:(PRChatMessageBaseViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    PRMessageModel* messageModel = _messages[indexPath.row];

    if(indexPath.row == 0) {
        if (firstRowDisplayCount > 0) {
            if (_hasNewMessages) {
                [self startRefreshNewData];
            }
            firstRowDisplayCount = 0;
        }
        firstRowDisplayCount ++;
    }

    if (![messageModel.status isEqualToString:kMessageStatus_Seen] && (![messageModel.clientId isEqualToString:[NSString stringWithFormat:@"%@%@", kClientPrefix, _clientId]])) {
        [self updateStatusForMessage:messageModel];
    }

    if ([messageModel isTasklink]) {
        ChatTaskCell* chatCell = (ChatTaskCell*)cell;

        PRMessageModel* tasklinkLastMessage = [PRDatabase getTaskLinkLastMessage:messageModel];
        [chatCell setTaskLastMessageInfo:tasklinkLastMessage];

    } else if ([messageModel messageType] == ChatMessageType_Voice) {
        if (!messageModel.audioFileName || [messageModel.audioFileName isEqualToString:@""]) {
            [PRMessageProcessingManager getAudioFileForVoiceMessage:messageModel];
        }
    } else if ([messageModel messageType] == ChatMessageType_Image || [messageModel messageType] == ChatMessageType_Video || [messageModel messageType] == ChatMessageType_Document || [messageModel messageType] == ChatMessageType_Contact || [messageModel messageType] == ChatMessageType_Location) {
        if (!messageModel.mediaFileName || [messageModel.mediaFileName isEqualToString:@""]) {
            [PRMessageProcessingManager getFileForMediaMessage:messageModel];
        }
    } else {
        [cell setMessageText:messageModel.text messageGuid:messageModel.guid];
        [cell.messageLabel sizeToFit];
    }

    [UIView setAnimationsEnabled:NO];
    [cell.contentView setNeedsLayout];
    [cell.contentView layoutIfNeeded];
    [UIView setAnimationsEnabled:YES];
}

#pragma mark - PRChatServicesViewDelegate

- (void)didSelectMenuItem:(PRServicesModel*)menuItemData
{
    _state = PRChatServicesViewState_Normal;

    [PRGoogleAnalyticsManager sendEventWithName:[NSString stringWithFormat:kServiceIconClicked, menuItemData.name] parameters:nil];

    if (menuItemData.nativeUrl && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:menuItemData.nativeUrl]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:menuItemData.nativeUrl]];
        return;
    }

    WebViewController* viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    viewController.url = menuItemData.url;
    viewController.title = menuItemData.name;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)didPressMoreButton
{
    [PRGoogleAnalyticsManager sendEventWithName:kMoreButtonClicked parameters:nil];
    if (_isKeyboardUp) {
        [UIView animateWithDuration:KServicesAnimationDuration
                         animations:^{
                             [_typingTextView resignFirstResponder];
                         }];
    }

    if (_state == PRChatServicesViewState_Expanded) {
        [self setChatServicesViewStateToNormalWithAnimation];
    } else {

        CGFloat height = [_chatServicesView heightForExpandedState];
        CGPoint offset = _messagesTableView.contentOffset;

        _extraHeight = height - kChatServicesViewDefaultHeight;
        offset.y += _extraHeight;

        [UIView animateWithDuration:KServicesAnimationDuration
                         animations:^{
                             _chatServicesViewHeightConstraint.constant = height;
                             _typingViewBottomConstraint.constant = height;
                             [_messagesTableView setContentOffset:offset];

                             [self.view layoutIfNeeded];
                         }];

        _state = PRChatServicesViewState_Expanded;
    }
}

- (void)setChatServicesViewStateToNormalWithAnimation
{

    if (_chatServicesView.state == PRChatServicesViewState_Normal) {
        return;
    }

    _state = PRChatServicesViewState_Normal;
    CGPoint offset = _messagesTableView.contentOffset;
    offset.y -= _extraHeight;

    [UIView animateWithDuration:KServicesAnimationDuration
                     animations:^{
                         _chatServicesViewHeightConstraint.constant = kChatServicesViewDefaultHeight;
                         _typingViewBottomConstraint.constant = kChatServicesViewDefaultHeight;
                         [_messagesTableView setContentOffset:offset];

                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         [_chatServicesView setState:PRChatServicesViewState_Normal];
                     }];
}

- (void)setChatServicesViewStateTo:(PRChatServicesViewState)state
{
    if (state == [_chatServicesView state]) {
        return;
    }

    CGFloat height = kChatServicesViewDefaultHeight;
    CGPoint offset = _messagesTableView.contentOffset;

    switch (state) {
        case PRChatServicesViewState_Normal: {
            offset.y -= _extraHeight;
            [_chatServicesView setState:PRChatServicesViewState_Normal];
        } break;
        case PRChatServicesViewState_Expanded: {
            height = [_chatServicesView heightForExpandedState];
            _extraHeight = height - kChatServicesViewDefaultHeight;
            offset.y += _extraHeight;
        } break;
        default:
            return;
    }

    if (!_isKeyboardUp) {
        _chatServicesViewBottomConstraint.constant = 0;
    }

    _chatServicesViewHeightConstraint.constant = height;
    _typingViewBottomConstraint.constant = height;
    [_messagesTableView setContentOffset:offset];
}

#pragma mark - Message Status

- (void)updateStatusForMessage:(PRMessageModel*)messageModel
{
    if (!self.isViewLoaded || !self.view.window) {
        return;
    }

    NSManagedObjectContext* mainContext = [NSManagedObjectContext MR_contextForCurrentThread];

    if ([messageModel isTasklink]) {
        NSString* channelId = [self currentChatIdWithPrefix];
        NSArray<PRMessageModel*>* taskLinks = [PRDatabase unseenMessagesForTask:messageModel.content.task.taskLinkId
                                                                      channelId:channelId
                                                                       clientId:[ChatUtility clientIdWithPrefix]
                                                                      inContext:mainContext];

        for (PRMessageModel* task in taskLinks) {
            task.status = kMessageStatus_Seen;
        }
    } else {
        PRMessageModel* message = [PRDatabase messageByGuid:messageModel.guid inContext:mainContext];
        message.status = kMessageStatus_Seen;
    }

    [PRDatabase decrementUnseenMessagesCountOfSubscriptionForChannelId:messageModel.channelId];

    __weak id weakTabBarController = (PRUITabBarController*)self.tabBarController;
    [mainContext MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError* _Nullable error) {
        [PRMessageProcessingManager updateMessageStatus:kMessageStatus_Seen guid:messageModel.guid];

        PRUITabBarController* strongTabBarController = weakTabBarController;
        if (!strongTabBarController) {
            return;
        }

        [strongTabBarController showBadge];
        NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:kUnseenMessageUpdate object:nil userInfo:nil];
        NSInteger indexOfMessageModel = [_messages indexOfObject:messageModel];

        if (indexOfMessageModel < [_messages count]) {
            [_messages removeObjectAtIndex:indexOfMessageModel];
            messageModel.status = kMessageStatus_Seen;
            [_messages insertObject:messageModel atIndex:indexOfMessageModel];
        }
    }];
}

- (void)showHeaderIfNeeded:(PRChatMessageBaseViewCell*)cell forModel:(PRMessageModel*)messageModel atIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.row == 0) {
        cell.needToShowHeaderView = YES;
        return;
    }
    PRMessageModel* previusMessageModel = _messages[indexPath.row - 1];
    NSDate* previusDate = [NSDate dateWithTimeIntervalSince1970:[previusMessageModel.timestamp doubleValue]];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[messageModel.timestamp doubleValue]];

    cell.needToShowHeaderView = ![previusDate mt_isWithinSameDay:date];
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    if (!_isKeyboardUp) {
        return;
    }
    _isKeyboardUp = NO;

    if (_typingViewBottomConstraint.constant == 0) {
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
        return;
    }

    CGFloat bottomConstraintConst = 0;
#ifdef ENABLE_INITIATION_REQUEST_BUTTONS_IN_CHAT
    if (_hasServices && !_chatId) {
        bottomConstraintConst = kChatServicesViewDefaultHeight;
        _chatServicesView.hidden = NO;
        _chatServicesViewBottomConstraint.constant = 0;
    }
#endif
    _typingViewBottomConstraint.constant = bottomConstraintConst;

    NSDictionary<NSString*, NSValue*>* userInfo = [notification userInfo];

    CGPoint offset = _messagesTableView.contentOffset;
    CGSize keyboardSize = [[userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat minusForContentOffset = CGRectGetHeight(_typingContainerView.frame);
#ifdef ENABLE_INITIATION_REQUEST_BUTTONS_IN_CHAT
    if (_hasServices) {
        minusForContentOffset += CGRectGetHeight(_chatServicesView.frame);
    }
#endif
    offset.y -= (keyboardSize.height - CGRectGetHeight(self.tabBarController.tabBar.bounds) - minusForContentOffset);
    [_messagesTableView setContentOffset:offset];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

- (void)keyboardWillShow:(NSNotification*)notification
{
    if ((_isKeyboardUp || ![_typingTextView isFirstResponder]) && !_enableKeyboardAppearance) {
        return;
    }

    if (_chatServicesView.state == PRChatServicesViewState_Expanded) {
        _chatServicesViewHeightConstraint.constant = kChatServicesViewDefaultHeight;
        [_chatServicesView setState:PRChatServicesViewState_Normal];
    }

    NSDictionary<NSString*, NSValue*>* userInfo = [notification userInfo];

    CGPoint offset = _messagesTableView.contentOffset;
    CGSize keyboardSize = [[userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    _extraHeight = keyboardSize.height;
    offset.y += (_extraHeight - CGRectGetHeight(self.tabBarController.tabBar.bounds) - CGRectGetHeight(_typingContainerView.frame));
    [_messagesTableView setContentOffset:offset];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    _isKeyboardUp = YES;
}

- (IBAction)attachAction:(UIButton*)sender
{
    UIAlertController* alert = [UIAlertController
                                alertControllerWithTitle:nil
                                message:nil
                                preferredStyle:UIAlertControllerStyleActionSheet];

    NSString* imageNamePrefix = @"";
#if defined(Raiffeisen) || defined(VTB24) || defined(Otkritie) || defined(Platinum) || defined(Skolkovo) || defined(PrimeConciergeClub) || defined(PrivateBankingPRIMEClub) || defined(PrimeRRClub) || defined(PrimeClubConcierge)
    imageNamePrefix = @"corp_";
#endif
    if(!_mediaFileManager)
        _mediaFileManager = [[PRMediaFilesProcessingManager alloc] initWithPresenter:self];

    UIAlertAction* cameraButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"Camera", nil)
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action){
                                                             AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
                                                             if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)
                                                             {
                                                                 [InformationAlertController presentAlertDoesNotHaveAccessTo:AccessTo_Camera
                                                                                                                 onPresenter:self];
                                                             }
                                                             else
                                                             {

                                                                 [_mediaFileManager handleCameraAction];
                                                             }
                                                         }];

    [cameraButton setValue:kAttachMainColor forKey:@"titleTextColor"];
    [cameraButton setValue:@0 forKey:@"titleTextAlignment"];
    [cameraButton setValue:[[UIImage imageNamed:[NSString stringWithFormat:@"%@%@", imageNamePrefix, @"camera"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];

    UIAlertAction* photoVideoButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"Photo/Video", nil)
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action){
                                                                 PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
                                                                 if (authStatus == PHAuthorizationStatusRestricted || authStatus == PHAuthorizationStatusDenied)
                                                                 {
                                                                     [InformationAlertController presentAlertDoesNotHaveAccessTo:AccessTo_PhotoLibrary
                                                                                                                     onPresenter:self];
                                                                 }
                                                                 else
                                                                 {
                                                                     [_mediaFileManager handlePhotoVideoAction];
                                                                 }
                                                             }];
    [photoVideoButton setValue:kAttachMainColor forKey:@"titleTextColor"];
    [photoVideoButton setValue:@0 forKey:@"titleTextAlignment"];
    [photoVideoButton setValue:[[UIImage imageNamed:[NSString stringWithFormat:@"%@%@", imageNamePrefix, @"photo_video"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];

    UIAlertAction* documentButton = [UIAlertAction
                                     actionWithTitle:NSLocalizedString(@"Document", nil)
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action){
                                         [_mediaFileManager handleDocumentAction];
                                     }];
    [documentButton setValue:kAttachMainColor forKey:@"titleTextColor"];
    [documentButton setValue:@0 forKey:@"titleTextAlignment"];
    [documentButton setValue:[[UIImage imageNamed:[NSString stringWithFormat:@"%@%@", imageNamePrefix, @"document"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];

    UIAlertAction* locationButton = [UIAlertAction
                                     actionWithTitle:NSLocalizedString(@"Location", nil)
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action){
                                         if([CLLocationManager locationServicesEnabled])
                                         {
                                             [_mediaFileManager handleLocationAction];
                                         }
                                         else
                                         {
                                             [InformationAlertController presentAlertDoesNotHaveAccessTo:AccessTo_Location
                                                                                             onPresenter:self];
                                         }
                                     }];
    [locationButton setValue:kAttachMainColor forKey:@"titleTextColor"];
    [locationButton setValue:@0 forKey:@"titleTextAlignment"];
    [locationButton setValue:[[UIImage imageNamed:[NSString stringWithFormat:@"%@%@", imageNamePrefix, @"location"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];

    UIAlertAction* contactsButton = [UIAlertAction
                                     actionWithTitle:NSLocalizedString(@"Contacts", nil)
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action){
                                         [_mediaFileManager handleContactsAction];
                                     }];
    [contactsButton setValue:kAttachMainColor forKey:@"titleTextColor"];
    [contactsButton setValue:@0 forKey:@"titleTextAlignment"];
    [contactsButton setValue:[[UIImage imageNamed:[NSString stringWithFormat:@"%@%@", imageNamePrefix, @"contacts"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];

    UIAlertAction* cancelButton = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                   style:UIAlertActionStyleCancel
                                   handler:nil];
    [cancelButton setValue:kAttachCancelColor forKey:@"titleTextColor"];

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        [alert addAction:cameraButton];
    [alert addAction:photoVideoButton];
    if([[NSProcessInfo processInfo] operatingSystemVersion].majorVersion > 10)
    {
        [alert addAction:documentButton];
    }
    [alert addAction:locationButton];
    [alert addAction:contactsButton];
    [alert addAction:cancelButton];

    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)sendAction:(UIButton*)sender
{
    if (!_typingTextView.text || [_typingTextView.text isEqualToString:@""]) {
        return;
    }

    [PRGoogleAnalyticsManager sendEventWithName:kMessageSendAction parameters:nil];

    NSString* trimmedMessageText = [_typingTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if ([PRRequestManager connectionRequired] && [PRDatabase isUserProfileFeatureEnabled:ProfileFeature_SMS_Messages]) {
        [self sendMessageInOfflineMode:trimmedMessageText];
        return;
    }

    PRMessageModel* messageModel = [PRMessageProcessingManager sendMessage:trimmedMessageText toChannelWithID:[self currentChatIdWithPrefix]];
    messageModel = [messageModel MR_inThreadContext];

    [_messages addObject:messageModel];
    [self saveMessagesForWidget];
    _typingTextView.text = @"";
    _finalString = @"";
    [self setSendButtonHidden:YES];

    [self setTextViewHeightForText];
    [_messagesTableView reloadData];
    [self scrollToBottomWithAnimation:YES];
}

- (void)scrollToBottomWithAnimation:(BOOL)animated
{
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        if (_messagesTableView.contentSize.height > CGRectGetHeight(_messagesTableView.frame)) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[_messagesTableView numberOfRowsInSection:0] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:animated];
            });
        }
    }];

    [_messagesTableView reloadData];
    [CATransaction commit];
}

- (void)reachabilityChanged:(NSNotification*)notification
{
	_microphoneButton.enabled = YES;

	DLog(@"Websocket --------- Reachabiliy changed");
	if ([PRRequestManager connectionRequired]) {
		_microphoneButton.enabled = NO;
		_sendButton.enabled = [PRDatabase isUserProfileFeatureEnabled:ProfileFeature_SMS_Messages];

		_hasNewMessages = NO;
		firstRowDisplayCount = 0;
		self.messages = [[PRDatabase messagesForChannelId:[self currentChatIdWithPrefix]] mutableCopy];
		[self removeTableViewHeaderAndReload];
		[self scrollToBottomWithAnimation:YES];

		return;
	}

	if (_finalString && ![_finalString isEqualToString:@""]) {
		_sendButton.enabled = YES;
	}

	[_lazyManager shouldBeUpdatedIfReachabilityChangedWithNotification:notification
																  date:[NSDate date]
														relativeToDate:nil
																  then:^(PRRequestMode mode) {
		[PRRequestManager getProfileFeaturesWithView:self.view
												mode:PRRequestMode_ShowNothing
											 success:^(NSArray<PRUserProfileFeaturesModel*>* profileFeatures) {
		}
											 failure:^{
		}];
	}];

	_hasNewMessages = YES;
	if (!_messagesTableView.tableHeaderView) {
		[self setupTableViewHeader];
		[_messagesTableView reloadData];
		[self scrollToBottomWithAnimation:YES];
		if (_messages.count == 0) {
			[self startRefreshNewData];
		}
	}
}

- (IBAction)openResendMessageMenu:(UIButton*)sender
{
    [PRGoogleAnalyticsManager sendEventWithName:kResendMessageButtonClicked parameters:nil];

    if (_isKeyboardUp) {

        [self checkNotContainsLinkAndCloseKeyboard:nil];
    }

    UIButton* resendButton = sender;
    currentIndexPathForMessage = resendButton.tag;
    UIActionSheet* resendActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Message has not been sent", nil)
                                                                   delegate:self
                                                          cancelButtonTitle:@"Cancel"
                                                     destructiveButtonTitle:nil
                                                          otherButtonTitles:NSLocalizedString(@"Send again", nil), nil];

    [resendActionSheet showInView:_messagesTableView];
}

- (void)actionSheet:(UIActionSheet*)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 0) {
        return;
    }
    PRMessageModel* modelToSend = [_messages objectAtIndex:currentIndexPathForMessage];
    [PRMessageProcessingManager resetMessageState:modelToSend];
}

- (void)openRequestForTask:(PRTasklinkTask*)task
{
    RequestsDetailViewController* requestVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RequestsDetailViewController"];
    requestVC.taskId = task.taskId;
    requestVC.requestDate = task.requestDate;
    [self.navigationController pushViewController:requestVC animated:YES];
}

- (void)openChatWithTask:(PRTasklinkTask*)task
{
    ChatViewController* taskChat = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];

    UILabel* label = [[UILabel alloc] init];
    [label setFont:[UIFont systemFontOfSize:17 weight:UIFontWeightSemibold]];
    [label setTextColor:kNavigationBarTitleTextColor];

    [label setText:task.taskName];
    [label sizeToFit];

#if defined(Raiffeisen) || defined(VTB24) || defined(PrivateBankingPRIMEClub) || defined(Davidoff)
    [label setTextColor:kNavigationBarTitleColor];
#endif

    taskChat.navigationItem.titleView = label;

    taskChat.chatId = task.taskLinkId.stringValue;
    [self.navigationController pushViewController:taskChat
                                         animated:YES];
}

#pragma mark - TabBarItemChanged

- (void)updateViewController
{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)handleLongPressOnTabBar:(UILongPressGestureRecognizer*)gesture
{
    [PRGoogleAnalyticsManager sendEventWithName:kLongPressedOnChatTab parameters:nil];

    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: { // Start recording.
            if (![PRRequestManager connectionRequired]) {
                [self startVoiceRecordingWithoutAnimation];
            }
        } break;
        case UIGestureRecognizerStateEnded: { // Stop recording.

            if (_recordingAnimationState == PRRecordingAnimationState_Stopped) {
                return;
            }

            [self stopAnimationOfVoiceRecording];
            [_audioPlayer stopRecording:^(NSData* audioFile) {
                if (audioFile) {
                    [self sendVoiceMessage:audioFile];
                }
            }];
        } break;
        default:
            break;
    }
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController*)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];

    switch (result) {
        case MessageComposeResultCancelled: {
            if (_isKeyboardOpenedBeforeNavigation) {
                [_typingTextView becomeFirstResponder];
            }

            // Scroll to bottom.
            if ((_messagesTableView.contentSize.height > CGRectGetHeight(_messagesTableView.frame))) {
                [_messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[_messagesTableView numberOfRowsInSection:0] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
            }
            break;
        }

        case MessageComposeResultFailed: {
            [self showSMSErrorAlertWithMessage:@"Failed to send SMS"];
            break;
        }

        case MessageComposeResultSent: {
            _typingTextView.text = @"";
            _finalString = @"";
            _sendButton.hidden = YES;
            [self setTextViewHeightForText];
            break;
        }

        default:
            break;
    }
}

#pragma mark - Private functios

- (void)sendMessageInOfflineMode:(NSString*)message
{
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"No connection to the Internet", nil)
                                                                             message:NSLocalizedString(@"You can send a message...", nil)
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    __weak ChatViewController* weakSelf = self;
    UIAlertAction* actionSMS = [UIAlertAction actionWithTitle:NSLocalizedString(@"by SMS", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction* _Nonnull action) {
                                                          _enableKeyboardAppearance = NO;

                                                          if ([MFMessageComposeViewController canSendText]) {
                                                              [weakSelf showSMSSenderWithMessage:message];
                                                          } else {
                                                              [weakSelf showSMSErrorAlertWithMessage:@"SMS service is not available for your device"];
                                                          }
                                                      }];

    UIAlertAction* actionCancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction* _Nonnull action) {
                                                             _enableKeyboardAppearance = NO;
                                                         }];

    _enableKeyboardAppearance = YES;
    _isKeyboardOpenedBeforeNavigation = [_typingTextView isFirstResponder];
    [alertController addAction:actionSMS];
    [alertController addAction:actionCancel];
    [self presentViewController:alertController animated:YES completion:nil];

    [PRGoogleAnalyticsManager sendEventWithName:kMessageSendInOfflineModeDialog parameters:nil];
}

- (void)showSMSSenderWithMessage:(NSString*)message
{
    PRUserProfileModel* profile = [PRDatabase getUserProfile];

    if (!(profile.clubPhone.length && ![profile.clubPhone isEqualToString:@""])) {
		[self showSMSErrorAlertWithMessage:@"There is no phone number for sending SMS"];
		return;
    }

	MFMessageComposeViewController* composeVC = [[MFMessageComposeViewController alloc] init];
	composeVC.messageComposeDelegate = self;

	composeVC.recipients = @[ profile.clubPhone ];
	composeVC.body = message;
	composeVC.modalPresentationStyle = UIModalPresentationFullScreen;
	[self presentViewController:composeVC animated:YES completion:nil];
}

- (void)showSMSErrorAlertWithMessage:(NSString*)message
{
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil)
                                                                             message:NSLocalizedString(message, nil)
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction* _Nonnull action) {
                                                       _enableKeyboardAppearance = NO;
                                                   }];

    _enableKeyboardAppearance = YES;
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)moreButtonClickFromWidget
{
    __weak id weakSelf = self;
    [PRRequestManager getServicesWithLongitude:@(_currentLocation.coordinate.longitude)
                                      latitude:@(_currentLocation.coordinate.latitude)
                                      datetime:[NSDate date]
                                          view:self.view
                                          mode:PRRequestMode_ShowNothing
                                       success:^(NSArray<PRServicesModel*>* services) {
                                           [_chatServicesView setState:PRChatServicesViewState_Expanded];
                                           [weakSelf didPressMoreButton];
                                       }
                                       failure:^{
                                       }];
}

#pragma mark - Loading functios

-(void)startRefreshNewData
{
    _activityIndicatorView.alpha = 1.0f;
    [_activityIndicatorView startAnimating];
    if ([PRRequestManager connectionRequired]) {
        [self finishRefreshNewData];
        return;
    }
    [self messagesForChannelId:[self currentChatIdWithPrefix]];
}

-(void)finishRefreshNewData
{
    [_activityIndicatorView stopAnimating];
    _activityIndicatorView.alpha = 0.0f;
}

#pragma mark - Update Messages functios

- (void)setMessages:(NSMutableArray<__kindof PRMessageModel *> *)messages {
	_messages = messages;
	NSLog(@"MESSAGES");
	for (PRMessageModel *model in _messages) {
		NSLog(@"%@ - %@", model.type, model.text);
	}
}

- (void)handleFetchedMessages:(NSArray<PRMessageModel*>*)messages startingFrom:(PRMessageModel*)firstMessage
{
    switch (_fetchedMessageCategory) {
        case MessagesFetchType_FirstLoad: {
            self.messages = [[PRMessageProcessingManager getMessagesInRange:kMessagesFetchLimit forChannelId:[self currentChatIdWithPrefix]] mutableCopy];
            NSArray<PRMessageModel*>* messagesInCoreData = [PRDatabase messagesForChannelId:[self currentChatIdWithPrefix]];

            if (_messages.count == 0 && messagesInCoreData.count > 0) {
                self.messages = [messagesInCoreData mutableCopy];
                [self filterMessagesArray];
                [self finishRefreshNewData];
                _fetchedMessageCategory = MessagesFetchType_NextLoad;
                _hasNewMessages = NO;
                [self removeTableViewHeaderAndReload];
                [_messagesTableView reloadData];
                return;
            }

            [self filterMessagesArray];
            [_messagesTableView reloadData];
            [self scrollToBottomWithAnimation:NO];
            _fetchedMessageCategory = MessagesFetchType_NextLoad;

            [self finishRefreshNewData];

            if (messagesInCoreData.count < kMessagesFetchLimit) {
                _hasNewMessages = NO;
                [self removeTableViewHeaderAndReload];
            }
        } break;
        case MessagesFetchType_NextLoad: {
            NSArray<PRMessageModel*>* messagesWithoutStatusUpdate = [PRMessageProcessingManager filterMessages:messages withTimestamp:firstMessage.timestamp];
            [self updateMessagesAndReloadTableView:messagesWithoutStatusUpdate];
            BOOL hasExpiredMessages = [PRMessageProcessingManager hasExpiredMessages:messagesWithoutStatusUpdate];

            [self finishRefreshNewData];

            if (_fetchedFromCoreDataCount > 1 || hasExpiredMessages) {
                _hasNewMessages = NO;
                [self removeTableViewHeaderAndReload];
            }
        } break;
        default: {
            _hasNewMessages = NO;
            [self finishRefreshNewData];
            [self removeTableViewHeaderAndReload];
            return;
        }
    }
}

- (void)updateMessagesAndReloadTableView:(NSArray<PRMessageModel*>*)messages
{
    NSArray<PRMessageModel*>* finalMessages;

    if (messages.count > 0) {
        finalMessages = [[PRMessageProcessingManager getMessagesInRange:messages.count+_messages.count forChannelId:[self currentChatIdWithPrefix]] mutableCopy];
        _fetchedFromCoreDataCount = 0;
    } else {
        finalMessages = [[PRDatabase messagesForChannelId:[self currentChatIdWithPrefix]] mutableCopy];
        if (finalMessages.count == _messages.count) {
            _fetchedFromCoreDataCount++;
        }
    }

    NSInteger topRowIndex = _messages.count - 1;
    self.messages = [finalMessages mutableCopy];
    [self filterMessagesArray];

    [_messagesTableView reloadData];
    [_messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messages.count - topRowIndex inSection:0]
                              atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

-(void)setupTableViewHeader
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(self.messagesTableView.frame.origin.x, self.messagesTableView.frame.origin.y, self.messagesTableView.frame.size.width, 40)];
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicatorView.frame = CGRectMake(30.0f, 25.0f, 20.0f, 20.0f);
    [headerView addSubview:_activityIndicatorView];
    self.messagesTableView.tableHeaderView = headerView;
    CGPoint indicatorCenter = CGPointMake(self.view.center.x, headerView.center.y);
    _activityIndicatorView.center = indicatorCenter;
}

-(void)removeTableViewHeaderAndReload
{
    [_activityIndicatorView removeFromSuperview];
    self.messagesTableView.tableHeaderView = nil;
    [_messagesTableView reloadData];
}

@end
