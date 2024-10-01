//
//  PRBalanceModel+CoreDataProperties.m
//  PRIME
//
//  Created by Admin on 9/28/15.
//  Copyright © 2015 XNTrends. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "PRExchangeModel.h"

@implementation PRExchangeModel

@dynamic quantity;
@dynamic currency;
@dynamic date;
@dynamic rate;

+ (RKObjectMapping*) mapping
{
    static RKObjectMapping *mapping = nil;
    
    pr_dispatch_once({
        
        mapping = [super mapping];
        
        [mapping addAttributeMappingsFromArray:
         @[
           @"currency",
           @"date",
           @"quantity",
           @"rate"
           ]];
    });
    
    
    [self setIdentificationAttributes: @[@"date", @"currency"]
                              mapping: mapping];
    return mapping;
}
@end
