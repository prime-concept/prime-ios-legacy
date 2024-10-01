//
//  FeatureImageTableViewCell.m
//  PRIME
//
//  Created by Sargis Terteryan on 5/29/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import "FeatureImageTableViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface FeatureImageTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView* featureImageView;

@end

@implementation FeatureImageTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setFeatureImage:(NSString*)image
{

    if (self.featureImageView.image != nil) {
        return;
    }

    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:image]];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];

    UIImageView* imgview = [UIImageView new];
    __weak FeatureImageTableViewCell* weakSelf = self;
    [imgview setImageWithURLRequest:request
                   placeholderImage:[UIImage new]
                            success:^(NSURLRequest* request, NSHTTPURLResponse* response, UIImage* image) {
                                FeatureImageTableViewCell* strongSelf = weakSelf;
                                if (!strongSelf) {
                                    return;
                                }

                                [strongSelf.featureImageView setImage:image];

                                if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(imageHasBeenDownloaded)]) {
                                    [strongSelf.delegate imageHasBeenDownloaded];
                                }

                            }
                            failure:^(NSURLRequest* request, NSHTTPURLResponse* response, NSError* error){
                            }];
}

@end
