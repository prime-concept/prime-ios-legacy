//
//  PaymentCardPickerItems.m
//  PRIME
//
//  Created by Admin on 2/27/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PaymentCardPickerItems.h"

@implementation PaymentCardPickerItem

@end

@interface PaymentCardPickerItems () {
}
    @property (nonatomic, strong) NSMutableArray* items;

@end

@implementation PaymentCardPickerItems

-(instancetype)init
{
    if (!(self = [super init])) return nil;
    
    _items = [[NSMutableArray alloc] init];
    
    return self;
}

- (PaymentCardPickerItem*) itemAtIndex: (NSUInteger) index
{
    if (index < [_items count] ) {
        return _items[index];
    }    
    return nil;
}

- (NSUInteger) count
{
    return [_items count];
}

- (void) addItemWithText: (NSString*) text image: (UIImage *) image
{
    PaymentCardPickerItem * item = [[PaymentCardPickerItem alloc] init];
    
    [item setText: text];
    [item setImage: image];
    
    [_items addObject: item];
}

@end
