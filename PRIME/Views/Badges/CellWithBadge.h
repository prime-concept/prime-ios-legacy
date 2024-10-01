//
//  CellWithBadge.h
//  PRIME
//
//  Created by Artak on 11/23/15.
//  Copyright © 2015 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CellWithBadge : UITableViewCell

@property (strong, nonatomic) UILabel *badge;
- (void) createBadgeWithValue:(NSInteger) count;
@end
