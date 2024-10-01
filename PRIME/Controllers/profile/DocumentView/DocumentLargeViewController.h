//
//  DocumentLargeViewController.h
//  PRIME
//
//  Created by Artak on 6/5/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "BaseViewController.h"
#import <UIKit/UIKit.h>

@interface DocumentLargeViewController : BaseViewController<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView* imageView;
@property (strong, nonatomic) UIImage* image;
@property (strong, nonatomic)PRMessageModel* model;

@end
