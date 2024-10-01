//
//  EditContactEmailCell.m
//  PRIME
//
//  Created by Taron on 3/23/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "EditContactEmailCell.h"
#import <DataSources/ProfileInfoDataSource.h>

@implementation EditContactEmailCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[UITextField appearance] setFont:[UIFont systemFontOfSize:kTextFieldTextFontSize]];
    _textFieldInfoValue.clearButtonMode = UITextFieldViewModeWhileEditing;
    _textFieldInfoValue.textColor = kProfileInfoValueColor;
    _textFieldInfoValue.autocorrectionType = UITextAutocorrectionTypeNo;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state.
}

- (void)willAppearForTableView:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath
{
    ProfileInfoDataSource* datasource = (ProfileInfoDataSource*)tableView.dataSource;
    if ([datasource.indexPathForKeyboard isEqual:indexPath]) {
        [_textFieldInfoValue becomeFirstResponder];
    }
}

- (UITextField*)getTextField
{
    return _textFieldInfoValue;
}

@end
