//
//  StatisticHeader.m
//  PRIME
//
//  Created by Admin on 3/17/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "StatisticHeader.h"

@implementation StatisticHeader

-(instancetype)init{
    
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"StatisticHeader" owner:self options:nil];
    id mainView = subviewArray[0];
    return mainView;
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
