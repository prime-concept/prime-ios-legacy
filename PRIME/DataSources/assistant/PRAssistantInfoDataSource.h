//
//  PRAssistantInfoDataSource.h
//  PRIME
//
//  Created by Spartak on 2/2/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PRAssistantInfoDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

+ (UIView*)assistantTitleViewWithFram:(CGRect)frame asistentName:(NSString*)asistentName;
- (instancetype)initWithAssistantPhone:(NSString*)phone email:(NSString*)email;

@end
