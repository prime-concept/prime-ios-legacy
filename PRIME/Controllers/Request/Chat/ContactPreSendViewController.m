//
//  ContactPreSendViewController.m
//  PRIME
//
//  Created by Armen on 5/16/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import "ContactPreSendViewController.h"
#import "ContactPreviewViewCell.h"
#import "PRMessageProcessingManager.h"

enum ContactInfoSections
{
    ContactInfoSection_Name = 0,
    ContactInfoSection_Company,
    ContactInfoSection_PhoneNumbers,
    ContactInfoSection_Emails
};

@interface ContactPreSendViewController () <UITableViewDelegate, UITableViewDataSource>

@property (assign, nonatomic) BOOL sendCompanyInfo;
@property (strong, nonatomic) NSMutableArray *finalContactPhoneNumbers;
@property (strong, nonatomic) NSMutableArray *finalContactEmailAddresses;
@property (strong, nonatomic)CNContact *contact;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;
@property (weak, nonatomic) IBOutlet UINavigationItem *barTitle;
@property (weak, nonatomic) IBOutlet UITableView *contactInfoTableView;

@end

@implementation ContactPreSendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_cancelButton setTitle:NSLocalizedString(@"Cancel", nil)];
    [_sendButton setTitle:NSLocalizedString(@"Send", nil)];
    [_barTitle setTitle:NSLocalizedString(@"Information", nil)];
    [_contactInfoTableView setDataSource:self];
    [_contactInfoTableView setDelegate:self];
    [_contactInfoTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_contactInfoTableView reloadData];
    _sendCompanyInfo = YES;
}

#pragma mark - Action Handling

