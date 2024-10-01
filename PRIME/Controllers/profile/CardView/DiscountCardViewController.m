//
//  DiscountCardViewController.m
//  PRIME
//
//  Created by Artak Tsatinyan on 7/17/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "CustomActionSheetViewController+Picker.h"
#import "DiscountCardViewController.h"
#import "LoyalCardTableViewCell.h"
#import "PRLoyalCardModel.h"
#import "UIPickerTextField.h"

typedef NS_ENUM(NSInteger, ActionSheetSelectedType) {
    ActionSheetSelectedType_Type = 0,
    ActionSheetSelectedType_IssueDate,
    ActionSheetSelectedType_ExpDate,
    ActionSheetSelectedType_None
};

typedef NS_ENUM(NSInteger, CardInfo) {
    CardInfo_Type = 0,
    CardInfo_CardNumber,
    CardInfo_IssueDate,
    CardInfo_ExpirationDate,
    CardInfo_Note,
    CardInfo_Password
};

typedef NS_ENUM(NSInteger, TableViewSection) {
    TableViewSection_Info = 0,
    TableViewSection_Delete
};

const int kMaxCardNumberLength = 151;

@interface DiscountCardViewController () {
    ActionSheetSelectedType _actionSheetSelectedType;
}

@property (strong, nonatomic) PRLoyalCardModel* card;
@property (strong, nonatomic) NSString* cardNumberText;
@property (strong, nonatomic) NSString* cardIssueDate;
@property (strong, nonatomic) NSString* cardExpiryDate;
@property (strong, nonatomic) NSString* cardDescription;
@property (strong, nonatomic) NSString* cardPassword;
@property (strong, nonatomic) PRCardTypeModel* cardType;
@property (strong, nonatomic) NSArray<PRCardTypeModel*>* types;
@property (strong, nonatomic) NSArray<NSString*>* fieldsArray;
@property (strong, nonatomic) PRCardTypeModel* selectedType;
@property (strong, nonatomic) CustomActionSheetViewController* issueDateSelectionVC;
@property (strong, nonatomic) CustomActionSheetViewController* expDateSelectionVC;
@property (strong, nonatomic) CustomActionSheetViewController* typeSelectionVC;

@property (nonatomic) BOOL isSaved;

@property (strong, nonatomic) UIResponder* activeField;
@end

@implementation DiscountCardViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    _actionSheetSelectedType = ActionSheetSelectedType_None;

    _tableView.delegate = self;
    _tableView.dataSource = self;

    self.title = NSLocalizedString(@"Bonus card", nil);

    _isSaved = _cardId != nil;

    if (_cardId) {
        _card = [PRDatabase getDiscountForId:_cardId];
    } else {
        _card = [PRLoyalCardModel MR_createEntity];
        _card.type = _type;
    }
    _cardNumberText = _card.cardNumber;
    _cardIssueDate = _card.issueDate;
    _cardExpiryDate = _card.expiryDate;
    _cardType = _card.type;
    _cardPassword = _card.password;

    _fieldsArray = @[ @"Type", @"Card number", @"Issue date", @"Expiration date", @"Note", @"Password" ];
    _types = [PRDatabase getDiscountTypes];

    _tableView.estimatedRowHeight = 40.0;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.backgroundColor = kTableViewBackgroundColor;
    [_tableView reloadData];
}

- (void)viewWillLayoutSubviews
{
    [_tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self dismissCustomActionSheetIfOpen];
    [super viewDidDisappear:animated];
}

- (void)dismissCustomActionSheetIfOpen
{
    switch (_actionSheetSelectedType) {
    case ActionSheetSelectedType_Type: {
        if (_typeSelectionVC) {
            [_typeSelectionVC dismiss];
            _actionSheetSelectedType = ActionSheetSelectedType_None;
        }
    } break;
    case ActionSheetSelectedType_IssueDate: {
        if (_issueDateSelectionVC) {
            [_issueDateSelectionVC dismiss];
            _actionSheetSelectedType = ActionSheetSelectedType_None;
        }
    } break;
    case ActionSheetSelectedType_ExpDate: {
        if (_expDateSelectionVC) {
            [_expDateSelectionVC dismiss];
            _actionSheetSelectedType = ActionSheetSelectedType_None;
        }
    } break;
    default:
        break;
    }
}

