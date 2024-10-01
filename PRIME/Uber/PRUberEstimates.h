//
//  PRUberEstimates.h
//  PRIME
//
//  Created by Nerses Hakobyan on 4/10/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PRUberEstimates : NSObject

/** Unique identifier representing a specific product for a given latitude & longitude. 
For example, uberX in San Francisco will have a different product_id than uberX in Los Angeles. */
@property (strong, nonatomic) NSString* productId;

/** Display name of product.*/
@property (strong, nonatomic) NSString* displayName;

/** Formatted string of estimate in local currency of the start location. 
 Estimate could be a range, a single number (flat rate) or "Metered" for TAXI. */
@property (strong, nonatomic) NSString* estimatedPrice;

/** Lower bound of the estimated price.*/
@property (strong, nonatomic) NSNumber* lowEstimate;

/** Upper bound of the estimated price.*/
@property (strong, nonatomic) NSNumber* highEstimate;

/** Expected surge multiplier. Surge is active if surge_multiplier is greater than 1. Price estimate already factors in the surge multiplier.*/
@property (strong, nonatomic) NSNumber* surgeMultiplier;

/** ETA for the product (in seconds). Always show estimate in minutes. */
@property (strong, nonatomic) NSNumber* estimatedPickupTime;

@property (strong, nonatomic) NSNumber* duration;

/** ISO 4217 currency code. */
@property (strong, nonatomic) NSString* currencyCode;

/** Latitude for pickup location */
@property (strong, nonatomic) NSNumber* startLatitude;

/** Longitude for pickup location */
@property (strong, nonatomic) NSNumber* startLongitude;

/** Latitude for dropoff location */
@property (strong, nonatomic) NSNumber* endLatitude;

/** Longitude for dropoff location */
@property (strong, nonatomic) NSNumber* endLongitude;

/** Dropoff address.*/
@property (strong, nonatomic) NSString* dropoffAddress;

/** Image representing the product.*/
@property (strong, nonatomic) UIImage* carImage;

@end
