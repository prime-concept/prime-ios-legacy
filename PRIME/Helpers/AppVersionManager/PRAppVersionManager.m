//
//  PRAppVersionManager.m
//  PRIME
//
//  Created by Aram on 10/4/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRAppVersionManager.h"
#import "UIAlertController+PRNewWindow.h"

@interface PRAppVersionManager ()
@property (strong, nonatomic) NSString* appStoreUrlString;

@end

@implementation PRAppVersionManager

- (void)checkAppVersionAndShowAlertIfNeeded
{
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString* appID = infoDictionary[@"CFBundleIdentifier"];
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?bundleId=%@", appID]];
    NSMutableURLRequest* request = [NSMutableURLRequest new];
    NSOperationQueue* queue = [NSOperationQueue new];
    [request setURL:url];
    [request setHTTPMethod:@"GET"];

    __weak PRAppVersionManager* weakSelf = self;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:^(NSURLResponse* _Nullable response, NSData* _Nullable data, NSError* _Nullable connectionError) {
                               PRAppVersionManager* strongSelf = weakSelf;
                               if (!strongSelf || !data) {
                                   return;
                               }

                               NSString* output = [NSString stringWithCString:[data bytes] length:[data length]];
                               NSData* jsonData = [output dataUsingEncoding:NSUTF8StringEncoding];
                               NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
                               NSString* appStoreUrlString = strongSelf.appStoreUrlString = [[[jsonDict objectForKey:@"results"] firstObject] objectForKey:@"trackViewUrl"];

                               if ([jsonDict[@"resultCount"] integerValue] != 0 && appStoreUrlString) {
                                   NSString* appStoreVersion = [[[jsonDict objectForKey:@"results"] firstObject] objectForKey:@"version"];
                                   NSString* currentVersion = infoDictionary[@"CFBundleShortVersionString"];

                                   if ([strongSelf isCurrentVersion:currentVersion olderThanAppStoreVersion:appStoreVersion]) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [strongSelf showNewVersionSuggestingAlert];
                                       });
                                   }
                               }
                           }];
}

- (BOOL)isCurrentVersion:(NSString*)currentVersion olderThanAppStoreVersion:(NSString*)appStoreVersion
{
    if ([appStoreVersion isEqualToString:currentVersion]) {
        return NO;
    }

    NSArray* currentVersionSegments = [currentVersion componentsSeparatedByString:@"."];
    NSArray* appStoreVersionSegments = [appStoreVersion componentsSeparatedByString:@"."];

    for (NSInteger index = 0; index < MAX([currentVersionSegments count], [appStoreVersionSegments count]); index++) {
        NSInteger currentSegment = (index < [currentVersionSegments count]) ? [[currentVersionSegments objectAtIndex:index] integerValue] : 0;
        NSInteger appStoreSegment = (index < [appStoreVersionSegments count]) ? [[appStoreVersionSegments objectAtIndex:index] integerValue] : 0;

        if (currentSegment == appStoreSegment) {
            continue;
        } else if (currentSegment > appStoreSegment) {
            return NO;
        } else {
            return YES;
        }
    }

    return NO;
}

- (void)goToAppStore
{
    NSURL* appStoreURL = [NSURL URLWithString:_appStoreUrlString];
    [[UIApplication sharedApplication] openURL:appStoreURL];
}

- (void)showNewVersionSuggestingAlert
{
    UIAlertController* alert =
        [UIAlertController alertControllerWithTitle:@""
                                            message:NSLocalizedString(@"A new version of the application is available. Install?", nil)
                                     preferredStyle:UIAlertControllerStyleAlert];

    __weak PRAppVersionManager* weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction* _Nonnull action) {
                                                PRAppVersionManager* strongSelf = weakSelf;
                                                if (strongSelf) {
                                                    [PRGoogleAnalyticsManager sendEventWithName:kNewVersionAvailableYesButtonClicked parameters:nil];
                                                    [strongSelf goToAppStore];
                                                }
                                            }]];

    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil)
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction* _Nonnull action) {
                                                PRAppVersionManager* strongSelf = weakSelf;
                                                if (strongSelf) {
                                                    [PRGoogleAnalyticsManager sendEventWithName:kNewVersionAvailableNoButtonClicked parameters:nil];
                                                }
                                            }]];

    [alert pr_show];
}

@end
