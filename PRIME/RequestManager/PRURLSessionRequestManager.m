//
//  PRURLSessionRequestManager.m
//  PRIME
//
//  Created by Sargis Terteryan on 7/23/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import "PRURLSessionRequestManager.h"
#import "Constants.h"
#import "ChatUtility.h"
#import "PRUserDefaultsManager.h"
#import "TaskIcons.h"
#import "NSDate+Utilities.h"
#import "PRAudioPlayer.h"
#import <RestKit/RestKit.h>
#import <RestKit/Search/RKManagedObjectStore+RKSearchAdditions.h>
#import "Config.h"

NSString* const RKMIMETypeJSON = @"application/json";
NSString* const kClientPrefixCode = @"C";
static NSString* const kFileGetPath = @"files:path";
static NSString* const kMediaFileInfoPathWithParameter = @"files/info/:uuid";

@interface PRURLSessionRequestManager ()

@property (strong, nonatomic) NSUserDefaults* defaults;

@end

@implementation PRURLSessionRequestManager

- (id)init
{
    self = [super init];
    if (self) {
        self.defaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    }
    return self;
}

#pragma mark - HTTP Request For Widget

- (void)makeURLSessionRequest:(NSString*)path success:(void (^)(NSArray* response))success failure:(void (^)(void))failure
{
    NSString* accessToken = [self.defaults valueForKey:kAccessTokenKey];
    NSURL* url = [NSURL URLWithString:path];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    NSString* authorizationValue = [NSString stringWithFormat:@"Bearer %@", accessToken];
    [request setValue:authorizationValue forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json"
        forHTTPHeaderField:@"Content-type"];

    NSURLSessionDataTask* dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                     completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
                                                                         NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                                                                         if (httpResponse.statusCode == 200) {
                                                                             NSError* jsonError = nil;
                                                                             NSArray* responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                                                                             if (jsonError) {
                                                                                 NSLog(@"Error converting widget response data: %@", error.localizedDescription);
                                                                                 return;
                                                                             }
                                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                                 success(responseDict);
                                                                             });

                                                                         } else {
                                                                             failure();
                                                                         }

                                                                     }];

    [dataTask resume];
}

#pragma mark - Tasks For Widget

- (void)setWidgetRequestsWithURLSession:(NSArray*)array
{
    NSPredicate* predicateNeedToPay = [NSPredicate predicateWithFormat:@"completed = %@  AND orders.@count > 0", @(NO)];
    NSPredicate* predicateOpenedTasks = [NSPredicate predicateWithFormat:@"completed = %@  AND  orders.@count = 0", @(NO)];

    NSArray* needToPayTasks = [self getTasksNeedToPayOrOpenedTasks:array withCount:5 andPredicate:predicateNeedToPay];
    NSArray* openedTasks = [self getTasksNeedToPayOrOpenedTasks:array withCount:5 - needToPayTasks.count andPredicate:predicateOpenedTasks];

    NSMutableArray* allTasks = [NSMutableArray new];

    for (NSInteger i = 0; i < needToPayTasks.count; i++) {
        [allTasks addObject:[self createRequestOrEventModelWithData:needToPayTasks[i] andEventType:kWidgetEventTypeNeedToPay]];
    }
    for (NSInteger i = 0; i < openedTasks.count; i++) {
        [allTasks addObject:[self createRequestOrEventModelWithData:openedTasks[i] andEventType:kWidgetEventTypeInProgress]];
    }

    [_defaults setValue:allTasks forKey:kWidgetRequests];
}

- (NSMutableDictionary*)createRequestOrEventModelWithData:(NSDictionary*)model andEventType:(NSString*)type
{
    NSMutableDictionary* data = [NSMutableDictionary new];
    [data setValue:[[model objectForKey:@"taskType"] valueForKey:@"name"] forKey:kWidgetMessageType];
    [data setValue:[model valueForKey:@"name"] forKey:kWidgetMessageTaskName];
    [data setValue:[model valueForKey:@"description"] forKey:kWidgetMessageTaskDescription];
    NSInteger taskTypeId = [[[model objectForKey:@"taskType"] valueForKey:@"id"] integerValue];
    [data setValue:[TaskIcons imageNameFromTaskTypeId:taskTypeId] forKey:kWidgetMessageImageName];

    NSTimeInterval timeInterval = [[model objectForKey:@"requestDate"] doubleValue];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:(timeInterval / 1000.0)];
    [data setValue:date forKey:kWidgetRequestDate];

    [data setValue:type forKey:kWidgetEventType];
    [data setValue:[model valueForKey:@"id"] forKey:kWidgetRequestID];
    NSArray* orders = [model objectForKey:@"orders"];

    if (orders.count > 0) {
        [data setValue:[[NSString alloc] initWithFormat:@"%@ %@", [orders valueForKey:@"amount"], NSLocalizedString([self getCurrency:[orders valueForKey:@"currency"]], nil)] forKey:kWidgetRequestPayText];
        [data setValue:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"due", nil), [orders valueForKey:@"dueDate"]] forKey:kWidgetRequestPayDate];
    }
    return data;
}

