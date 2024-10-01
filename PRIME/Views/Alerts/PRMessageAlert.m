//
//  PRMessageAlert.m
//  PRIME
//
//  Created by Simon on 31/01/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRMessageAlert.h"
#import "PRStatusModel.h"
#import "UIView+CustomToast.h"

typedef NS_ENUM(NSInteger, MessageType) {
    MessageType_Error,
    MessageType_Warning,
    MessageType_Info
};

typedef void (^RepeatFunction)();

@interface PRMessageAlert ()

@property (strong, nonatomic) RepeatFunction repeat;
@property (strong, nonatomic) RepeatFunction ok;

@end

@implementation PRMessageAlert

#pragma mark Public Methods
#pragma mark -

+ (void)showMessageWithStatus:(NSInteger)statusCode
                        error:(NSError*)error
{
    [self.class showMessageWithStatus:statusCode
                                error:error
                                   ok:nil];
}

+ (void)showMessageWithStatus:(NSInteger)statusCode
                        error:(NSError*)error
                           ok:(void (^)())ok
{
    [self.class showMessageWithStatus:statusCode
                                error:error
                                   ok:ok
                               repeat:nil];
}

+ (void)showMessageWithStatus:(NSInteger)statusCode
                        error:(NSError*)error
                           ok:(void (^)())ok
                       repeat:(void (^)())repeat
{
    NSArray* objectMapperErrorObjectsArray = (error.userInfo)[RKObjectMapperErrorObjectsKey];

    NSString* errorMessage = @"";

    if (objectMapperErrorObjectsArray != nil && [objectMapperErrorObjectsArray count] != 0) {
        PRStatusModel* status = [objectMapperErrorObjectsArray firstObject];
        errorMessage = status.error;
    }

    if (statusCode >= RKStatusCodeClassServerError) {
        [self.class showServerErrorMessageWithCode:statusCode
                                           message:errorMessage
                                                ok:ok
                                            repeat:repeat];
    }
    else if (statusCode >= RKStatusCodeClassClientError) {
        [self.class showClientErrorMessageWithCode:statusCode
                                           message:errorMessage
                                                ok:ok
                                            repeat:repeat];
    }
    else if (statusCode >= RKStatusCodeClassRedirection) {
        [self.class showRedirectionMessageWithCode:statusCode
                                           message:errorMessage
                                                ok:ok
                                            repeat:repeat];
    }
    else if (statusCode >= RKStatusCodeClassSuccessful) {
        [self.class showSuccessfulMessageWithCode:statusCode
                                          message:errorMessage
                                               ok:ok
                                           repeat:repeat];
    }
    else if (statusCode >= RKStatusCodeClassInformational) {
        [self.class showInformationalMessageWithCode:statusCode
                                             message:errorMessage
                                                  ok:ok
                                              repeat:repeat];
    }
    else {
        [self.class showCustomMessageWithCode:statusCode
                                        error:error
                                      message:errorMessage
                                           ok:ok
                                       repeat:repeat];
    }
}

#pragma mark Protected Methods
#pragma mark -

+ (void)showServerErrorMessageWithCode:(NSInteger)code
                               message:(NSString*)message
                                    ok:(void (^)())ok
                                repeat:(void (^)())repeat
{
    switch (code) {
    case 500: // Internal Server Error
        [self.class showMessageServerFailed:ok
                                     repeat:repeat];
        break;
    case 501: // Not Implemented
    case 502: // Bad Gateway
    case 503: // Service Unavailable
    case 504: // Gateway Timeout
    case 505: // HTTP Version Not Supported
    case 506: // Variant Also Negotiates
    case 507: // Insufficient Storage
    case 508: // Loop Detected
    case 509: // Bandwidth Limit Exceeded
    case 510: // Not Extended
    case 511: // Network Authentication Required
        [self.class showMessageServerFailed:ok
                                     repeat:repeat];
        break;

    default:
        [self.class showMessageServerFailed:ok
                                     repeat:repeat];
        break;
    }
}

