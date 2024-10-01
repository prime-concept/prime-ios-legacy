//
//  PRWGServicesCell.m
//  PRIME
//
//  Created by Armen on 5/3/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import "PRWGServicesCell.h"
#import "Constants.h"

@interface PRWGServicesCell()

@property (weak, nonatomic) IBOutlet UIImageView *serviceIcon;
@property (weak, nonatomic) IBOutlet UILabel *serviceName;

@end

@implementation PRWGServicesCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)updateCellWithData:(NSDictionary*)data
{
    NSData *image = [data valueForKey:kWidgetServiceIconName];
    if (image) {
        [_serviceIcon setImage:[[UIImage alloc] initWithData:image]];
    }
    [_serviceName setText:[data valueForKey:kWidgetServiceName]];
    _serviceName.textColor = kChatTaskIconTextColor;
}

- (void)addMoreButton:(NSString*)imageName
{
    [_serviceIcon setImage:[UIImage imageNamed:imageName]];
    [_serviceName setText:@""];
}

@end
