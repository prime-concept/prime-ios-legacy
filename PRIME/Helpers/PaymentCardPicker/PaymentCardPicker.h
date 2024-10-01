//
//  PaymentCardPicker.h
//  PRIME
//
//  Created by Admin on 2/27/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <Availability.h>
#undef weak_delegate
#if __has_feature(objc_arc_weak)
#define weak_delegate weak
#else
#define weak_delegate unsafe_unretained
#endif

#import "PaymentCardPickerItems.h"

#import <UIKit/UIKit.h>

@class PaymentCardPicker;


@protocol PaymentCardPickerDelegate <UIPickerViewDelegate>

- (void)paymentCardPicker:(PaymentCardPicker *)picker didSelectCardWithIndex:(NSInteger) index;

@end

@interface PaymentCardPicker : UIPickerView

@property (nonatomic, strong) PaymentCardPickerItems* items; //TODO: should be copy !!!

@property (nonatomic, weak_delegate) id<PaymentCardPickerDelegate> delegate;

@property (nonatomic, assign) NSUInteger selectedCardIndex;

- (void)setSelectedCardIndex:(NSInteger)index animated:(BOOL)animated;

@end