+ (void)showClientErrorMessageWithCode:(NSInteger)code
                               message:(NSString*)message
                                    ok:(void (^)())ok
                                repeat:(void (^)())repeat
{
    switch (code) {
    case 404: // Not Found,
        [self.class showMessageNotFound:ok
                                 repeat:repeat];
        break;
    case 400: // Bad Request
        [self.class showMessageBedRequest:message
                                       ok:ok
                                   repeat:repeat];
        break;
    case 401: // Unauthorized
        [self.class showMessageUnauthorized:message
                                         ok:ok
                                     repeat:repeat];
        break;
    case 402: // Payment Required
    case 403: // Forbidden
    case 405: // Method Not Allowed
    case 406: // Not Acceptable
    case 407: // Proxy Authentication Required
    case 408: // Request Timeout
    case 409: // Conflict
    case 410: // Gone
    case 411: // Length Required
    case 412: // Precondition Failed
    case 413: // Request Entity Too Large
    case 414: // Request-URI Too Long
    case 415: // Unsupported Media Type
    case 416: // Requested Range Not Satisfiable
    case 417: // Expectation Failed
    case 418: // I'm a teapot
    case 420: // Enhance Your Calm
    case 422: // Unprocessable Entity
    case 423: // Locked
    case 424: // Failed Dependency, Method Failure
    case 425: // Unordered Collection
    case 426: // Upgrade Required
    case 428: // Precondition Required
    case 429: // Too Many Requests
    case 431: // Request Header Fields Too Large
    case 451: // Unavailable For Legal Reasons
        [self.class showMessageFailed:ok
                               repeat:repeat];
        break;

    default:
        [self.class showMessageFailed:ok
                               repeat:repeat];
        break;
    }
}

+ (void)showRedirectionMessageWithCode:(NSInteger)code
                               message:(NSString*)message
                                    ok:(void (^)())ok
                                repeat:(void (^)())repeat
{
    switch (code) {
    case 300: // Multiple Choices
    case 301: // Moved Permanently
    case 302: // Found
    case 303: // See Other
    case 304: // Not Modified
    case 305: // Use Proxy
    case 306: // Switch Proxy
    case 307: // Temporary Redirect
    case 308: // Permanent Redirect
        [self.class showMessageServerFailed:ok
                                     repeat:repeat];
        break;

    default:
        [self.class showMessageServerFailed:ok
                                     repeat:repeat];
        break;
    }
}

+ (void)showSuccessfulMessageWithCode:(NSInteger)code
                              message:(NSString*)message
                                   ok:(void (^)())ok
                               repeat:(void (^)())repeat
{
    switch (code) {
    case 200: // OK
    case 201: // Created
    case 202: // Accepted
    case 203: // Non-Authoritative Information
    case 204: // No Content
    case 205: // Reset Content
    case 206: // Partial Content
    case 207: // Multi-Status
    case 208: // Already Reported
    case 226: // IM Used
        break;

    default:
        [self.class showMessageServerFailed:ok
                                     repeat:repeat];
        break;
    }
}

+ (void)showInformationalMessageWithCode:(NSInteger)code
                                 message:(NSString*)message
                                      ok:(void (^)())ok
                                  repeat:(void (^)())repeat
{
    switch (code) {
    case 100: // Continue
    case 101: // Switching Protocols
    case 102: // Processing
        break;

    default:
        [self.class showMessageServerFailed:ok
                                     repeat:repeat];
        break;
    }
}

+ (void)showCustomMessageWithCode:(NSInteger)code
                            error:(NSError*)error
                          message:(NSString*)message
                               ok:(void (^)())ok
                           repeat:(void (^)())repeat
{
    switch (code) {
    case RKUnsupportedMIMETypeError:
        [self.class showMessageServerFailed:ok
                                     repeat:repeat];
        break;
    case RKOperationCancelledError:
        [self.class showMessageServerFailed:ok
                                     repeat:repeat];
        break;

    case 0:

        if ([error.domain isEqualToString:@"NSURLErrorDomain"]) {
            switch (error.code) {
            case kCFURLErrorNotConnectedToInternet: case kCFURLErrorDataNotAllowed:
                [self.class showMessageNoInternetConnectrion:ok
                                                      repeat:repeat];
                break;
            default:
                [self.class showMessageServerFailed:ok
                                             repeat:repeat];
            }
        }

        break;
    default:
        [self.class showMessageServerFailed:ok
                                     repeat:repeat];
        break;
    }
}

