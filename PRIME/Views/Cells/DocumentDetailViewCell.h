//
//  DocumentDetailViewCell.h
//  PRIME
//
//  Created by Artak on 6/25/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DocumentDetailViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextField* textFieldValue;

- (void)configureCellByName:(NSString*)name text:(NSString*)text andPlaceholder:(NSString*)placeholder;
@end
