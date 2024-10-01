//
//  PRAddNewDataTableViewCell.m
//  PRIME
//
//  Created by Mariam on 1/19/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRAddNewDataTableViewCell.h"

@interface PRAddNewDataTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel* labelAddInfo;
@property (weak, nonatomic) IBOutlet UIImageView* imageviewAddIcon;

@end

@implementation PRAddNewDataTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)configureCellWithText:(NSString*)text
{
    _labelAddInfo.text = text;

    UIImage* image = [UIImage imageNamed:@"add_data"];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _imageviewAddIcon.image = image;
#if defined(PrimeClubConcierge)
    _imageviewAddIcon.tintColor = KAClubRed;
    _labelAddInfo.textColor = KAClubRed;
#else
    _imageviewAddIcon.tintColor = kIconsColor;
    _labelAddInfo.textColor = kIconsColor;
#endif
}

@end