+ (void)showMessageBedRequest:(NSString*)message
                           ok:(void (^)())ok
                       repeat:(void (^)())repeat
{
    NSArray* errorMessages = @[ @"invalid_key", @"invalid_grant", @"customer_not_found" ];

    NSUInteger index = [errorMessages indexOfObject:message];

    if (index != NSNotFound) {
        switch (index) {
        case 0: // Invalid key
            [self.class _showMessage:NSLocalizedString(@"Confirmation code is wrong. An SMS with the registration code has been sent to you.", )
                               toast:YES
                                type:MessageType_Error
                                  ok:ok
                              repeat:nil]; // No need to repeat
            break;
        case 1: // Bad credentials
            [self.class _showMessage:NSLocalizedString(@"The phone number or password you entered is incorrect.", )
                               toast:YES
                                type:MessageType_Error
                                  ok:ok
                              repeat:nil]; // No need to pepeat
            break;

        case 2:
            ok();
            break; //NO need to display message

        default:
            NSAssert(0, @"All cases shoulb be handled!");
            break;
        }
    }
    else {
        [self.class showMessageServerFailed:ok
                                     repeat:repeat];
    }
}

+ (void)showMessageUnauthorized:(NSString*)message
                             ok:(void (^)())ok
                         repeat:(void (^)())repeat
{
    NSArray* errorMessages = @[ @"customer_not_found" ];

    NSUInteger index = [errorMessages indexOfObject:message];

    if (index != NSNotFound) {
        switch (index) {
        case 0: // Customer not found
            [self.class _showMessage:NSLocalizedString(@"The phone number or password you entered is incorrect.", )
                               toast:YES
                                type:MessageType_Error
                                  ok:ok
                              repeat:nil]; // No need to repeat
            break;

        default:
            NSAssert(0, @"All cases shoulb be handled!");
            break;
        }
    }
    else {
        [self.class showMessageServerFailed:ok
                                     repeat:repeat];
    }
}

+ (void)showMessage:(Message)message
                 ok:(void (^)())ok
{
    [self.class showMessage:message
                      toast:NO
                         ok:ok];
}

+ (void)showToastWithMessage:(Message)message
{
    [self.class showMessage:message
                      toast:YES
                         ok:nil];
}

+ (NSString*)getStringFromMessage:(Message)message
{
    switch (message) {
    case Message_PasswordDoesnotMatch:
        return NSLocalizedString(@"Passwords don't match.", );
    case Message_InvalidCard:
        return NSLocalizedString(@"Card with this number does not exist.", );
    case Message_InvalidExpDate:
        return NSLocalizedString(@"Expiration date of the card is entered incorrectly.", );
    case Message_OnlyMasterVisaSupported:
        return NSLocalizedString(@"Payment system only processes Visa and MasterCard.", );
    case Message_PaymentCardAlreadyRegistered:
        return NSLocalizedString(@"The payment card is already registered.", );
    case Message_InvalidEmail:
        return NSLocalizedString(@"Invalid Email address.", );
    case Message_ConnectedToInternet:
        return NSLocalizedString(@"Connected to Internet.", );
    case Message_Logout:
        return NSLocalizedString(@"Remember, you will need to create new password after logout.", );
    case Message_EmptyTextField:
        return NSLocalizedString(@"Please fill the message", );
    case Message_AutofillCardData:
        return NSLocalizedString(@"Autofill card data?", );
    case Message_SaveCardData:
        return NSLocalizedString(@"Keep this card for future payment?", );
    case Message_SaveModification:
        return NSLocalizedString(@"Save modification?", );
    case Message_FeedBackSend:
        return NSLocalizedString(@"Message was sent", );
    case Messgae_UnableToSynchronizeAvatarWithServer:
        return NSLocalizedString(@"Unable to synchronize the avatar with server", );
    case Message_InternetConnectionOffline:
        return NSLocalizedString(@"The Internet connection appears to be offline.", ); //TODO translate to russian
    case Message_UberTimeIsExpired:
        return NSLocalizedString(@"UBER is unavailable at this moment.", );
    case Message_SaveContactFailed:
        return NSLocalizedString(@"Failed to save contact changes", );
    case Message_CouldNotPlayAudioFile:
        return NSLocalizedString(@"Could not play audio file", );
    case Message_IncorrectPassword:
        return NSLocalizedString(@"Password is incorrect", );
    case Message_AccountDeleted:
        return NSLocalizedString(@"Your account has been successfully deleted", );
    default:
        break;
    }

    return @"";
}

