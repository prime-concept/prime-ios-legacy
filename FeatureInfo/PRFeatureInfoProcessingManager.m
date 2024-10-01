//
//  PRFeatureInfoProcessingManager.m
//  PRIME
//
//  Created by Sargis Terteryan on 5/24/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import "PRFeatureInfoProcessingManager.h"
#import "PRUserProfileFeaturesModel.h"
#import "PRFeatureInfoViewController.h"
#import "PRFeaturesContainerViewController.h"
#import "PRInformationModel.h"

static NSString* const kFeaturesDataDownloadUrl = @"https://primeconcept.co.uk/features/%@/ios%@.json";
static NSString* const kLocaleLanguageCodeKey = @"kCFLocaleLanguageCodeKey";
static NSString* const kFeatureInfoViewController = @"PRFeatureInfoViewController";

@implementation PRFeatureInfoProcessingManager

- (void)getFeatureInfoData:(void (^)(NSArray<UIViewController*>* pageViewControllers))featurePagesHandler
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSArray<PRUserProfileFeaturesModel*>* profileFeatures = [PRUserProfileFeaturesModel MR_findAll];
    UIStoryboard* mainStoryboard = [Utils mainStoryboard];
    __block NSMutableArray<UIViewController*>* pages;
    dispatch_group_t group = dispatch_group_create();
    NSString* boolKeyForFeatures = nil;

    for (PRUserProfileFeaturesModel* feature in profileFeatures) {
        NSString* featureName = feature.feature;

        boolKeyForFeatures = [NSString stringWithFormat:kInfoIsRequested, featureName];

        if (![defaults boolForKey:boolKeyForFeatures]) {
            dispatch_group_enter(group);
            NSMutableURLRequest* request = [self createURLRequestForFeature:featureName];
            __weak PRFeatureInfoProcessingManager* weakSelf = self;
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
                                                                                      PRFeatureInfoProcessingManager* strongSelf = weakSelf;
                                                                                      if (!strongSelf) {
                                                                                          return;
                                                                                      }

                                                                                      NSArray* featuresArray = [responseDict valueForKey:kInformationItems];
                                                                                      if (!featuresArray || !featuresArray.count) {
                                                                                          [defaults setBool:YES forKey:boolKeyForFeatures];
                                                                                          return;
                                                                                      }

                                                                                      if (!pages) {
                                                                                          pages = [[NSMutableArray alloc] init];
                                                                                      }

                                                                                      PRFeatureInfoViewController* viewController = (PRFeatureInfoViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:kFeatureInfoViewController];
                                                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                                                          [viewController view];
                                                                                          [viewController setFeatureInfoData:featuresArray withFeatureBoolKey:boolKeyForFeatures];
                                                                                          [pages addObject:viewController];
                                                                                      });
                                                                                      dispatch_group_leave(group);
                                                                                  } else {
                                                                                      PRFeatureInfoProcessingManager* strongSelf = weakSelf;
                                                                                      if (!strongSelf) {
                                                                                          return;
                                                                                      }

                                                                                      dispatch_group_leave(group);
                                                                                      if (httpResponse.statusCode == kErrorNotFound) {
                                                                                          [defaults setBool:YES forKey:boolKeyForFeatures];
                                                                                      }
                                                                                  }
                                                                              }];

            [dataTask resume];
        }
    }

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (pages.count > 0) {
            featurePagesHandler(pages);
        }
    });
}

- (void)getHelpScreenFeatures:(void (^)(NSArray* featuresData))helpScreenHandler
{
    __weak PRFeatureInfoProcessingManager* weakSelf = self;
    NSMutableURLRequest* request = [self createURLRequestForFeature:kTargetName];
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
                                                                              PRFeatureInfoProcessingManager* strongSelf = weakSelf;
                                                                              NSArray* featuresArray = [responseDict valueForKey:kInformationItems];

                                                                              if (!strongSelf || !featuresArray || !featuresArray.count) {
                                                                                  return;
                                                                              }

                                                                              NSManagedObjectContext* mainContext = [NSManagedObjectContext MR_contextForCurrentThread];
                                                                              PRInformationModel* model = [PRDatabase getInformation];
                                                                              if (model) {
                                                                                  model = [model MR_inContext:mainContext];
                                                                                  model.informationsArray = featuresArray;
                                                                              } else {
                                                                                  model = [PRInformationModel MR_createEntityInContext:mainContext];
                                                                                  model.informationsArray = featuresArray;
                                                                              }

                                                                              [mainContext MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError * _Nullable error) {
                                                                              }];

                                                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                                                  helpScreenHandler(featuresArray);
                                                                              });
                                                                          }
                                                                      }];

    [dataTask resume];
}

- (NSMutableURLRequest*)createURLRequestForFeature:(NSString*)feature
{
    NSString* const language = [[NSLocale preferredLanguages] firstObject];
    NSDictionary* const languageDic = [NSLocale componentsFromLocaleIdentifier:language];
    NSString* languageCode = [languageDic objectForKey:kLocaleLanguageCodeKey];
    NSString* urlString = nil;

    if ([languageCode isEqualToString:@"ru"]) {
        urlString = [NSString stringWithFormat:kFeaturesDataDownloadUrl, feature, [@"_" stringByAppendingString:languageCode]];
    } else if ([languageCode isEqualToString:@"en"]) {
        urlString = [NSString stringWithFormat:kFeaturesDataDownloadUrl, feature, [@"_" stringByAppendingString:languageCode]];
    } else {
        urlString = [NSString stringWithFormat:kFeaturesDataDownloadUrl, feature, @""];
    }

    NSURL* url = [[NSURL alloc] initWithString:urlString];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];

    return request;
}

@end