#pragma mark - Navigation Bar

- (void)prepareNavigationBar
{
    if (_cardNumberText && ![_cardNumberText isEqualToString:@""]) {
        UIBarButtonItem* doneButton =
            [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", )
                                             style:UIBarButtonItemStylePlain
                                            target:self
                                            action:@selector(done)];

        self.navigationItem.rightBarButtonItem = doneButton;

        UIBarButtonItem* cancelButton =
            [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", )
                                             style:UIBarButtonItemStylePlain
                                            target:self
                                            action:@selector(cancel)];

        self.navigationItem.leftBarButtonItem = cancelButton;

        return;
    }

    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)didMoveToParentViewController:(UIViewController*)parent
{
    if (![parent isEqual:self.parentViewController] && !_isSaved) {
        [_card MR_deleteEntity];
        [_dataSource reload];
    }
}

#pragma mark - Loyal Card Model

- (void)saveLoyalCardModelNewValues
{
    _card.cardNumber = _cardNumberText;
    _card.issueDate = _cardIssueDate;
    _card.expiryDate = _cardExpiryDate;
    _card.type = _cardType;
    _card.cardDescription = _cardDescription;
    _card.password = _cardPassword;
}

#pragma mark - Actions

- (void)done
{
    [self saveLoyalCardModelNewValues];
    void (^goBack)() = ^void() {

        _isSaved = YES;

        [self.navigationController popViewControllerAnimated:YES];

        if (_cardId == nil) {
            [self.navigationController popViewControllerAnimated:YES];
        }

    };

     [PRGoogleAnalyticsManager sendEventWithName:kMyCardsSaveLoyaltyCard parameters:nil];
    if (_cardId == nil) {
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext* localContext) {
            PRLoyalCardModel* card = [_card MR_inContext:localContext];
            card.syncStatus = @(1);
        }];

        if (![PRRequestManager connectionRequired]) {
            [PRRequestManager createDiscount:_card
                view:self.view
                mode:PRRequestMode_ShowErrorMessagesAndProgress
                success:^(PRLoyalCardModel* model) {

                    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext* localContext) {
                        PRLoyalCardModel* card = [_card MR_inContext:localContext];
                        card.syncStatus = @(0);
                    }];

                    [_dataSource reload];

                    goBack();

                }
                failure:^{
                    _isSaved = NO;
                }];
        }
    } else {
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext* localContext) {
            PRLoyalCardModel* card = [_card MR_inContext:localContext];
            card.syncStatus = @(2);
        }];

        if (![PRRequestManager connectionRequired]) {
            [PRRequestManager updateDiscount:_card
                view:self.view
                mode:PRRequestMode_ShowErrorMessagesAndProgress
                success:^(PRLoyalCardModel* model) {

                    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext* localContext) {
                        PRLoyalCardModel* card = [_card MR_inContext:localContext];
                        card.syncStatus = @(0);
                    }];

                    [_dataSource reload];

                    goBack();
                }
                failure:^{
                    _isSaved = NO;
                }];
        }
    }

    if ([PRRequestManager connectionRequired]) {
        goBack();
    }

    [_dataSource reload];
}

- (void)cancel
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)reload
{

    if (_cardId) {
        _card = [PRDatabase getDiscountForId:_cardId];
        [_tableView reloadData];

        return;
    }

    _card = [PRLoyalCardModel MR_createEntity];
}

#pragma mark Table View DataSource

- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    return YES;
}

