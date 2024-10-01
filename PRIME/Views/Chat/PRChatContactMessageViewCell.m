//
//  PRChatContactMessageViewCell.m
//  PRIME
//
//  Created by Armen on 5/16/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import "PRChatContactMessageViewCell.h"
#import "InformationAlertController.h"
#import "Constants.h"
@import ContactsUI;

@interface PRChatContactMessageViewCell()<CNContactViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *contactImageView;
@property (weak, nonatomic) IBOutlet UITextView *contactNameTextView;
@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIView *horizontalSeparatorView;
@property (weak, nonatomic) IBOutlet UIView *verticalSeparatorView;
@property (strong, nonatomic) CNContact *contact;

@end

static NSString* const kReceivedContactMessageCellIdentifier = @"PRChatReceiveContactMessageViewCell";

@implementation PRChatContactMessageViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setUpBalloonImageView];
}

- (void)setUpBalloonImageView
{
    NSString* balloonImageName = @"ModernBubbleOutgoingFull";
    UIColor* balloonImageTintColor = kChatBalloonImageViewColor;
    UIColor* timeLabelTextColor = kChatRightTimeLabelTextColor;

    [_contactNameTextView.textContainer setMaximumNumberOfLines:2];
    [_callButton setTitle:NSLocalizedString(@"Call", nil) forState:UIControlStateNormal];
    [_saveButton setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];

    _horizontalSeparatorView.backgroundColor = kRightContactMessageSeperatorColor;
    _verticalSeparatorView.backgroundColor = kRightContactMessageSeperatorColor;
    [_contactNameTextView setTextColor:kRightContactMessageButtonColor];
    [_callButton setTitleColor:kRightContactMessageButtonColor forState:UIControlStateNormal];
    [_saveButton setTitleColor:kRightContactMessageButtonColor forState:UIControlStateNormal];

    if ([self.reuseIdentifier isEqualToString:kReceivedContactMessageCellIdentifier]) {
        balloonImageName = @"ModernBubbleIncomingFull";
        balloonImageTintColor = kChatLeftBalloonImageViewColor;
        _horizontalSeparatorView.backgroundColor = kLeftContactMessageSeperatorColor;
        _verticalSeparatorView.backgroundColor = kLeftContactMessageSeperatorColor;
        [_contactNameTextView setTextColor:kLeftContactMessageButtonColor];
        [_callButton setTitleColor:kLeftContactMessageButtonColor forState:UIControlStateNormal];
        [_saveButton setTitleColor:kLeftContactMessageButtonColor forState:UIControlStateNormal];
        timeLabelTextColor = kChatLeftTimeLabelTextColor;
    }

    [self.balloonImageView setImage:[UIImage imageNamed:balloonImageName]];
    [self.balloonImageView setTintColor:balloonImageTintColor];

    NSURL *phoneURL = [NSURL URLWithString:@"tel:"];
    if ([[UIApplication sharedApplication] canOpenURL:phoneURL])
    {
        [_callButton setEnabled:YES];
        [_callButton setAlpha:1.0f];
    }
    else
    {
        [_callButton setEnabled:NO];
        [_callButton setAlpha:0.4f];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)callAction:(id)sender
{
    UIAlertController* alert = [UIAlertController
                                alertControllerWithTitle:nil
                                message:nil
                                preferredStyle:UIAlertControllerStyleActionSheet];

    for(CNLabeledValue<CNPhoneNumber*>* contactNumber in [_contact phoneNumbers])
    {
        UIAlertAction *phoneNumberButton = [UIAlertAction actionWithTitle:contactNumber.value.stringValue
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action){
                                                                      NSString *filteredPhoneNumber = [[[action title] componentsSeparatedByCharactersInSet:
                                                                                              [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                                                                                             componentsJoinedByString:@""];
                                                                      NSString *phoneStr = [NSString stringWithFormat:@"tel:%@", filteredPhoneNumber];
                                                                      NSURL *phoneURL = [NSURL URLWithString:phoneStr];
                                                                      [[UIApplication sharedApplication] openURL:phoneURL];
                                                                  }];
        [phoneNumberButton setValue:kAttachMainColor forKey:@"titleTextColor"];
        [alert addAction:phoneNumberButton];
    }
    UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [cancelButton setValue:kAttachCancelColor forKey:@"titleTextColor"];
    [alert addAction:cancelButton];
    [_presenter presentViewController:alert
                             animated:YES
                           completion:nil];
}

- (IBAction)saveAction:(id)sender
{
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (status == CNAuthorizationStatusDenied || status == CNAuthorizationStatusRestricted)
    {
        [InformationAlertController presentAlertDoesNotHaveAccessTo:AccessTo_Contacts
                                                        onPresenter:_presenter];
    }
    else
    {
        CNContactViewController *contactViewController = [CNContactViewController viewControllerForNewContact:[self.class newContactFromContact:_contact]];
        [contactViewController setDelegate:self];
        UILabel *titleLabel = [UILabel new];
        [contactViewController.navigationItem setTitleView:titleLabel];
        [_presenter.navigationController pushViewController:contactViewController animated:YES];
    }
}

- (void)setContactWithPath:(NSString*)path
{
    NSURL* directory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                               inDomains:NSUserDomainMask] lastObject];
    NSString* docDirPath = [directory path];
    NSString* filePath = [NSString stringWithFormat:@"%@/%@", docDirPath, path];
    NSData* contactData = [NSData dataWithContentsOfFile:filePath];
    _contact = [NSKeyedUnarchiver unarchiveObjectWithData:contactData];

    NSMutableString *contactFullName = [NSMutableString new];
    [contactFullName appendString:@""];
    if([[_contact givenName] length] > 0)
    {
        [contactFullName appendFormat:@"%@\n", [_contact givenName]];
    }
    if([_contact familyName])
    {
        [contactFullName appendString:[_contact familyName]];
    }
    [_contactNameTextView setText:contactFullName];

    UIImage *avatarImage = ([UIImage imageWithData:[_contact thumbnailImageData]]) ?[UIImage imageWithData:[_contact thumbnailImageData]] :[UIImage imageWithData:[_contact imageData]];
    if(avatarImage)
    {
        [_contactImageView setImage:avatarImage];
    }
    else
    {
        avatarImage = [UIImage imageNamed:@"avatar"];
        avatarImage = [avatarImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_contactImageView setImage:avatarImage];
        [self.reuseIdentifier isEqualToString:kReceivedContactMessageCellIdentifier] ? [_contactImageView setTintColor:kLeftContactMessageSeperatorColor] : [_contactImageView setTintColor:kRightContactMessageButtonColor];
    }
    [[_contactImageView layer] setCornerRadius:[_contactImageView bounds].size.width/2];

    NSURL *phoneURL = [NSURL URLWithString:@"tel:"];

    if([[_contact phoneNumbers] count] == 0)
    {
        [_callButton setEnabled:NO];
        [_callButton setAlpha:0.4f];
    }
    else if ([[UIApplication sharedApplication] canOpenURL:phoneURL])
    {
        [_callButton setEnabled:YES];
        [_callButton setAlpha:1.0f];
    }
}

