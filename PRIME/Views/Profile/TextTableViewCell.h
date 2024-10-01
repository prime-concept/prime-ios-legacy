//
//  TextTableViewCell.h
//  PRIME
//
//  Created by Artak on 1/31/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel* labelText;
@property (weak, nonatomic) IBOutlet UIImageView* plusImageView;

- (TextTableViewCell*)configureCellByText:(NSString*)text andImage:(UIImage*)image;

@end