- (CGFloat)tableView:(UITableView*)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.row == CardInfo_Note) {
        return 100;
    }

    return 44;
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return UITableViewAutomaticDimension;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return _cardId ? 2 : 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == TableViewSection_Delete) {
        return 1;
    }

    return _fieldsArray.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == TableViewSection_Delete) {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Delete"];
        cell.textLabel.text = NSLocalizedString(@"Delete", nil);
        cell.textLabel.textColor = kDeleteButtonColor;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;

        return cell;
    }

    BOOL isPickerTableViewCell = (indexPath.row == CardInfo_Type) || (indexPath.row == CardInfo_IssueDate) || (indexPath.row == CardInfo_ExpirationDate);
    NSString* cellIdentifier = isPickerTableViewCell ? @"LoyalCardPickerTableViewCell" : @"LoyalCardTableViewCell";

    LoyalCardTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.textFieldValue.keyboardType = UIKeyboardTypeDefault;

    NSString* fieldValue;
    switch (indexPath.row) {
    case CardInfo_Type:
        fieldValue = _cardType.name;
        break;
    case CardInfo_CardNumber:
        fieldValue = _cardNumberText;
        cell.textFieldValue.keyboardType = UIKeyboardTypeDecimalPad;
        break;
    case CardInfo_IssueDate:
        if (_cardIssueDate) {
            _cardIssueDate = [Utils fromMillisecondsToFormattedDate:_cardIssueDate];
        }
        fieldValue = _cardIssueDate;
        break;
    case CardInfo_ExpirationDate:
        if (_cardExpiryDate) {
            _cardExpiryDate = [Utils fromMillisecondsToFormattedDate:_cardExpiryDate];
        }
        fieldValue = _cardExpiryDate;
        break;
    case CardInfo_Note:
        fieldValue = _card.cardDescription;
        break;
    case CardInfo_Password:
        fieldValue = _card.password;
        break;

    default:
        break;
    }

    [cell configureCellWithFieldName:[_fieldsArray objectAtIndex:indexPath.row]
                          fieldValue:fieldValue
                              parent:self
                     isTextViewShown:indexPath.row == CardInfo_Note || indexPath.row == CardInfo_Password
                                 tag:indexPath.row];

    return cell;
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == TableViewSection_Info) {
        return;
    }

    [PRGoogleAnalyticsManager sendEventWithName:kMyCardsDeleteLoyaltyCardButtonClicked parameters:nil];
    [PRRequestManager deleteDiscount:_card
                                view:self.view
                                mode:PRRequestMode_ShowErrorMessagesAndProgress
                             success:^{

                                 [_dataSource reload];
                                 [self.navigationController popViewControllerAnimated:YES];

                             }
                             failure:^{

                             }];
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{

    return UITableViewAutomaticDimension;
}

- (CGSize)sizeOfText:(NSString*)textToMesure widthOfTextView:(CGFloat)width withFont:(UIFont*)font
{
    CGRect textSize = [textToMesure boundingRectWithSize:CGSizeMake(width - 12, FLT_MAX)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{ NSFontAttributeName : font }
                                                 context:nil];

    return textSize.size;
}

#pragma mark - Text View Delegate

- (BOOL)textView:(UITextView*)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text
{
    NSString* finalString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if (finalString.length > 60 && finalString.length > textView.text.length) {
        return NO;
    }

    [self prepareNavigationBar];

    if (textView.tag == CardInfo_Note) {
        _cardDescription = finalString;
    } else if (textView.tag == CardInfo_Password) {
        _cardPassword = finalString;
    }

    NSInteger index = textView.tag;

    LoyalCardTableViewCell* cell = (LoyalCardTableViewCell*)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:TableViewSection_Info]];

    CGFloat cellTextHeigth = cell.textViewConstraintHeigth.constant;
    cell.textViewConstraintHeigth.constant = [self sizeOfText:finalString
                                                 widthOfTextView:cell.textViewValue.frame.size.width
                                                        withFont:cell.textViewValue.font]
                                                 .height
        + 17;

    [cell.contentView setNeedsLayout];
    [cell.contentView layoutIfNeeded];

    BOOL needToScroll = cellTextHeigth != cell.textViewConstraintHeigth.constant;
    cellTextHeigth = cell.textViewConstraintHeigth.constant;

    if (needToScroll) {
        [_tableView beginUpdates];
        [_tableView endUpdates];

        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:TableViewSection_Info] atScrollPosition:UITableViewScrollPositionNone animated:NO];
    }

    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
    }

    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView*)textView
{
    _activeField = textView;

    return YES;
}

