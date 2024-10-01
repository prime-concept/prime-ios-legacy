//
//  FeatureHelpScreenItemsTableViewCell.m
//  PRIME
//
//  Created by Sargis Terteryan on 6/21/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import "PRInformationDetailsTableViewCell.h"

@interface PRInformationDetailsTableViewCell ()

@property (strong, nonatomic) NSArray* helpScreenItems;
@property (weak, nonatomic) IBOutlet UIImageView* itemImage;
@property (weak, nonatomic) IBOutlet UILabel* itemTitle;
@property (weak, nonatomic) IBOutlet UILabel* itemSubtitle;

@end

static CGFloat const kItemTitleTextLabelFontSize = 17.0f;
static CGFloat const kItemSubtitleTextLabelFontSize = 12.0f;

@implementation PRInformationDetailsTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setInformationDetails:(NSDictionary*)infoDetailsDictionary
{
    self.itemTitle.text = [infoDetailsDictionary valueForKey:kInformationItemName];
    self.itemSubtitle.text = [infoDetailsDictionary valueForKey:kInformationValue];
    [self.itemTitle setFont:[UIFont boldSystemFontOfSize:kItemTitleTextLabelFontSize]];
    [self.itemSubtitle setFont:[UIFont systemFontOfSize:kItemSubtitleTextLabelFontSize]];

    if (self.itemImage.image != nil) {
        return;
    }

    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[infoDetailsDictionary valueForKey:kInformationIcon]]];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];

    UIImageView* imgview = [UIImageView new];
    __weak PRInformationDetailsTableViewCell* weakSelf = self;
    [imgview setImageWithURLRequest:request
                   placeholderImage:[UIImage new]
                            success:^(NSURLRequest* request, NSHTTPURLResponse* response, UIImage* image) {
                                PRInformationDetailsTableViewCell* strongSelf = weakSelf;
                                if (!strongSelf) {
                                    return;
                                }

                                [strongSelf.itemImage setImage:image];
                                [strongSelf.itemImage setTintColor:[UIColor whiteColor]];

                            }
                            failure:^(NSURLRequest* request, NSHTTPURLResponse* response, NSError* error){
                            }];
}

@end
