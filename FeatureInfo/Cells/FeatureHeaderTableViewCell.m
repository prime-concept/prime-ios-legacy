//
//  FeatureHeaderTableViewCell.m
//  PRIME
//
//  Created by Sargis Terteryan on 5/29/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import "FeatureHeaderTableViewCell.h"

@interface FeatureHeaderTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel* headerTextLabel;

@end

static CGFloat const kHeaderTextLabelFontSize = 20.0f;

@implementation FeatureHeaderTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setFeatureInfoHeader:(NSString*)text withBoldText:(BOOL)isBold
{
    self.headerTextLabel.text = text;

    if (isBold) {
        [self.headerTextLabel setFont:[UIFont boldSystemFontOfSize:kHeaderTextLabelFontSize]];
    } else {
        [self.headerTextLabel setFont:[UIFont systemFontOfSize:kHeaderTextLabelFontSize]];
    }
}

@end
