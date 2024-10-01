//
//  UITabBarItem+CustomBadge.m
//  CityGlance
//
//  Created by Enrico Vecchio on 18/05/14.
//  Copyright (c) 2014 Cityglance SRL. All rights reserved.
//

#import "UITabBarItem+CustomBadge.h"
#import <PureLayout.h>


#define CUSTOM_BADGE_TAG 99
#define OFFSET 0.6f


@implementation UITabBarItem (CustomBadge)


-(void) setMyAppCustomBadgeValue: (NSString *) value
{
    UIFont *myAppFont = [UIFont systemFontOfSize:13.0];
    UIColor *myAppFontColor = [UIColor whiteColor];
    UIColor *myAppBackColor = [UIColor lightGrayColor];
    
    [self setCustomBadgeValue:value withFont:myAppFont andFontColor:myAppFontColor andBackgroundColor:myAppBackColor];
}



-(void)setCustomBadgeValue:(NSString *)value
				  withFont:(UIFont *)font
			  andFontColor:(UIColor *)color
		andBackgroundColor:(UIColor *)backColor
{
    UIView *v = [self valueForKey:@"view"];
    
    [self setBadgeValue:value];

    for(UIView *sv in v.subviews) {
        if(false == [NSStringFromClass(sv.class) isEqualToString:@"_UIBadgeView"]) {
			continue;
		}

		for(UIView *ssv in sv.subviews) {
			// REMOVE PREVIOUS IF EXIST
			if(ssv.tag == CUSTOM_BADGE_TAG) { [ssv removeFromSuperview]; }
		}

		UILabel *badgeLabel = [UILabel newAutoLayoutView];

		[badgeLabel setFont:font];
		[badgeLabel setText:value];
		[badgeLabel setBackgroundColor:backColor];
		[badgeLabel setTextColor:color];
		[badgeLabel setTextAlignment:NSTextAlignmentCenter];

		badgeLabel.layer.cornerRadius = badgeLabel.frame.size.height/2;
		badgeLabel.layer.masksToBounds = YES;

		// Fix for border
		sv.layer.borderWidth = 1;
		sv.layer.borderColor = [backColor CGColor];
		sv.layer.cornerRadius = sv.frame.size.height/2;
		sv.layer.masksToBounds = YES;

		[sv addSubview:badgeLabel];
		sv.backgroundColor = badgeLabel.backgroundColor;

		badgeLabel.tag = CUSTOM_BADGE_TAG;

		[badgeLabel autoPinEdgesToSuperviewEdges];
    }
}




@end
