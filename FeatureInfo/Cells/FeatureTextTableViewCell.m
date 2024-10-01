//
//  FeatureTextTableViewCell.m
//  PRIME
//
//  Created by Sargis Terteryan on 5/29/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import "FeatureTextTableViewCell.h"

@interface FeatureTextTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel* featureTextLabel;

@end

static CGFloat const kTextLabelFontSize = 13.5f;

@implementation FeatureTextTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setFeatureText:(NSString*)text
{
    [self.featureTextLabel setTextColor:kFeatureInfoTextColor];
    self.featureTextLabel.text = text;
    [self.featureTextLabel setFont:[UIFont systemFontOfSize:kTextLabelFontSize]];
}

@end
