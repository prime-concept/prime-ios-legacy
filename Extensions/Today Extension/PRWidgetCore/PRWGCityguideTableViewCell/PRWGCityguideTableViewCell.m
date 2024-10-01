//
//  PRWGCityguideTableViewCell.m
//  PRIME
//
//  Created by Armen on 5/8/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import "PRWGCityguideTableViewCell.h"
#import "Constants.h"

@interface PRWGCityguideTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation PRWGCityguideTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _contentImageView.layer.masksToBounds = YES;
    _contentImageView.layer.cornerRadius = 6;
}
- (void)updateCellWithData:(NSDictionary*)data {

    UIImage *image = [[UIImage alloc] initWithData:[data valueForKey:kWidgetCityguideImage]];
    [_contentImageView setImage:image];
    _nameLabel.text = [data valueForKey:kWidgetCityguideName];
    _descriptionLabel.text = [data valueForKey:kWidgetCityguideDescription];
}

@end
