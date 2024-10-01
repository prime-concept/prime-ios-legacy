//
//  UberManager.m
//  PRIME
//
//  Created by Nerses Hakobyan on 4/9/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "PRUberEstimates.h"
#import "UberManager.h"
#import <AFNetworking/AFHTTPRequestOperation.h>

static NSString* const kProductsPricePath = @"/v1/products";
static NSString* const kEstimatesPricePath = @"/v1/estimates/price";
static NSString* const kEstimatesTimePath = @"/v1/estimates/time";

@implementation UberManager

+ (UberManager*)sharedManager
{
    static UberManager* sharedManager = nil;

    pr_dispatch_once({
        sharedManager = [[self alloc] init];
    });

    return sharedManager;
}

- (void)getUberCarsImagesForStartLatitude:(NSNumber*)startLatitude
                           startlongitude:(NSNumber*)startLongitude
                              withSuccess:(void (^)(NSArray<NSDictionary*>* products))success
                                  failure:(void (^)(NSError* error))failure
{
    NSDictionary* parameters = @{
        @"latitude" : startLatitude,
        @"longitude" : startLongitude
    };

    AFJSONRequestOperation* operation = [AFJSONRequestOperation
        JSONRequestOperationWithRequest:[self constructRequestWithPath:kProductsPricePath andParameters:parameters]
        success:^(NSURLRequest* request, NSHTTPURLResponse* response, NSDictionary* JSON) {
            if (JSON && [JSON valueForKey:@"products"]) {
                NSArray<NSDictionary*>* products = [JSON valueForKey:@"products"];
                success(products);
            }

        }
        failure:^(NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON) {
            NSLog(@"NSError: %@", error.localizedDescription);

        }];

    [operation setCacheResponseBlock:^NSCachedURLResponse*(NSURLConnection* connection, NSCachedURLResponse* cachedResponse) {
        return nil;
    }];

    [operation start];
}

- (void)getEstimatedPricesWithStartLatitude:(NSNumber*)startLatitude
                             startLongitude:(NSNumber*)startLongitude
                                endLatitude:(NSNumber*)endLatitude
                               endLongitude:(NSNumber*)endLongitude
                                withSuccess:(void (^)(NSArray<PRUberEstimates*>* uberEstimates))success
                                    failure:(void (^)(NSError* error))failure
{
    NSDictionary* parameters = @{
        @"start_latitude" : startLatitude,
        @"end_latitude" : endLatitude,
        @"start_longitude" : startLongitude,
        @"end_longitude" : endLongitude
    };

    AFJSONRequestOperation* operation = [AFJSONRequestOperation
        JSONRequestOperationWithRequest:[self constructRequestWithPath:kEstimatesPricePath andParameters:parameters]
        success:^(NSURLRequest* request, NSHTTPURLResponse* response, NSDictionary* JSON) {
            if (JSON && [JSON valueForKey:@"prices"]) {
                NSLog(@"%@", JSON);
                NSLog(@"start latitude = %@, start longitude = %@", startLatitude, startLongitude);
                NSLog(@"end latitude = %@, end longitude = %@", endLatitude, endLongitude);
                NSArray<NSDictionary*>* estimates = [JSON valueForKey:@"prices"];
                NSMutableArray<PRUberEstimates*>* uberEstimates = [NSMutableArray array];
                for (int i = 0; i < estimates.count; i++) {
                    PRUberEstimates* uberEstimate = [PRUberEstimates new];
                    uberEstimate.productId = [estimates[i] valueForKey:@"product_id"];
                    uberEstimate.estimatedPrice = [estimates[i] valueForKey:@"estimate"];
                    uberEstimate.lowEstimate = [estimates[i] valueForKey:@"low_estimate"];
                    uberEstimate.highEstimate = [estimates[i] valueForKey:@"high_estimate"];
                    uberEstimate.currencyCode = [estimates[i] valueForKey:@"currency_code"];
                    uberEstimate.displayName = [estimates[i] valueForKey:@"display_name"];
                    uberEstimate.surgeMultiplier = [estimates[i] valueForKey:@"surge_multiplier"];
                    uberEstimate.duration = [estimates[i] valueForKey:@"duration"];
                    [uberEstimates addObject:uberEstimate];
                }

                [self getEstimatedPickupTimeWithStartLatitude:startLatitude
                                               startLongitude:startLongitude
                                                 forEstimates:uberEstimates
                                                  withSuccess:success
                                                      failure:failure];
                success(uberEstimates);
            }

        }
        failure:^(NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON) {
            NSLog(@"NSError: %@", error.localizedDescription);
            if (failure) {
                failure(error);
            }

        }];

    [operation setCacheResponseBlock:^NSCachedURLResponse*(NSURLConnection* connection, NSCachedURLResponse* cachedResponse) {
        return nil;
    }];

    [operation start];
}

