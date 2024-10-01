//
//  ProfileContactsTableView.m
//  PRIME
//
//  Created by Artak on 2/11/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "ProfileContactsTableView.h"

@implementation ProfileContactsTableView

- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) {
        return nil;
    }

    self.closeKeyboardOnTouch = NO;

    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.closeKeyboardOnTouch = NO;
}

@end
