//
//  PaymentCardPickerItems.h
//  PRIME
//
//  Created by Admin on 2/27/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PaymentCardPickerItem : NSObject

@property (nonatomic, strong) NSString * text;
@property (nonatomic, strong) UIImage * image;

@end

@interface PaymentCardPickerItems : NSObject

- (PaymentCardPickerItem*) itemAtIndex: (NSUInteger) index;

@property (NS_NONATOMIC_IOSONLY, readonly) NSUInteger count;

- (void) addItemWithText: (NSString*) text image: (UIImage *) image;

@end
