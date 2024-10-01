//
//  PRUserDefaultsManager.m
//  PRIME
//
//  Created by Armen on 4/30/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import "PRUserDefaultsManager.h"
#import "ChatUtility.h"
#import "TaskIcons.h"
#import "Utils.h"
#import "PRAudioPlayer.h"

static const NSUInteger kWidgetMaxMessagesCount = 5;
static const NSUInteger kWidgetMaxTasksCount = 9;

@interface PRService : NSObject

@property (strong, nonatomic) PRServicesModel* info;
@property (strong, nonatomic) UIImage* icon;
@property (assign, nonatomic) NSInteger tag;

@end

@interface PRUserDefaultsManager () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) NSUserDefaults* defaults;
@property (strong, nonatomic) NSString* clientID;

@end

@implementation PRUserDefaultsManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static PRUserDefaultsManager* instance;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
        instance.locationManager = [[CLLocationManager alloc] init];
        instance.defaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    });

    return instance;
}

- (void)saveToken:(NSString*)token
{
    [_defaults setValue:token forKey:kAccessTokenKey];
    NSUserDefaults* siriDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSiriUserDefaultsSuiteName];
    [siriDefaults setValue:token forKey:kAccessTokenKey];
}

- (void)setWidgetMessages:(NSArray*)messages
{
    _clientID = [ChatUtility clientIdWithPrefix];
    NSMutableArray* array = [NSMutableArray new];

    for (PRMessageModel* model in messages) {
        [array addObject:[self createJsonWithMessageModel:model]];
    }
    [_defaults setValue:array forKey:kMessagesForWidget];
}

- (void)updateWidgetMessages
{
    NSArray<PRMessageModel*>* allMessages = [PRDatabase messagesForChannelId:[ChatUtility mainChatIdWithPrefix]];

    NSMutableArray* messagesForWidget = [NSMutableArray new];
    NSInteger i = allMessages.count > kWidgetMaxMessagesCount ? kWidgetMaxMessagesCount : allMessages.count;
    NSMutableArray* array = [NSMutableArray new];

    for (; i > 0; i--) {
        [messagesForWidget addObject:allMessages[allMessages.count - i]];
        [array addObject:[self createJsonWithMessageModel:allMessages[allMessages.count - i]]];
    }

    [_defaults setValue:array forKey:kMessagesForWidget];
}

- (void)setWidgetRequests
{
    NSArray* needToPayTasks = [PRDatabase getLastNeedToPayTasksWithCount:kWidgetMaxTasksCount];
    NSArray* openedTasks = [PRDatabase getLastOpenedTasksWithCount:kWidgetMaxTasksCount - needToPayTasks.count];

    NSMutableArray* allTasks = [NSMutableArray new];

    for (PRTaskDetailModel* model in needToPayTasks) {
        [allTasks addObject:[self createRequestOrEventModelWithData:model andEventType:kWidgetEventTypeNeedToPay]];
    }
    for (PRTaskDetailModel* model in openedTasks) {
        [allTasks addObject:[self createRequestOrEventModelWithData:model andEventType:kWidgetEventTypeInProgress]];
    }

    [_defaults setValue:allTasks forKey:kWidgetRequests];
}

- (void)setWidgetEvents
{
    NSArray* eventsModels = [PRDatabase getLastTasksReservedOnTodayOrAfter];

    NSMutableArray* events = [NSMutableArray new];

    for (NSInteger i = 0; i < eventsModels.count && i < kWidgetMaxTasksCount; ++i) {
        [events addObject:[self createRequestOrEventModelWithData:eventsModels[i] andEventType:nil]];
    }

    [_defaults setValue:events forKey:kWidgetEvents];
}

- (void)saveServicesImagesForWidgets:(NSArray*)servicesArray
{
    NSMutableArray* services = [NSMutableArray new];
    for (PRService* model in servicesArray) {
        NSData* icon = UIImagePNGRepresentation(model.icon);
        NSMutableDictionary* data = [NSMutableDictionary new];
        [data setValue:icon forKey:kWidgetServiceIconName];
        [data setValue:model.info.name forKey:kWidgetServiceName];
        [data setValue:model.info.serviceId forKey:kWidgetServiceId];

        [services addObject:data];
        if (services.count == 10) {
            break;
        }
    }
    [_defaults setValue:services forKey:kWidgetServices];
}

