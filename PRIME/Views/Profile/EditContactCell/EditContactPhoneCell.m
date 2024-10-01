//
//  EditContactPhoneCell.m
//  PRIME
//
//  Created by Artak Tsatinyan on 2/2/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "EditContactPhoneCell.h"
#import <DataSources/ProfileInfoDataSource.h>

@implementation EditContactPhoneCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[UITextField appearance] setFont:[UIFont systemFontOfSize:kTextFieldTextFontSize]];
    _textFieldInfoValue.clearButtonMode = UITextFieldViewModeWhileEditing;
    _textFieldInfoValue.textColor = kProfileInfoValueColor;
    _textFieldInfoValue.autocorrectionType = UITextAutocorrectionTypeNo;
    [_textFieldInfoValue.formatter setDefaultOutputPattern:@"###################" imagePath:nil];
    [_textFieldInfoValue.formatter addOutputPattern:@"+# (###) ###-##-##-##-##-##-##" forRegExp:@"^\\d\\d\\d\\d[0-9]\\d*$" imagePath:nil];
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
