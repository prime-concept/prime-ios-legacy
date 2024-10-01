//
//  StatisticTableViewCell.h
//  PRIME
//
//  Created by Admin on 3/17/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatisticTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelCurrencies;
@property (weak, nonatomic) IBOutlet UILabel *labelType;
@property (weak, nonatomic) IBOutlet UILabel *labelPercent;
@property (nonatomic) BOOL needToDrawProgerss;

@property (strong, nonatomic) UIColor *progressBarColor;
@property CGFloat progressBarHeigth;
@property CGFloat progressSize;
@property CGFloat leftMargin;

@end
