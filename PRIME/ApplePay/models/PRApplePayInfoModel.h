//
//  PRApplePayInfoModel.h
//  PRIME
//
//  Created by Davit on 1/10/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PassKit/PassKit.h>
#import "PRApplePayItemModel.h"

@interface PRApplePayInfoModel : NSObject

@property (strong, nonatomic) NSNumber* orderId;
@property (strong, nonatomic) NSNumber* status;
@property (strong, nonatomic) NSString* amount;
@property (strong, nonatomic) NSString* paymentUid;
@property (strong, nonatomic) NSString* merchantIdentifier;
@property (strong, nonatomic) NSString* countryCode;
@property (strong, nonatomic) NSString* currencyCode;
@property (strong, nonatomic) NSString* providerUrl;
@property (strong, nonatomic, getter=getSupportedNetworks) NSArray<PKPaymentNetwork>* supportedNetworks;
@property (assign, nonatomic, getter=getMerchantCapability) PKMerchantCapability merchantCapability;
@property (strong, nonatomic) NSArray<PRApplePayItemModel*>* paymentSummaryItems;

+ (RKObjectMapping*)mapping;

@end
