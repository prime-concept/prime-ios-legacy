//
//  PROrderModel.m
//  PRIME
//
//  Created by Admin on 2/18/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PROrderModel.h"

@implementation PROrderModel

#ifdef USE_COREDATA
@dynamic orderStatus, amount, paymentLink, paymentUid, dueDate, currency;
#endif

+ (RKObjectMapping*)mapping
{
    static RKObjectMapping* mapping = nil;

    pr_dispatch_once({

        mapping = [super mapping];

        [mapping addAttributeMappingsFromArray:
                     @[
                        @"orderStatus",
                        @"amount",
                        @"currency",
                        @"paymentLink",
                        @"paymentUid",
                        @"dueDate"
                     ]];
    });

    return mapping;
}

- (NSString*)getCurrency
{
    NSArray* currencyTypes = @[ @"", @"RUR", @"EUR", @"USD" ];
    NSString* currency = [self.currency stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSInteger item = [currencyTypes indexOfObject:currency];

    switch (item) {
    case 1:
        return @"₽";
    case 2:
        return @"€";
    case 3:
        return @"$";
    default:
        return currency;
    }
}

@end
