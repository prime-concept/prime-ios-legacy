//
//  PRProfileRegistrationFooterView.h
//  PRIME
//
//  Created by Aram on 8/22/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PRCheckboxDelegate <NSObject>
- (void)didSelectCheckbox:(BOOL)selection;

@end

@interface PRProfileRegistrationFooterView : UITableViewHeaderFooterView
- (void)configureViewWithTitle:(NSString*)title titleFont:(UIFont*)titleFont delegate:(id<PRCheckboxDelegate>)delegate checkboxSize:(CGSize)checkboxSize;

@end
