//
//  PROverviewScreenLoader.h
//  PRIME
//
//  Created by Davit on 8/24/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OverviewScreenLoaderDelegate <NSObject>

- (void)onScreenLoaded:(UIViewController*)viewController;

@end

@interface PROverviewScreenLoader : NSObject

- (void)loadScreensWithDelegate:(id<OverviewScreenLoaderDelegate>)delegate;

@end
