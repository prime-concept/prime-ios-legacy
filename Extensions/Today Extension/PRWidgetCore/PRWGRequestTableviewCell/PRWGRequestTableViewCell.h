//
//  PRWGRequestTableViewCell.h
//  PRWidgetPrime
//
//  Created by Armen on 4/4/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PRWGRequestTableViewCell : UITableViewCell

- (void)updateCellWithData:(NSDictionary*)data;
- (void)setDate:(NSDictionary *)date;
- (void)setRequestStatus:(NSDictionary *)data;
@end
