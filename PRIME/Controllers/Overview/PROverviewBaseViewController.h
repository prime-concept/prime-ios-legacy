//
//  PROverviewBaseViewController.h
//  PRIME
//
//  Created by Davit on 8/24/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "BaseViewController.h"
#import "PROverviewScreenConstants.h"

@protocol FillScreenDataProtocol <NSObject>

@optional
- (void)fillScreenWithData:(NSDictionary*)dataDict;

@end

@interface PROverviewBaseViewController : BaseViewController <FillScreenDataProtocol>

- (void)applyGradientToView:(UIView*)view;

@end
