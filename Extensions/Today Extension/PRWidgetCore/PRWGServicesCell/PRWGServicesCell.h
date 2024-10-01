//
//  PRWGServicesCell.h
//  PRIME
//
//  Created by Armen on 5/3/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PRWGServicesCell : UICollectionViewCell

- (void)updateCellWithData:(NSDictionary*)data;
- (void)addMoreButton:(NSString*)imageName;

@end
