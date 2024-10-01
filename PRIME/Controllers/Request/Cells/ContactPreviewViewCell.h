//
//  ContactPreviewViewCell.h
//  PRIME
//
//  Created by Armen on 5/17/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContactPreviewViewCell : UITableViewCell

@property (assign, nonatomic, getter = isChecked) BOOL checked;

- (void)setCategoryLabelText:(NSString*)text;
- (void)setMainContentText:(NSString*)text;
- (void)setContactName:(NSString*)text;
- (void)changeCheckedStatus;
- (void)setSeparator;

@end

NS_ASSUME_NONNULL_END
