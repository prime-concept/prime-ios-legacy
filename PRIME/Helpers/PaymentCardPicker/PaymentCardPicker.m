//
//  PaymentCardPicker.m
//  PRIME
//
//  Created by Admin on 2/27/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PaymentCardPicker.h"

#pragma GCC diagnostic ignored "-Wselector"
#pragma GCC diagnostic ignored "-Wgnu"


#import <Availability.h>
#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif

@interface PaymentCardPicker () <UIPickerViewDelegate, UIPickerViewDataSource>

@end

@implementation PaymentCardPicker

//doesn't use _ prefix to avoid name clash with superclass
@synthesize delegate;

- (void)setUp
{
    super.dataSource = self;
    super.delegate = self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self setUp];
    }
    return self;
}

- (void)setDataSource:(__unused id<UIPickerViewDataSource>)dataSource
{
    //does nothing
}

- (void)setSelectedCardIndex:(NSInteger)selectedCardIndex animated:(BOOL)animated
{
    PaymentCardPickerItem * item = [_items itemAtIndex: selectedCardIndex];
    
    if (item != nil)
    {
        [self selectRow:(NSInteger)selectedCardIndex inComponent:0 animated:animated];
    }
}

- (NSUInteger) selectedCardIndex
{
    return (NSUInteger)[self selectedRowInComponent:0];
}

#pragma mark -
#pragma mark UIPicker

- (NSInteger)numberOfComponentsInPickerView:(__unused UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(__unused UIPickerView *)pickerView numberOfRowsInComponent:(__unused NSInteger)component
{
    return (NSInteger)[_items count];
}

- (UIView *)pickerView:(__unused UIPickerView *)pickerView viewForRow:(NSInteger)row
          forComponent:(__unused NSInteger)component reusingView:(UIView *)view
{
    if (!view)
    {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 30)];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(35, 3, 245, 24)];
        label.backgroundColor = [UIColor clearColor];
        label.tag = 1;
        [view addSubview:label];
        
        UIImageView *flagView = [[UIImageView alloc] initWithFrame:CGRectMake(3, 3, 24, 24)];
        flagView.contentMode = UIViewContentModeScaleAspectFit;
        flagView.tag = 2;
        [view addSubview:flagView];
    }
    
    PaymentCardPickerItem * item = [_items itemAtIndex: (NSUInteger)row];
    
    ((UILabel *)[view viewWithTag:1]).text = [item text];
    ((UIImageView *)[view viewWithTag:2]).image = [item image];
    
    return view;
}

- (void)pickerView:(__unused UIPickerView *)pickerView
      didSelectRow:(__unused NSInteger)row
       inComponent:(__unused NSInteger)component
{
    __strong id<PaymentCardPickerDelegate> strongDelegate = delegate;
    
    [strongDelegate paymentCardPicker:self didSelectCardWithIndex:row];
}
@end