- (void)getEstimatedPickupTimeWithStartLatitude:(NSNumber*)startLatitude
                                 startLongitude:(NSNumber*)startLongitude
                                   forEstimates:(NSMutableArray<PRUberEstimates*>*)uberEstimates
                                    withSuccess:(void (^)(NSArray<PRUberEstimates*>* uberEstimatesToReturn))success
                                        failure:(void (^)(NSError* error))failure
{
    NSDictionary* parameters = @{
        @"start_latitude" : startLatitude,
        @"start_longitude" : startLongitude,
    };

    AFJSONRequestOperation* operation = [AFJSONRequestOperation
        JSONRequestOperationWithRequest:[self constructRequestWithPath:kEstimatesTimePath andParameters:parameters]
        success:^(NSURLRequest* request, NSHTTPURLResponse* response, NSDictionary* JSON) {
            NSLog(@"%@", JSON);
            if (JSON && [JSON valueForKey:@"times"]) {
                NSArray<NSDictionary*>* estimates = [JSON valueForKey:@"times"];
                for (PRUberEstimates* uberEstimate in uberEstimates) {
                    for (int i = 0; i < estimates.count; i++) {
                        if ([[estimates[i] valueForKey:@"product_id"] isEqualToString:uberEstimate.productId]) {
                            uberEstimate.estimatedPickupTime = [estimates[i] valueForKey:@"estimate"];
                            break;
                        }
                    }
                }
                success(uberEstimates);
            }
        }
        failure:^(NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON) {
            NSLog(@"NSError: %@", error.localizedDescription);
        }];

    [operation setCacheResponseBlock:^NSCachedURLResponse*(NSURLConnection* connection, NSCachedURLResponse* cachedResponse) {
        return nil;
    }];

    [operation start];
}

- (NSMutableURLRequest*)constructRequestWithPath:(NSString*)path andParameters:(NSDictionary*)parameters
{
    NSURL* url = [[NSURL alloc] initWithString:kUberServerUrl];
    AFHTTPClient* client = [[AFHTTPClient alloc] initWithBaseURL:url];

    NSMutableURLRequest* request = [client requestWithMethod:@"GET" path:path parameters:parameters];
    [request setValue:[NSString stringWithFormat:@"Token %@", kUberServerToken] forHTTPHeaderField:@"Authorization"];
    return request;
}

- (void)openUrlForProductId:(NSString*)productId
              startLatitude:(NSNumber*)startLatitude
             startLongitude:(NSNumber*)startLongitude
                endLatitude:(NSNumber*)endLatitude
               endLongitude:(NSNumber*)endLongitude
             dropoffAddress:(NSString*)dropoffAddress
{
    NSString* encodedDropoffAddress = [dropoffAddress stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString* uberUrlPattern = @"uber://?client_id=%@&action=setPickup&pickup[latitude]=%@&pickup[longitude]=%@&dropoff[latitude]=%@&dropoff[longitude]=%@&dropoff[formatted_address]=%@&product_id=%@";

    NSString* url = [NSString stringWithFormat:uberUrlPattern, kUberClientID, startLatitude, startLongitude, endLatitude, endLongitude, encodedDropoffAddress, productId];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"uber://"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        return;
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://m.uber.com"]];
}

- (NSString*)getEstimateForUber:(PRUberEstimates*)uberEstimate
{
    return ([uberEstimate.lowEstimate doubleValue] == [uberEstimate.highEstimate doubleValue]) ? [NSString stringWithFormat:@"%@", uberEstimate.highEstimate]
                                                                                               : [NSString stringWithFormat:@"%@-%@", uberEstimate.lowEstimate, uberEstimate.highEstimate];
}

- (NSString*)getCurrencySignForCode:(NSString*)code
{
    return [code isEqualToString:@"RUB"] ? @"₽" : [code isEqualToString:@"USD"] ? @"$" : [code isEqualToString:@"EUR"] ? @"€" : code;
}

- (BOOL)isUberAvailableAtTime:(NSDate*)date
{
    NSTimeInterval timeInterval = date.timeIntervalSinceNow;
    if (fabs(timeInterval) <= 60 * 20 || (timeInterval >= 0 && timeInterval <= 60 * 60 * 3)) {
        return YES;
    }
    return NO;
}

- (BOOL)isUberAvailableInCurrentLocation:(CLLocation*)currentLocation
                        forEventLocation:(CLLocation*)eventLocation
{
    if (!currentLocation) {
        return NO;
    }

    const NSUInteger kKilometerCoefficient = 1000;
    const NSUInteger kMaximumAllowedDistance = 300;

    CLLocationDistance locationDistance = [currentLocation distanceFromLocation:eventLocation];
    const CGFloat locationDistanceInKilometers = ceil(locationDistance / kKilometerCoefficient);

    if (locationDistanceInKilometers <= kMaximumAllowedDistance) {
        return YES;
    }
    return NO;
}

@end