+ (MessageType)getMessageType:(Message)message
{
    switch (message) {
    case Message_PasswordDoesnotMatch:
        return MessageType_Error;
    case Message_InvalidCard:
        return MessageType_Error;
    case Message_InvalidExpDate:
        return MessageType_Error;
    case Message_OnlyMasterVisaSupported:
        return MessageType_Warning;
    case Message_PaymentCardAlreadyRegistered:
        return MessageType_Warning;
    case Message_InvalidEmail:
        return MessageType_Error;
    case Message_ConnectedToInternet:
        return MessageType_Info;
    case Message_Logout:
        return MessageType_Info;
    case Message_EmptyTextField:
        return MessageType_Warning;
    case Message_AutofillCardData:
        return MessageType_Info;
    case Message_SaveCardData:
        return MessageType_Info;
    case Message_SaveModification:
        return MessageType_Info;
    case Message_FeedBackSend:
        return MessageType_Info;
    case Message_AccountDeleted:
        return MessageType_Info;
    default:
        break;
    }

    return MessageType_Info;
}

+ (void)showMessage:(Message)message
              toast:(BOOL)toast
                 ok:(void (^)())ok
{
    [self.class _showMessage:[self.class getStringFromMessage:message]
                        type:[self.class getMessageType:message]
                       toast:toast
                          ok:ok];
}

+ (void)showMessage:(Message)message
                yes:(void (^)())yes
                 no:(void (^)())no
{
    [self.class _showMessage:[self.class getStringFromMessage:message]
                         yes:yes
                          no:no];
}

+ (void)showMessage:(Message)message
{
    [self.class showMessage:message
                         ok:nil];
}

#pragma mark Protected Methods - Messages
#pragma mark -

+ (void)showMessageNotFound:(void (^)())ok
                     repeat:(void (^)())repeat
{
    [self.class _showMessage:NSLocalizedString(@"Unable to find the requested data.", )
                       toast:NO
                        type:MessageType_Error
                          ok:ok
                      repeat:repeat];
    // "ALERT_NOT_FOUND_MESSAGE" = "Не удалось найти запрашиваемые данные."
}

+ (void)showMessageFailed:(void (^)())ok
                   repeat:(void (^)())repeat
{
    [self.class _showMessage:NSLocalizedString(@"The server is temporarily unavailable or no Internet connection. Please try again later.", )
                       toast:NO
                        type:MessageType_Error
                          ok:ok
                      repeat:repeat];
    // "ALERT_FAILED_MESSAGE" = "Сервер временно недоступен или отсутствует соединение с интернетом. Попробуйте повторить попытку позже."
}

+ (void)showMessageServerFailed:(void (^)())ok
                         repeat:(void (^)())repeat
{

    // Now needn't to show this message. This logic closed  temporarily or will delete it later.
    //In any case ,when server failed,we need to call failure block
    if (ok)
    {
        ok();
    }
    //    [self.class _showMessage:NSLocalizedString(@"Temporary problem. Please try again later.", )
    //                       toast:YES
    //                        type:MessageType_Error
    //                          ok:ok
    //                      repeat:repeat];
    // "ALERT_SERVER_FAILED_MESSAGE" = "Временные неполадки. Пожалуйста, повторите попытку чуть позже."
}