- (IBAction)cancelButton:(UIBarButtonItem *)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)sendAction:(UIBarButtonItem *)sender
{
    CNMutableContact* finalContact = [_contact mutableCopy];
    if(!_sendCompanyInfo)
    {
        [finalContact setOrganizationName:@""];
    }

    NSMutableArray<CNLabeledValue *> *phoneNumbers = [NSMutableArray new];
    for(NSInteger i = 0; i<[_contact.phoneNumbers count]; ++i)
    {
        if([_finalContactPhoneNumbers[i] boolValue])
        {
            CNLabeledValue * labelValue = [[CNLabeledValue alloc]initWithLabel:_contact.phoneNumbers[i].label value:_contact.phoneNumbers[i].value];
            [phoneNumbers addObject:labelValue];
        }
    }
    [finalContact setPhoneNumbers:phoneNumbers];

    NSMutableArray<CNLabeledValue *> *emailAddresses = [NSMutableArray new];
    for(NSInteger i = 0; i<[_contact.emailAddresses count]; ++i)
    {
        if([_finalContactEmailAddresses[i] boolValue])
        {
            CNLabeledValue * labelValue = [[CNLabeledValue alloc]initWithLabel:_contact.emailAddresses[i].label value:_contact.emailAddresses[i].value];
            [emailAddresses addObject:labelValue];
        }
    }
    [finalContact setEmailAddresses:emailAddresses];

    NSData *data = [CNContactVCardSerialization dataWithContacts:@[finalContact] error:nil];
    NSData *contactImageData = [finalContact thumbnailImageData] ? [finalContact thumbnailImageData] : [finalContact imageData];
    if(contactImageData)
    {
        NSString* vcString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSString* base64Image = contactImageData.base64Encoding;
        NSString* vcardImageString = [[@"PHOTO;TYPE=JPEG;ENCODING=BASE64:" stringByAppendingString:base64Image] stringByAppendingString:@"\n"];
        vcString = [vcString stringByReplacingOccurrencesOfString:@"END:VCARD" withString:[vcardImageString stringByAppendingString:@"END:VCARD"]];
        data = [vcString dataUsingEncoding:NSUTF8StringEncoding];
    }
    if(_chatViewControllerProtocolResponder && [_chatViewControllerProtocolResponder respondsToSelector:@selector(currentChatIdWithPrefix)] && [_chatViewControllerProtocolResponder respondsToSelector:@selector(addMessage:)])
    {
        PRMessageModel* messageModel = [PRMessageProcessingManager sendMediaMessage:data
                                                                           mimeType:kContactMessageMimeType
                                                                        messageType:kMessageType_Contact
                                                                    toChannelWithID:[_chatViewControllerProtocolResponder currentChatIdWithPrefix]
                                                                            success:^(PRMediaMessageModel *mediaMessageModel) {}
                                                                            failure:^(NSInteger statusCode, NSError *error) {}];
        messageModel = [messageModel MR_inThreadContext];
        [_chatViewControllerProtocolResponder addMessage:messageModel];
    }
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ContactPreviewViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactPreviewViewCellIdentifier"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    switch (indexPath.section) {
        case ContactInfoSection_Name:
        {
            NSString *contactFullName;
            if([_contact.givenName length]!=0)
            {
                contactFullName = _contact.givenName;
            }
            if([_contact.familyName length]!=0)
            {
                contactFullName = [NSString stringWithFormat:@"%@\n%@", contactFullName, _contact.familyName];
            }
            [cell setContactName:contactFullName];
            return cell;
        }
        case ContactInfoSection_Company:
        {
            [cell setCategoryLabelText:NSLocalizedString(@"company", nil)];
            [cell setMainContentText:_contact.organizationName];
            if([_contact.emailAddresses count] != 0 || [_contact.phoneNumbers count] != 0)
            {
                [cell setSeparator];
            }
            return cell;
        }
        case ContactInfoSection_PhoneNumbers:
        {
            NSString *realLabel = [CNLabeledValue localizedStringForLabel:_contact.phoneNumbers[indexPath.row].label];
            [cell setCategoryLabelText:realLabel];
            [cell setMainContentText:_contact.phoneNumbers[indexPath.row].value.stringValue];
            if(indexPath.row ==[_contact.phoneNumbers count]-1 && [_contact.emailAddresses count] != 0)
            {
                [cell setSeparator];
            }
            return cell;
        }
        case ContactInfoSection_Emails:
        {
            NSString *realLabel = [CNLabeledValue localizedStringForLabel:_contact.emailAddresses[indexPath.row].label];
            [cell setCategoryLabelText:realLabel];
            [cell setMainContentText:_contact.emailAddresses[indexPath.row].value];
            return cell;
        }
    }
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case ContactInfoSection_Name:
            if([_contact.givenName length] == 0 && [_contact.familyName length] == 0)
            {
                return 0;
            }
            else
            {
                return 1;
            }
        case ContactInfoSection_Company:
            if([_contact.organizationName length]>0)
            {
                return 1;
            }
            else
            {
                return 0;
            }
        case ContactInfoSection_PhoneNumbers:
            return [_contact.phoneNumbers count];
        case ContactInfoSection_Emails:
            return [_contact.emailAddresses count];
        default:
            return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactPreviewViewCell* cell = (ContactPreviewViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    [cell changeCheckedStatus];
    switch (indexPath.section) {
        case ContactInfoSection_Company:
            if([cell isChecked])
            {
                _sendCompanyInfo = YES;
            }
            else
            {
                _sendCompanyInfo = NO;
            }
            break;
        case ContactInfoSection_PhoneNumbers:
            if([cell isChecked])
            {
                _finalContactPhoneNumbers[indexPath.row] = @YES;
            }
            else
            {
                _finalContactPhoneNumbers[indexPath.row] = @NO;
            }
            break;
        case ContactInfoSection_Emails:
            if([cell isChecked])
            {
                _finalContactEmailAddresses[indexPath.row] = @YES;
            }
            else
            {
                _finalContactEmailAddresses[indexPath.row] = @NO;
            }
            break;
    }
}

- (void)setContact:(CNContact * _Nonnull)contact
{
    _contact = contact;

    _finalContactPhoneNumbers = [NSMutableArray new];
    for(NSInteger i = 0; i < [_contact.phoneNumbers count]; ++i)
    {
        [_finalContactPhoneNumbers addObject:@YES];
    }

    _finalContactEmailAddresses = [NSMutableArray new];
    for(NSInteger i = 0; i < [_contact.emailAddresses count]; ++i)
    {
        [_finalContactEmailAddresses addObject:@YES];
    }
}

@end