- (NSArray*)getTasksNeedToPayOrOpenedTasks:(NSArray*)array withCount:(NSInteger)count andPredicate:(NSPredicate*)predicate
{
    NSMutableArray* needToPayTasks = [[array filteredArrayUsingPredicate:predicate] mutableCopy];

    if (needToPayTasks.count <= count) {
        return needToPayTasks;
    }

    NSMutableArray* tasks = [NSMutableArray new];
    for (NSInteger i = 0; i < count; i++) {
        [tasks addObject:needToPayTasks[i]];
    }
    return tasks;
}

- (void)setWidgetEventsWithURLSession:(NSArray*)data
{
    NSArray* eventsModels = [[self getLastTasksReservedOnTodayOrAfter:data] copy];

    NSMutableArray* events = [NSMutableArray new];
    for (NSInteger i = 0; i < eventsModels.count; i++) {
        [events addObject:[self createRequestOrEventModelWithData:eventsModels[i] andEventType:nil]];
    }

    [_defaults setValue:events forKey:kWidgetEvents];
}

- (NSArray*)getLastTasksReservedOnTodayOrAfter:(NSArray*)data
{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSInteger milliseconds = timeInterval * 1000;
    NSMutableArray* tasks = [NSMutableArray new];

    for (NSInteger i = 0; i < data.count; i++) {
        NSInteger reservedTaskValue = [[data[i] valueForKey:@"reserved"] integerValue];
        NSInteger taskRequestDateMilliseconds = [[data[i] valueForKey:@"requestDate"] integerValue];
        NSDate* requestDate = [NSDate dateWithTimeIntervalSince1970:(taskRequestDateMilliseconds / 1000.0)];
        if ((reservedTaskValue == 1) && ([requestDate isToday:requestDate] || taskRequestDateMilliseconds >= milliseconds)) {
            [tasks addObject:data[i]];
        }
    }

    NSArray* sortedTasks = [tasks sortedArrayUsingDescriptors:@[ [[NSSortDescriptor alloc] initWithKey:@"requestDate"
                                                                                             ascending:YES] ]];

    return sortedTasks;
}

#pragma mark - Messages For Widget

- (void)saveMessagesForWidgetWithURLSession:(NSArray*)messages
{
    NSMutableArray* messagesForWidget = [NSMutableArray new];
    for (NSInteger i = messages.count - 1; i >= 0; i--) {
        [messagesForWidget addObject:[self createJsonWithMessageModel:messages[i]]];
    }

    [self.defaults setValue:messagesForWidget forKey:kMessagesForWidget];
}

