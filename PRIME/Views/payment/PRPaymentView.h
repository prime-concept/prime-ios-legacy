//
//  PRPaymentView.h
//  PRIME
//
//  Created by Davit on 1/11/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PRTaskDetailModel.h"
#import "PRPaymentDataModel.h"

@protocol PaymentViewDelegate;

@interface PRPaymentView : UIView

@property (weak, nonatomic) id<PaymentViewDelegate> delegate;

- (void)setupViewWithTask:(PRTaskDetailModel*)task
              paymentInfo:(PRPaymentDataModel*)paymentData;

@end

@protocol PaymentViewDelegate <NSObject>

- (void)paymentViewCloseButtonDidPress:(PRPaymentView*)paymentView;
- (void)paymentViewPayWithCardButtonDidPress:(PRPaymentView*)paymentView;
- (void)paymentViewPayWithApplePayButtonDidPress:(PRPaymentView*)paymentView;

@end
