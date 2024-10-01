//
//  PRApplePayInfoModel.m
//  PRIME
//
//  Created by Davit on 1/10/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRApplePayInfoModel.h"

@interface PRApplePayInfoModel ()

@property (strong, nonatomic) NSString* merchantCapabilities;

@end

@implementation PRApplePayInfoModel

+ (RKObjectMapping*)mapping
{
    static RKObjectMapping* mapping = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        mapping = [RKObjectMapping mappingForClass:[PRApplePayInfoModel class]];

        [mapping addAttributeMappingsFromArray:
                     @[
                        @"countryCode",
                        @"currencyCode",
                        @"amount",
                        @"merchantCapabilities",
                        @"merchantIdentifier",
                        @"orderId",
                        @"status",
                        @"paymentUid",
                        @"providerUrl"
                     ]];

        [mapping addRelationshipMappingWithSourceKeyPath:@"paymentSummaryItems" mapping:[PRApplePayItemModel mapping]];
    });

    return mapping;
}

- (PKMerchantCapability)getMerchantCapability
{
    if ([_merchantCapabilities isEqualToString:@"3DS"]) {
        return PKMerchantCapability3DS;
    }
    if ([_merchantCapabilities isEqualToString:@"EMV"]) {
        return PKMerchantCapabilityEMV;
    }
    if ([_merchantCapabilities isEqualToString:@"Credit"]) {
        return PKMerchantCapabilityCredit;
    }
    if ([_merchantCapabilities isEqualToString:@"Debit"]) {
        return PKMerchantCapabilityDebit;
    }
    return 0;
}

- (NSArray<PKPaymentNetwork>*)getSupportedNetworks
{
    return @[ PKPaymentNetworkAmex,
        PKPaymentNetworkChinaUnionPay,
        PKPaymentNetworkDiscover,
        PKPaymentNetworkInterac,
        PKPaymentNetworkMasterCard,
        PKPaymentNetworkPrivateLabel,
        PKPaymentNetworkVisa,
        PKPaymentNetworkJCB,
        PKPaymentNetworkSuica ];
}

@end