- (NSMutableDictionary*)createJsonWithMessageModel:(NSDictionary*)messages
{
    NSMutableDictionary* dict = [NSMutableDictionary new];
    NSString* type = [messages valueForKey:@"type"];

    if ([type isEqualToString:kMessageType_VoiceMessage]) {
        [dict setValue:[messages valueForKey:@"content"] forKey:kWidgetMessageAudioFileName];
        [dict setValue:[self getDuration:[messages valueForKey:@"guid"]] forKey:kWidgetMessageDuration];

    } else if ([type isEqualToString:kMessageType_TaskLink]) {
        NSMutableDictionary* taskLink = [NSMutableDictionary new];
        NSDictionary* task = [[messages valueForKey:@"content"] valueForKey:@"task"];
        NSDictionary* taskType = [task valueForKey:@"taskType"];
        NSInteger typeID = [[taskType valueForKey:@"id"] integerValue];
        [taskLink setValue:[TaskIcons imageNameFromTaskTypeId:typeID] forKey:kWidgetMessageImageName];
        [taskLink setValue:[task valueForKey:@"name"] forKey:kWidgetMessageTaskName];
        [taskLink setValue:[task valueForKey:@"description"] forKey:kWidgetMessageTaskDescription];

        NSDictionary* taskLinkBody = [[[messages valueForKey:@"content"] valueForKey:@"message"] valueForKey:@"body"];
        [taskLink setValue:[taskLinkBody valueForKey:@"content"] forKey:kWidgetMessage];
        [taskLink setValue:[taskLinkBody valueForKey:@"timestamp"] forKey:kWidgetMessageTimestamp];

        [dict setValue:taskLink forKey:kWidgetMessageTaskLink];
    } else {
        [dict setValue:[messages valueForKey:@"content"] forKey:kWidgetMessageText];
    }

    [dict setValue:type forKey:kWidgetMessageType];
    [dict setValue:[messages valueForKey:@"timestamp"] forKey:kWidgetMessageTimestamp];

    NSTimeInterval timeStamp = [[messages valueForKey:@"timestamp"] doubleValue];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:timeStamp];

    [dict setObject:[self formatedDate:date] forKey:kWidgetMessageFormatedDate];

    NSString* userName = [_defaults valueForKey:kCustomerId];
    NSString* clientId = [kClientPrefixCode stringByAppendingString:userName];
    BOOL isLeftCell = ![[messages valueForKey:@"clientId"] isEqualToString:clientId];
    [dict setObject:@(isLeftCell) forKey:kWidgetMessageIsLeft];

    return dict;
}

#pragma mark - City Guide For Widget

- (void)createDataForCityGuideInWIdgetWithURLSession:(NSArray*)data
{
    NSMutableArray* array = [NSMutableArray new];
    for (NSInteger i = 0; i < data.count && i < 9; i++) {
        [array addObject:[self createCityGuideModelWithData:data[i]]];
    }
    [_defaults setValue:array forKey:kWidgetCityguideData];
}

- (NSMutableDictionary*)createCityGuideModelWithData:(NSDictionary*)data
{
    NSMutableDictionary* dict = [NSMutableDictionary new];
    [dict setValue:[data valueForKey:kWidgetCityguideDescription] forKey:kWidgetCityguideDescription];
    [dict setValue:[data valueForKey:kWidgetCityguideName] forKey:kWidgetCityguideName];
    NSString* imageURL = [data valueForKey:kWidgetCityguideImageSrc];
    NSData* image = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:imageURL]];
    [dict setValue:image forKey:kWidgetCityguideImage];
    [dict setValue:[data valueForKey:kWidgetCityguideInner_link] forKey:kWidgetCityguideInner_link];

    return dict;
}

#pragma mark - Helpers

- (NSString*)formatedDate:(NSDate*)date

{
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];

    if ([date isToday:date]) {
        return NSLocalizedString(@"Today", );
    }

    if ([date isYesterday]) {
        return NSLocalizedString(@"Yesterday", );
    }

    if ([date isThisYear]) {
        [dateFormat setDateFormat:@"EEE, d MMMM"];
        return [dateFormat stringFromDate:date];
    }

    [dateFormat setDateFormat:@"dd MMMM yyyy"];

    return [dateFormat stringFromDate:date];
}

