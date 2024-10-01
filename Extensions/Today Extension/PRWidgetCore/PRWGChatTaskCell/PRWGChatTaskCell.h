//
//  PRWGChatTaskCell.h
//  PRIME
//
//  Created by Armen on 5/2/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PRWGChatTaskCell : UITableViewCell

-(void)updateCellWithData:(NSDictionary*)data;
-(void)updateForCompactMode;

@end
