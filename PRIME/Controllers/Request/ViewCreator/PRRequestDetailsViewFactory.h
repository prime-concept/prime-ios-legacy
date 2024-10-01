//
//  PRRequestDetailsViewFactory.h
//  PRIME
//
//  Created by Admin on 5/25/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PRRequestDetailsViewBuilder.h"
#import "TTTAttributedLabel.h"

@interface PRRequestDetailsViewFactory : NSObject <PRRequestDetailsViewFactoryInterface>

@property (strong,nonatomic)id<TTTAttributedLabelDelegate> parentViewDelegate;

@end
