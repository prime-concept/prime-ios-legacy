//
//  PRTransactionModel.m
//  PRIME
//
//  Created by Admin on 7/29/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRTransactionModel.h"
#import <objc/runtime.h>

@implementation PRTransactionModel

#ifdef USE_COREDATA
@dynamic transactionId;
@dynamic period;
@dynamic category;
@dynamic toReport;
@dynamic type;
@dynamic balanceBefore;
@dynamic amount;
@dynamic balanceAfter;
@dynamic currency;
@dynamic directPayment;
@dynamic day;
@dynamic balance;
@dynamic exchangeRate;
@dynamic expense;
@dynamic taskInfoId;
#endif

+ (RKObjectMapping*) mapping
{
    static RKObjectMapping *mapping = nil;
    
    pr_dispatch_once({
        
        mapping = [super mapping];
        
        [mapping addAttributeMappingsFromArray:
         @[
           @"period",
           @"category",
           @"toReport",
           @"type",
           @"balanceBefore",
           @"amount",
           @"balanceAfter",
           @"currency",
           @"directPayment",
           @"exchangeRate",
           @"taskInfoId",
           @"expense"
           ]];
        
        [mapping addAttributeMappingsFromDictionary:
         @{
           @"id" : @"transactionId"}];
        
        [self setIdentificationAttributes: @[@"transactionId"]
                                               mapping: mapping];
    });

    
    return mapping;
}

- (NSDate *)day {
    
    return [self.period mt_startOfCurrentDay];
    
}

- (NSString*) description
{
    unsigned int count=0;
    objc_property_t *props = class_copyPropertyList([self class],&count);
    NSMutableString *desc = [NSMutableString stringWithString:@""];
    
    for ( int i=0;i<count;i++ )
    {
        const char *name = property_getName(props[i]);
        id value = [self valueForKey:[NSString stringWithUTF8String:name]];
        NSString *values = [NSString stringWithFormat:@"property  %s - %@", name, value];
        [desc appendString:values];
    }
    
    return [NSString stringWithString:desc];
    
}

@end
