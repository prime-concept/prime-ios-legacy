//
//  PRCardData.m
//  PRIME
//
//  Created by Admin on 2/6/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRCardData.h"

#import <Motis/Motis.h>

@implementation PRCardData

+ (NSDictionary*)mts_mapping
{
    return @{
             @"c": mts_key(cardNumber),
             @"e": mts_key(expDate)
             };
}

+ (BOOL)mts_shouldSetUndefinedKeys
{
    return NO;
}

@end
