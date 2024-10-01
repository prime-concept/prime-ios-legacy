//
//  PRBalanceModel.m
//  PRIME
//
//  Created by Admin on 7/29/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRBalanceModel.h"
#import "PRTransactionModel.h"


@implementation PRBalanceModel

#ifdef USE_COREDATA
@dynamic openingBalance;
@dynamic closingBalance;
@dynamic currency;
@dynamic transactions;
@dynamic month;
@dynamic year;
#endif

+ (RKObjectMapping*) mapping
{
    static RKObjectMapping *mapping = nil;
    
    pr_dispatch_once({
        
        mapping = [super mapping];
        
        [mapping addAttributeMappingsFromArray:
         @[
           @"openingBalance",
            @"closingBalance",
            @"currency"
           ]];
        
        [mapping addRelationshipMappingWithSourceKeyPath:@"transactions"
                                                 mapping: [PRTransactionModel mapping]];
    });
    
    
    return mapping;
}
@end
