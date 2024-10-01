//
//  DocumentTableViewCell.h
//  PRIME
//
//  Created by Artak on 1/31/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface DocumentTableViewCell : UITableViewCell

- (void)setLabelsValuesForLabelName:(NSString*)name
                    labelItemsCount:(NSString*)count
                          textColor:(UIColor*)color;

@end
