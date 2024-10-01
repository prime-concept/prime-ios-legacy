//
//  PRProfileRegistrationCell.h
//  PRIME
//
//  Created by Aram on 8/8/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PRProfileRegistrationCell : UITableViewCell
- (void)configureCellWithTextfieldText:(NSString*)text placeholder:(NSString*)placeholder tag:(NSInteger)tag delegate:(id)delegate arrowImageHidden:(BOOL)hidden;
- (void)setSelection:(BOOL)selection;
- (void)changePlaceholderText:(NSString*)text;
- (void)disableTextfield;

@end
