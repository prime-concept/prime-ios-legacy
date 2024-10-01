//
//  ProfileTableViewCell.h
//  PRIME
//
//  Created by Aram on 1/20/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PRProfileDataCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView* cellImage;
@property (weak, nonatomic) IBOutlet UILabel* cellTitle;

- (void)configureCellByText:(NSString*)text andImage:(UIImage*)image;

@end