#pragma mark - Text Field Delegate

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
    NSString* finalString = [textField.text stringByReplacingCharactersInRange:range withString:string];

    if (textField.tag == CardInfo_CardNumber) {
        if (finalString.length > kMaxCardNumberLength || ![self isTextNumeric:finalString]) {
            return NO;
        }
        _cardNumberText = finalString;
    } else if (textField.tag == CardInfo_Note) {
        _cardDescription = finalString;
    } else if (textField.tag == CardInfo_Password) {
        _cardPassword = finalString;
    }

    [self prepareNavigationBar];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField*)textField
{
    NSString* dateFormat = DATE_DAY_FORMAT;

#if defined(Otkritie)
    dateFormat = DATE_FORMAT_ddMMyyyy;
#endif

    if (textField.tag == CardInfo_IssueDate) {

        [PRGoogleAnalyticsManager sendEventWithName:kMyCardsLoyaltyCardIssueDateClicked parameters:nil];
        if (!_issueDateSelectionVC) {
            _issueDateSelectionVC = [[CustomActionSheetViewController alloc] init];
            _issueDateSelectionVC.delegate = self;
            _issueDateSelectionVC.picker = [UIDatePicker new];
            ((UIDatePicker*)_issueDateSelectionVC.picker).datePickerMode = UIDatePickerModeDate;
            if (@available(iOS 13.4, *)) {
                ((UIDatePicker*)_issueDateSelectionVC.picker).preferredDatePickerStyle = UIDatePickerStyleWheels;
            }
        }

        [_activeField resignFirstResponder];

        [_issueDateSelectionVC showForField:(UIPickerTextField*)textField];

        if (!textField.text || [textField.text isEqualToString:@""]) {
            ((UIDatePicker*)_issueDateSelectionVC.picker).date = [NSDate new];
        } else {
            ((UIDatePicker*)_issueDateSelectionVC.picker).date = [NSDate mt_dateFromString:textField.text usingFormat:dateFormat];
        }

        [_issueDateSelectionVC showForField:(UIPickerTextField*)textField];
        _actionSheetSelectedType = ActionSheetSelectedType_IssueDate;

        return NO;
    } else if (textField.tag == CardInfo_ExpirationDate) {
        [PRGoogleAnalyticsManager sendEventWithName:kMyCardsLoyaltyCardExpirationDateClicked parameters:nil];
        if (!_expDateSelectionVC) {
            _expDateSelectionVC = [[CustomActionSheetViewController alloc] init];
            _expDateSelectionVC.delegate = self;
            _expDateSelectionVC.picker = [UIDatePicker new];
            ((UIDatePicker*)_expDateSelectionVC.picker).datePickerMode = UIDatePickerModeDate;
            if (@available(iOS 13.4, *)) {
                ((UIDatePicker*)_expDateSelectionVC.picker).preferredDatePickerStyle = UIDatePickerStyleWheels;
            }
        }

        [_activeField resignFirstResponder];

        ((UIDatePicker*)_expDateSelectionVC.picker).datePickerMode = UIDatePickerModeDate;
        if (@available(iOS 13.4, *)) {
            ((UIDatePicker*)_expDateSelectionVC.picker).preferredDatePickerStyle = UIDatePickerStyleWheels;
        }

        if (!textField.text || [textField.text isEqualToString:@""]) {
            ((UIDatePicker*)_expDateSelectionVC.picker).date = [NSDate new];
        } else {
            ((UIDatePicker*)_expDateSelectionVC.picker).date = [NSDate mt_dateFromString:textField.text usingFormat:dateFormat];
        }

        [_expDateSelectionVC showForField:(UIPickerTextField*)textField];
        _actionSheetSelectedType = ActionSheetSelectedType_ExpDate;

        return NO;
    } else if (textField.tag == CardInfo_Type) {
        _typeSelectionVC = [[CustomActionSheetViewController alloc] init];
        _typeSelectionVC.delegate = self;
        _typeSelectionVC.picker = [self getTypePicker];

        [_activeField resignFirstResponder];
        [_typeSelectionVC showForField:(UIPickerTextField*)textField];
        _actionSheetSelectedType = ActionSheetSelectedType_Type;

        return NO;
    }

    _activeField = textField;
    return YES;
}

