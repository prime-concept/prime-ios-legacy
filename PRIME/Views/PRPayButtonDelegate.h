//
//  PRPayButtonDelegate.h
//  PRIME
//
//  Created by Admin on 2/19/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#ifndef PRIME_PRPayButtonDelegate_h
#define PRIME_PRPayButtonDelegate_h

@protocol PRPayButtonDelegate

- (void)pay:(NSString*)paymentLink withSender:(id)sender;

@end

#endif
