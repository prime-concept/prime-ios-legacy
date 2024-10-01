//
//  DocumentDetailViewCell.m
//  PRIME
//
//  Created by Artak on 6/25/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "DocumentDetailViewCell.h"

@interface DocumentDetailViewCell ()
@property (weak, nonatomic) IBOutlet UILabel* labelName;
@property (weak, nonatomic) IBOutlet UIImageView* flagImageView;

@end

@implementation DocumentDetailViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    [_textFieldValue setFont:[UIFont systemFontOfSize:16]];
    [_labelName setFont:[UIFont systemFontOfSize:16]];

    _labelName.textColor = kDocumentDetailViewCellTextColor;
    self.accessoryType = UITableViewCellAccessoryNone;
}

- (void)configureCellByName:(NSString*)name text:(NSString*)text andPlaceholder:(NSString*)placeholder
{
    _labelName.text = name;
    _textFieldValue.text = text;
    _textFieldValue.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder ? placeholder : @""
                                                                            attributes:@{ NSForegroundColorAttributeName : kDocumentDetailViewCellPlaceholderColor }];
}

- (void)setFlag:(UIImage*)image
{
    _flagImageView.image = image;
}

@end
