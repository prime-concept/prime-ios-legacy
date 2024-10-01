//
//  FeatureImageTableViewCell.h
//  PRIME
//
//  Created by Sargis Terteryan on 5/29/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FeatureImageDelegate <NSObject>
- (void)imageHasBeenDownloaded;
@end

@interface FeatureImageTableViewCell : UITableViewCell

@property (weak, nonatomic) id<FeatureImageDelegate> delegate;
- (void)setFeatureImage:(NSString*)image;

@end