- (CNContact*)getContact
{
    return _contact;
}

+ (CNMutableContact*)newContactFromContact:(CNContact*)contact
{
    CNMutableContact* saveContact = [CNMutableContact new];
    [saveContact setNamePrefix:[contact namePrefix]];
    [saveContact setGivenName:[contact givenName]];
    [saveContact setMiddleName:[contact middleName]];
    [saveContact setFamilyName:[contact familyName]];
    [saveContact setPreviousFamilyName:[contact previousFamilyName]];
    [saveContact setNameSuffix:[contact nameSuffix]];
    [saveContact setNickname:[contact nickname]];
    [saveContact setPhoneticGivenName:[contact phoneticGivenName]];
    [saveContact setPhoneticMiddleName:[contact phoneticMiddleName]];
    [saveContact setPhoneticFamilyName:[contact phoneticFamilyName]];
    [saveContact setFamilyName:[contact familyName]];

    [saveContact setJobTitle:[contact jobTitle]];
    [saveContact setDepartmentName:[contact departmentName]];
    [saveContact setOrganizationName:[contact organizationName]];
    [saveContact setPhoneticOrganizationName:[contact phoneticOrganizationName]];

    NSMutableArray<CNLabeledValue *> *postalAddresses= [NSMutableArray new];
    for(CNLabeledValue* labeledValue in [contact postalAddresses])
    {
        CNLabeledValue * labelValue = [[CNLabeledValue alloc]initWithLabel:labeledValue.label value:labeledValue.value];
        [postalAddresses addObject:labelValue];
    }
    [saveContact setPostalAddresses:postalAddresses];

    NSMutableArray<CNLabeledValue *> *emailAddresses= [NSMutableArray new];
    for(CNLabeledValue* labeledValue in [contact emailAddresses])
    {
        CNLabeledValue * labelValue = [[CNLabeledValue alloc]initWithLabel:labeledValue.label value:labeledValue.value];
        [emailAddresses addObject:labelValue];
    }
    [saveContact setEmailAddresses:emailAddresses];

    NSMutableArray<CNLabeledValue *> *urlAddresses= [NSMutableArray new];
    for(CNLabeledValue* labeledValue in [contact emailAddresses])
    {
        CNLabeledValue * labelValue = [[CNLabeledValue alloc]initWithLabel:labeledValue.label value:labeledValue.value];
        [urlAddresses addObject:labelValue];
    }
    [saveContact setUrlAddresses:urlAddresses];

    NSMutableArray<CNLabeledValue *> *phoneNumbers = [NSMutableArray new];
    for(CNLabeledValue* labeledValue in [contact phoneNumbers])
    {
        CNLabeledValue * labelValue = [[CNLabeledValue alloc]initWithLabel:labeledValue.label value:labeledValue.value];
        [phoneNumbers addObject:labelValue];
    }
    [saveContact setPhoneNumbers:phoneNumbers];

    NSMutableArray<CNLabeledValue *> *dates = [NSMutableArray new];
    for(CNLabeledValue* labeledValue in [contact dates])
    {
        CNLabeledValue * labelValue = [[CNLabeledValue alloc]initWithLabel:labeledValue.label value:labeledValue.value];
        [phoneNumbers addObject:labelValue];
    }
    [saveContact setDates:dates];

    [saveContact setNonGregorianBirthday:[contact nonGregorianBirthday]];
    [saveContact setBirthday:[contact birthday]];

    [saveContact setNote:[contact note]];

    [saveContact setImageData:[contact imageData]];

    return saveContact;
}

- (void)contactViewController:(CNContactViewController *)viewController didCompleteWithContact:(CNContact *)contact
{
    if(!contact)
    {
        [_presenter.navigationController popViewControllerAnimated:YES];
    }
}

@end
