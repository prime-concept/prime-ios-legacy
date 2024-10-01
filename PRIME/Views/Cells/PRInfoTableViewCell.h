//
//  PRInfoTableViewCell.h
//  PRIME
//
//  Created by Mariam on 1/19/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PRInfoTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel* labelInfo;

- (void)configureCellWithInfo:(NSString*)info;

- (void)configureCellWithInfo:(NSString*)info andDetail:(NSString*)detail;

- (void)configureCellWithInfo:(NSString*)info detail:(NSString*)detail andImage:(UIImage*)image;

- (void)configureCellWithInfo:(NSString*)info placeholder:(NSString*)placeholder andDetail:(NSString*)detail;

- (void)configureCellWithInfo:(NSString*)info placeholder:(NSString*)placeholder detail:(NSString*)detail andImage:(UIImage*)image;

@end