+ (void)showMessageNoInternetConnectrion:(void (^)())ok
                                  repeat:(void (^)())repeat
{
    [self.class _showMessage:NSLocalizedString(@"No internet connection.", )
                       toast:YES
                        type:MessageType_Error
                          ok:ok
                      repeat:repeat];
    // "ALERT_SERVER_FAILED_MESSAGE" = "Временные неполадки. Пожалуйста, повторите попытку чуть позже."
}

+ (void)_showMessage:(NSString*)message
                 yes:(void (^)())yes
                  no:(void (^)())no
{
    PRMessageAlert* alert = nil;

    alert = [[self.class alloc] initWithTitle:nil
                                      message:message
                                     delegate:nil
                            cancelButtonTitle:NSLocalizedString(@"Yes", )
                            otherButtonTitles:NSLocalizedString(@"No", ),
                            nil];

    alert.ok = yes;
    alert.repeat = no;
    alert.delegate = alert;

    [alert show];
}

+ (void)_showMessage:(NSString*)message
               toast:(BOOL)toast
                type:(MessageType)type
                  ok:(void (^)())ok
              repeat:(void (^)())repeat
{
    if (toast) {

#if 1
        // For modal views
        UIView* rootView = [[[[UIApplication sharedApplication] keyWindow] subviews] lastObject];

        //id<UIApplicationDelegate> appDelegate = [[UIApplication sharedApplication] delegate];
        //UIView *rootView = appDelegate.window.rootViewController.view;

        [rootView makeCustomToast:message
                         duration:3.0
                         position:CSToastPositionCenter];
#else
        NSString* styleName = nil;

        switch (type) {
        case MessageType_Info:
            styleName = JDStatusBarStyleSuccess;
            break;

        case MessageType_Error:
            styleName = JDStatusBarStyleError;
            break;

        case MessageType_Warning:
            styleName = JDStatusBarStyleWarning;
            break;

        default:
            styleName = JDStatusBarStyleDefault;
            break;
        }

        [JDStatusBarNotification showWithStatus:message
                                   dismissAfter:5.0f
                                      styleName:styleName];
#endif

        if (ok != nil) {
            ok();
        }
    }
    else {
        PRMessageAlert* alert = nil;

        if (repeat) {
            alert = [[self.class alloc] initWithTitle:nil
                                              message:message
                                             delegate:nil
                                    cancelButtonTitle:NSLocalizedString(@"Close", )
                                    otherButtonTitles:NSLocalizedString(@"Repeat", ),
                                    nil];

            alert.ok = ok;
            alert.repeat = ^{
                repeat(repeat, PRRequestOption_Repeat);
            };
            alert.delegate = alert;
        }
        else {
            alert = [[self.class alloc] initWithTitle:nil
                                              message:message
                                             delegate:nil
                                    cancelButtonTitle:NSLocalizedString(@"Close", )
                                    otherButtonTitles:nil];

            if (ok) {
                alert.ok = ok;
                alert.delegate = alert;
            }
        }

        //"CLOSE" = "Закрыть"
        //"REPEAT" = "Повторить"

        [alert show];
    }
}

+ (void)_showMessage:(NSString*)message
                type:(MessageType)type
               toast:(BOOL)toast
              repeat:(void (^)())repeat
{
    [self.class _showMessage:message
                       toast:(BOOL)toast
                        type:type
                          ok:nil
                      repeat:repeat];
}

+ (void)_showMessage:(NSString*)message
                type:(MessageType)type
               toast:(BOOL)toast
                  ok:(void (^)())ok
{
    [self.class _showMessage:message
                       toast:toast
                        type:type
                          ok:ok
                      repeat:nil];
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSAssert([alertView isKindOfClass:[self class]],
        @"alertView should be instance of PRMessageAlert class!");

    PRMessageAlert* alert = (PRMessageAlert*)alertView;
    switch (buttonIndex) {
    case 0: // Ok
        if (alert.ok != nil) {
            alert.ok();
        }
        break;

    case 1: //Repeat
        NSAssert(alert.repeat != nil,
            @"alert.repeate callback function can not be nil");
        alert.repeat();
        break;
    }
}

@end
