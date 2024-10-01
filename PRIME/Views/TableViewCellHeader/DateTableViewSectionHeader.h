//
//  viewForHeaderInSection.h
//  PRIME
//
//  Created by Taron Sahakyan on 12/8/15.
//  Copyright © 2015 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DateTableViewSectionHeader : UIView
- (instancetype)init:(UITableView*)tableView withSectionTitle:(NSString*)sectionTitle;
- (instancetype)init:(UITableView*)tableView withSectionTitle:(NSString*)sectionTitle andTitlePositionFromLeft:(CGFloat)position;
@end