#pragma mark - Private Functions

- (void)getCityGuideDataWithLocation
{
    NSMutableURLRequest* request = [self createURLRequsetForCityguideData];
    __weak PRUserDefaultsManager* weakSelf = self;
    NSURLSessionDataTask* dataTask =  [[NSURLSession sharedSession] dataTaskWithRequest:request
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
                                                                                  PRUserDefaultsManager* strongSelf = weakSelf;
                                                                                  if (strongSelf && responseDict) {
                                                                                      [strongSelf createDataForCityGuideInWIdget:responseDict];
                                                                                  }
                                                                              });
                                                                          }
                                                                      }];

    [dataTask resume];
}

- (void)createDataForCityGuideInWIdget:(NSArray*)data
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSMutableArray* array = [NSMutableArray new];
    for (NSInteger i = 0; i < data.count && i < 9; i++) {
        [array addObject:[self createCityGuideModelWithData:data[i]]];
    }
    [_defaults setValue:array forKey:kWidgetCityguideData];
    });
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

- (NSMutableDictionary*)createRequestOrEventModelWithData:(PRTaskDetailModel*)model andEventType:(NSString*)type
{
    NSMutableDictionary* data = [NSMutableDictionary new];
    [data setValue:model.taskType.typeName forKey:kWidgetMessageType];
    [data setValue:model.taskName forKey:kWidgetMessageTaskName];
    [data setValue:model.taskDescription forKey:kWidgetMessageTaskDescription];
    [data setValue:[TaskIcons imageNameFromTaskTypeId:model.taskType.typeId.integerValue] forKey:kWidgetMessageImageName];
    [data setValue:model.requestDate forKey:kWidgetRequestDate];
    [data setValue:type forKey:kWidgetEventType];
    [data setValue:model.taskId forKey:kWidgetRequestID];
    if (model.orders.count > 0) {
        PROrderModel* order = [model.orders firstObject];
        [data setValue:[[NSString alloc] initWithFormat:@"%@ %@", [order amount], NSLocalizedString([order getCurrency], nil)] forKey:kWidgetRequestPayText];
        [data setValue:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"due", nil), [order dueDate]] forKey:kWidgetRequestPayDate];
    }
    return data;
}

- (NSMutableURLRequest*)createURLRequsetForCityguideData
{
    CGFloat longitude = _locationManager.location.coordinate.longitude;
    CGFloat latitude = _locationManager.location.coordinate.latitude;
    NSString* urlString = [NSString stringWithFormat:kCityGuideUrl, longitude, latitude];
    NSURL* url = [[NSURL alloc] initWithString:urlString];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    return request;
}

- (NSMutableDictionary*)createJsonWithMessageModel:(PRMessageModel*)model
{
    NSMutableDictionary* dict = [NSMutableDictionary new];
    [dict setValue:model.type forKey:kWidgetMessageType];
    [dict setValue:model.timestamp forKey:kWidgetMessageTimestamp];
    [dict setValue:model.text forKey:kWidgetMessageText];
    [dict setValue:model.audioFileName forKey:kWidgetMessageAudioFileName];

    if ([model.type isEqualToString:kMessageType_VoiceMessage] && model.audioFileName) {
        [dict setValue:[model getDuration] forKey:kWidgetMessageDuration];
    }

    if (model.content) {
        NSMutableDictionary* taskLink = [NSMutableDictionary new];

        [taskLink setValue:[TaskIcons imageNameFromTaskTypeId:model.content.task.taskType.typeId.integerValue] forKey:kWidgetMessageImageName];
        [taskLink setValue:model.content.task.taskName forKey:kWidgetMessageTaskName];
        [taskLink setValue:model.content.task.taskDescription forKey:kWidgetMessageTaskDescription];
        [taskLink setValue:model.content.message.body.content forKey:kWidgetMessage];
        [taskLink setValue:model.content.message.body.timestamp forKey:kWidgetMessageTimestamp];
        [dict setValue:taskLink forKey:kWidgetMessageTaskLink];
    }
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:model.timestamp.doubleValue];
    [dict setObject:[ChatUtility formatedDate:date] forKey:kWidgetMessageFormatedDate];
    BOOL isLeftCell = ![model.clientId isEqualToString:_clientID];
    [dict setObject:@(isLeftCell) forKey:kWidgetMessageIsLeft];

    return dict;
}

@end