- (NSString*)getCurrency:(NSString*)currency
{
    NSArray* currencyTypes = @[ @"", @"RUR", @"EUR", @"USD" ];
    NSString* currentCcurrency = [currency stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSInteger item = [currencyTypes indexOfObject:currency];

    switch (item) {
    case 1:
        return @"₽";
    case 2:
        return @"€";
    case 3:
        return @"$";
    default:
        return currentCcurrency;
    }
}

- (NSString*)getDuration:(NSString*)audioFileName
{
    PRAudioPlayer* player = [[PRAudioPlayer alloc] initWithAudioFileName:audioFileName];
    return [player duration];
}

- (void)sendMessage:(NSDictionary*)message
          toChannel:(NSString*)channelId
    withAccessToken:(NSString*)accessToken
       withDeviceID:(NSString *)deviceID
            success:(void (^)(void))success
            failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    NSNumber* timeStamp = @((long)[[NSDate new] timeIntervalSince1970]);
    NSString* path = [NSString stringWithFormat:kMessageSendPath, accessToken, timeStamp, kClientID, deviceID];
	NSString *kChatBaseUrl = [NSString stringWithFormat:@"%@/chat-server/v3_1/", Config.chatEndpoint];
    NSMutableString* messagesUrl = [[NSMutableString alloc] initWithString:kChatBaseUrl];
    [messagesUrl appendString:path];
    NSURL* url = [NSURL URLWithString:messagesUrl];
    NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];

    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:message options:0 error:nil];
    [urlRequest setHTTPMethod:@"POST"];
    NSString* authorizationValue = [NSString stringWithFormat:@"Bearer %@", accessToken];
    [urlRequest setValue:authorizationValue forHTTPHeaderField:@"Authorization"];
    [urlRequest setValue:RKMIMETypeJSON forHTTPHeaderField:@"Content-Type"];
    urlRequest.HTTPBody = jsonData;

    NSURLSessionDataTask* messagePostTask = [[NSURLSession sharedSession] dataTaskWithRequest:urlRequest
                                                                            completionHandler:^(NSData* data,
                                                                                                NSURLResponse* response,
                                                                                                NSError* error) {
                                                                                NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                                                                                if (httpResponse.statusCode == kStatusCodeSuccess) {
                                                                                    success();
                                                                                } else {
                                                                                    failure(httpResponse.statusCode, error);
                                                                                }
                                                                            }];

    [messagePostTask resume];
}

- (void)downloadFileWithPath:(NSString*)path
                     success:(void (^)(NSData* fileData))success
                     failure:(void (^)(NSInteger statusCode, NSError* error))failure
{
    if (!path) {
        return;
    }

    RKObjectManager* oldManager = [RKObjectManager sharedManager];

    [self setupObjectManagerForMediaMessage];

    RKObjectManager* manager = [RKObjectManager sharedManager];

    NSString* tmpPath = RKPathFromPatternWithObject(
                                                    kFileGetPath,
                                                    @{
                                                      @"path" : [path stringByReplacingOccurrencesOfString:@"chat." withString:@""],
                                                      });

    NSMutableURLRequest* downloadRequest = [manager requestWithObject:nil
                                                               method:RKRequestMethodGET
                                                                 path:tmpPath
                                                           parameters:nil];

    AFHTTPRequestOperation* requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:downloadRequest];

    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation* operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSData class]]) {
            success((NSData*)responseObject);
        } else {
        }
    }
                                            failure:^(AFHTTPRequestOperation* operation, NSError* error) {

                                                failure([operation.response statusCode], error);

                                            }];

    [manager.HTTPClient enqueueHTTPRequestOperation:requestOperation];

    [RKObjectManager setSharedManager:oldManager];
}

- (void)getMediaInfoWithUUID:(NSString *)uuid
                     success:(void (^)(NSData *))success
                     failure:(void (^)(NSInteger, NSError *))failure
{
    NSString *urlString = [NSString stringWithFormat:@"%@/storage/files/info/%@", Config.chatEndpoint, uuid];
    [self makeURLSessionRequest:urlString success:^(NSArray *response) {
        NSString *fileExtension = @"";
        NSArray *fileNameSeperated = [[response valueForKey:@"name"] componentsSeparatedByString:@"."];
        if([fileNameSeperated count] > 1)
        {
            fileExtension = [fileNameSeperated lastObject];
        }
        NSDictionary *documentInfo = @{kDocumentMessageFileNameKey: [response valueForKey:@"name"],
                                       kDocumentMessageFileSizeKey: [NSString stringWithFormat:@"%ld", [[response valueForKey:@"size"] integerValue]],
                                       kDocumentMessageFileExtensionKey: fileExtension
                                       };
        NSData *documentInfoData = [NSKeyedArchiver archivedDataWithRootObject:documentInfo];
        success(documentInfoData);
    } failure:^{
    }];
}

- (void)setupObjectManagerForMediaMessage
{
    // Initialize RestKit Object Manager.
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/storage/", Config.chatEndpoint]];

    AFHTTPClient* client = [[AFHTTPClient alloc] initWithBaseURL:url];

    NSString* accessToken = [self.defaults valueForKey:kAccessTokenKey];
    [client setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@", accessToken]];

    client.allowsInvalidSSLCertificate = YES;

    // Initialize RestKit.
    RKObjectManager* manager = [[RKObjectManager alloc] initWithHTTPClient:client];

    [RKObjectManager setSharedManager:manager];
}

@end