- (UIPickerView*)getTypePicker
{
    UIPickerView* typePicker = [[UIPickerView alloc] init];
    typePicker.delegate = self;
    typePicker.dataSource = self;
    int index = 0;

    if (_cardType.typeId) {
        for (PRCardTypeModel* type in _types) {
            if ([type.typeId isEqualToNumber:_cardType.typeId]) {

                [typePicker selectRow:index inComponent:0 animated:NO];
                _type = type;
            }

            index++;
        }
    }

    if ([_types count] && (!_type || [_type.name isEqualToString:@""])) {
        _type = _types[0];
    }

    _selectedType = _type;

    return typePicker;
}

#pragma mark - Picker View Delegate

- (void)pickerView:(UIPickerView*)pV didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ([_types count] > row && ![_selectedType isEqual:_types]) {
        _selectedType = _types[row];
        [self prepareNavigationBar];
    }
}

- (NSString*)pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _types[row].name;
}

#pragma mark - Picker View DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_types count];
}

#pragma mark - CountryPicker selection Delegates

- (void)selectionViewControllerDidDoneFor:(CustomActionSheetViewController*)sheet
{
    _actionSheetSelectedType = ActionSheetSelectedType_None;
    NSString* dateString = nil;
    NSString* dateFormat = DATE_DAY_FORMAT;

#if defined(Otkritie)
    dateFormat = DATE_FORMAT_ddMMyyyy;
#endif

    if ([sheet isEqual:_issueDateSelectionVC]) {
        [PRGoogleAnalyticsManager sendEventWithName:kDatePickerSelectButtonClicked parameters:nil];
        if (!((UIDatePicker*)sheet.picker).date) {
            dateString = [[NSDate new] mt_stringFromDateWithFormat:dateFormat localized:NO];
        } else {
            dateString = [((UIDatePicker*)sheet.picker).date mt_stringFromDateWithFormat:dateFormat localized:NO];
        }
        if (![_cardIssueDate isEqualToString:dateString]) {
            _cardIssueDate = dateString;
            [self prepareNavigationBar];
        }
        [_tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:CardInfo_IssueDate inSection:TableViewSection_Info] ] withRowAnimation:UITableViewRowAnimationNone];
    } else if ([sheet isEqual:_expDateSelectionVC]) {
        [PRGoogleAnalyticsManager sendEventWithName:kDatePickerSelectButtonClicked parameters:nil];
        if (!((UIDatePicker*)sheet.picker).date) {
            dateString = [[NSDate new] mt_stringFromDateWithFormat:dateFormat localized:NO];
        } else {
            dateString = [((UIDatePicker*)sheet.picker).date mt_stringFromDateWithFormat:dateFormat localized:NO];
        }
        if (![_cardExpiryDate isEqualToString:dateString]) {
            _cardExpiryDate = dateString;
            [self prepareNavigationBar];
        }
        [_tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:CardInfo_ExpirationDate inSection:TableViewSection_Info] ] withRowAnimation:UITableViewRowAnimationNone];
    } else if (_typeSelectionVC) {
        [PRGoogleAnalyticsManager sendEventWithName:kLoyaltyCardTypePickerSelectButtonClicked parameters:nil];
        _cardType = _selectedType;
        [_tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:CardInfo_Type inSection:TableViewSection_Info] ] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)selectionViewControllerDidCancelFor:(CustomActionSheetViewController*)sheet
{
    if ([sheet isEqual:_typeSelectionVC]) {
        [PRGoogleAnalyticsManager sendEventWithName:kLoyaltyCardTypePickerCancelButtonClicked parameters:nil];
    }
    [PRGoogleAnalyticsManager sendEventWithName:kDatePickerCancelButtonClicked parameters:nil];
    _actionSheetSelectedType = ActionSheetSelectedType_None;
    _selectedType = _type;
}

#pragma mark - Checkings

- (BOOL)isTextNumeric:(NSString*)text
{
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

    NSNumber* candidateNumber = nil;
    NSRange range = NSMakeRange(0, [text length]);

    [numberFormatter getObjectValue:&candidateNumber forString:text range:&range error:nil];

    if (([text length] > 0) && (candidateNumber == nil || range.length < [text length])) {
        return NO;
    }

    return YES;
}

@end
