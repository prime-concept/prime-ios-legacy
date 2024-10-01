//
//  ViewForTableViewHeader.h
//  PRIME
//
//  Created by Taron Sahakyan on 12/8/15.
//  Copyright © 2015 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewForTableViewHeader : UIView
@property (strong, nonatomic) NSMutableArray* labels;
@property (strong, nonatomic) UIView * bottomView;
@property (weak, nonatomic) UITableView *tableView;
@property(strong, nonatomic) UIView* topView;
@property (strong, nonatomic) UIView* lablesView;

- (id)initWithNewAutoLayoutView :(NSArray*)balances;

- (void) resizeHeadrView;
@end
