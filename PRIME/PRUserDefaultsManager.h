//
//  PRUserDefaultsManager.h
//  PRIME
//
//  Created by Armen on 4/30/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PRUserDefaultsManager : NSObject

+ (instancetype)sharedInstance;
- (void)setWidgetMessages:(NSArray*)messages;
- (void)setWidgetRequests;
- (void)setWidgetEvents;
- (void)getCityGuideDataWithLocation;
- (void)saveServicesImagesForWidgets:(NSArray*)servicesArray;
- (void)saveToken:(NSString*)token;
- (void)updateWidgetMessages;

@end
