//
//  UberManager.h
//  PRIME
//
//  Created by Nerses Hakobyan on 4/9/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "PRUberEstimates.h"
#import <Foundation/Foundation.h>

@interface UberManager : NSObject

+ (UberManager*)sharedManager;
- (void)getEstimatedPricesWithStartLatitude:(NSNumber*)startLatitude
                             startLongitude:(NSNumber*)startLongitude
                                endLatitude:(NSNumber*)endLatitude
                               endLongitude:(NSNumber*)endLongitude
                                withSuccess:(void (^)(NSArray<PRUberEstimates*>* uberEstimates))success
                                    failure:(void (^)(NSError* error))failure;

- (void)getUberCarsImagesForStartLatitude:(NSNumber*)startLatitude
                           startlongitude:(NSNumber*)startLongitude
                              withSuccess:(void (^)(NSArray<NSDictionary*>* products))success
                                  failure:(void (^)(NSError* error))failure;

- (void)openUrlForProductId:(NSString*)productId
              startLatitude:(NSNumber*)startLatitude
             startLongitude:(NSNumber*)startLongitude
                endLatitude:(NSNumber*)endLatitude
               endLongitude:(NSNumber*)endLongitude
             dropoffAddress:(NSString*)dropoffAddress;

- (NSString*)getEstimateForUber:(PRUberEstimates*)uberEstimate;
- (NSString*)getCurrencySignForCode:(NSString*)code;

- (BOOL)isUberAvailableAtTime:(NSDate*)date;
- (BOOL)isUberAvailableInCurrentLocation:(CLLocation*)currentLocation
                        forEventLocation:(CLLocation*)eventLocation;

@end
