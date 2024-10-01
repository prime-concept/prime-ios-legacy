//
//  PRFeatureInfoProcessingManager.h
//  PRIME
//
//  Created by Sargis Terteryan on 5/24/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PRFeatureInfoProcessingManager : NSObject

- (void)getFeatureInfoData:(void (^) (NSArray<UIViewController*>* pages)) featurePagesHandler;
- (void)getHelpScreenFeatures:(void (^)(NSArray* featuresData))helpScreenHandler;

@end
